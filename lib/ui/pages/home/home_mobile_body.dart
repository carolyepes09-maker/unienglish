import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/vocabulario_service.dart';
import '../../../services/progreso_service.dart';
import '../../../services/actividad_service.dart';
import '../vocabulario_screen.dart';
import 'home_widgets.dart';

/// =============================================================================
/// WIDGET: lib/ui/pages/home/home_mobile_body.dart
/// =============================================================================
/// Layout de teléfono de HomeScreen, extraído tal cual (sin cambiar ninguna
/// propiedad visual) desde home_screen.dart para reducir el tamaño de ese
/// archivo. HomeScreen sigue siendo el dueño del GifController y del
/// ProgresoService (para el listener que dispara el rebuild); este widget
/// solo recibe esas instancias ya creadas.
/// =============================================================================

const Color _kPrimaryRed = Color(0xFFCC0000);
const Color _kGoldAccent = Color(0xFF8B6914);

class HomeMobileBody extends StatelessWidget {
  final AuthService authService;
  final VocabularioService vocabularioService;
  final Function(int)? onNavigate;
  final GifController fireController;
  final ProgresoService progresoService;

  const HomeMobileBody({
    super.key,
    required this.authService,
    required this.vocabularioService,
    required this.onNavigate,
    required this.fireController,
    required this.progresoService,
  });

  @override
  Widget build(BuildContext context) {
    // ─── CONSUMO DE DATOS EN TIEMPO REAL ─────────────────────────────────────
    // La pantalla de inicio le pide al servicio la lista de actividades que fueron
    // registradas (Paso: loggear actividad al terminar un ejercicio).
    final actividadesRecientes = actividadService.obtenerActividades();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBody: true,

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── CABECERA DINÁMICA: PERFIL Y PROGRESO ──────────────────────
              // Esta sección utiliza un Stack para superponer la información
              // del usuario sobre una imagen de fondo con textura.
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Sombra proyectada hacia abajo-derecha: da sensación de
                  // que la tarjeta "flota" sobre el fondo blanco. Nota: no
                  // se usa un `border` con lados de distinto color/ancho
                  // aquí porque Flutter no puede combinarlo con esquinas
                  // redondeadas — termina dibujando un borde rectangular
                  // "roto" que ignora el radius (eso era el cuadro gris feo).
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      offset: const Offset(5, 8),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                  children: [
                    // Capa 1: Fondo visual
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/bg_home.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    // Capa 2: Filtro de legibilidad
                    Positioned.fill(
                      child: Container(color: Colors.black.withValues(alpha: 0.50)),
                    ),
                    // Capa 2b: relieve sobre la textura — luz arriba-
                    // izquierda y sombra abajo-derecha en el mismo
                    // degradado, para leerse como bisel sin usar un Border
                    // (que rompe las esquinas redondeadas). Todo esto vive
                    // dentro del ClipRRect, así que sí respeta el radius.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.22),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Capa 2c: filo claro de 1.5px arriba, el "borde
                    // iluminado" — mismo truco que la línea de luz, pero
                    // sin depender de Border + radius.
                    Positioned(
                      top: 0,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    // Capa 3: Información del Usuario (Nombre y Nivel)
                    Padding(
                      padding: const EdgeInsets.all(20),
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
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    authService
                                            .usuarioActual?['nombre_completo'] ??
                                        AppStrings.tr('Usuario', 'User'),
                                    style: AppFonts.poppins(
                                      color: const Color(0xFFF5E6D0),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Badge de Nivel (A1, A2, B1...)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _kGoldAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  authService
                                          .usuarioActual?['nivel_actual'] ??
                                      'A1',
                                  style: AppFonts.poppins(
                                    color: const Color(0xFFF5E6D0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
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
                                  width: 30,
                                  height: 30,
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
                          const SizedBox(height: 16),
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
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(progresoService.progresoHaciaSiguienteNivel * 100).toInt()}%',
                                style: AppFonts.poppins(
                                  color: const Color(0xFFF5E6D0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value:
                                  progresoService.progresoHaciaSiguienteNivel,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _kPrimaryRed,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.tr('Acceso Rápido', 'Quick Access'),
                  style: AppFonts.poppins(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    GestureDetector(
                      onTap: () => onNavigate?.call(1),
                      child: _quickAccessCard(
                        icon: Icons.menu_book,
                        label: AppStrings.tr('Lecciones', 'Lessons'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onNavigate?.call(2),
                      child: _quickAccessCard(
                        icon: Icons.timer,
                        label: AppStrings.tr('Simulacros', 'Mock Exams'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VocabularioScreen(
                            vocabularioService: vocabularioService,
                          ),
                        ),
                      ),
                      child: _quickAccessCard(
                        icon: Icons.text_fields,
                        label: AppStrings.tr('Vocabulario', 'Vocabulary'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onNavigate?.call(3),
                      child: _quickAccessCard(
                        icon: Icons.trending_up,
                        label: AppStrings.tr('Mi Progreso', 'My Progress'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.tr('Actividad Reciente', 'Recent Activity'),
                  style: AppFonts.poppins(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (actividadesRecientes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppStrings.tr(
                      'No has completado ninguna actividad todavía.',
                      'You haven\'t completed any activity yet.',
                    ),
                    style: AppFonts.poppins(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ...actividadesRecientes.map((act) {
                  final bool esPerfecto = act['esPerfecto'] ?? false;
                  return activityTile(
                    icon: esPerfecto ? Icons.check_circle : Icons.play_circle,
                    iconColor: esPerfecto
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    title: act['titulo'] ?? AppStrings.tr('Actividad', 'Activity'),
                    subtitle: act['subtitulo'] ?? AppStrings.tr('Progreso', 'Progress'),
                    percentage: act['porcentaje'] ?? '0%',
                  );
                }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAccessCard({required IconData icon, required String label}) {
    return textureCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppFonts.poppins(
              color: const Color(0xFFF5E6D0),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
