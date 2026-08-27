import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'auth_service.dart';

/// =============================================================================
/// 📜 SERVICIO: lib/services/actividad_service.dart
/// =============================================================================
/// Este servicio registra el historial de acciones recientes del usuario.
/// Se guarda localmente (SharedPreferences, como caché rápida/offline) y en
/// Firestore (campo 'actividades_recientes' del documento del usuario), para
/// que sobreviva a un borrado de caché igual que la sesión de login.
/// =============================================================================

const int _kMaxActividades = 3;

class ActividadService {
  static final ActividadService _instance = ActividadService._internal();
  factory ActividadService() => _instance;
  ActividadService._internal();

  late SharedPreferences _prefs;
  List<Map<String, dynamic>> _actividades = [];

  // ─── INICIALIZACIÓN DEL SISTEMA ──────────────────────────────────────────
  Future<void> initialize() async {
    try {
      AppLogger.log('📝 ActividadService: Inicializando SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      AppLogger.log('✅ ActividadService: SharedPreferences lista');
      AppLogger.log('📝 ActividadService: Cargando datos base...');
      await _cargarDatosBase();
      AppLogger.log('✅ ActividadService: Datos base cargados');
    } catch (e) {
      AppLogger.log('❌ ActividadService: Error durante initialize: $e');
      rethrow;
    }
  }

  // Carga datos: primero local (SharedPreferences o assets como semilla),
  // y si hay sesión ya restaurada, Firestore manda como fuente de verdad.
  Future<void> _cargarDatosBase() async {
    try {
      // Solo confiamos en el caché local si es de ESTE usuario (o de una
      // versión anterior sin la marca de cuenta). Si en este navegador hay
      // actividad guardada de OTRA cuenta (alguien cerró sesión y entró con
      // otra), no la mostramos — Firestore es quien manda a continuación.
      final usuarioIdActual = AuthService().usuarioActualId;
      final uidLocal = _prefs.getString('actividad_uid');
      final localEsDeEsteUsuario = uidLocal == null || uidLocal == usuarioIdActual;

      final actividadesJson = _prefs.getString('actividades_recientes');
      if (actividadesJson != null && localEsDeEsteUsuario) {
        _actividades = List<Map<String, dynamic>>.from(
          jsonDecode(actividadesJson),
        );
      } else if (actividadesJson == null) {
        // Si no hay nada en SP, cargar desde assets
        final String assetsJsonString = await rootBundle.loadString(
          'assets/data/actividad_reciente.json',
        );
        final List<dynamic> assetsList = jsonDecode(assetsJsonString);
        _actividades = List<Map<String, dynamic>>.from(assetsList);
      } else {
        // Había actividad local, pero de otra cuenta: empezamos vacío hasta
        // que la sincronización con Firestore traiga la de este usuario.
        _actividades = [];
      }
    } catch (e) {
      AppLogger.log('❌ Error cargando actividades: $e');
      _actividades = [];
    }

    await _sincronizarDesdeFirestore();
    _recortarAlLimite();
  }

  // Si hay usuario autenticado, trae 'actividades_recientes' de su documento
  // en Firestore y la usa como fuente de verdad (más completa que un
  // SharedPreferences local, que no viaja entre dispositivos/caché borrado).
  Future<void> _sincronizarDesdeFirestore() async {
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId == null) return;

    try {
      final usuario = await AuthService().obtenerUsuarioPorId(usuarioId);
      final remotas = usuario?['actividades_recientes'];
      if (remotas is List) {
        _actividades = List<Map<String, dynamic>>.from(
          remotas.map((e) => Map<String, dynamic>.from(e as Map)),
        );
        await _guardarLocal();
      }
    } catch (e) {
      AppLogger.log('❌ Error sincronizando actividades desde Firestore: $e');
    }
  }

  void _recortarAlLimite() {
    if (_actividades.length > _kMaxActividades) {
      _actividades = _actividades.sublist(0, _kMaxActividades);
    }
  }

  Future<void> _guardarLocal() async {
    await _prefs.setString('actividades_recientes', jsonEncode(_actividades));
    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId != null) {
      await _prefs.setString('actividad_uid', usuarioId);
    }
  }

  /// Registra una nueva actividad: local (rápido/offline) y en Firestore.
  Future<void> registrarActividad({
    required String titulo,
    required String subtitulo,
    required String porcentaje,
    required bool esPerfecto,
  }) async {
    final nuevaActividad = {
      'titulo': titulo,
      'subtitulo': subtitulo,
      'porcentaje': porcentaje,
      'esPerfecto': esPerfecto,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Insertar al inicio de la lista y quedarnos solo con las últimas 3.
    _actividades.insert(0, nuevaActividad);
    _recortarAlLimite();

    try {
      await _guardarLocal();
    } catch (e) {
      AppLogger.log('❌ Error guardando actividad localmente: $e');
    }

    final usuarioId = AuthService().usuarioActualId;
    if (usuarioId != null) {
      try {
        await AuthService().actualizarUsuario(usuarioId, {
          'actividades_recientes': _actividades,
        });
      } catch (e) {
        AppLogger.log('❌ Error guardando actividad en Firestore: $e');
      }
    }
  }

  // Retorna la lista de actividades para la UI
  List<Map<String, dynamic>> obtenerActividades() {
    return _actividades;
  }
}

// Singleton global (misma instancia que `ActividadService()`).
final ActividadService actividadService = ActividadService();
