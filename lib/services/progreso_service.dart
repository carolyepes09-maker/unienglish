import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'auth_service.dart';

/// =============================================================================
/// 📈 SERVICIO: lib/services/progreso_service.dart
/// =============================================================================
/// Este servicio gestiona las estadísticas del usuario. Se guardan localmente
/// (SharedPreferences, como caché rápida/offline) y también en el documento
/// Firestore del usuario, para que el progreso esté atado a la cuenta y no
/// solo al navegador/dispositivo (por ejemplo, al entrar en incógnito o desde
/// otro dispositivo).
///
/// Todo lo que muestra sale de actividad real con fecha:
/// - Racha: días calendario seguidos con al menos una sesión de estudio.
/// - Tiempo: minutos medidos de cada sesión (lección, repaso, simulacro).
/// - Actividad semanal: minutos por día de la semana EN CURSO (lunes a
///   domingo); al empezar una semana nueva se reinicia.
/// - Habilidades: promedio móvil del % de aciertos por habilidad, así que
///   también baja si el rendimiento baja.
/// - Nivel: se gana; al llenar la barra de progreso se sube al siguiente.
/// =============================================================================

class ProgresoService extends ChangeNotifier {
  static final ProgresoService _instance = ProgresoService._internal();
  factory ProgresoService() => _instance;
  ProgresoService._internal();

  /// Reloj inyectable para pruebas (racha y semana dependen de la fecha).
  @visibleForTesting
  static DateTime Function() reloj = DateTime.now;

  static const List<String> niveles = ['A1', 'A2', 'B1', 'B2'];

  // Peso de la última sesión en el promedio móvil de cada habilidad.
  static const double _pesoUltimaSesion = 0.3;

  // Cuánto llena la barra de nivel cada actividad, ponderado por el % de
  // aciertos: ~25 lecciones perfectas o ~8 simulacros perfectos por nivel.
  static const double _avancePorLeccion = 0.04;
  static const double _avancePorExamen = 0.12;

  late SharedPreferences _prefs;

  // Datos internos — arrancan en cero: son los valores por defecto para una
  // cuenta nueva sin nada aún guardado en SharedPreferences ni Firestore.
  int _rachaDias = 0;
  String? _ultimoDiaActividad; // 'yyyy-mm-dd'
  int _tiempoTotalMinutos = 0;
  int _tiempoMesMinutos = 0;
  String? _mesTiempo; // 'yyyy-mm'
  int _leccionesCompletadas = 0;
  int _examenesRealizados = 0;
  List<double> _actividadSemanal = List.filled(7, 0); // minutos, lunes..domingo
  String? _inicioSemana; // 'yyyy-mm-dd' del lunes de esa semana
  List<double> _habilidadesValues = [0, 0, 0, 0, 0];
  double _progresoHaciaSiguienteNivel = 0.0;

  // ─── Fechas ──────────────────────────────────────────────────────────────
  static String _dia(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  static String _mes(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  static DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _lunesDe(DateTime d) =>
      _dia(_soloFecha(d).subtract(Duration(days: d.weekday - 1)));

  // ─── Getters ─────────────────────────────────────────────────────────────
  /// La racha solo sigue viva si hubo actividad hoy o ayer; si no, ya se
  /// rompió aunque todavía no se haya registrado una sesión nueva.
  int get rachaDias {
    if (_ultimoDiaActividad == null) return 0;
    final ultimo = DateTime.tryParse(_ultimoDiaActividad!);
    if (ultimo == null) return 0;
    final dias = _soloFecha(reloj()).difference(ultimo).inDays;
    return dias <= 1 ? _rachaDias : 0;
  }

  /// Horas estudiadas en el mes en curso (la tarjeta dice "horas este mes").
  int get tiempoTotalHoras =>
      _mesTiempo == _mes(reloj()) ? _tiempoMesMinutos ~/ 60 : 0;
  int get tiempoMesMinutos =>
      _mesTiempo == _mes(reloj()) ? _tiempoMesMinutos : 0;
  int get tiempoTotalMinutos => _tiempoTotalMinutos;
  int get leccionesCompletadas => _leccionesCompletadas;
  int get examenesRealizados => _examenesRealizados;

  /// Minutos por día de la semana en curso. Si la semana guardada ya pasó,
  /// se muestra vacía.
  List<double> get actividadSemanal => _inicioSemana == _lunesDe(reloj())
      ? List.unmodifiable(_actividadSemanal)
      : List.filled(7, 0);
  List<String> get etiquetasSemana => ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  /// Escala de la gráfica: al menos 60 min, o el día más alto de la semana.
  double get maxActividad => math.max(60, actividadSemanal.reduce(math.max));

  List<double> get habilidadesValues => _habilidadesValues;
  List<String> get habilidadesLabels => [
    'Grammar',
    'Reading',
    'Listening',
    'Writing',
    'Speaking',
  ];
  double get progresoHaciaSiguienteNivel => _progresoHaciaSiguienteNivel;

  String get nivelActual {
    final nivel = AuthService().usuarioActual?['nivel_actual'];
    return niveles.contains(nivel) ? nivel as String : 'A1';
  }

  String get siguienteNivel {
    final i = niveles.indexOf(nivelActual);
    return niveles[math.min(i + 1, niveles.length - 1)];
  }

  Future<void> initialize() async {
    await precargarLocal();
    await sincronizarConCuenta();
  }

  void _reiniciarEnMemoria() {
    _rachaDias = 0;
    _ultimoDiaActividad = null;
    _tiempoTotalMinutos = 0;
    _tiempoMesMinutos = 0;
    _mesTiempo = null;
    _leccionesCompletadas = 0;
    _examenesRealizados = 0;
    _actividadSemanal = List.filled(7, 0);
    _inicioSemana = null;
    _habilidadesValues = [0, 0, 0, 0, 0];
    _progresoHaciaSiguienteNivel = 0.0;
  }

  static const List<String> _clavesLocales = [
    'racha_dias',
    'ultimo_dia_actividad',
    'tiempo_total_horas',
    'tiempo_total_minutos',
    'tiempo_mes_minutos',
    'tiempo_mes',
    'lecciones_completadas',
    'examenes_realizados',
    'actividad_semanal',
    'actividad_semana_inicio',
    'habilidades_values',
    'progreso_siguiente_nivel',
    'siguiente_nivel',
    'progreso_actualizado_en',
    'progreso_uid',
  ];

  /// Borra la caché local (SharedPreferences) y reinicia el estado en
  /// memoria a los valores por defecto. Se llama al cerrar sesión: sin
  /// esto, la próxima persona que use este mismo navegador/dispositivo
  /// vería por un instante el progreso de la cuenta anterior durante la
  /// precarga local (que corre antes de saber quién inició sesión).
  Future<void> limpiarCacheLocal() async {
    try {
      for (final clave in _clavesLocales) {
        await _prefs.remove(clave);
      }
    } catch (e) {
      AppLogger.log('❌ Error limpiando caché local de progreso: $e');
    }
    _reiniciarEnMemoria();
    notifyListeners();
  }

  /// Fase 1: solo SharedPreferences -- no depende de Firebase ni de que haya
  /// sesión, así que puede correr en paralelo con Firebase.initializeApp()
  /// en vez de esperarlo primero.
  Future<void> precargarLocal() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _reiniciarEnMemoria();

      _rachaDias = _prefs.getInt('racha_dias') ?? 0;
      _ultimoDiaActividad = _prefs.getString('ultimo_dia_actividad');
      _tiempoTotalMinutos = _prefs.getInt('tiempo_total_minutos') ?? 0;
      _tiempoMesMinutos = _prefs.getInt('tiempo_mes_minutos') ?? 0;
      _mesTiempo = _prefs.getString('tiempo_mes');
      _leccionesCompletadas = _prefs.getInt('lecciones_completadas') ?? 0;
      _examenesRealizados = _prefs.getInt('examenes_realizados') ?? 0;
      _inicioSemana = _prefs.getString('actividad_semana_inicio');

      final actividadStr = _prefs.getString('actividad_semanal');
      if (actividadStr != null) {
        _actividadSemanal = _lista(jsonDecode(actividadStr), 7);
      }
      final habilidadesStr = _prefs.getString('habilidades_values');
      if (habilidadesStr != null) {
        _habilidadesValues = _lista(jsonDecode(habilidadesStr), 5);
      }

      _progresoHaciaSiguienteNivel =
          _prefs.getDouble('progreso_siguiente_nivel') ?? 0.0;

      notifyListeners();
    } catch (e) {
      AppLogger.log('❌ ProgresoService precargarLocal error: $e');
      AppLogger.log('⚠️ Continuando con valores por defecto');
    }
  }

  // Convierte una lista JSON/Firestore a List<double> de largo fijo.
  static List<double> _lista(dynamic valor, int largo) {
    final resultado = List<double>.filled(largo, 0);
    if (valor is List) {
      for (var i = 0; i < largo && i < valor.length; i++) {
        resultado[i] = (valor[i] as num?)?.toDouble() ?? 0;
      }
    }
    return resultado;
  }

  /// Fase 2: decide si la caché local es de esta cuenta y sincroniza con
  /// Firestore. Necesita que AuthService ya haya restaurado/iniciado sesión
  /// (usuarioActualId/usuarioActual poblados), así que se llama después de
  /// esperar eso.
  Future<void> sincronizarConCuenta() async {
    try {
      // Solo cuenta como "de este usuario" si el uid guardado coincide con
      // el que tiene sesión ahora (si no, es de otra cuenta que usó este
      // mismo navegador/dispositivo antes).
      final usuarioIdActual = AuthService().usuarioActualId;
      final uidLocal = _prefs.getString('progreso_uid');
      final localEsDeEsteUsuario =
          uidLocal != null && uidLocal == usuarioIdActual;

      if (!localEsDeEsteUsuario && uidLocal != null) {
        _reiniciarEnMemoria();
      }

      // "Última modificación real" de estos datos en este dispositivo (no
      // "última vez que se sincronizó" -- eso importa para la comparación
      // de abajo). Si el progreso local es de otra cuenta, no cuenta.
      final actualizadoLocal = localEsDeEsteUsuario
          ? DateTime.tryParse(_prefs.getString('progreso_actualizado_en') ?? '')
          : null;

      await _sincronizarPorTimestamp(actualizadoLocal);

      notifyListeners();
    } catch (e) {
      AppLogger.log('❌ Error cargando datos de progreso: $e');
    }
  }

  // Compara cuándo se modificó realmente el progreso por última vez en este
  // dispositivo ([actualizadoLocal]) contra cuándo se modificó por última
  // vez en la cuenta (Firestore), y aplica el más reciente sobre el otro
  // lado -- así un dispositivo con datos viejos en caché nunca sobrescribe
  // con esos datos viejos algo más nuevo que ya se guardó desde otro
  // dispositivo. Si ninguno de los dos tiene timestamp todavía (cuenta
  // recién creada), no hace nada: se queda con los valores en cero.
  Future<void> _sincronizarPorTimestamp(DateTime? actualizadoLocal) async {
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId == null) return;

    try {
      // AuthService ya tiene el documento completo del usuario en memoria
      // (lo cargó al iniciar sesión/restaurar sesión) -- se reutiliza esa
      // copia en vez de volver a pedirle lo mismo a Firestore.
      final usuario = AuthService().usuarioActual;
      final actualizadoRemotoStr =
          usuario?['progreso_actualizado_en'] as String?;
      final actualizadoRemoto = actualizadoRemotoStr != null
          ? DateTime.tryParse(actualizadoRemotoStr)
          : null;

      final ganaLocal =
          actualizadoLocal != null &&
          (actualizadoRemoto == null ||
              actualizadoLocal.isAfter(actualizadoRemoto));

      if (ganaLocal) {
        await _guardarEnFirestore(actualizadoLocal);
      } else if (actualizadoRemoto != null) {
        _aplicarDatosRemotos(usuario!);
        await _guardarLocal(actualizadoRemoto);
      }
    } catch (e) {
      AppLogger.log('❌ Error sincronizando progreso por timestamp: $e');
    }
  }

  // Copia a memoria los campos que sí existan en el documento remoto -- si
  // un campo nunca se guardó, se conserva el valor local/por defecto.
  void _aplicarDatosRemotos(Map<String, dynamic> usuario) {
    int? entero(String clave) => (usuario[clave] as num?)?.toInt();

    _rachaDias = entero('racha_dias') ?? _rachaDias;
    _ultimoDiaActividad =
        usuario['ultimo_dia_actividad'] as String? ?? _ultimoDiaActividad;
    _tiempoTotalMinutos = entero('tiempo_total_minutos') ?? _tiempoTotalMinutos;
    _tiempoMesMinutos = entero('tiempo_mes_minutos') ?? _tiempoMesMinutos;
    _mesTiempo = usuario['tiempo_mes'] as String? ?? _mesTiempo;
    _leccionesCompletadas =
        entero('lecciones_completadas') ?? _leccionesCompletadas;
    _examenesRealizados = entero('examenes_realizados') ?? _examenesRealizados;
    _inicioSemana =
        usuario['actividad_semana_inicio'] as String? ?? _inicioSemana;
    if (usuario['actividad_semanal'] is List) {
      _actividadSemanal = _lista(usuario['actividad_semanal'], 7);
    }
    if (usuario['habilidades_values'] is List) {
      _habilidadesValues = _lista(usuario['habilidades_values'], 5);
    }
    _progresoHaciaSiguienteNivel =
        (usuario['progreso_siguiente_nivel'] as num?)?.toDouble() ??
        _progresoHaciaSiguienteNivel;
  }

  // [marcaDeTiempo] es cuándo se modificó realmente este progreso -- puede
  // ser "ahora" (acaba de pasar algo, ver _saveData) o el timestamp que ya
  // traía el lado que ganó la comparación en _sincronizarPorTimestamp (para
  // no inventarle una fecha más nueva de la que en verdad tiene).
  Future<void> _guardarLocal(DateTime marcaDeTiempo) async {
    try {
      await _prefs.setInt('racha_dias', _rachaDias);
      if (_ultimoDiaActividad != null) {
        await _prefs.setString('ultimo_dia_actividad', _ultimoDiaActividad!);
      }
      await _prefs.setInt('tiempo_total_minutos', _tiempoTotalMinutos);
      await _prefs.setInt('tiempo_mes_minutos', _tiempoMesMinutos);
      if (_mesTiempo != null) {
        await _prefs.setString('tiempo_mes', _mesTiempo!);
      }
      await _prefs.setInt('lecciones_completadas', _leccionesCompletadas);
      await _prefs.setInt('examenes_realizados', _examenesRealizados);
      await _prefs.setString(
        'actividad_semanal',
        jsonEncode(_actividadSemanal),
      );
      if (_inicioSemana != null) {
        await _prefs.setString('actividad_semana_inicio', _inicioSemana!);
      }
      await _prefs.setString(
        'habilidades_values',
        jsonEncode(_habilidadesValues),
      );
      await _prefs.setDouble(
        'progreso_siguiente_nivel',
        _progresoHaciaSiguienteNivel,
      );
      await _prefs.setString(
        'progreso_actualizado_en',
        marcaDeTiempo.toIso8601String(),
      );

      final usuarioId = AuthService().usuarioActualId;
      if (usuarioId != null) {
        await _prefs.setString('progreso_uid', usuarioId);
      }
    } catch (e) {
      AppLogger.log('❌ Error guardando datos locales de progreso: $e');
    }
  }

  Future<void> _guardarEnFirestore(DateTime marcaDeTiempo) async {
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId == null) return;

    try {
      await AuthService().actualizarUsuario(usuarioId, {
        'racha_dias': _rachaDias,
        'ultimo_dia_actividad': ?_ultimoDiaActividad,
        'tiempo_total_horas': _tiempoTotalMinutos ~/ 60,
        'tiempo_total_minutos': _tiempoTotalMinutos,
        'tiempo_mes_minutos': _tiempoMesMinutos,
        'tiempo_mes': ?_mesTiempo,
        'lecciones_completadas': _leccionesCompletadas,
        'examenes_realizados': _examenesRealizados,
        'actividad_semanal': _actividadSemanal,
        'actividad_semana_inicio': ?_inicioSemana,
        'habilidades_values': _habilidadesValues,
        'progreso_siguiente_nivel': _progresoHaciaSiguienteNivel,
        'siguiente_nivel': siguienteNivel,
        'progreso_actualizado_en': marcaDeTiempo.toIso8601String(),
      });
    } catch (e) {
      AppLogger.log('❌ Error guardando progreso en Firestore: $e');
    }
  }

  // Se llama cada vez que una acción real del usuario cambia el progreso:
  // ese es el único momento en que corresponde estampar "ahora" como última
  // modificación.
  Future<void> _saveData() async {
    final ahora = reloj();
    notifyListeners();
    await _guardarLocal(ahora);
    await _guardarEnFirestore(ahora);
  }

  // ─── Registro de actividad ─────────────────────────────────────────────

  /// Marca hoy como día de estudio (racha) y suma el tiempo de la sesión al
  /// mes y al día de la semana correspondientes.
  void _registrarSesion(Duration duracion) {
    final ahora = reloj();
    final hoy = _dia(ahora);

    // Racha por días calendario: solo cuenta una vez por día.
    if (_ultimoDiaActividad != hoy) {
      final ultimo = _ultimoDiaActividad == null
          ? null
          : DateTime.tryParse(_ultimoDiaActividad!);
      final diasDesdeUltimo = ultimo == null
          ? null
          : _soloFecha(ahora).difference(ultimo).inDays;
      _rachaDias = diasDesdeUltimo == 1 ? _rachaDias + 1 : 1;
      _ultimoDiaActividad = hoy;
    }

    // Una sesión cuenta al menos 1 minuto y como mucho 3 horas (evita que
    // una pestaña olvidada abierta infle las estadísticas).
    final minutos = duracion.inMinutes.clamp(1, 180);

    final mes = _mes(ahora);
    if (_mesTiempo != mes) {
      _mesTiempo = mes;
      _tiempoMesMinutos = 0;
    }
    _tiempoMesMinutos += minutos;
    _tiempoTotalMinutos += minutos;

    final lunes = _lunesDe(ahora);
    if (_inicioSemana != lunes) {
      _inicioSemana = lunes;
      _actividadSemanal = List.filled(7, 0);
    }
    _actividadSemanal[ahora.weekday - 1] += minutos;
  }

  /// Suma avance hacia el siguiente nivel; al completar la barra sube de
  /// nivel en la cuenta (A1 → A2 → B1 → B2). En B2, el tope, la barra se
  /// queda llena.
  void _sumarAvanceNivel(double avance) {
    _progresoHaciaSiguienteNivel += avance;
    if (_progresoHaciaSiguienteNivel < 1.0) return;

    final i = niveles.indexOf(nivelActual);
    if (i >= niveles.length - 1) {
      _progresoHaciaSiguienteNivel = 1.0;
      return;
    }

    final nuevoNivel = niveles[i + 1];
    _progresoHaciaSiguienteNivel = 0.0;
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId != null) {
      AuthService().actualizarNivel(usuarioId, nuevoNivel);
    }
  }

  /// Sesión de repaso de vocabulario terminada.
  void registrarRevision(int aciertos, {Duration duracion = Duration.zero}) {
    _registrarSesion(duracion);
    _saveData();
  }

  /// Lección terminada con [porcentaje] de aciertos (0.0 a 1.0). Si se
  /// indica la [habilidad] ('Grammar', 'Reading'...), también actualiza su
  /// promedio, igual que un examen.
  void completarLeccion({
    double porcentaje = 1.0,
    Duration duracion = Duration.zero,
    String? habilidad,
  }) {
    _leccionesCompletadas++;
    final indice = _indicePorHabilidad[habilidad?.toLowerCase()];
    if (indice != null) _actualizarHabilidad(indice, porcentaje * 100);
    _registrarSesion(duracion);
    _sumarAvanceNivel(_avancePorLeccion * porcentaje.clamp(0.0, 1.0));
    _saveData();
  }

  // Posición de cada habilidad del examen dentro de _habilidadesValues /
  // habilidadesLabels ('Grammar', 'Reading', 'Listening', 'Writing',
  // 'Speaking'). El examen nunca evalúa Speaking, así que esa posición (4)
  // no tiene entrada aquí y queda intacta.
  static const Map<String, int> _indicePorHabilidad = {
    'grammar': 0,
    'reading': 1,
    'listening': 2,
    'writing': 3,
  };

  // Promedio móvil: la sesión nueva pesa un 30% y el historial un 70%.
  void _actualizarHabilidad(int indice, double porcentaje) {
    final anterior = _habilidadesValues[indice];
    _habilidadesValues[indice] =
        (anterior + (porcentaje - anterior) * _pesoUltimaSesion).clamp(
          0.0,
          100.0,
        );
  }

  /// Actualiza el progreso por habilidad según los aciertos/total reales de
  /// cada habilidad en el examen. Cada habilidad es un promedio móvil del %
  /// de aciertos: sube si se responde bien y baja si se responde mal.
  void registrarExamen(
    Map<String, int> correctasPorHabilidad,
    Map<String, int> totalPorHabilidad, {
    Duration duracion = Duration.zero,
  }) {
    _examenesRealizados++;

    var correctasExamen = 0;
    var totalExamen = 0;
    for (final habilidad in totalPorHabilidad.keys) {
      final total = totalPorHabilidad[habilidad] ?? 0;
      final indice = _indicePorHabilidad[habilidad];
      if (total == 0 || indice == null) continue;

      final correctas = correctasPorHabilidad[habilidad] ?? 0;
      correctasExamen += correctas;
      totalExamen += total;

      _actualizarHabilidad(indice, (correctas / total) * 100);
    }

    _registrarSesion(duracion);
    if (totalExamen > 0) {
      _sumarAvanceNivel(_avancePorExamen * (correctasExamen / totalExamen));
    }
    _saveData();
  }
}
