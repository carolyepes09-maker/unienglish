import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ui/utils/app_strings.dart';
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
  ///
  /// Si la cuenta de Firebase Auth existe pero su perfil no (el registro
  /// creó la cuenta y falló al guardar el perfil, p. ej. por perder la
  /// conexión justo en ese momento), se crea un perfil base en vez de dejar
  /// la cuenta "huérfana": sin esto no se podía iniciar sesión (no hay
  /// perfil) ni volver a registrarse (el correo ya está en uso).
  Future<void> _cargarPerfil(String usuarioId) async {
    final doc = await _usuariosRef.doc(usuarioId).get().timeout(
      _kFirestoreTimeout,
    );
    if (doc.exists) {
      _usuarioActualId = usuarioId;
      _usuarioActualData = doc.data();
      AppLogger.log('✅ Perfil restaurado desde Firestore: $usuarioId');
      return;
    }

    final usuarioFirebase = _auth.currentUser;
    if (usuarioFirebase == null || usuarioFirebase.uid != usuarioId) return;
    final email = usuarioFirebase.email ?? '';
    final perfil = _perfilNuevo(
      usuarioId: usuarioId,
      email: email,
      nombreCompleto: usuarioFirebase.displayName ?? email.split('@').first,
      // Esta cuenta se registró antes de guardar su perfil; el consentimiento
      // se le vuelve a pedir al entrar (ver MainNavigation).
      aceptoPolitica: false,
    );
    await _usuariosRef.doc(usuarioId).set(perfil).timeout(_kFirestoreTimeout);
    _usuarioActualId = usuarioId;
    _usuarioActualData = perfil;
    AppLogger.log('🩹 Perfil faltante recreado para: $usuarioId');
  }

  Map<String, dynamic> _perfilNuevo({
    required String usuarioId,
    required String email,
    required String nombreCompleto,
    String? codigoEstudiante,
    String? facultadPrograma,
    required bool aceptoPolitica,
  }) {
    final ahora = DateTime.now().toIso8601String();
    return {
      'usuario_id': usuarioId,
      'nombre_completo': nombreCompleto,
      'correo_electronico': email,
      'codigo_estudiante': codigoEstudiante ?? '',
      'facultad_programa': facultadPrograma ?? '',
      'idioma_preferido': 'es',
      'nivel_actual': 'A1',
      'racha_dias': 0,
      'puntos_totales': 0,
      'fecha_registro': ahora,
      'ultima_conexion': ahora,
      'notificaciones_activas': true,
      'acepto_politica_datos': aceptoPolitica,
      if (aceptoPolitica) 'fecha_aceptacion_politica': ahora,
    };
  }

  /// Getters básicos
  String? get usuarioActualId => _usuarioActualId;
  bool get estaAutenticado => _usuarioActualId != null;
  Map<String, dynamic>? get usuarioActual => _usuarioActualData;

  /// Traduce los códigos de error de Firebase a mensajes en el idioma de la
  /// interfaz (antes solo salían en español).
  String _mensajeError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppStrings.tr(
          'El correo ya está registrado',
          'This email is already registered',
        );
      case 'invalid-email':
        return AppStrings.tr(
          'Correo electrónico inválido',
          'Invalid email address',
        );
      case 'weak-password':
        return AppStrings.tr(
          'La contraseña es demasiado débil',
          'The password is too weak',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.tr('Credenciales inválidas', 'Invalid credentials');
      case 'too-many-requests':
        return AppStrings.tr(
          'Demasiados intentos. Intenta de nuevo más tarde',
          'Too many attempts. Please try again later',
        );
      case 'network-request-failed':
        return AppStrings.tr(
          'Sin conexión. Revisa tu internet e inténtalo de nuevo',
          'No connection. Check your internet and try again',
        );
      case 'requires-recent-login':
        return AppStrings.tr(
          'Por seguridad, vuelve a iniciar sesión e inténtalo de nuevo',
          'For security, sign in again and retry',
        );
      default:
        return AppStrings.tr(
          'Error de autenticación: ${e.message ?? e.code}',
          'Authentication error: ${e.message ?? e.code}',
        );
    }
  }

  String _errorInesperado(Object e) =>
      AppStrings.tr('Error inesperado: $e', 'Unexpected error: $e');

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

      final nuevoUsuario = _perfilNuevo(
        usuarioId: usuarioId,
        email: email,
        nombreCompleto: nombreCompleto,
        codigoEstudiante: codigoEstudiante,
        facultadPrograma: facultadPrograma,
        // El formulario de registro ya bloquea el botón hasta que se marca
        // el checkbox de aceptación (ver login_screen.dart), así que si
        // llegamos aquí es porque el usuario ya aceptó.
        aceptoPolitica: true,
      );

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
      return {'success': false, 'error': _errorInesperado(e)};
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
      return {'success': false, 'error': _errorInesperado(e)};
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
      return {'success': false, 'error': _errorInesperado(e)};
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

  /// Elimina permanentemente la cuenta del usuario (documento en Firestore
  /// + cuenta de Firebase Authentication). Firebase exige una sesión
  /// "reciente" para esta operación, así que primero se reautentica con la
  /// contraseña que el usuario acaba de escribir -- si la sesión es vieja,
  /// un delete() directo fallaría con 'requires-recent-login'.
  Future<Map<String, dynamic>> eliminarCuenta({
    required String password,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null || usuario.email == null) {
      return {
        'success': false,
        'error': AppStrings.tr('No hay sesión activa', 'No active session'),
      };
    }
    final usuarioId = usuario.uid;

    try {
      final credencial = fb_auth.EmailAuthProvider.credential(
        email: usuario.email!,
        password: password,
      );
      await usuario.reauthenticateWithCredential(credencial);

      // Borra el documento de Firestore MIENTRAS la sesión de Auth todavía
      // es válida -- las reglas exigen request.auth.uid == usuarioId, y
      // eso deja de cumplirse en cuanto se borra la cuenta de Auth.
      await _usuariosRef.doc(usuarioId).delete().timeout(_kFirestoreTimeout);

      // Última: borra la cuenta de Firebase Auth (esto cierra la sesión).
      await usuario.delete();

      _usuarioActualId = null;
      _usuarioActualData = null;

      return {'success': true};
    } on fb_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'error': _mensajeError(e)};
    } catch (e) {
      return {'success': false, 'error': _errorInesperado(e)};
    }
  }
}
