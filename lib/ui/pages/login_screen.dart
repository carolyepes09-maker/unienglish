import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/progreso_service.dart';
import '../../services/vocabulario_service.dart';
import '../../services/actividad_service.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import 'login/login_mobile_view.dart';
import 'login/login_desktop_view.dart';

/// =============================================================================
/// 🔐 PANTALLA: lib/ui/pages/login_screen.dart
/// =============================================================================
/// Esta pantalla gestiona el primer contacto del usuario con la app.
///
/// FUNCIONALIDADES:
/// 1. Modo Dual: Soporta tanto Inicio de Sesión como Registro en la misma vista.
/// 2. Validaciones: Comprueba correos válidos y contraseñas seguras antes de
///    llamar al servicio.
/// 3. Interfaz Premium: Utiliza un diseño de capas con imágenes y desenfoques
///    para una experiencia de usuario atractiva.
/// =============================================================================

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VocabularioService vocabularioService;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.vocabularioService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Controladores de captura de texto
class _LoginScreenState extends State<LoginScreen>
    with IdiomaListenerMixin<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _programaController = TextEditingController();

  late AuthService _authService;

  bool _obscurePassword = true;
  bool _esRegistro = false;
  bool _cargando = false;
  bool _aceptaPolitica = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _codigoController.dispose();
    _programaController.dispose();
    super.dispose();
  }

  /// Valida los campos del formulario
  bool _validarFormulario() {
    if (_emailController.text.isEmpty) {
      _mostrarError(
        AppStrings.tr('Por favor ingresa tu correo', 'Please enter your email'),
      );
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _mostrarError(
        AppStrings.tr('Correo electrónico inválido', 'Invalid email address'),
      );
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _mostrarError(
        AppStrings.tr(
          'Por favor ingresa tu contraseña',
          'Please enter your password',
        ),
      );
      return false;
    }
    if (_passwordController.text.length < 6) {
      _mostrarError(
        AppStrings.tr(
          'La contraseña debe tener al menos 6 caracteres',
          'Password must be at least 6 characters long',
        ),
      );
      return false;
    }
    if (_esRegistro) {
      if (_nombreController.text.isEmpty) {
        _mostrarError(
          AppStrings.tr(
            'Por favor ingresa tu nombre completo',
            'Please enter your full name',
          ),
        );
        return false;
      }
      if (_programaController.text.isEmpty) {
        _mostrarError(
          AppStrings.tr(
            'Por favor ingresa tu programa o facultad',
            'Please enter your program or faculty',
          ),
        );
        return false;
      }
      if (!_aceptaPolitica) {
        _mostrarError(
          AppStrings.tr(
            'Debes aceptar la Política de Tratamiento de Datos y confirmar que eres mayor de edad',
            'You must accept the Data Policy and confirm you are of legal age',
          ),
        );
        return false;
      }
    }
    return true;
  }

  /// Muestra un mensaje de error en SnackBar
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Trae el progreso, vocabulario y actividades reciente de la cuenta que
  /// acaba de iniciar sesión. Es necesario porque estos servicios ya
  /// intentaron sincronizar una vez al arrancar la app (antes de que
  /// hubiera sesión) y, si el navegador no tenía nada guardado localmente
  /// (incógnito, otro dispositivo), esa sincronización no tuvo uid con qué
  /// trabajar. Se ejecuta en paralelo con la pausa de UX ya existente, así
  /// que no agrega demora perceptible.
  Future<void> _sincronizarDatosDeCuenta() async {
    // Límite de tiempo: cada llamada a Firestore ya tiene su propio timeout
    // (auth_service.dart), pero este además garantiza que un problema de
    // red no deje al usuario atascado en la pantalla de login tras haber
    // iniciado sesión correctamente.
    await Future.wait([
      ProgresoService().initialize(),
      widget.vocabularioService.initialize(),
      ActividadService().initialize(),
    ]).timeout(const Duration(seconds: 10), onTimeout: () => []);
  }

  /// Envía el correo de restablecimiento de contraseña para el email que el
  /// usuario ya haya escrito en el campo de correo del formulario.
  Future<void> _olvideContrasena() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _mostrarError(
        AppStrings.tr(
          'Escribe tu correo arriba para poder enviarte el enlace',
          'Enter your email above so we can send you the link',
        ),
      );
      return;
    }

    final resultado = await _authService.enviarCorreoRecuperacion(
      email: email,
    );

    if (!mounted) return;
    if (resultado['success']) {
      _mostrarExito(
        AppStrings.tr(
          'Te enviamos un correo para restablecer tu contraseña',
          'We sent you an email to reset your password',
        ),
      );
    } else {
      _mostrarError(
        resultado['error'] ??
            AppStrings.tr(
              'No se pudo enviar el correo de recuperación',
              'Could not send the recovery email',
            ),
      );
    }
  }

  /// Muestra un mensaje de éxito
  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// PASO 1: El disparador de la UI
  /// Este método se activa cuando el usuario presiona el botón "Iniciar Sesión".
  Future<void> _iniciarSesion() async {
    // 1.1 Validación local: No enviamos datos si los campos están vacíos.
    if (!_validarFormulario()) return;

    setState(() => _cargando = true);

    // 1.2 LLAMADA AL SERVICIO: Salimos de la UI y entramos a la lógica de negocio.
    Map<String, dynamic> resultado = await _authService.iniciarSesion(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _cargando = false);

    // 1.3 RETORNO A LA UI: El servicio nos dice si tuvo éxito o no.
    if (resultado['success']) {
      _mostrarExito(
        AppStrings.tr(
          '¡Sesión iniciada correctamente!',
          'Signed in successfully!',
        ),
      );

      // 1.4 NAVEGACIÓN: Si el login fue exitoso, cambiamos de pantalla.
      // La sincronización corre en paralelo con la pausa de UX que ya
      // existía, así que no se percibe demora extra.
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 800)),
        _sincronizarDatosDeCuenta(),
      ]);
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } else {
      // Manejo de errores (Credenciales incorrectas, etc)
      _mostrarError(
        resultado['error'] ??
            AppStrings.tr('Error en inicio de sesión', 'Sign-in error'),
      );
    }
  }

  /// Realiza el registro de nuevo usuario
  Future<void> _registrar() async {
    if (!_validarFormulario()) return;

    setState(() => _cargando = true);

    Map<String, dynamic> resultado = await _authService.registrarUsuario(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombreCompleto: _nombreController.text.trim(),
      codigoEstudiante: _codigoController.text.trim(),
      facultadPrograma: _programaController.text.trim(),
    );

    setState(() => _cargando = false);

    if (resultado['success']) {
      _mostrarExito(
        AppStrings.tr(
          '¡Registro exitoso! Iniciando sesión automáticamente...',
          'Registration successful! Signing you in automatically...',
        ),
      );

      // Imprimir información de debug después de registrarse
      await _authService.imprimirDebug();

      // Iniciar sesión automáticamente después del registro
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Map<String, dynamic> resultadoLogin = await _authService.iniciarSesion(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (resultadoLogin['success'] && mounted) {
          await _sincronizarDatosDeCuenta();
        }
        if (resultadoLogin['success'] && mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacementNamed('/main');
        } else if (mounted) {
          _mostrarError(
            AppStrings.tr(
              'Registro completado, pero falla al iniciar sesión',
              'Registration completed, but sign-in failed',
            ),
          );
          setState(() => _esRegistro = false);
        }
      }
    } else {
      _mostrarError(
        resultado['error'] ?? AppStrings.tr('Error en registro', 'Registration error'),
      );
    }
  }

  void _onTogglePassword() =>
      setState(() => _obscurePassword = !_obscurePassword);

  void _onToggleAceptaPolitica() =>
      setState(() => _aceptaPolitica = !_aceptaPolitica);

  void _onToggleModo() {
    setState(() => _esRegistro = !_esRegistro);
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return LoginDesktopView(
        esRegistro: _esRegistro,
        cargando: _cargando,
        obscurePassword: _obscurePassword,
        aceptaPolitica: _aceptaPolitica,
        emailController: _emailController,
        passwordController: _passwordController,
        nombreController: _nombreController,
        codigoController: _codigoController,
        programaController: _programaController,
        onTogglePassword: _onTogglePassword,
        onToggleAceptaPolitica: _onToggleAceptaPolitica,
        onOlvideContrasena: _olvideContrasena,
        onIniciarSesion: _iniciarSesion,
        onRegistrar: _registrar,
        onToggleModo: _onToggleModo,
      );
    }
    return LoginMobileView(
      esRegistro: _esRegistro,
      cargando: _cargando,
      obscurePassword: _obscurePassword,
      aceptaPolitica: _aceptaPolitica,
      emailController: _emailController,
      passwordController: _passwordController,
      nombreController: _nombreController,
      codigoController: _codigoController,
      programaController: _programaController,
      onTogglePassword: _onTogglePassword,
      onToggleAceptaPolitica: _onToggleAceptaPolitica,
      onOlvideContrasena: _olvideContrasena,
      onIniciarSesion: _iniciarSesion,
      onRegistrar: _registrar,
      onToggleModo: _onToggleModo,
    );
  }


}
