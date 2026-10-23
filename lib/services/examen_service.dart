import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show mergeSort;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/simulacro_model.dart';
import '../models/contenido_tema.dart';
import '../models/grammar_content.dart';
import '../models/reading_content.dart';
import '../models/listening_content.dart';
import '../models/writing_content.dart';
import 'progreso_service.dart';

/// =============================================================================
/// 📝 SERVICIO: lib/services/examen_service.dart
/// =============================================================================
/// Este servicio gestiona los "Simulacros Globales". Es similar a
/// EjercicioService pero con lógica de tiempo, carga masiva y feedback
/// inmediato por pregunta.
///
/// FUNCIONES PRINCIPALES:
/// 1. Temporizador: Cuenta regresiva proporcional a la cantidad de preguntas.
/// 2. Banco multi-habilidad: combina las preguntas de Reading del JSON
///    `simulacros.json` con las preguntas ya existentes de las lecciones de
///    Grammar/Reading/Listening/Writing (mismo contenido verificado que usan
///    las lecciones normales, sin inventar material nuevo).
/// 3. Escalado por nivel: entre más avanzado el nivel del usuario, más
///    preguntas por habilidad entran al examen (y por lo tanto más tiempo).
/// 4. Aleatoriedad: Mezcla las preguntas cada vez que se inicia un examen.
///
/// RELACIÓN CON OTRAS CAPAS:
/// - UI: [SimulacroScreen] depende de este servicio para el reloj y el contenido.
/// - PROGRESO: Al terminar, envía los resultados a [ProgresoService].
/// =============================================================================

// Preguntas recientes que se evitan repetir en el siguiente simulacro.
const String _kPreguntasVistas = 'simulacro_preguntas_vistas';
const int _kMaxPreguntasVistas = 200;

class ExamenService extends ChangeNotifier {
  static final ExamenService _instance = ExamenService._internal();
  factory ExamenService() => _instance;
  ExamenService._internal();

  List<SimulacroPregunta> _preguntas = [];
  int _secondsRemaining = 3600;
  Timer? _timer;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _respondida = false;
  int _correctas = 0;
  bool _isLoading = true;

  // Estado del examen: en curso mientras hay preguntas cargadas y no se ha
  // finalizado. Vive en el singleton (no en la pantalla), así que cambiar
  // de pestaña a mitad del examen ya no lo reinicia.
  bool _enCurso = false;
  bool _tiempoAgotado = false;
  DateTime? _inicio;

  // Aciertos y total de preguntas respondidas, agrupados por habilidad
  // ('grammar', 'reading', 'listening', 'writing'), para que al terminar el
  // examen el progreso se reparta en la habilidad real de cada pregunta y no
  // siempre en las mismas dos (ver ProgresoService.registrarExamen).
  final Map<String, int> _correctasPorHabilidad = {};
  final Map<String, int> _totalPorHabilidad = {};

  // Getters
  int get secondsRemaining => _secondsRemaining;
  int get currentQuestion => _preguntas.isEmpty ? 0 : _currentIndex + 1;
  int get totalQuestions => _preguntas.length;
  int? get selectedAnswer => _selectedAnswer;
  bool get respondida => _respondida;
  List<String> get answers =>
      _preguntas.isEmpty ? [] : _preguntas[_currentIndex].options;
  SimulacroPregunta? get preguntaActual =>
      _preguntas.isEmpty ? null : _preguntas[_currentIndex];
  bool get isLoading => _isLoading;
  int get correctas => _correctas;
  bool get enCurso => _enCurso;

  /// true si el examen terminó porque se acabó el tiempo y la pantalla
  /// todavía no ha mostrado los resultados (ver [consumirTiempoAgotado]).
  bool get tiempoAgotado => _tiempoAgotado;

  String get formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_preguntas.isEmpty) return 0;
    return (_currentIndex + 1) / _preguntas.length;
  }

  /// ─── INICIALIZACIÓN DEL SIMULACRO ────────────────────────────────────────
  /// Arma el banco de preguntas combinando el JSON de Reading con las
  /// preguntas ya existentes de las lecciones de las 4 habilidades, elige
  /// cuántas de cada una entran según el nivel del usuario, y prepara el
  /// estado del examen.
  Future<void> inicializar({String nivel = 'A1'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Preguntas de Reading con pasaje, del banco original en JSON.
      final String response = await rootBundle.loadString(
        'assets/data/simulacros.json',
      );
      final data = await json.decode(response) as List;
      final List<SimulacroPregunta> readingConPasaje = data
          .map((e) => SimulacroPregunta.fromJson(e))
          .toList();

      // 2. Resto del banco: se reutilizan las preguntas de las lecciones de
      //    cada habilidad (mismo contenido ya verificado, sin inventar
      //    material nuevo). Reading se empareja con el texto de su lección y
      //    Listening con su audio, para que el usuario siempre tenga a la
      //    vista (o al oído) aquello sobre lo que se le pregunta.
      final List<SimulacroPregunta> banco = [
        ...readingConPasaje,
        ..._preguntasDeLecciones(
          readingTopics,
          'reading',
          pasajeDe: (tema) =>
              tema.textoEjemplo is Texto
                  ? (tema.textoEjemplo as Texto).ingles
                  : null,
        ),
        ..._preguntasDeLecciones(grammarTopics, 'grammar'),
        ..._preguntasDeLecciones(
          listeningTopics,
          'listening',
          audioDe: (tema) => tema.audioFile,
        ),
        ..._preguntasDeLecciones(writingTopics, 'writing'),
      ];

      // 3. Se agrupan por habilidad y se toma una cantidad pareja de cada
      //    una (más preguntas cuanto más avanzado el nivel), para que el
      //    examen sea realmente multi-habilidad y no solo Reading.
      final Map<String, List<SimulacroPregunta>> porHabilidad = {};
      for (final pregunta in banco) {
        (porHabilidad[pregunta.skill] ??= []).add(pregunta);
      }

      // Adaptativo: la habilidad más débil del usuario recibe una pregunta
      // extra, y dentro de cada habilidad van primero las preguntas que no
      // salieron en los simulacros recientes.
      final int porCadaHabilidad = _preguntasPorHabilidadSegunNivel(nivel);
      final String? masDebil = _habilidadMasDebil();
      final Set<String> vistas = await _preguntasVistas();
      final List<SimulacroPregunta> seleccionadas = [];
      for (final habilidad in _habilidades) {
        final disponibles = List<SimulacroPregunta>.from(
          porHabilidad[habilidad] ?? const [],
        )..shuffle();
        // sort es estable: conserva el orden aleatorio dentro de cada grupo.
        mergeSort(
          disponibles,
          compare: (a, b) => (vistas.contains(a.clave) ? 1 : 0).compareTo(
            vistas.contains(b.clave) ? 1 : 0,
          ),
        );
        final cantidad = porCadaHabilidad + (habilidad == masDebil ? 1 : 0);
        seleccionadas.addAll(disponibles.take(cantidad));
      }
      seleccionadas.shuffle(); // No siempre en el mismo orden de habilidad.

      // 4. Reseteo de contadores de sesión.
      _preguntas = seleccionadas;
      _currentIndex = 0;
      _selectedAnswer = null;
      _respondida = false;
      _correctas = 0;
      _correctasPorHabilidad.clear();
      _totalPorHabilidad.clear();
      _secondsRemaining = _tiempoParaExamen(_preguntas.length);
      _tiempoAgotado = false;
      _inicio = DateTime.now();
      _enCurso = _preguntas.isNotEmpty;
      if (_enCurso) startTimer();
    } catch (e) {
      debugPrint('❌ Error cargando simulacros: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const List<String> _habilidades = [
    'grammar',
    'reading',
    'listening',
    'writing',
  ];

  /// La habilidad con menor dominio según el progreso del usuario, o null si
  /// todavía no hay datos (usuario nuevo: examen parejo).
  String? _habilidadMasDebil() {
    final valores = ProgresoService().habilidadesValues;
    if (valores.take(_habilidades.length).every((v) => v == 0)) return null;
    var indice = 0;
    for (var i = 1; i < _habilidades.length && i < valores.length; i++) {
      if (valores[i] < valores[indice]) indice = i;
    }
    return _habilidades[indice];
  }

  Future<Set<String>> _preguntasVistas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_kPreguntasVistas) ?? const []).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _guardarPreguntasVistas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nuevas = _preguntas.map((p) => p.clave).toSet();
      final anteriores = (prefs.getStringList(_kPreguntasVistas) ?? const [])
          .where((c) => !nuevas.contains(c));
      final todas = [...anteriores, ...nuevas];
      await prefs.setStringList(
        _kPreguntasVistas,
        todas.length > _kMaxPreguntasVistas
            ? todas.sublist(todas.length - _kMaxPreguntasVistas)
            : todas,
      );
    } catch (e) {
      debugPrint('⚠️ No se pudieron guardar las preguntas vistas: $e');
    }
  }

  /// Extrae las [Pregunta] de cada tema de una habilidad y las convierte a
  /// [SimulacroPregunta]. [pasajeDe] adjunta un texto de contexto (Reading) y
  /// [audioDe] un audio de contexto (Listening), para que la pregunta nunca
  /// quede "colgada" sin lo que necesita para responderla.
  List<SimulacroPregunta> _preguntasDeLecciones(
    Map<String, ContenidoTema> temas,
    String skill, {
    String? Function(ContenidoTema tema)? pasajeDe,
    String? Function(ContenidoTema tema)? audioDe,
  }) {
    final resultado = <SimulacroPregunta>[];
    for (final tema in temas.values) {
      final pasaje = pasajeDe?.call(tema);
      final audio = audioDe?.call(tema);
      for (final pregunta in tema.ejercicios) {
        resultado.add(
          SimulacroPregunta.fromPregunta(
            pregunta,
            skill: skill,
            passage: pasaje,
            audioFile: audio,
          ),
        );
      }
    }
    return resultado;
  }

  /// A mayor nivel, más preguntas por habilidad (y por lo tanto examen más
  /// largo). Los niveles fuera de este mapa (o nulos) se tratan como A1.
  int _preguntasPorHabilidadSegunNivel(String nivel) {
    switch (nivel) {
      case 'A1':
      case 'A2':
        return 2;
      case 'B1':
        return 3;
      case 'B2':
      default:
        return 4;
    }
  }

  /// Tiempo del examen proporcional a la cantidad de preguntas (1.5 min por
  /// pregunta), con un piso de 10 minutos y un techo de 60 — ya no es un
  /// bloque fijo de 60 minutos sin importar cuántas preguntas haya.
  int _tiempoParaExamen(int totalPreguntas) {
    const segundosPorPregunta = 90;
    const minimoSegundos = 600;
    const maximoSegundos = 3600;
    final segundos = totalPreguntas * segundosPorPregunta;
    if (segundos < minimoSegundos) return minimoSegundos;
    if (segundos > maximoSegundos) return maximoSegundos;
    return segundos;
  }

  /// ─── CONTROL DEL TIEMPO ──────────────────────────────────────────────────
  /// Maneja el contador regresivo de forma asíncrona.
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners(); // Actualiza el reloj en la pantalla por cada segundo.
      }
      if (_secondsRemaining == 0) {
        // Se acabó el tiempo: el examen se cierra con lo respondido hasta
        // ahora (las preguntas sin responder cuentan como no acertadas).
        _tiempoAgotado = true;
        finalizar();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  /// ─── INTERACCIÓN DEL USUARIO ─────────────────────────────────────────────
  /// Registra la respuesta marcada por el estudiante y la valida al
  /// instante (igual que en las lecciones normales): a partir de aquí la
  /// UI puede mostrar el acierto/error y la explicación de la pregunta.
  void selectAnswer(int index) {
    if (!_enCurso || _respondida || _preguntas.isEmpty) return;
    _selectedAnswer = index;
    _respondida = true;

    final skill = _preguntas[_currentIndex].skill;
    _totalPorHabilidad[skill] = (_totalPorHabilidad[skill] ?? 0) + 1;
    if (index == _preguntas[_currentIndex].correctIndex) {
      _correctas++;
      _correctasPorHabilidad[skill] = (_correctasPorHabilidad[skill] ?? 0) + 1;
    }
    notifyListeners();
  }

  /// Avanza a la siguiente pregunta (ya validada previamente en
  /// [selectAnswer]). Retorna true si hay más preguntas, false si terminó.
  bool nextQuestion() {
    if (_currentIndex < _preguntas.length - 1) {
      _currentIndex++;
      _selectedAnswer = null;
      _respondida = false;
      notifyListeners();
      return true;
    } else {
      finalizar();
      return false;
    }
  }

  /// Cierra el examen y lo registra en el progreso global, desglosado por la
  /// habilidad real de cada pregunta. Idempotente: solo registra una vez.
  void finalizar() {
    stopTimer();
    if (!_enCurso) return;
    _enCurso = false;

    // Las preguntas que quedaron sin responder (por tiempo) también cuentan
    // en el total de su habilidad, como no acertadas.
    for (var i = _currentIndex + (_respondida ? 1 : 0); i < _preguntas.length; i++) {
      final skill = _preguntas[i].skill;
      _totalPorHabilidad[skill] = (_totalPorHabilidad[skill] ?? 0) + 1;
    }

    ProgresoService().registrarExamen(
      _correctasPorHabilidad,
      _totalPorHabilidad,
      duracion: _inicio == null
          ? Duration.zero
          : DateTime.now().difference(_inicio!),
    );
    _guardarPreguntasVistas();
    notifyListeners();
  }

  /// La pantalla llama a esto al mostrar los resultados de un examen que
  /// terminó por tiempo, para no volver a mostrarlos.
  void consumirTiempoAgotado() => _tiempoAgotado = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
