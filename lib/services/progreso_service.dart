import 'dart:convert';
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
/// =============================================================================

class ProgresoService extends ChangeNotifier {
  static final ProgresoService _instance = ProgresoService._internal();
  factory ProgresoService() => _instance;
  ProgresoService._internal();

  late SharedPreferences _prefs;

  // Datos internos — arrancan en cero: son los valores por defecto para una
  // cuenta nueva sin nada aún guardado en SharedPreferences ni Firestore.
  // Una cuenta ya existente nunca llega a usar estos defaults, porque
  // _cargarDatos() encuentra sus propios valores guardados antes de caer aquí.
  int _rachaDias = 0;
  int _tiempoTotalHoras = 0;
  int _leccionesCompletadas = 0;
  int _examenesRealizados = 0;
  List<double> _actividadSemanal = [0, 0, 0, 0, 0, 0, 0];
  List<double> _habilidadesValues = [0, 0, 0, 0, 0];
  double _progresoHaciaSiguienteNivel = 0.0;
  String _siguienteNivel = 'A2';

  // Getters
  int get rachaDias => _rachaDias;
  int get tiempoTotalHoras => _tiempoTotalHoras;
  int get leccionesCompletadas => _leccionesCompletadas;
  int get examenesRealizados => _examenesRealizados;
  List<double> get actividadSemanal => _actividadSemanal;
  List<String> get etiquetasSemana => ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  double get maxActividad => 100;
  List<double> get habilidadesValues => _habilidadesValues;
  List<String> get habilidadesLabels => [
    'Grammar',
    'Reading',
    'Listening',
    'Writing',
    'Speaking',
  ];
  double get progresoHaciaSiguienteNivel => _progresoHaciaSiguienteNivel;
  String get siguienteNivel => _siguienteNivel;

  Future<void> initialize() async {
    try {
      AppLogger.log('⏳ ProgresoService: Obteniendo SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      AppLogger.log('✅ ProgresoService: SharedPreferences obtenido');
      AppLogger.log('⏳ ProgresoService: Cargando datos...');
      await _cargarDatos();
      AppLogger.log('✅ ProgresoService: Datos cargados');
    } catch (e) {
      AppLogger.log('❌ ProgresoService initialize error: $e');
      AppLogger.log('⚠️ Continuando con valores por defecto');
    }
  }

  Future<void> _cargarDatos() async {
    try {
      // Carga primero lo que haya localmente (caché rápida/offline), pero
      // solo cuenta como "de este usuario" si el uid guardado coincide con
      // el que tiene sesión ahora (si no, es de otra cuenta que usó este
      // mismo navegador/dispositivo antes).
      final usuarioIdActual = AuthService().usuarioActualId;
      final uidLocal = _prefs.getString('progreso_uid');
      final localEsDeEsteUsuario =
          uidLocal != null && uidLocal == usuarioIdActual;

      _rachaDias = _prefs.getInt('racha_dias') ?? _rachaDias;
      _tiempoTotalHoras =
          _prefs.getInt('tiempo_total_horas') ?? _tiempoTotalHoras;
      _leccionesCompletadas =
          _prefs.getInt('lecciones_completadas') ?? _leccionesCompletadas;
      _examenesRealizados =
          _prefs.getInt('examenes_realizados') ?? _examenesRealizados;

      final actividadStr = _prefs.getString('actividad_semanal');
      if (actividadStr != null) {
        _actividadSemanal = List<double>.from(jsonDecode(actividadStr));
      }

      final habilidadesStr = _prefs.getString('habilidades_values');
      if (habilidadesStr != null) {
        _habilidadesValues = List<double>.from(jsonDecode(habilidadesStr));
      }

      _progresoHaciaSiguienteNivel =
          _prefs.getDouble('progreso_siguiente_nivel') ??
          _progresoHaciaSiguienteNivel;
      _siguienteNivel = _prefs.getString('siguiente_nivel') ?? _siguienteNivel;

      // "Última modificación real" de estos datos en este dispositivo (no
      // "última vez que se sincronizó" -- eso importa para la comparación
      // de abajo). Si el progreso local es de otra cuenta, no cuenta.
      final actualizadoLocal = localEsDeEsteUsuario
          ? DateTime.tryParse(_prefs.getString('progreso_actualizado_en') ?? '')
          : null;

      await _sincronizarPorTimestamp(actualizadoLocal);

      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando datos de progreso: $e');
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
      // copia en vez de volver a pedirle lo mismo a Firestore. Antes,
      // Progreso/Vocabulario/Actividad hacían cada uno su propia lectura
      // del MISMO documento en cada arranque: 4 viajes de red para leer
      // 4 partes de un solo documento.
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
        // Lo que hay en este dispositivo es más nuevo (o la cuenta todavía
        // no tiene nada): lo subimos, conservando su propio timestamp.
        await _guardarEnFirestore(actualizadoLocal);
      } else if (actualizadoRemoto != null) {
        // La cuenta tiene algo igual o más nuevo que este dispositivo: lo
        // bajamos, conservando el timestamp con el que llegó.
        _aplicarDatosRemotos(usuario!);
        await _guardarLocal(actualizadoRemoto);
      }
    } catch (e) {
      debugPrint('Error sincronizando progreso por timestamp: $e');
    }
  }

  // Copia a memoria los campos que sí existan en el documento remoto --  si
  // un campo nunca se guardó, se conserva el valor local/por defecto.
  void _aplicarDatosRemotos(Map<String, dynamic> usuario) {
    if (usuario['racha_dias'] != null) {
      _rachaDias = (usuario['racha_dias'] as num).toInt();
    }
    if (usuario['tiempo_total_horas'] != null) {
      _tiempoTotalHoras = (usuario['tiempo_total_horas'] as num).toInt();
    }
    if (usuario['lecciones_completadas'] != null) {
      _leccionesCompletadas =
          (usuario['lecciones_completadas'] as num).toInt();
    }
    if (usuario['examenes_realizados'] != null) {
      _examenesRealizados = (usuario['examenes_realizados'] as num).toInt();
    }
    final actividad = usuario['actividad_semanal'];
    if (actividad is List) {
      _actividadSemanal = actividad.map((e) => (e as num).toDouble()).toList();
    }
    final habilidades = usuario['habilidades_values'];
    if (habilidades is List) {
      _habilidadesValues = habilidades
          .map((e) => (e as num).toDouble())
          .toList();
    }
    if (usuario['progreso_siguiente_nivel'] != null) {
      _progresoHaciaSiguienteNivel =
          (usuario['progreso_siguiente_nivel'] as num).toDouble();
    }
    if (usuario['siguiente_nivel'] != null) {
      _siguienteNivel = usuario['siguiente_nivel'] as String;
    }
  }

  // [marcaDeTiempo] es cuándo se modificó realmente este progreso -- puede
  // ser "ahora" (acaba de pasar algo, ver _saveData) o el timestamp que ya
  // traía el lado que ganó la comparación en _sincronizarPorTimestamp (para
  // no inventarle una fecha más nueva de la que en verdad tiene).
  Future<void> _guardarLocal(DateTime marcaDeTiempo) async {
    try {
      await _prefs.setInt('racha_dias', _rachaDias);
      await _prefs.setInt('tiempo_total_horas', _tiempoTotalHoras);
      await _prefs.setInt('lecciones_completadas', _leccionesCompletadas);
      await _prefs.setInt('examenes_realizados', _examenesRealizados);
      await _prefs.setString(
        'actividad_semanal',
        jsonEncode(_actividadSemanal),
      );
      await _prefs.setString(
        'habilidades_values',
        jsonEncode(_habilidadesValues),
      );
      await _prefs.setDouble(
        'progreso_siguiente_nivel',
        _progresoHaciaSiguienteNivel,
      );
      await _prefs.setString('siguiente_nivel', _siguienteNivel);
      await _prefs.setString(
        'progreso_actualizado_en',
        marcaDeTiempo.toIso8601String(),
      );

      final usuarioId = AuthService().usuarioActualId;
      if (usuarioId != null) {
        await _prefs.setString('progreso_uid', usuarioId);
      }
    } catch (e) {
      debugPrint('Error guardando datos locales de progreso: $e');
    }
  }

  Future<void> _guardarEnFirestore(DateTime marcaDeTiempo) async {
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId == null) return;

    try {
      await AuthService().actualizarUsuario(usuarioId, {
        'racha_dias': _rachaDias,
        'tiempo_total_horas': _tiempoTotalHoras,
        'lecciones_completadas': _leccionesCompletadas,
        'examenes_realizados': _examenesRealizados,
        'actividad_semanal': _actividadSemanal,
        'habilidades_values': _habilidadesValues,
        'progreso_siguiente_nivel': _progresoHaciaSiguienteNivel,
        'siguiente_nivel': _siguienteNivel,
        'progreso_actualizado_en': marcaDeTiempo.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error guardando progreso en Firestore: $e');
    }
  }

  // Se llama cada vez que una acción real del usuario cambia el progreso
  // (registrarRevision, completarLeccion, registrarExamen): ese es el único
  // momento en que corresponde estampar "ahora" como última modificación.
  Future<void> _saveData() async {
    final ahora = DateTime.now();
    await _guardarLocal(ahora);
    await _guardarEnFirestore(ahora);
    notifyListeners();
  }

  // Métodos para actualizar datos
  void registrarRevision(int aciertos) {
    _rachaDias++;
    _tiempoTotalHoras += 1;
    _actividadSemanal[6] += 10.0;
    _saveData();
  }

  void completarLeccion() {
    _leccionesCompletadas++;
    _progresoHaciaSiguienteNivel += 0.02;

    if (_progresoHaciaSiguienteNivel >= 1.0) {
      _progresoHaciaSiguienteNivel = 0.05;
      _siguienteNivel = 'B2';
    }
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

  /// Actualiza el progreso por habilidad según los aciertos/total reales de
  /// cada habilidad en el examen (no siempre las dos mismas posiciones).
  void registrarExamen(
    Map<String, int> correctasPorHabilidad,
    Map<String, int> totalPorHabilidad,
  ) {
    _examenesRealizados++;

    for (final habilidad in totalPorHabilidad.keys) {
      final total = totalPorHabilidad[habilidad] ?? 0;
      final indice = _indicePorHabilidad[habilidad];
      if (total == 0 || indice == null) continue;

      final correctas = correctasPorHabilidad[habilidad] ?? 0;
      final porcentaje = correctas / total;
      _habilidadesValues[indice] += porcentaje * 5;
      if (_habilidadesValues[indice] > 100) _habilidadesValues[indice] = 100;
    }

    _saveData();
  }
}
