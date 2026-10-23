import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../../services/leccion_service.dart';
import '../../services/progreso_service.dart';
import 'leccion_detalle_screen.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import 'home/home_widgets.dart' show textureCard;
import 'tema_detalle/tema_detalle_pages.dart' show kGrammarTopicImages;

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kTextDark = Color(0xFF1A0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kDesktopCream = Color(0xFFF7EEE0);

/// =============================================================================
/// 📚 PANTALLA: lib/ui/pages/lecciones_screen.dart
/// =============================================================================
/// Muestra el mapa de aprendizaje dividido por niveles (A1, A2, B1, B2).
///
/// FUNCIONALIDADES:
/// 1. Selector de Nivel: Permite al usuario filtrar el contenido académico.
/// 2. Lista de Habilidades: Muestra las categorías (Grammar, Reading, etc.)
///    con sus respectivos progresos.
/// 3. Control de Acceso: Bloquea visualmente las lecciones que aún no están
///    disponibles o terminadas.
/// =============================================================================

class LeccionesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final dynamic authService; // Se recibe dynamic o AuthService

  const LeccionesScreen({super.key, this.onBack, required this.authService});

  @override
  State<LeccionesScreen> createState() => _LeccionesScreenState();
}

//  Se recibe dynamic o AuthService , crea una instancia del servicio LeccionService
class _LeccionesScreenState extends State<LeccionesScreen>
    with IdiomaListenerMixin<LeccionesScreen> {
  final LeccionService _leccionService = LeccionService();
  final ProgresoService _progresoService = ProgresoService();
  int _selectedLevel = 0;
  bool _imagenesPrecargadas = false;

  @override
  void initState() {
    super.initState();
    String nivelActual =
        widget.authService.usuarioActual?['nivel_actual'] ?? 'A1';
    _selectedLevel = _leccionService.niveles.indexOf(nivelActual);
    if (_selectedLevel == -1) _selectedLevel = 0;
    _progresoService.addListener(_actualizarUI);
  }

  void _actualizarUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _progresoService.removeListener(_actualizarUI);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precarga en segundo plano las imágenes ilustrativas de los temas de
    // Grammar mientras el usuario todavía está viendo esta pantalla, para
    // que ya estén listas (sin espera de red) cuando entre a un tema.
    if (!_imagenesPrecargadas) {
      _imagenesPrecargadas = true;
      for (final ruta in kGrammarTopicImages.values) {
        precacheImage(AssetImage(ruta), context);
      }
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    // ─── PASO 3: CONSUMO DEL SERVICIO ───────────────────────────────────────
    // Le pedimos al servicio las lecciones que corresponden al nivel seleccionado.
    final lecciones = _leccionService.getLecciones(
      _leccionService.niveles[_selectedLevel],
      _progresoService.habilidadesValues,
    );

    if (isDesktop(context)) {
      return _buildDesktopLayout(context, lecciones);
    }
    return _buildMobileLayout(context, lecciones);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileLayout(
    BuildContext context,
    List<LeccionInfo> lecciones,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          AppStrings.tr('Lecciones', 'Lessons'),
          style: AppFonts.poppins(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TABS de nivel ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_leccionService.niveles.length, (index) {
                final isSelected = _selectedLevel == index;
                return GestureDetector(
                  // Solo cambia qué nivel se está viendo. El nivel de la
                  // cuenta se gana completando lecciones y simulacros (ver
                  // ProgresoService), no se elige con esta pestaña.
                  onTap: () => setState(() => _selectedLevel = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? kPrimaryRed : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _leccionService.niveles[index],
                      style: AppFonts.poppins(
                        color: isSelected
                            ? kPrimaryRed
                            : AppColors.textSecondary(context),
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Divider(height: 1, color: AppColors.divider(context)),

          const SizedBox(height: 12),

          // ── BANNER con textura ────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 100),
            height: 80,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/bg_nivel.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.50)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.tr(
                          'Nivel ${_leccionService.niveles[_selectedLevel]}',
                          'Level ${_leccionService.niveles[_selectedLevel]}',
                        ),
                        textAlign: TextAlign.center,
                        style: AppFonts.poppins(
                          color: kCream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.tr(
                          'Continua practicando',
                          'Keep practicing',
                        ),
                        textAlign: TextAlign.center,
                        style: AppFonts.poppins(
                          color: kCreamMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA de lecciones: El puente entre la UI y el Contenido ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: lecciones.length,
              // 1.3 RENDERIZADO: Por cada curso definido en el servicio, creamos una tarjeta.
              itemBuilder: (context, index) {
                final leccion = lecciones[index];
                return _lessonCard(
                  icon: leccion.icon,
                  title: leccion.title,
                  subtitle: leccion.subtitle,
                  progress: leccion.progress,
                  isLocked: leccion.isLocked,
                  // ─── PASO 4: EVENTO DE CLIC (NAVEGACIÓN) ────────────────────────
                  // Al tocar una tarjeta, validamos si no está bloqueada para ir al detalle.
                  onTap: () {
                    if (!leccion.isLocked) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeccionDetalleScreen(
                            // Enviamos los datos de la lección seleccionada a la siguiente pantalla
                            titulo: leccion.title,
                            subtitulo: leccion.subtitle,
                            icon: leccion.icon,
                            progress: leccion.progress,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    // ── Tarjeta BLOQUEADA — gris claro sin textura ──────────────────────────
    if (isLocked) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder(context), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBorder(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.lock, color: AppColors.iconMuted(context), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.poppins(
                      color: AppColors.textSecondary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppFonts.poppins(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0,
                      backgroundColor: AppColors.divider(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.cardBorder(context),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '0%',
              style: AppFonts.poppins(
                color: AppColors.textSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // ── Tarjeta ACTIVA — con textura roja ───────────────────────────────────
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          children: [
            // Textura roja
            Positioned.fill(
              child: Image.asset('assets/images/fondo.webp', fit: BoxFit.cover),
            ),
            // Capa oscura
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.42)),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Ícono
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: kCream, size: 22),
                  ),
                  const SizedBox(width: 14),
                  // Título + subtítulo + barra
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppFonts.poppins(
                            color: kCream,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: AppFonts.poppins(
                            color: kCreamMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              kPrimaryRed,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Porcentaje
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppFonts.poppins(
                      color: kCream,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — cabecera propia, tabs en píldora, banner de
  // nivel y tarjetas de habilidad en grilla de 2 columnas. Misma lógica de
  // selección de nivel y navegación que el móvil.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(
    BuildContext context,
    List<LeccionInfo> lecciones,
  ) {
    final nivelActual = _leccionService.niveles[_selectedLevel];
    final desbloqueadas = lecciones.where((l) => !l.isLocked).toList();
    final activas = desbloqueadas.length;
    // Promedio real de progreso entre las habilidades desbloqueadas (antes
    // era un "68%" fijo, igual para cualquier usuario). Se excluye Speaking
    // (bloqueada) para no arrastrar el promedio hacia abajo con una
    // habilidad que ningún usuario puede practicar todavía.
    final double progresoPromedio = desbloqueadas.isEmpty
        ? 0.0
        : desbloqueadas.map((l) => l.progress).reduce((a, b) => a + b) /
              desbloqueadas.length;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabecera ────────────────────────────────────────────────
              Row(
                children: [
                  Material(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.chevron_left, color: AppColors.textPrimary(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr('Lecciones', 'Lessons'),
                        style: AppFonts.poppins(
                          color: AppColors.textPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.tr(
                          'Domina cada habilidad para avanzar de nivel.',
                          'Master each skill to level up.',
                        ),
                        style: AppFonts.poppins(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Tabs de nivel en píldora ────────────────────────────────
              Row(
                children: List.generate(_leccionService.niveles.length, (
                  index,
                ) {
                  final isSelected = _selectedLevel == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Material(
                      color: isSelected ? kPrimaryRed : AppColors.card(context),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        // Solo cambia qué nivel se está viendo (ver la
                        // pestaña de la versión móvil).
                        onTap: () => setState(() => _selectedLevel = index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          child: Text(
                            _leccionService.niveles[index],
                            style: AppFonts.poppins(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // ── Banner de nivel ─────────────────────────────────────────
              // Misma textureCard() (fondo.webp + capa oscura + bisel) que
              // ya usan las tarjetas de habilidad justo debajo -- antes este
              // banner era el único con un degradado plano sin textura.
              textureCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 22,
                ),
                radius: 18,
                imageAlignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('Nivel $nivelActual', 'Level $nivelActual'),
                          style: AppFonts.poppins(
                            color: kCream,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.tr(
                            'Continúa practicando · $activas de ${lecciones.length} habilidades activas',
                            'Keep practicing · $activas of ${lecciones.length} skills active',
                          ),
                          style: AppFonts.poppins(
                            color: kCreamMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(progresoPromedio * 100).toInt()}%',
                          style: AppFonts.poppins(
                            color: const Color(0xFFD4A017),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.tr('completado', 'completed'),
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

              const SizedBox(height: 24),

              // ── Grilla de habilidades (2 columnas) ──────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lecciones.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (context, index) {
                  final leccion = lecciones[index];
                  return _desktopSkillCard(
                    icon: leccion.icon,
                    title: leccion.title,
                    subtitle: leccion.subtitle,
                    progress: leccion.progress,
                    isLocked: leccion.isLocked,
                    onTap: () {
                      if (!leccion.isLocked) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeccionDetalleScreen(
                              titulo: leccion.title,
                              subtitulo: leccion.subtitle,
                              icon: leccion.icon,
                              progress: leccion.progress,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _desktopSkillCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBorder(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.lock, color: AppColors.iconMuted(context), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppFonts.poppins(
                      color: AppColors.textSecondary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppStrings.tr('Próximamente', 'Coming soon'),
                    style: AppFonts.poppins(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0,
                      backgroundColor: AppColors.cardBorder(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.cardBorder(context),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.lock, color: Colors.amber[300], size: 18),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fondo.webp', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.42)),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: kCream, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: AppFonts.poppins(
                                color: kCream,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppFonts.poppins(
                                color: kCream,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          subtitle,
                          style: AppFonts.poppins(
                            color: kCreamMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD4A017),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
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
}
