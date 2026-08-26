import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

      final int porCadaHabilidad = _preguntasPorHabilidadSegunNivel(nivel);
      final List<SimulacroPregunta> seleccionadas = [];
      for (final habilidad in const [
        'grammar',
        'reading',
        'listening',
        'writing',
      ]) {
        final disponibles = List<SimulacroPregunta>.from(
          porHabilidad[habilidad] ?? const [],
        )..shuffle();
        seleccionadas.addAll(disponibles.take(porCadaHabilidad));
      }
      seleccionadas.shuffle(); // No siempre en el mismo orden de habilidad.

      // 4. Reseteo de contadores de sesión.
      _preguntas = seleccionadas;
      _currentIndex = 0;
      _selectedAnswer = null;
      _respondida = false;
      _correctas = 0;
      _secondsRemaining = _tiempoParaExamen(_preguntas.length);
      startTimer();
    } catch (e) {
      debugPrint('❌ Error cargando simulacros: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
      } else {
        stopTimer(); // Se acaba el tiempo.
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
    if (_respondida || _preguntas.isEmpty) return;
    _selectedAnswer = index;
    _respondida = true;
    if (index == _preguntas[_currentIndex].correctIndex) {
      _correctas++;
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
      stopTimer();
      // Registrar en el progreso global
      ProgresoService().registrarExamen(_correctas, _preguntas.length);
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
