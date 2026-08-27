import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/progreso_service.dart';
import '../../services/vocabulario_service.dart';
import '../../services/actividad_service.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import 'login/login_mobile_view.dart';

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

  // Colores del tema
  static const _creamColor = Color(0xFFF5E6D0);
  static const _hintColor = Color(0xFF9E8070);

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

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return _buildDesktopLayout(context);
    }
    return LoginMobileView(
      esRegistro: _esRegistro,
      cargando: _cargando,
      obscurePassword: _obscurePassword,
      emailController: _emailController,
      passwordController: _passwordController,
      nombreController: _nombreController,
      codigoController: _codigoController,
      programaController: _programaController,
      onTogglePassword: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      onOlvideContrasena: _olvideContrasena,
      onIniciarSesion: _iniciarSesion,
      onRegistrar: _registrar,
      onToggleModo: () {
        setState(() => _esRegistro = !_esRegistro);
        _passwordController.clear();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — panel dividido: sello a la izquierda,
  // formulario a la derecha. Reutiliza los mismos controladores, validaciones
  // y lógica de negocio que el layout móvil; solo cambia la composición visual.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamColor,
      body: Row(
        children: [
          // ── Panel izquierdo: identidad institucional ──────────────────
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/fondo.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Container(color: const Color(0xFF1A0000).withOpacity(0.35)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6B1010).withOpacity(0.55),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.55),
                                blurRadius: 60,
                                spreadRadius: 6,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.recortado.webp',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text(
                                  'UL',
                                  style: TextStyle(
                                    color: Color(0xFFD4A017),
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'UNIVERSIDAD LIBRE',
                          style: TextStyle(
                            color: _creamColor.withOpacity(0.80),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'UniEnglish',
                          style: TextStyle(
                            color: _creamColor,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.tr(
                            'Aprende inglés de manera efectiva',
                            'Learn English effectively',
                          ),
                          style: TextStyle(
                            color: _creamColor.withOpacity(0.70),
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 3,
                              color: const Color(0xFFD4A017),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 10,
                              height: 3,
                              color: const Color(0xFFD4A017).withOpacity(0.6),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 10,
                              height: 3,
                              color: const Color(0xFFD4A017).withOpacity(0.3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Panel derecho: formulario ──────────────────────────────────
          Expanded(
            flex: 2,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.tr('BIENVENIDO', 'WELCOME'),
                        style: TextStyle(
                          color: const Color(0xFF8B6914),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _esRegistro
                            ? AppStrings.tr('Crear cuenta', 'Create account')
                            : AppStrings.tr('Iniciar sesión', 'Sign in'),
                        style: const TextStyle(
                          color: Color(0xFF3A0A0A),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _esRegistro
                            ? AppStrings.tr(
                                'Completa tus datos para comenzar',
                                'Complete your details to get started',
                              )
                            : AppStrings.tr(
                                'Ingresa tus credenciales para continuar',
                                'Enter your credentials to continue',
                              ),
                        style: TextStyle(
                          color: Colors.brown[300],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (_esRegistro) ...[
                        _desktopField(
                          label: AppStrings.tr(
                            'Nombre completo',
                            'Full name',
                          ),
                          ctrl: _nombreController,
                          hint: AppStrings.tr(
                            'Nombre y apellidos',
                            'First and last name',
                          ),
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                      ],

                      _desktopField(
                        label: AppStrings.tr(
                          'Correo electrónico',
                          'Email address',
                        ),
                        ctrl: _emailController,
                        hint: 'nombre@unilibre.edu.co',
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _desktopField(
                        label: AppStrings.tr('Contraseña', 'Password'),
                        ctrl: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffix: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _hintColor,
                            size: 19,
                          ),
                        ),
                      ),

                      if (_esRegistro) ...[
                        const SizedBox(height: 16),
                        _desktopField(
                          label: AppStrings.tr(
                            'Código estudiantil (opcional)',
                            'Student ID (optional)',
                          ),
                          ctrl: _codigoController,
                          hint: AppStrings.tr(
                            'Código estudiantil',
                            'Student ID',
                          ),
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _desktopField(
                          label: AppStrings.tr(
                            'Programa o Facultad',
                            'Program or Faculty',
                          ),
                          ctrl: _programaController,
                          hint: AppStrings.tr(
                            'Programa o Facultad',
                            'Program or Faculty',
                          ),
                          icon: Icons.school_outlined,
                        ),
                      ],

                      if (!_esRegistro) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _olvideContrasena,
                            child: Text(
                              AppStrings.tr(
                                '¿Olvidaste tu contraseña?',
                                'Forgot your password?',
                              ),
                              style: const TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _cargando
                              ? null
                              : (_esRegistro ? _registrar : _iniciarSesion),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _esRegistro
                                      ? AppStrings.tr('Registrarse', 'Sign up')
                                      : AppStrings.tr(
                                          'Iniciar sesión',
                                          'Sign in',
                                        ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _cargando
                              ? null
                              : () {
                                  setState(() => _esRegistro = !_esRegistro);
                                  _passwordController.clear();
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3A0A0A),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _esRegistro
                                ? AppStrings.tr(
                                    '¿Ya tienes cuenta? Inicia sesión',
                                    'Already have an account? Sign in',
                                  )
                                : AppStrings.tr(
                                    '¿No tienes cuenta? Regístrate',
                                    "Don't have an account? Sign up",
                                  ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          '© Universidad Libre · Colombia',
                          style: TextStyle(
                            color: Colors.brown[200],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Campo con etiqueta encima, usado únicamente en el layout de escritorio.
  Widget _desktopField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3A0A0A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, color: _hintColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  obscureText: obscure,
                  keyboardType: inputType,
                  style: const TextStyle(
                    color: Color(0xFF3A0A0A),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (suffix != null) ...[suffix, const SizedBox(width: 14)],
            ],
          ),
        ),
      ],
    );
  }

}
