import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';

/// =============================================================================
/// 🔐 SERVICIO: lib/services/auth_service.dart
/// =============================================================================
/// Este servicio gestiona la autenticación con Firebase Authentication y
/// guarda el perfil del usuario en Cloud Firestore (colección 'usuarios').
///
/// Al vivir la cuenta y los datos en el servidor (no solo en el navegador),
/// la sesión sobrevive a refrescos, cierres de la app e incluso a borrar
/// por completo la caché/datos del navegador: basta con volver a iniciar
/// sesión con el mismo correo y contraseña para recuperar el perfil.
///
/// Todas las llamadas a Firestore tienen un tiempo límite (_kFirestoreTimeout):
/// en modo incógnito algunos navegadores restringen IndexedDB, lo que puede
/// dejar colgada una operación de Firebase indefinidamente. Sin límite, eso
/// congelaría toda la app (la pantalla de carga nunca terminaría). Con
/// límite, la operación falla como cualquier error de red normal y la app
/// sigue funcionando con lo que ya tenía en memoria/local.
/// =============================================================================

const Duration _kFirestoreTimeout = Duration(seconds: 6);

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() : _authInyectado = null, _firestoreInyectado = null;

  /// Solo para pruebas: crea una instancia INDEPENDIENTE del singleton
  /// global de arriba, con FirebaseAuth/FirebaseFirestore inyectados (ej.
  /// los fakes de firebase_auth_mocks / fake_cloud_firestore). El resto de
  /// la app real nunca llama a este constructor -- siempre usa AuthService()
  /// (el singleton), que sigue funcionando exactamente igual que antes.
  AuthService.forTesting({
    required fb_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _authInyectado = auth,
       _firestoreInyectado = firestore;

  final fb_auth.FirebaseAuth? _authInyectado;
  final FirebaseFirestore? _firestoreInyectado;

  // Getters (no campos 'final' evaluados al construir el objeto): así,
  // construir AuthService() nunca toca el SDK de Firebase -- solo lo hace
  // cuando de verdad se llama a un método (initialize, iniciarSesion, etc.),
  // momento en el que Firebase.initializeApp() ya debería haber terminado.
  // Si esto fueran campos 'final', se evaluarían de inmediato al construir
  // la instancia, y truenan si Firebase.initializeApp() todavía no ha
  // corrido -- exactamente el orden en que main.dart construye estos
  // servicios ahora (ver hallazgo 9).
  fb_auth.FirebaseAuth get _auth => _authInyectado ?? fb_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreInyectado ?? FirebaseFirestore.instance;

  Map<String, dynamic>? _usuarioActualData;
  String? _usuarioActualId;

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _firestore.collection('usuarios');

  /// Inicializa el servicio: si Firebase Auth ya tiene una sesión persistida
  /// (refresco de página, reapertura de la app), recupera el perfil desde
  /// Firestore para restaurar el estado de sesión.
  Future<void> initialize() async {
    try {
      final fb_auth.User? usuarioFirebase = _auth.currentUser;
      if (usuarioFirebase != null) {
        await _cargarPerfil(usuarioFirebase.uid);
      }
    } catch (e) {
      AppLogger.log('❌ Error restaurando sesión: $e');
    }
  }

  /// Carga el documento de perfil desde Firestore y actualiza el estado local.
  Future<void> _cargarPerfil(String usuarioId) async {
    final doc = await _usuariosRef.doc(usuarioId).get().timeout(
      _kFirestoreTimeout,
    );
    if (doc.exists) {
      _usuarioActualId = usuarioId;
      _usuarioActualData = doc.data();
      AppLogger.log('✅ Perfil restaurado desde Firestore: $usuarioId');
    }
  }

  /// Getters básicos
  String? get usuarioActualId => _usuarioActualId;
  bool get estaAutenticado => _usuarioActualId != null;
  Map<String, dynamic>? get usuarioActual => _usuarioActualData;

  /// Traduce los códigos de error de Firebase a mensajes en español
  String _mensajeError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }

  /// Registra un nuevo usuario (Firebase Authentication + perfil en Firestore)
  Future<Map<String, dynamic>> registrarUsuario({
    required String email,
    required String password,
    required String nombreCompleto,
    String? codigoEstudiante,
    String? facultadPrograma,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final usuarioId = credencial.user!.uid;

      // Mejor esfuerzo: si falla (límite de envíos, red, etc.) no debe
      // impedir que el registro se complete -- el usuario ya puede usar la
      // app, solo no habrá podido verificar el correo en este intento.
      try {
        await credencial.user!.sendEmailVerification();
      } catch (e) {
        AppLogger.log('⚠️ No se pudo enviar el correo de verificación: $e');
      }

      final nuevoUsuario = {
        'usuario_id': usuarioId,
        'nombre_completo': nombreCompleto,
        'correo_electronico': email,
        'codigo_estudiante': codigoEstudiante ?? '',
        'facultad_programa': facultadPrograma ?? '',
        'idioma_preferido': 'es',
        'nivel_actual': 'A1',
        'racha_dias': 0,
        'puntos_totales': 0,
        'fecha_registro': DateTime.now().toIso8601String(),
        'ultima_conexion': DateTime.now().toIso8601String(),
        'notificaciones_activas': true,
        // El formulario de registro ya bloquea el botón hasta que se marca
        // el checkbox de aceptación (ver login_screen.dart), así que si
        // llegamos aquí es porque el usuario ya aceptó.
        'acepto_politica_datos': true,
        'fecha_aceptacion_politica': DateTime.now().toIso8601String(),
      };

      await _usuariosRef
          .doc(usuarioId)
          .set(nuevoUsuario)
          .timeout(_kFirestoreTimeout);

      _usuarioActualId = usuarioId;
      _usuarioActualData = nuevoUsuario;

      return {'success': true, 'usuario_id': usuarioId};
    } on fb_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mensajeError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Error inesperado: ${e.toString()}'};
    }
  }

  /// Inicio de sesión (Firebase Authentication + carga de perfil en Firestore)
  Future<Map<String, dynamic>> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final usuarioId = credencial.user!.uid;

      await _cargarPerfil(usuarioId);

      // Actualizar última conexión
      await _usuariosRef
          .doc(usuarioId)
          .update({'ultima_conexion': DateTime.now().toIso8601String()})
          .timeout(_kFirestoreTimeout);
      _usuarioActualData?['ultima_conexion'] = DateTime.now()
          .toIso8601String();

      return {'success': true, 'usuario_id': usuarioId};
    } on fb_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mensajeError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Error inesperado: ${e.toString()}'};
    }
  }

  /// Envía el correo de restablecimiento de contraseña de Firebase Auth.
  Future<Map<String, dynamic>> enviarCorreoRecuperacion({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true};
    } on fb_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mensajeError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Error inesperado: ${e.toString()}'};
    }
  }

  /// Cierra la sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _usuarioActualId = null;
    _usuarioActualData = null;
  }

  /// Actualiza el nivel actual del usuario (A1, A2, B1, B2...)
  Future<bool> actualizarNivel(String usuarioId, String nivel) async {
    return actualizarUsuario(usuarioId, {'nivel_actual': nivel});
  }

  /// Actualiza datos del usuario en Firestore
  Future<bool> actualizarUsuario(
    String usuarioId,
    Map<String, dynamic> datos,
  ) async {
    try {
      await _usuariosRef
          .doc(usuarioId)
          .set(datos, SetOptions(merge: true))
          .timeout(_kFirestoreTimeout);
      if (usuarioId == _usuarioActualId) {
        _usuarioActualData = {...?_usuarioActualData, ...datos};
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Incrementa los puntos totales del usuario
  Future<void> incrementarPuntos(String usuarioId, int puntos) async {
    try {
      await _usuariosRef
          .doc(usuarioId)
          .update({'puntos_totales': FieldValue.increment(puntos)})
          .timeout(_kFirestoreTimeout);
      if (usuarioId == _usuarioActualId) {
        await _cargarPerfil(usuarioId);
      }
    } catch (e) {
      AppLogger.log('Error incrementando puntos: $e');
    }
  }

  /// Obtiene el usuario actual ID
  Future<String?> obtenerUsuarioId() async => _usuarioActualId;
}
