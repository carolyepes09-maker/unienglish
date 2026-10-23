import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/palabra_model.dart';
import '../utils/app_logger.dart';
import 'auth_service.dart';

/// =============================================================================
///  SERVICIO: lib/services/vocabulario_service.dart
/// =============================================================================
/// Este servicio gestiona el Diccionario Personalizado localmente.
///
/// Extiende ChangeNotifier para avisar cuando la sincronización con la
/// cuenta (Firestore) termina en segundo plano -- así, si la pantalla de
/// Vocabulario ya estaba abierta con la caché local, se refresca sola en
/// vez de quedarse con datos incompletos hasta que el usuario salga y
/// vuelva a entrar.
/// ============================================================================

class VocabularioService extends ChangeNotifier {
  final AuthService _authService;
  late SharedPreferences _prefs;

  List<Map<String, dynamic>> _tarjetasSistema = [];
  List<Map<String, dynamic>> _tarjetasUsuario = [];
  List<Map<String, dynamic>> _progresoTarjetas = [];

  VocabularioService(this._authService);

  /// Inicializa el servicio cargando datos desde Assets y SharedPreferences
  Future<void> initialize() async {
    await precargarLocal();
    await sincronizarConCuenta();
  }

  /// Borra la caché local (SharedPreferences) y reinicia el estado en
  /// memoria. Se llama al cerrar sesión: sin esto, la próxima persona que
  /// use este mismo navegador/dispositivo vería por un instante el
  /// vocabulario de la cuenta anterior durante la precarga local (que
  /// corre antes de saber quién inició sesión).
  Future<void> limpiarCacheLocal() async {
    try {
      await _prefs.remove('palabras_usuario');
      await _prefs.remove('progreso_vocabulario');
      await _prefs.remove('vocabulario_actualizado_en');
      await _prefs.remove('vocabulario_uid');
    } catch (e) {
      AppLogger.log('❌ Error limpiando caché local de vocabulario: $e');
    }
    _tarjetasUsuario = [];
    _progresoTarjetas = [];
    notifyListeners();
  }

  /// Fase 1: SharedPreferences + vocabulario del sistema (assets) -- no
  /// depende de Firebase ni de que haya sesión, así que puede correr en
  /// paralelo con Firebase.initializeApp() en vez de esperarlo primero.
  Future<void> precargarLocal() async {
    try {
      AppLogger.log('⏳ VocabularioService: Obteniendo SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      AppLogger.log('✅ VocabularioService: SharedPreferences obtenido');
      AppLogger.log('⏳ VocabularioService: Cargando palabras del sistema...');
      await _cargarPalabrasSistema();
      AppLogger.log('✅ VocabularioService: Palabras del sistema cargadas');

      final palabrasJson = _prefs.getString('palabras_usuario') ?? '[]';
      _tarjetasUsuario = List<Map<String, dynamic>>.from(
        jsonDecode(palabrasJson),
      );

      final progresoJson = _prefs.getString('progreso_vocabulario') ?? '[]';
      _progresoTarjetas = List<Map<String, dynamic>>.from(
        jsonDecode(progresoJson),
      );
    } catch (e) {
      AppLogger.log('❌ VocabularioService precargarLocal error: $e');
      AppLogger.log('⚠️ Continuando con valores por defecto');
    }
  }

  /// Fase 2: decide si el vocabulario local es de esta cuenta y sincroniza
  /// con Firestore. Necesita que _authService ya haya restaurado/iniciado
  /// sesión (usuarioActualId/usuarioActual poblados).
  Future<void> sincronizarConCuenta() async {
    try {
      // El vocabulario local solo cuenta como "de este usuario" si el uid
      // guardado coincide con el que tiene sesión ahora (si no, es de otra
      // cuenta que usó este mismo navegador/dispositivo antes).
      final usuarioIdActual = _authService.usuarioActualId;
      final uidLocal = _prefs.getString('vocabulario_uid');
      final localEsDeEsteUsuario =
          uidLocal != null && uidLocal == usuarioIdActual;

      // "Última modificación real" del vocabulario en este dispositivo (no
      // "última vez que se sincronizó"). Si el vocabulario local es de otra
      // cuenta, no cuenta.
      final actualizadoLocal = localEsDeEsteUsuario
          ? DateTime.tryParse(
              _prefs.getString('vocabulario_actualizado_en') ?? '',
            )
          : null;

      await _sincronizarPorTimestamp(actualizadoLocal);

      AppLogger.log('✅ ${_tarjetasUsuario.length} palabras del usuario cargadas');
      // Avisa a quien esté escuchando (ej. VocabularioScreen ya abierta con
      // la caché local) que hay datos nuevos, por si la sincronización
      // trajo algo de otra cuenta/dispositivo.
      notifyListeners();
    } catch (e) {
      AppLogger.log('❌ Error cargando vocabulario local: $e');
    }
  }

  Future<void> _cargarPalabrasSistema() async {
    try {
      AppLogger.log('📄 Cargando palabras.json desde assets...');
      final String jsonString = await rootBundle.loadString(
        'assets/data/palabras.json',
      );
      final List<dynamic> list = jsonDecode(jsonString);
      _tarjetasSistema = List<Map<String, dynamic>>.from(list);
      AppLogger.log('✅ ${_tarjetasSistema.length} palabras del sistema cargadas');
    } catch (e) {
      AppLogger.log('❌ Error cargando palabras sistema: $e');
      _tarjetasSistema = [];
    }
  }

  // Compara cuándo se modificó realmente el vocabulario por última vez en
  // este dispositivo ([actualizadoLocal]) contra cuándo se modificó por
  // última vez en la cuenta (Firestore), y aplica el más reciente sobre el
  // otro lado -- así un dispositivo con vocabulario viejo en caché nunca
  // sobrescribe con esos datos viejos algo más nuevo guardado desde otro
  // dispositivo. Si ninguno de los dos tiene timestamp todavía (cuenta
  // recién creada / sin vocabulario propio aún), no hace nada.
  Future<void> _sincronizarPorTimestamp(DateTime? actualizadoLocal) async {
    final usuarioId = _authService.usuarioActualId;
    if (usuarioId == null) return;

    try {
      // _authService ya tiene el documento completo del usuario en memoria
      // (lo cargó al iniciar/restaurar sesión) -- se reutiliza esa copia en
      // vez de volver a pedirle lo mismo a Firestore. Antes, Progreso/
      // Vocabulario/Actividad hacían cada uno su propia lectura del MISMO
      // documento en cada arranque: 4 viajes de red para leer 4 partes de
      // un solo documento.
      final usuario = _authService.usuarioActual;
      final actualizadoRemotoStr =
          usuario?['vocabulario_actualizado_en'] as String?;
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
        final tarjetas = usuario?['vocabulario_tarjetas_usuario'];
        final progreso = usuario?['vocabulario_progreso_tarjetas'];
        if (tarjetas is List) {
          _tarjetasUsuario = tarjetas
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        if (progreso is List) {
          _progresoTarjetas = progreso
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        await _guardarDatosLocal(actualizadoRemoto);
      }
    } catch (e) {
      AppLogger.log('❌ Error sincronizando vocabulario por timestamp: $e');
    }
  }

  // [marcaDeTiempo] es cuándo se modificó realmente este vocabulario --
  // puede ser "ahora" (el usuario acaba de agregar/editar/borrar una
  // palabra, ver _guardarDatosUsuarioLocal) o el timestamp que ya traía el
  // lado que ganó la comparación en _sincronizarPorTimestamp.
  Future<void> _guardarDatosLocal(DateTime marcaDeTiempo) async {
    try {
      await _prefs.setString('palabras_usuario', jsonEncode(_tarjetasUsuario));
      await _prefs.setString(
        'progreso_vocabulario',
        jsonEncode(_progresoTarjetas),
      );
      await _prefs.setString(
        'vocabulario_actualizado_en',
        marcaDeTiempo.toIso8601String(),
      );
      final usuarioId = _authService.usuarioActualId;
      if (usuarioId != null) {
        await _prefs.setString('vocabulario_uid', usuarioId);
      }
    } catch (e) {
      AppLogger.log('❌ Error guardando vocabulario: $e');
    }
  }

  Future<void> _guardarEnFirestore(DateTime marcaDeTiempo) async {
    final usuarioId = _authService.usuarioActualId;
    if (usuarioId == null) return;

    try {
      await _authService.actualizarUsuario(usuarioId, {
        'vocabulario_tarjetas_usuario': _tarjetasUsuario,
        'vocabulario_progreso_tarjetas': _progresoTarjetas,
        'vocabulario_actualizado_en': marcaDeTiempo.toIso8601String(),
      });
    } catch (e) {
      AppLogger.log('❌ Error guardando vocabulario en Firestore: $e');
    }
  }

  // Se llama cada vez que una acción real del usuario cambia el vocabulario
  // (guardarPalabra, eliminarPalabra, actualizarPalabra): ese es el único
  // momento en que corresponde estampar "ahora" como última modificación.
  Future<void> _guardarDatosUsuarioLocal() async {
    final ahora = DateTime.now();
    await _guardarDatosLocal(ahora);
    await _guardarEnFirestore(ahora);
  }

  /// Carga todas las tarjetas combinadas
  Future<List<PalabraModel>> cargarPalabras() async {
    // Índice por tarjeta_id: una sola pasada en vez de recorrer toda la
    // lista de progreso por cada tarjeta.
    final progresoPorId = <String, Map<String, dynamic>>{
      for (final p in _progresoTarjetas)
        if (p['tarjeta_id'] != null) p['tarjeta_id'].toString(): p,
    };

    final palabras = <PalabraModel>[];
    for (final tarjeta in [..._tarjetasSistema, ..._tarjetasUsuario]) {
      final ingles = tarjeta['palabra_termino']?.toString() ?? '';
      // El id debe ser estable entre arranques: si se generara al vuelo, el
      // progreso guardado nunca volvería a encontrar su tarjeta.
      final tarjetaId = tarjeta['id']?.toString() ?? 'sin_id_$ingles';
      final progreso = progresoPorId[tarjetaId] ?? const {};

      palabras.add(
        PalabraModel(
          id: tarjetaId,
          ingles: ingles,
          espanol: tarjeta['traduccion_definicion']?.toString() ?? '',
          ejemplo: tarjeta['ejemplo_uso']?.toString() ?? '',
          repeticiones: (progreso['repeticiones'] as num?)?.toInt() ?? 0,
          facilidad:
              (progreso['facilidad'] as num?)?.toDouble() ??
              PalabraModel.facilidadInicial,
          intervaloDias: (progreso['intervalo_dias'] as num?)?.toInt() ?? 0,
          proximaRevision: DateTime.tryParse(
            progreso['proxima_revision']?.toString() ?? '',
          ),
          vecesCorrectamente:
              (progreso['total_correctas'] as num?)?.toInt() ?? 0,
          vecesIncorrectamente:
              (progreso['total_incorrectas'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    return palabras;
  }

  /// Obtiene solo las palabras que tocan hoy según SM-2.
  Future<List<PalabraModel>> obtenerPalabrasParaRepasar() async {
    final palabras = await cargarPalabras();
    return palabras.where((p) => p.necesitaRevision).toList();
  }

  /// Guarda el resultado de un repaso (ya aplicado sobre [palabra] con
  /// [PalabraModel.responder]). Sirve tanto para palabras del usuario como
  /// del sistema: el progreso vive aparte de la tarjeta, por tarjeta_id.
  ///
  /// La lista en memoria se actualiza ANTES del primer await, así que quien
  /// lea [cargarPalabras] justo después ya ve el cambio aunque el guardado
  /// en disco/Firestore siga en curso.
  Future<void> registrarRespuesta(PalabraModel palabra) async {
    final progreso = {
      'tarjeta_id': palabra.id,
      'facilidad': palabra.facilidad,
      'intervalo_dias': palabra.intervaloDias,
      'repeticiones': palabra.repeticiones,
      'proxima_revision': palabra.proximaRevision.toIso8601String(),
      'total_revisiones':
          palabra.vecesCorrectamente + palabra.vecesIncorrectamente,
      'total_correctas': palabra.vecesCorrectamente,
      'total_incorrectas': palabra.vecesIncorrectamente,
    };

    final index = _progresoTarjetas.indexWhere(
      (p) => p['tarjeta_id'] == palabra.id,
    );
    if (index == -1) {
      _progresoTarjetas.add(progreso);
    } else {
      _progresoTarjetas[index] = progreso;
    }

    try {
      await _guardarDatosUsuarioLocal();
    } catch (e) {
      AppLogger.log('❌ Error guardando progreso de repaso: $e');
    }
    notifyListeners();
  }

  /// Guarda una nueva palabra
  Future<bool> guardarPalabra(PalabraModel palabra) async {
    try {
      String tarjetaId = const Uuid().v4();
      Map<String, dynamic> tarjeta = {
        'id': tarjetaId,
        'palabra_termino': palabra.ingles,
        'traduccion_definicion': palabra.espanol,
        'ejemplo_uso': palabra.ejemplo,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'tipo_tarjeta': 'usuario',
      };

      _tarjetasUsuario.add(tarjeta);

      // Progreso inicial
      Map<String, dynamic> progreso = {
        'tarjeta_id': tarjetaId,
        'facilidad': 2.5,
        'intervalo_dias': 0,
        'repeticiones': 0,
        'proxima_revision': DateTime.now().toIso8601String(),
        'total_revisiones': 0,
        'total_correctas': 0,
        'total_incorrectas': 0,
      };

      _progresoTarjetas.add(progreso);
      await _guardarDatosUsuarioLocal();
      return true;
    } catch (e) {
      AppLogger.log('❌ Error al guardar palabra: $e');
      return false;
    }
  }

  Future<bool> eliminarPalabra(String tarjetaId) async {
    try {
      _tarjetasUsuario.removeWhere((t) => t['id'] == tarjetaId);
      _progresoTarjetas.removeWhere((p) => p['tarjeta_id'] == tarjetaId);
      await _guardarDatosUsuarioLocal();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> actualizarPalabra(
    String tarjetaId,
    Map<String, dynamic> datos,
  ) async {
    try {
      final index = _tarjetasUsuario.indexWhere((t) => t['id'] == tarjetaId);
      if (index != -1) {
        _tarjetasUsuario[index].addAll(datos);
        await _guardarDatosUsuarioLocal();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
