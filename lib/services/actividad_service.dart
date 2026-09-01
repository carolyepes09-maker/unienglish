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
      await precargarLocal();
      await sincronizarConCuenta();
    } catch (e) {
      AppLogger.log('❌ ActividadService: Error durante initialize: $e');
      rethrow;
    }
  }

  /// Fase 1: SharedPreferences (y la semilla de assets si no hay nada
  /// guardado todavía) -- no depende de Firebase ni de que haya sesión, así
  /// que puede correr en paralelo con Firebase.initializeApp() en vez de
  /// esperarlo primero. Si SÍ había algo guardado, decidir si es de esta
  /// cuenta se deja para sincronizarConCuenta() (necesita saber quién tiene
  /// sesión).
  Future<void> precargarLocal() async {
    AppLogger.log('📝 ActividadService: Inicializando SharedPreferences...');
    _prefs = await SharedPreferences.getInstance();
    AppLogger.log('✅ ActividadService: SharedPreferences lista');

    try {
      final actividadesJson = _prefs.getString('actividades_recientes');
      if (actividadesJson == null) {
        // No hay nada guardado en este dispositivo todavía: usamos la
        // semilla de assets mientras se resuelve si hay cuenta con datos
        // propios (esto no depende de a quién pertenezca, es solo el
        // contenido de ejemplo por defecto).
        final String assetsJsonString = await rootBundle.loadString(
          'assets/data/actividad_reciente.json',
        );
        final List<dynamic> assetsList = jsonDecode(assetsJsonString);
        _actividades = List<Map<String, dynamic>>.from(assetsList);
      }
    } catch (e) {
      AppLogger.log('❌ Error cargando actividades: $e');
      _actividades = [];
    }
  }

  /// Fase 2: decide si la actividad guardada localmente es de esta cuenta y
  /// sincroniza con Firestore. Necesita que AuthService ya haya restaurado/
  /// iniciado sesión (usuarioActualId/usuarioActual poblados).
  Future<void> sincronizarConCuenta() async {
    try {
      // Solo confiamos en el caché local si es de ESTE usuario (o de una
      // versión anterior sin la marca de cuenta). Si en este navegador hay
      // actividad guardada de OTRA cuenta (alguien cerró sesión y entró con
      // otra), no la mostramos — Firestore es quien manda a continuación.
      final usuarioIdActual = AuthService().usuarioActualId;
      final uidLocal = _prefs.getString('actividad_uid');
      final localEsDeEsteUsuario = uidLocal == null || uidLocal == usuarioIdActual;

      final actividadesJson = _prefs.getString('actividades_recientes');
      if (actividadesJson != null) {
        _actividades = localEsDeEsteUsuario
            ? List<Map<String, dynamic>>.from(jsonDecode(actividadesJson))
            // Había actividad local, pero de otra cuenta: empezamos vacío
            // hasta que la sincronización con Firestore traiga la de este
            // usuario.
            : [];
      }
      // Si actividadesJson era null, precargarLocal() ya cargó la semilla
      // de assets -- nada que decidir aquí.
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
      // AuthService ya tiene el documento completo del usuario en memoria
      // (lo cargó al iniciar/restaurar sesión) -- se reutiliza esa copia en
      // vez de volver a pedirle lo mismo a Firestore. Antes, Progreso/
      // Vocabulario/Actividad hacían cada uno su propia lectura del MISMO
      // documento en cada arranque: 4 viajes de red para leer 4 partes de
      // un solo documento.
      final usuario = AuthService().usuarioActual;
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

  /// Borra la caché local (SharedPreferences) y reinicia el estado en
  /// memoria. Se llama al cerrar sesión: sin esto, la próxima persona que
  /// use este mismo navegador/dispositivo vería por un instante la
  /// actividad reciente de la cuenta anterior durante la precarga local
  /// (que corre antes de saber quién inició sesión).
  Future<void> limpiarCacheLocal() async {
    try {
      await _prefs.remove('actividades_recientes');
      await _prefs.remove('actividad_uid');
    } catch (e) {
      AppLogger.log('❌ Error limpiando caché local de actividad: $e');
    }
    _actividades = [];
  }
}

// Singleton global (misma instancia que `ActividadService()`).
final ActividadService actividadService = ActividadService();
