import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      print('⏳ ProgresoService: Obteniendo SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      print('✅ ProgresoService: SharedPreferences obtenido');
      print('⏳ ProgresoService: Cargando datos...');
      await _cargarDatos();
      print('✅ ProgresoService: Datos cargados');
    } catch (e) {
      print('❌ ProgresoService initialize error: $e');
      print('⚠️ Continuando con valores por defecto');
    }
  }

  Future<void> _cargarDatos() async {
    try {
      // Si estas claves ya existen Y pertenecen al usuario que tiene sesión
      // ahora, este navegador/dispositivo tiene progreso real acumulado
      // localmente. Si no existen (incógnito, navegador nuevo, otro
      // dispositivo) o pertenecen a OTRA cuenta (alguien cerró sesión y
      // entró con otra en el mismo navegador), no hay nada de este usuario
      // que proteger y conviene traer el progreso guardado en su cuenta.
      final usuarioIdActual = AuthService().usuarioActualId;
      final uidLocal = _prefs.getString('progreso_uid');
      final huboDatosLocales =
          _prefs.containsKey('lecciones_completadas') &&
          (uidLocal == null || uidLocal == usuarioIdActual);

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

      if (huboDatosLocales) {
        // Este dispositivo ya tenía progreso real: lo subimos a Firestore
        // en vez de arriesgarnos a pisarlo con un valor remoto vacío.
        await _guardarEnFirestore();
      } else {
        await _sincronizarDesdeFirestore();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando datos de progreso: $e');
    }
  }

  // Trae el progreso guardado en la cuenta (Firestore) cuando no hay nada
  // local que proteger. Solo sobreescribe los campos que sí existan en el
  // documento remoto — si un campo nunca se guardó, se conserva el valor
  // local/por defecto.
  Future<void> _sincronizarDesdeFirestore() async {
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId == null) return;

    try {
      final usuario = await AuthService().obtenerUsuarioPorId(usuarioId);
      if (usuario == null) return;

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
        _actividadSemanal = actividad
            .map((e) => (e as num).toDouble())
            .toList();
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

      await _guardarLocal();
    } catch (e) {
      debugPrint('Error sincronizando progreso desde Firestore: $e');
    }
  }

  Future<void> _guardarLocal() async {
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

      final usuarioId = AuthService().usuarioActualId;
      if (usuarioId != null) {
        await _prefs.setString('progreso_uid', usuarioId);
      }
    } catch (e) {
      debugPrint('Error guardando datos locales de progreso: $e');
    }
  }

  Future<void> _guardarEnFirestore() async {
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
      });
    } catch (e) {
      debugPrint('Error guardando progreso en Firestore: $e');
    }
  }

  Future<void> _saveData() async {
    await _guardarLocal();
    await _guardarEnFirestore();
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
