import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:fluter_app/ui/pages/vocabulario_screen.dart';
import '../../services/auth_service.dart';
import '../../services/actividad_service.dart';
import '../../services/vocabulario_service.dart';
import '../../services/progreso_service.dart';
import 'package:gif/gif.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kGoldAccent = Color(0xFF8B6914);
const Color kTextDark = Color(0xFF1A0000);
const Color kDesktopCream = Color(0xFFF7EEE0);

/// =============================================================================
/// 🏠 PANTALLA: lib/ui/pages/home_screen.dart
/// =============================================================================
/// Es el centro de control de la aplicación una vez que el usuario ingresa.
///
/// FUNCIONALIDADES:
/// 1. Resumen de Perfil: Muestra el nombre, nivel y racha actual del estudiante.
/// 2. Acceso Rápido: Botones directos a las áreas principales (Lecciones, etc).
/// 3. Feed de Actividad: Muestra dinámicamente lo último que el usuario practicó
///    consultando el [ActividadService].
/// 4. Gamificación: Barra de progreso visual hacia el siguiente nivel.
/// =============================================================================

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final VocabularioService vocabularioService;
  final Function(int)? onNavigate;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.vocabularioService,
    this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, IdiomaListenerMixin<HomeScreen> {
  late GifController _fireController;
  final ProgresoService _progresoService = ProgresoService();

  @override
  void initState() {
    super.initState();
    _fireController = GifController(vsync: this);
    _progresoService.addListener(_actualizarUI);
  }

  void _actualizarUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _progresoService.removeListener(_actualizarUI);
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return _buildDesktopBody(context);
    }
    return _buildMobileBody(context);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileBody(BuildContext context) {
    // ─── CONSUMO DE DATOS EN TIEMPO REAL ─────────────────────────────────────
    // La pantalla de inicio le pide al servicio la lista de actividades que fueron
    // registradas (Paso: loggear actividad al terminar un ejercicio).
    final actividadesRecientes = actividadService.obtenerActividades();

    return Scaffold(
      backgroundColor: Colors.white,
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
                      color: Colors.black.withOpacity(0.42),
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
                      child: Container(color: Colors.black.withOpacity(0.50)),
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
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
                              Colors.black.withOpacity(0.22),
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
                        color: Colors.white.withOpacity(0.28),
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
                                    widget
                                            .authService
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
                                  color: kGoldAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget
                                          .authService
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
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Gif(
                                  image: const AssetImage(
                                    'assets/images/Fire.gif',
                                  ),
                                  controller: _fireController,
                                  autostart: Autostart.loop,
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.tr(
                                    '${_progresoService.rachaDias} días',
                                    '${_progresoService.rachaDias} days',
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
                                  'Progreso hacia ${_progresoService.siguienteNivel}',
                                  'Progress towards ${_progresoService.siguienteNivel}',
                                ),
                                style: AppFonts.poppins(
                                  color: const Color(0xAAF5E6D0),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(_progresoService.progresoHaciaSiguienteNivel * 100).toInt()}%',
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
                                  _progresoService.progresoHaciaSiguienteNivel,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                kPrimaryRed,
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
                    color: kTextDark,
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
                      onTap: () => widget.onNavigate?.call(1),
                      child: _quickAccessCard(
                        icon: Icons.menu_book,
                        label: AppStrings.tr('Lecciones', 'Lessons'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNavigate?.call(2),
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
                            vocabularioService: widget.vocabularioService,
                          ),
                        ),
                      ),
                      child: _quickAccessCard(
                        icon: Icons.text_fields,
                        label: AppStrings.tr('Vocabulario', 'Vocabulary'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onNavigate?.call(3),
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
                    color: kTextDark,
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
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ...actividadesRecientes.map((act) {
                  final bool esPerfecto = act['esPerfecto'] ?? false;
                  return _activityTile(
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

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — panel de contenido que vive junto al
  // sidebar de [MainNavigation]. Misma información y misma lógica que el
  // móvil (racha, progreso, accesos rápidos, actividad reciente), solo con
  // una composición visual adaptada al espacio horizontal disponible.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopBody(BuildContext context) {
    final actividadesRecientes = actividadService.obtenerActividades();
    final nombre =
        widget.authService.usuarioActual?['nombre_completo'] ??
        AppStrings.tr('Usuario', 'User');

    return Scaffold(
      backgroundColor: kDesktopCream,
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
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Gif(
                                image: const AssetImage(
                                  'assets/images/Fire.gif',
                                ),
                                controller: _fireController,
                                autostart: Autostart.loop,
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.tr(
                                  '${_progresoService.rachaDias} días',
                                  '${_progresoService.rachaDias} days',
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
                            'Progreso hacia ${_progresoService.siguienteNivel}',
                            'Progress towards ${_progresoService.siguienteNivel}',
                          ),
                          style: AppFonts.poppins(
                            color: const Color(0xAAF5E6D0),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(_progresoService.progresoHaciaSiguienteNivel * 100).toInt()}%',
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
                        value: _progresoService.progresoHaciaSiguienteNivel,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          kGoldAccent,
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
                      color: kTextDark,
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
                      onTap: () => widget.onNavigate?.call(1),
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
                      onTap: () => widget.onNavigate?.call(2),
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
                            vocabularioService: widget.vocabularioService,
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
                      onTap: () => widget.onNavigate?.call(3),
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
                  color: kTextDark,
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
                    border: Border.all(color: Colors.brown.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kDesktopCream,
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
                          color: kTextDark,
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
                    child: _activityTile(
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
              color: Colors.white.withOpacity(0.15),
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

  Widget _textureCard({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    EdgeInsets padding = const EdgeInsets.all(20),
    double radius = 16,
    Color? overlayColor, // Nuevo parámetro para el tinte
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // Sombra proyectada para dar sensación de profundidad. No se usa
        // un `border` con lados de distinto color/ancho porque Flutter no
        // puede combinarlo con esquinas redondeadas (dibuja un borde
        // rectangular "roto" que ignora el radius).
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.42),
            offset: const Offset(5, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                color: overlayColor ?? Colors.black.withOpacity(0.42),
              ),
            ),
            // Relieve sobre la textura: luz arriba-izquierda y sombra
            // abajo-derecha en el mismo degradado — se lee como bisel sin
            // usar Border (respeta las esquinas porque vive dentro del
            // ClipRRect).
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.transparent,
                      Colors.black.withOpacity(0.22),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Filo claro de 1.5px arriba — el "borde iluminado".
            Positioned(
              top: 0,
              left: radius,
              right: radius,
              child: Container(
                height: 1.5,
                color: Colors.white.withOpacity(0.28),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessCard({required IconData icon, required String label}) {
    return _textureCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
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

  Widget _activityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String percentage,
  }) {
    // Calcular color de fondo según el porcentaje
    final int val = int.tryParse(percentage.replaceAll('%', '')) ?? 0;
    Color overlayColor;

    if (val >= 80) {
      overlayColor = const Color(
        0xFF003300,
      ).withOpacity(0.6); // Tinte verde oscuro
    } else if (val >= 50) {
      overlayColor = const Color(
        0xFF442200,
      ).withOpacity(0.6); // Tinte ámbar/marrón
    } else {
      overlayColor = const Color(
        0xFF330000,
      ).withOpacity(0.6); // Tinte rojo oscuro
    }

    return _textureCard(
      overlayColor: overlayColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.poppins(
                    color: const Color(0xFFF5E6D0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppFonts.poppins(
                    color: const Color(0xAAF5E6D0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentage,
              style: AppFonts.poppins(
                color: const Color(0xFFF5E6D0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
