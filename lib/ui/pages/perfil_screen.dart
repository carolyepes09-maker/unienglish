import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import 'package:gif/gif.dart';
import '../../services/auth_service.dart';
import '../../services/progreso_service.dart';
import '../../services/vocabulario_service.dart';
import '../../services/actividad_service.dart';
import '../../services/idioma_service.dart';
import '../../services/tema_service.dart';
import '../utils/app_colors.dart';
import 'politica_privacidad_screen.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kGoldAccent = Color(0xFF8B6914);
const Color kTextDark = Color(0xFF1A0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);

/// =============================================================================
/// 👤 PANTALLA: lib/ui/pages/perfil_screen.dart
/// =============================================================================
/// Visualiza la identidad y los logros detallados del estudiante.
///
/// FUNCIONALIDADES:
/// 1. Información Académica: Muestra nombre, código y facultad del usuario.
/// 2. Estadísticas de "Gaming": Presenta la racha de días, horas de estudio y
///    lecciones completadas.
/// 3. Radar de Habilidades: Gráfico circular que muestra el dominio en
///    las 5 áreas del lenguaje.
/// =============================================================================

class PerfilScreen extends StatefulWidget {
  final AuthService authService;
  final VocabularioService vocabularioService;
  final VoidCallback? onBack;

  const PerfilScreen({
    super.key,
    required this.authService,
    required this.vocabularioService,
    this.onBack,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin, IdiomaListenerMixin<PerfilScreen> {
  late GifController _fireController;
  final ProgresoService _progresoService = ProgresoService();
  final IdiomaService _idiomaService = IdiomaService();
  // No necesita listener propio: al cambiar el tema, MaterialApp (main.dart)
  // reconstruye con un nuevo Theme, y Theme.of(context) (usado por
  // AppColors) se redibuja solo vía InheritedWidget — a diferencia del
  // idioma, que sí usa un campo estático sin ese mecanismo automático.
  final TemaService _temaService = TemaService();

  @override
  void initState() {
    super.initState();
    _fireController = GifController(vsync: this);
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  /// Obtiene las iniciales del nombre completo
  String _obtenerIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    } else if (partes.isNotEmpty) {
      return partes[0][0].toUpperCase();
    }
    return '';
  }

  /// Pide confirmación + contraseña (Firebase exige sesión reciente para
  /// borrar la cuenta) y, si todo sale bien, elimina la cuenta por completo.
  void _confirmarEliminarCuenta() {
    final passwordController = TextEditingController();
    bool cargando = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            AppStrings.tr('Eliminar cuenta', 'Delete account'),
            style: const TextStyle(color: kPrimaryRed),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kPrimaryRed.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: kPrimaryRed,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.tr(
                          'Esta acción borra tu cuenta y todos tus datos de forma permanente. No se puede deshacer.',
                          'This permanently deletes your account and all your data. This cannot be undone.',
                        ),
                        style: const TextStyle(
                          color: kPrimaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.tr(
                  'Escribe tu contraseña para confirmar:',
                  'Enter your password to confirm:',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(dialogContext),
              child: Text(AppStrings.tr('Cancelar', 'Cancel')),
            ),
            TextButton(
              onPressed: cargando
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) {
                        setDialogState(
                          () => error = AppStrings.tr(
                            'Ingresa tu contraseña',
                            'Enter your password',
                          ),
                        );
                        return;
                      }
                      setDialogState(() {
                        cargando = true;
                        error = null;
                      });
                      final resultado = await widget.authService
                          .eliminarCuenta(password: passwordController.text);
                      if (resultado['success'] == true) {
                        // Misma limpieza de caché local que al cerrar
                        // sesión: sin esto, el siguiente que use este
                        // navegador vería por un instante los datos de
                        // esta cuenta ya eliminada durante la precarga.
                        await Future.wait([
                          _progresoService.limpiarCacheLocal(),
                          widget.vocabularioService.limpiarCacheLocal(),
                          ActividadService().limpiarCacheLocal(),
                        ]);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      } else {
                        setDialogState(() {
                          cargando = false;
                          error =
                              resultado['error'] ??
                              AppStrings.tr(
                                'Error al eliminar la cuenta',
                                'Error deleting account',
                              );
                        });
                      }
                    },
              child: cargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      AppStrings.tr('Eliminar', 'Delete'),
                      style: const TextStyle(color: kPrimaryRed),
                    ),
            ),
          ],
        ),
      ),
    ).then((_) => passwordController.dispose());
  }

  /// Abre el selector de idioma de interfaz y aplica el cambio de inmediato.
  void _mostrarSelectorIdioma() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.tr(
                      'Idioma de interfaz',
                      'Interface language',
                    ),
                    style: AppFonts.poppins(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _opcionIdioma(
                label: 'Español',
                seleccionado: _idiomaService.idioma == AppIdioma.es,
                onTap: () {
                  _idiomaService.cambiarIdioma(AppIdioma.es);
                  Navigator.pop(sheetContext);
                },
              ),
              _opcionIdioma(
                label: 'English',
                seleccionado: _idiomaService.idioma == AppIdioma.en,
                onTap: () {
                  _idiomaService.cambiarIdioma(AppIdioma.en);
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _opcionIdioma({
    required String label,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppFonts.poppins(
                  color: AppColors.textPrimary(context),
                  fontSize: 15,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle, color: kPrimaryRed, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.authService.usuarioActual;
    final programa = usuario?['facultad_programa'] ?? '';
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ══════════════════════════════════════════════════════════════
            // HEADER — textura roja con avatar, nombre, nivel
            // ══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  // Textura roja
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/bg_perfil.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  // Capa oscura
                  Positioned.fill(
                    child: Container(color: Colors.black.withValues(alpha: 0.60)),
                  ),
                  // Contenido
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          // Botón back
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: kCream,
                                ),
                                onPressed: () {
                                  if (widget.onBack != null) {
                                    widget.onBack!();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ),

                          // Avatar con textura interna
                          Container(
                            width: 96,
                            height: 96,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 3,
                              ),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/fondo.webp'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.20),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    _obtenerIniciales(
                                      usuario?['nombre_completo'] ?? '',
                                    ),
                                    style: AppFonts.poppins(
                                      color: kCream,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Nombre
                          const SizedBox(height: 12),
                          Text(
                            usuario?['nombre_completo'] ?? 'Usuario',
                            style: AppFonts.poppins(
                              color: kCream,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Código
                          Text(
                            AppStrings.tr(
                              'Código: ${widget.authService.usuarioActual?['codigo_estudiante'] ?? 'N/A'}',
                              'Code: ${widget.authService.usuarioActual?['codigo_estudiante'] ?? 'N/A'}',
                            ),
                            style: AppFonts.poppins(
                              color: kCreamMuted,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Badge nivel
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kGoldAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              usuario?['nivel_actual'] ?? 'A1',
                              style: AppFonts.poppins(
                                color: kCream,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Programa
                          if (programa.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: kCreamMuted,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  programa,
                                  style: AppFonts.poppins(
                                    color: kCreamMuted,
                                    fontSize: 12,
                                  ),
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

            const SizedBox(height: 20),

            // ══════════════════════════════════════════════════════════════
            // STATS ROW — con textura
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/fondo.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withValues(alpha: 0.42)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem(
                            iconWidget: Gif(
                              image: const AssetImage('assets/images/Fire.gif'),
                              controller: _fireController,
                              autostart: Autostart.loop,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                            value: AppStrings.tr(
                              '${_progresoService.rachaDias} días',
                              '${_progresoService.rachaDias} days',
                            ),
                            label: AppStrings.tr('Racha', 'Streak'),
                            iconColor: kGoldAccent,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _statItem(
                            iconWidget: const Icon(
                              Icons.menu_book,
                              color: kCream,
                              size: 22,
                            ),
                            value: _progresoService.leccionesCompletadas
                                .toString(),
                            label: AppStrings.tr('Lecciones', 'Lessons'),
                            iconColor: kCream,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _statItem(
                            iconWidget: const Icon(
                              Icons.timer,
                              color: kCream,
                              size: 22,
                            ),
                            value: _progresoService.examenesRealizados
                                .toString(),
                            label: AppStrings.tr('Exámenes', 'Exams'),
                            iconColor: kCream,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════
            // CONFIGURACIÓN — fondo blanco limpio
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.tr('Configuración', 'Settings'),
                  style: AppFonts.poppins(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder(context), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _settingsItem(
                      icon: Icons.notifications_outlined,
                      label: AppStrings.tr(
                        'Notificaciones',
                        'Notifications',
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.iconMuted(context),
                        size: 20,
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider(context)),
                    _settingsItem(
                      icon: Icons.dark_mode_outlined,
                      label: AppStrings.tr('Modo oscuro', 'Dark mode'),
                      trailing: Switch(
                        value: _temaService.tema == AppTema.oscuro,
                        activeThumbColor: kPrimaryRed,
                        onChanged: (activo) => _temaService.cambiarTema(
                          activo ? AppTema.oscuro : AppTema.claro,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider(context)),
                    _settingsItem(
                      icon: Icons.language,
                      label: AppStrings.tr(
                        'Idioma de interfaz',
                        'Interface language',
                      ),
                      onTap: _mostrarSelectorIdioma,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _idiomaService.idioma == AppIdioma.en
                                ? 'English'
                                : 'Español',
                            style: AppFonts.poppins(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.iconMuted(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider(context)),
                    _settingsItem(
                      icon: Icons.privacy_tip_outlined,
                      label: AppStrings.tr(
                        'Privacidad y términos',
                        'Privacy & terms',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PoliticaPrivacidadScreen(),
                          ),
                        );
                      },
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.iconMuted(context),
                        size: 20,
                      ),
                    ),
                    Divider(height: 1, color: AppColors.divider(context)),
                    _settingsItem(
                      icon: Icons.logout,
                      label: AppStrings.tr('Cerrar sesión', 'Log out'),
                      iconColor: kPrimaryRed,
                      labelColor: kPrimaryRed,
                      onTap: () async {
                        // Mostrar confirmación
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              AppStrings.tr('Cerrar sesión', 'Log out'),
                            ),
                            content: Text(
                              AppStrings.tr(
                                '¿Estás seguro de que deseas cerrar sesión?',
                                'Are you sure you want to log out?',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppStrings.tr('Cancelar', 'Cancel'),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await widget.authService.cerrarSesion();
                                  // Limpia la caché local de las 3 fuentes
                                  // de datos: sin esto, si otra persona usa
                                  // este mismo navegador/dispositivo y
                                  // inicia sesión con su propia cuenta,
                                  // vería por un instante el progreso,
                                  // vocabulario y actividad de esta cuenta
                                  // durante la precarga local del arranque.
                                  await Future.wait([
                                    _progresoService.limpiarCacheLocal(),
                                    widget.vocabularioService.limpiarCacheLocal(),
                                    ActividadService().limpiarCacheLocal(),
                                  ]);
                                  // AuthWrapper redirigirá automáticamente a LoginScreen
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/',
                                    );
                                  }
                                },
                                child: Text(
                                  AppStrings.tr('Cerrar sesión', 'Log out'),
                                  style: const TextStyle(color: kPrimaryRed),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: AppColors.divider(context)),
                    _settingsItem(
                      icon: Icons.delete_forever,
                      label: AppStrings.tr('Eliminar cuenta', 'Delete account'),
                      iconColor: kPrimaryRed,
                      labelColor: kPrimaryRed,
                      onTap: _confirmarEliminarCuenta,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: AppColors.textSecondary(context),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Universidad Libre',
                    style: AppFonts.poppins(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stat item ─────────────────────────────────────────────────────────────
  Widget _statItem({
    required Widget iconWidget,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        iconWidget,
        const SizedBox(height: 6),
        Text(
          value,
          style: AppFonts.poppins(
            color: kCream,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppFonts.poppins(color: kCreamMuted, fontSize: 11),
        ),
      ],
    );
  }

  // ── Settings item ─────────────────────────────────────────────────────────
  Widget _settingsItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    Color? iconColor,
    Color? labelColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.iconMuted(context), size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppFonts.poppins(
                  color: labelColor ?? AppColors.textPrimary(context),
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
