import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_strings.dart';
import '../../../services/auth_service.dart';
import '../../../services/vocabulario_service.dart';
import '../../../services/progreso_service.dart';
import '../../../services/actividad_service.dart';
import '../vocabulario_screen.dart';
import 'home_widgets.dart';

/// =============================================================================
/// WIDGET: lib/ui/pages/home/home_desktop_body.dart
/// =============================================================================
/// Layout de escritorio de HomeScreen, extraído tal cual (sin cambiar
/// ninguna propiedad visual) desde home_screen.dart para reducir el tamaño
/// de ese archivo. HomeScreen sigue siendo el dueño del GifController y del
/// ProgresoService; este widget solo recibe esas instancias ya creadas.
/// =============================================================================

const Color _kGoldAccent = Color(0xFF8B6914);
const Color _kTextDark = Color(0xFF1A0000);
const Color _kDesktopCream = Color(0xFFF7EEE0);

class HomeDesktopBody extends StatelessWidget {
  final AuthService authService;
  final VocabularioService vocabularioService;
  final Function(int)? onNavigate;
  final GifController fireController;
  final ProgresoService progresoService;

  const HomeDesktopBody({
    super.key,
    required this.authService,
    required this.vocabularioService,
    required this.onNavigate,
    required this.fireController,
    required this.progresoService,
  });

  @override
  Widget build(BuildContext context) {
    final actividadesRecientes = actividadService.obtenerActividades();
    final nombre =
        authService.usuarioActual?['nombre_completo'] ??
        AppStrings.tr('Usuario', 'User');

    return Scaffold(
      backgroundColor: _kDesktopCream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Encabezado: saludo + racha + progreso ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6B1010), Color(0xFF3A0A0A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tr('Hola,', 'Hi,'),
                              style: AppFonts.poppins(
                                color: const Color(0xAAF5E6D0),
                                fontSize: 15,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  nombre,
                                  style: AppFonts.poppins(
                                    color: const Color(0xFFF5E6D0),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('👋', style: TextStyle(fontSize: 22)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Gif(
                                image: const AssetImage(
                                  'assets/images/Fire.gif',
                                ),
                                controller: fireController,
                                autostart: Autostart.loop,
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.tr(
                                  '${progresoService.rachaDias} días',
                                  '${progresoService.rachaDias} days',
                                ),
                                style: AppFonts.poppins(
                                  color: const Color(0xFFF5E6D0),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.tr(
                            'Progreso hacia ${progresoService.siguienteNivel}',
                            'Progress towards ${progresoService.siguienteNivel}',
                          ),
                          style: AppFonts.poppins(
                            color: const Color(0xAAF5E6D0),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(progresoService.progresoHaciaSiguienteNivel * 100).toInt()}%',
                          style: AppFonts.poppins(
                            color: const Color(0xFFF5E6D0),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progresoService.progresoHaciaSiguienteNivel,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _kGoldAccent,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Acceso rápido ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.tr('Acceso rápido', 'Quick access'),
                    style: AppFonts.poppins(
                      color: _kTextDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.tr('4 secciones', '4 sections'),
                    style: AppFonts.poppins(
                      color: Colors.brown[300],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigate?.call(1),
                      child: _desktopQuickAccessCard(
                        icon: Icons.menu_book,
                        label: AppStrings.tr('Lecciones', 'Lessons'),
                        subtitle: AppStrings.tr(
                          'Continúa tu aprendizaje',
                          'Continue your learning',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigate?.call(2),
                      child: _desktopQuickAccessCard(
                        icon: Icons.timer,
                        label: AppStrings.tr('Simulacros', 'Mock Exams'),
                        subtitle: AppStrings.tr(
                          'Pon a prueba tu nivel',
                          'Test your level',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VocabularioScreen(
                            vocabularioService: vocabularioService,
                          ),
                        ),
                      ),
                      child: _desktopQuickAccessCard(
                        icon: Icons.text_fields,
                        label: AppStrings.tr('Vocabulario', 'Vocabulary'),
                        subtitle: AppStrings.tr(
                          'Amplía tu léxico',
                          'Expand your vocabulary',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigate?.call(3),
                      child: _desktopQuickAccessCard(
                        icon: Icons.trending_up,
                        label: AppStrings.tr('Mi Progreso', 'My Progress'),
                        subtitle: AppStrings.tr(
                          'Revisa tus estadísticas',
                          'Check your stats',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Actividad reciente ──────────────────────────────────────
              Text(
                AppStrings.tr('Actividad reciente', 'Recent activity'),
                style: AppFonts.poppins(
                  color: _kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (actividadesRecientes.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _kDesktopCream,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.brown[300],
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.tr(
                          'No has completado ninguna actividad todavía',
                          'You haven\'t completed any activity yet',
                        ),
                        style: AppFonts.poppins(
                          color: _kTextDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.tr(
                          'Empieza una lección para ver tu progreso aquí.',
                          'Start a lesson to see your progress here.',
                        ),
                        style: AppFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...actividadesRecientes.map((act) {
                  final bool esPerfecto = act['esPerfecto'] ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: activityTile(
                      icon: esPerfecto ? Icons.check_circle : Icons.play_circle,
                      iconColor: esPerfecto
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      title: act['titulo'] ?? AppStrings.tr('Actividad', 'Activity'),
                      subtitle: act['subtitulo'] ?? AppStrings.tr('Progreso', 'Progress'),
                      percentage: act['porcentaje'] ?? '0%',
                    ),
                  );
                }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopQuickAccessCard({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B1010), Color(0xFF3A0A0A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: AppFonts.poppins(
              color: const Color(0xFFF5E6D0),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppFonts.poppins(
              color: const Color(0xAAF5E6D0),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
