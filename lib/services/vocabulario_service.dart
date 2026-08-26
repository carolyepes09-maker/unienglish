import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/palabra_model.dart';
import 'auth_service.dart';

/// =============================================================================
///  SERVICIO: lib/services/vocabulario_service.dart
/// =============================================================================
/// Este servicio gestiona el Diccionario Personalizado localmente.
/// ============================================================================

class VocabularioService {
  final AuthService _authService;
  late SharedPreferences _prefs;

  List<Map<String, dynamic>> _tarjetasSistema = [];
  List<Map<String, dynamic>> _tarjetasUsuario = [];
  List<Map<String, dynamic>> _progresoTarjetas = [];

  VocabularioService(this._authService);

  /// Inicializa el servicio cargando datos desde Assets y SharedPreferences
  Future<void> initialize() async {
    try {
      print('⏳ VocabularioService: Obteniendo SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      print('✅ VocabularioService: SharedPreferences obtenido');
      print('⏳ VocabularioService: Cargando palabras del sistema...');
      await _cargarPalabrasSistema();
      print('✅ VocabularioService: Palabras del sistema cargadas');
      print('⏳ VocabularioService: Cargando datos del usuario...');
      await _cargarDatosUsuarioLocal();
      print('✅ VocabularioService: Datos del usuario cargados');
    } catch (e) {
      print('❌ VocabularioService initialize error: $e');
      print('⚠️ Continuando con valores por defecto');
    }
  }

  Future<void> _cargarPalabrasSistema() async {
    try {
      print('📄 Cargando palabras.json desde assets...');
      final String jsonString = await rootBundle.loadString(
        'assets/data/palabras.json',
      );
      final List<dynamic> list = jsonDecode(jsonString);
      _tarjetasSistema = List<Map<String, dynamic>>.from(list);
      print('✅ ${_tarjetasSistema.length} palabras del sistema cargadas');
    } catch (e) {
      print('❌ Error cargando palabras sistema: $e');
      _tarjetasSistema = [];
    }
  }

  Future<void> _cargarDatosUsuarioLocal() async {
    try {
      // Si esta clave ya existe Y pertenece al usuario que tiene sesión
      // ahora, este navegador/dispositivo tiene vocabulario real guardado
      // localmente. Si no existe (incógnito, navegador nuevo, otro
      // dispositivo) o pertenece a OTRA cuenta (alguien cerró sesión y
      // entró con otra en el mismo navegador), no hay nada de este usuario
      // que proteger y conviene traer el vocabulario guardado en su cuenta.
      final usuarioIdActual = _authService.usuarioActualId;
      final uidLocal = _prefs.getString('vocabulario_uid');
      final huboDatosLocales =
          _prefs.containsKey('palabras_usuario') &&
          (uidLocal == null || uidLocal == usuarioIdActual);

      final palabrasJson = _prefs.getString('palabras_usuario') ?? '[]';
      _tarjetasUsuario = List<Map<String, dynamic>>.from(
        jsonDecode(palabrasJson),
      );

      final progresoJson = _prefs.getString('progreso_vocabulario') ?? '[]';
      _progresoTarjetas = List<Map<String, dynamic>>.from(
        jsonDecode(progresoJson),
      );

      if (huboDatosLocales) {
        // Este dispositivo ya tenía vocabulario real: lo subimos a Firestore
        // en vez de arriesgarnos a pisarlo con un valor remoto vacío.
        await _guardarEnFirestore();
      } else {
        await _sincronizarDesdeFirestore();
      }

      print('✅ ${_tarjetasUsuario.length} palabras del usuario cargadas');
    } catch (e) {
      print('❌ Error cargando vocabulario local: $e');
    }
  }

  // Trae el vocabulario guardado en la cuenta (Firestore) cuando no hay
  // nada local que proteger.
  Future<void> _sincronizarDesdeFirestore() async {
    final usuarioId = _authService.usuarioActualId;
    if (usuarioId == null) return;

    try {
      final usuario = await _authService.obtenerUsuarioPorId(usuarioId);
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

      if (tarjetas is List || progreso is List) {
        await _guardarDatosLocal();
      }
    } catch (e) {
      print('❌ Error sincronizando vocabulario desde Firestore: $e');
    }
  }

  Future<void> _guardarDatosLocal() async {
    try {
      await _prefs.setString('palabras_usuario', jsonEncode(_tarjetasUsuario));
      await _prefs.setString(
        'progreso_vocabulario',
        jsonEncode(_progresoTarjetas),
      );
      final usuarioId = _authService.usuarioActualId;
      if (usuarioId != null) {
        await _prefs.setString('vocabulario_uid', usuarioId);
      }
    } catch (e) {
      print('❌ Error guardando vocabulario: $e');
    }
  }

  Future<void> _guardarEnFirestore() async {
    final usuarioId = _authService.usuarioActualId;
    if (usuarioId == null) return;

    try {
      await _authService.actualizarUsuario(usuarioId, {
        'vocabulario_tarjetas_usuario': _tarjetasUsuario,
        'vocabulario_progreso_tarjetas': _progresoTarjetas,
      });
    } catch (e) {
      print('❌ Error guardando vocabulario en Firestore: $e');
    }
  }

  // Guarda los cambios locales (SharedPreferences) y en la cuenta
  // (Firestore), para que el vocabulario esté atado al usuario.
  Future<void> _guardarDatosUsuarioLocal() async {
    await _guardarDatosLocal();
    await _guardarEnFirestore();
  }

  /// Carga todas las tarjetas combinadas
  Future<List<PalabraModel>> cargarPalabras() async {
    List<PalabraModel> palabras = [];
    final todasLasTarjetas = [..._tarjetasSistema, ..._tarjetasUsuario];

    for (var tarjeta in todasLasTarjetas) {
      final tarjetaId =
          tarjeta['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Buscar progreso
      Map<String, dynamic> progreso = {};
      try {
        progreso = _progresoTarjetas.firstWhere(
          (p) => p['tarjeta_id'] == tarjetaId,
          orElse: () => {},
        );
      } catch (_) {}

      if (progreso.isNotEmpty) {
        palabras.add(
          PalabraModel(
            id: tarjetaId,
            ingles: tarjeta['palabra_termino'] ?? '',
            espanol: tarjeta['traduccion_definicion'] ?? '',
            ejemplo: tarjeta['ejemplo_uso'] ?? '',
            nivel: ((progreso['facilidad'] ?? 2.5) as num).toInt(),
            proximaRevision:
                DateTime.tryParse(
                  progreso['proxima_revision'] as String? ?? '',
                ) ??
                DateTime.now(),
            vecesCorrectamente: progreso['total_correctas'] as int? ?? 0,
            vecesIncorrectamente: progreso['total_incorrectas'] as int? ?? 0,
          ),
        );
      } else {
        palabras.add(
          PalabraModel(
            id: tarjetaId,
            ingles: tarjeta['palabra_termino'] ?? '',
            espanol: tarjeta['traduccion_definicion'] ?? '',
            ejemplo: tarjeta['ejemplo_uso'] ?? '',
            nivel: 0,
            proximaRevision: DateTime.now(),
            vecesCorrectamente: 0,
            vecesIncorrectamente: 0,
          ),
        );
      }
    }
    return palabras;
  }

  /// Obtiene la lista de palabras destinadas al repaso
  Future<List<PalabraModel>> obtenerPalabrasParaRepasar() async {
    return await cargarPalabras();
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
        'intervalo_dias': 1,
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
      print('❌ Error al guardar palabra: $e');
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
