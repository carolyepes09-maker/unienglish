import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../utils/app_strings.dart';
import '../politica_privacidad_screen.dart';
import '../../utils/app_colors.dart';

/// =============================================================================
/// WIDGET: lib/ui/pages/login/login_desktop_view.dart
/// =============================================================================
/// Layout de escritorio de LoginScreen, extraído tal cual (sin cambiar
/// ninguna propiedad visual) desde login_screen.dart para reducir el tamaño
/// de ese archivo. Toda la lógica de negocio se queda en LoginScreen; este
/// widget solo recibe el estado ya resuelto y notifica intenciones del
/// usuario por callback.
/// =============================================================================

const _creamColor = Color(0xFFF5E6D0);
const _hintColor = Color(0xFF9E8070);

class LoginDesktopView extends StatelessWidget {
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

  const LoginDesktopView({
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Row(
        children: [
          // ── Panel izquierdo: identidad institucional ──────────────────
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/fondo.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                Container(color: const Color(0xFF1A0000).withValues(alpha: 0.35)),
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
                            color: const Color(0xFF6B1010).withValues(alpha: 0.55),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.55),
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
                              errorBuilder: (_, _, _) => const Center(
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
                            color: _creamColor.withValues(alpha: 0.80),
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
                            color: _creamColor.withValues(alpha: 0.70),
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
                              color: const Color(0xFFD4A017).withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 10,
                              height: 3,
                              color: const Color(0xFFD4A017).withValues(alpha: 0.3),
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
                        esRegistro
                            ? AppStrings.tr('Crear cuenta', 'Create account')
                            : AppStrings.tr('Iniciar sesión', 'Sign in'),
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        esRegistro
                            ? AppStrings.tr(
                                'Completa tus datos para comenzar',
                                'Complete your details to get started',
                              )
                            : AppStrings.tr(
                                'Ingresa tus credenciales para continuar',
                                'Enter your credentials to continue',
                              ),
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (esRegistro) ...[
                        _desktopField(
                          context: context,
                          label: AppStrings.tr(
                            'Nombre completo',
                            'Full name',
                          ),
                          ctrl: nombreController,
                          hint: AppStrings.tr(
                            'Nombre y apellidos',
                            'First and last name',
                          ),
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                      ],

                      _desktopField(
                        context: context,
                        label: AppStrings.tr(
                          'Correo electrónico',
                          'Email address',
                        ),
                        ctrl: emailController,
                        hint: 'nombre@unilibre.edu.co',
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _desktopField(
                        context: context,
                        label: AppStrings.tr('Contraseña', 'Password'),
                        ctrl: passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: obscurePassword,
                        suffix: GestureDetector(
                          onTap: onTogglePassword,
                          child: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _hintColor,
                            size: 19,
                          ),
                        ),
                      ),

                      if (esRegistro) ...[
                        const SizedBox(height: 16),
                        _desktopField(
                          context: context,
                          label: AppStrings.tr(
                            'Código estudiantil (opcional)',
                            'Student ID (optional)',
                          ),
                          ctrl: codigoController,
                          hint: AppStrings.tr(
                            'Código estudiantil',
                            'Student ID',
                          ),
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _desktopField(
                          context: context,
                          label: AppStrings.tr(
                            'Programa o Facultad',
                            'Program or Faculty',
                          ),
                          ctrl: programaController,
                          hint: AppStrings.tr(
                            'Programa o Facultad',
                            'Program or Faculty',
                          ),
                          icon: Icons.school_outlined,
                        ),
                      ],

                      if (!esRegistro) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: onOlvideContrasena,
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

                      // ── CHECKBOX — Aceptación de política de datos ──────
                      if (esRegistro) ...[
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: aceptaPolitica,
                                onChanged: (_) => onToggleAceptaPolitica(),
                                activeColor: const Color(0xFFB71C1C),
                                side: BorderSide(
                                  color: AppColors.cardBorder(context),
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
                                      color: AppColors.textSecondary(context),
                                      fontSize: 13,
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
                                        style: TextStyle(
                                          color: AppColors.textPrimary(context),
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
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: cargando || (esRegistro && !aceptaPolitica)
                              ? null
                              : (esRegistro ? onRegistrar : onIniciarSesion),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: cargando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  esRegistro
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
                          onPressed: cargando ? null : onToggleModo,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary(context),
                            backgroundColor: AppColors.card(context),
                            side: BorderSide(color: AppColors.cardBorder(context)),
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
                            color: AppColors.textSecondary(context),
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
    required BuildContext context,
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
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder(context)),
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
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: AppColors.textSecondary(context), fontSize: 14),
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
