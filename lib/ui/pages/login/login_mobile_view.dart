import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../utils/app_strings.dart';
import '../politica_privacidad_screen.dart';

/// =============================================================================
/// WIDGET: lib/ui/pages/login/login_mobile_view.dart
/// =============================================================================
/// Layout de teléfono de LoginScreen, extraído tal cual (sin cambiar ninguna
/// propiedad visual) desde login_screen.dart para reducir el tamaño de ese
/// archivo. Toda la lógica de negocio (validación, llamadas a AuthService,
/// etc.) se queda en LoginScreen; este widget solo recibe el estado ya
/// resuelto y notifica intenciones del usuario por callback.
/// =============================================================================

const _creamColor = Color(0xFFF5E6D0);
const _hintColor = Color(0xFF9E8070);

class LoginMobileView extends StatelessWidget {
  final bool esRegistro;
  final bool cargando;
  final bool obscurePassword;
  final bool aceptaPolitica;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nombreController;
  final TextEditingController codigoController;
  final TextEditingController programaController;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleAceptaPolitica;
  final VoidCallback onOlvideContrasena;
  final VoidCallback onIniciarSesion;
  final VoidCallback onRegistrar;
  final VoidCallback onToggleModo;

  const LoginMobileView({
    super.key,
    required this.esRegistro,
    required this.cargando,
    required this.obscurePassword,
    required this.aceptaPolitica,
    required this.emailController,
    required this.passwordController,
    required this.nombreController,
    required this.codigoController,
    required this.programaController,
    required this.onTogglePassword,
    required this.onToggleAceptaPolitica,
    required this.onOlvideContrasena,
    required this.onIniciarSesion,
    required this.onRegistrar,
    required this.onToggleModo,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Tamaños responsivos con clamp
    final sealSize = (w * 0.78).clamp(220.0, 280.0);
    final bool isMobile = w < 600; // detecta móvil vs desktop
    final horizontalPadding = (w * 0.07).clamp(20.0, 40.0);
    final subtitleSize = (w * 0.028).clamp(10.0, 13.0);
    final titleSize = (w * 0.110).clamp(34.0, 54.0);
    final sloganSize = (w * 0.034).clamp(12.0, 16.0);
    final linkSize = (w * 0.032).clamp(11.0, 15.0);
    final footerSize = (w * 0.026).clamp(10.0, 13.0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A0000), // fondo base oscuro
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ─────────────────────────────────────────────────────────────────
          // CAPA 1 — Imagen de fondo FUERA del SafeArea (cubre TODO)
          // ─────────────────────────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // CAPA 2 — Contenido (SafeArea solo protege el contenido)
          // ─────────────────────────────────────────────────────────────────
          SafeArea(
            top: false, // permite que el sello desborde por arriba
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 390,
                ), // ancho iPhone
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: bottomPadding + 20, // padding dinámico
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: h * 0.000),

                      // ─────────────────────────────────────────────────────────
                      // SELLO — imagen circular con sombra dramática (desborda arriba)
                      // ─────────────────────────────────────────────────────────
                      Transform.translate(
                        offset: Offset(
                          0,
                          isMobile ? -sealSize * 0.06 : 0,
                        ), // solo desborda en móvil
                        child: Container(
                          width: sealSize,
                          height: sealSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.80),
                                blurRadius: 60,
                                spreadRadius: 10,
                                offset: const Offset(0, 16),
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFF880000,
                                ).withValues(alpha: 0.40),
                                blurRadius: 80,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.recortado.webp',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF4A3000),
                                child: const Center(
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
                        ),
                      ),

                      SizedBox(height: h * 0.010),

                      // ─────────────────────────────────────────────────────────
                      // SUBTÍTULO
                      // ─────────────────────────────────────────────────────────
                      Text(
                        'UNIVERSIDAD LIBRE',
                        style: TextStyle(
                          color: _creamColor.withValues(alpha: 0.80),
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 3.2,
                        ),
                      ),

                      SizedBox(height: h * 0.006),

                      // ─────────────────────────────────────────────────────────
                      // TÍTULO
                      // ─────────────────────────────────────────────────────────
                      Text(
                        'UniEnglish',
                        style: TextStyle(
                          color: _creamColor,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: h * 0.01),

                      // ─────────────────────────────────────────────────────────
                      // SLOGAN
                      // ─────────────────────────────────────────────────────────
                      Text(
                        esRegistro
                            ? AppStrings.tr(
                                'Crea tu cuenta para empezar',
                                'Create your account to get started',
                              )
                            : AppStrings.tr(
                                'Aprende inglés de manera efectiva',
                                'Learn English effectively',
                              ),
                        style: TextStyle(
                          color: _creamColor.withValues(alpha: 0.67),
                          fontSize: sloganSize,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: h * 0.032),

                      // ─────────────────────────────────────────────────────────
                      // CAMPOS — Email + Contraseña + Campos de Registro
                      // ─────────────────────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B2020).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _creamColor.withValues(alpha: 0.20),
                            width: 1.0,
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3],
                          ),
                        ),
                        child: Column(
                          children: [
                            // Campo nombre (solo en registro)
                            if (esRegistro) ...[
                              _fieldRow(
                                ctrl: nombreController,
                                hint: AppStrings.tr(
                                  'Nombre completo',
                                  'Full name',
                                ),
                                icon: Icons.person_outline,
                              ),
                              Divider(
                                color: _creamColor.withValues(alpha: 0.13),
                                height: 1,
                                thickness: 1,
                              ),
                            ],

                            // Campo email
                            _fieldRow(
                              ctrl: emailController,
                              hint: AppStrings.tr(
                                'Correo electrónico',
                                'Email address',
                              ),
                              icon: Icons.email_outlined,
                              inputType: TextInputType.emailAddress,
                            ),
                            Divider(
                              color: _creamColor.withValues(alpha: 0.13),
                              height: 1,
                              thickness: 1,
                            ),

                            // Campo contraseña
                            _fieldRow(
                              ctrl: passwordController,
                              hint: AppStrings.tr('Contraseña', 'Password'),
                              icon: Icons.lock_outline_rounded,
                              obscure: obscurePassword,
                              suffix: GestureDetector(
                                onTap: onTogglePassword,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _hintColor,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),

                            // Campo código estudiantil (solo en registro)
                            if (esRegistro) ...[
                              Divider(
                                color: _creamColor.withValues(alpha: 0.13),
                                height: 1,
                                thickness: 1,
                              ),
                              _fieldRow(
                                ctrl: codigoController,
                                hint: AppStrings.tr(
                                  'Código estudiantil (opcional)',
                                  'Student ID (optional)',
                                ),
                                icon: Icons.badge_outlined,
                              ),
                              Divider(
                                color: _creamColor.withValues(alpha: 0.13),
                                height: 1,
                                thickness: 1,
                              ),
                              _fieldRow(
                                ctrl: programaController,
                                hint: AppStrings.tr(
                                  'Programa o Facultad',
                                  'Program or Faculty',
                                ),
                                icon: Icons.school_outlined,
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.014),

                      // ─────────────────────────────────────────────────────────
                      // CHECKBOX — Aceptación de política de datos (solo en
                      // registro; el botón primario queda bloqueado hasta que
                      // se marque, ver LoginScreen._validarFormulario).
                      // ─────────────────────────────────────────────────────────
                      if (esRegistro)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: aceptaPolitica,
                                onChanged: (_) => onToggleAceptaPolitica(),
                                activeColor: const Color(0xFFCC0000),
                                side: BorderSide(
                                  color: _creamColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: onToggleAceptaPolitica,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: _creamColor.withValues(alpha: 0.75),
                                      fontSize: linkSize,
                                      height: 1.3,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: AppStrings.tr(
                                          'Confirmo que soy mayor de edad y he leído y acepto la ',
                                          'I confirm I am of legal age and I have read and accept the ',
                                        ),
                                      ),
                                      TextSpan(
                                        text: AppStrings.tr(
                                          'Política de Tratamiento de Datos y los Términos de Uso',
                                          'Data Policy and Terms of Use',
                                        ),
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const PoliticaPrivacidadScreen(),
                                              ),
                                            );
                                          },
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      // ─────────────────────────────────────────────────────────
                      // LINK — ¿Olvidaste tu contraseña? (solo en login)
                      // ─────────────────────────────────────────────────────────
                      if (!esRegistro)
                        GestureDetector(
                          onTap: onOlvideContrasena,
                          child: Text(
                            AppStrings.tr(
                              '¿Olvidaste tu contraseña?',
                              'Forgot your password?',
                            ),
                            style: TextStyle(
                              color: _creamColor.withValues(alpha: 0.80),
                              fontSize: linkSize,
                            ),
                          ),
                        ),

                      if (esRegistro) SizedBox(height: h * 0.014),

                      SizedBox(height: h * 0.022),

                      // ─────────────────────────────────────────────────────
                      // BOTÓN PRIMARIO
                      // ─────────────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: cargando || (esRegistro && !aceptaPolitica)
                              ? null
                              : (esRegistro ? onRegistrar : onIniciarSesion),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: Colors.grey[600],
                          ),
                          child: cargando
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: _creamColor,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFCC0000),
                                        Color(0xFFEE2222),
                                        Color(0xFFAA0000),
                                      ],
                                      stops: [0.0, 0.45, 1.0],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: const Border(
                                      top: BorderSide(
                                        color: Color(0x55FF6666),
                                        width: 1.0,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.40),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox.expand(
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFFFFF0E0),
                                                Color(0xFFD4A882),
                                              ],
                                            ).createShader(bounds),
                                        child: Text(
                                          esRegistro
                                              ? AppStrings.tr(
                                                  'Registrarse',
                                                  'Sign up',
                                                )
                                              : AppStrings.tr(
                                                  'Iniciar sesión',
                                                  'Sign in',
                                                ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: (w * 0.04).clamp(
                                              14.0,
                                              18.0,
                                            ),
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.black45,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: h * 0.010),

                      // ─────────────────────────────────────────────────────────
                      // BOTÓN SECUNDARIO
                      // ─────────────────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: cargando ? null : onToggleModo,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _creamColor,
                            disabledForegroundColor: Colors.grey[500],
                            side: BorderSide(
                              color: _creamColor.withValues(alpha: 0.28),
                              width: 1.2,
                            ),
                            backgroundColor: Colors.black.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            esRegistro
                                ? AppStrings.tr(
                                    '¿Ya tienes cuenta? Inicia sesión',
                                    'Already have an account? Sign in',
                                  )
                                : AppStrings.tr(
                                    '¿No tienes cuenta? Regístrate',
                                    "Don't have an account? Sign up",
                                  ),
                            style: TextStyle(
                              fontSize: (w * 0.032).clamp(11.0, 15.0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.040),

                      // ─────────────────────────────────────────────────────────
                      // FOOTER
                      // ─────────────────────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.copyright,
                            color: _creamColor.withValues(alpha: 0.40),
                            size: footerSize,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Universidad Libre  ·  Colombia',
                            style: TextStyle(
                              color: _creamColor.withValues(alpha: 0.40),
                              fontSize: footerSize,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: h * 0.030),
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

  // ── Helper: fila de campo para el container unificado ────────────────────
  Widget _fieldRow({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: 44,
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
              style: const TextStyle(color: Color(0xFFE8D5B8), fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _hintColor, fontSize: 15),
                border: InputBorder.none,
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
              ),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }
}
