import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import 'tema_detalle_screen.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kTextDark = Color(0xFF1A0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kDesktopCream = Color(0xFFF7EEE0);

// =============================================================================
// MODELO DE DATOS PARA TEMAS
// =============================================================================
enum EstadoTema { completado, enProgreso, bloqueado }

class Tema {
  final String nombre;
  final String descripcion;
  final String descripcionEn;
  final EstadoTema estado;

  const Tema({
    required this.nombre,
    required this.descripcion,
    required this.descripcionEn,
    required this.estado,
  });
}

// =============================================================================
// DATOS DE TEMAS POR LECCIÓN
// =============================================================================
final Map<String, List<Tema>> temasLecciones = {
  'Grammar': [
    const Tema(
      nombre: 'Present Simple',
      descripcion: 'Oraciones afirmativas y negativas',
      descripcionEn: 'Affirmative and negative sentences',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Present Continuous',
      descripcion: 'Acciones en progreso',
      descripcionEn: 'Actions in progress',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Past Simple',
      descripcion: 'Eventos en el pasado',
      descripcionEn: 'Events in the past',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Present Perfect',
      descripcion: 'Experiencias y resultados',
      descripcionEn: 'Experiences and results',
      estado: EstadoTema.enProgreso,
    ),
    const Tema(
      nombre: 'Future Tenses',
      descripcion: 'Will, going to, present continuous',
      descripcionEn: 'Will, going to, present continuous',
      estado: EstadoTema.bloqueado,
    ),
  ],
  'Reading': [
    const Tema(
      nombre: 'Skimming',
      descripcion: 'Lectura rápida para idea general',
      descripcionEn: 'Quick reading for the general idea',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Scanning',
      descripcion: 'Búsqueda de información específica',
      descripcionEn: 'Searching for specific information',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Inference',
      descripcion: 'Deducciones del texto',
      descripcionEn: 'Deductions from the text',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Critical Reading',
      descripcion: 'Análisis y evaluación',
      descripcionEn: 'Analysis and evaluation',
      estado: EstadoTema.bloqueado,
    ),
    const Tema(
      nombre: 'Academic Texts',
      descripcion: 'Textos universitarios',
      descripcionEn: 'University texts',
      estado: EstadoTema.bloqueado,
    ),
  ],
  'Listening': [
    const Tema(
      nombre: 'Basic Conversations',
      descripcion: 'Diálogos cotidianos',
      descripcionEn: 'Everyday dialogues',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Accents & Pronunciation',
      descripcion: 'Variantes del inglés',
      descripcionEn: 'Varieties of English',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'News & Media',
      descripcion: 'Audio de noticias reales',
      descripcionEn: 'Real news audio',
      estado: EstadoTema.enProgreso,
    ),
    const Tema(
      nombre: 'Academic Lectures',
      descripcion: 'Conferencias universitarias',
      descripcionEn: 'University lectures',
      estado: EstadoTema.bloqueado,
    ),
    const Tema(
      nombre: 'IELTS Listening',
      descripcion: 'Formato de examen oficial',
      descripcionEn: 'Official exam format',
      estado: EstadoTema.bloqueado,
    ),
  ],
  'Writing': [
    const Tema(
      nombre: 'Paragraph Structure',
      descripcion: 'Topic sentence y soporte',
      descripcionEn: 'Topic sentence and support',
      estado: EstadoTema.completado,
    ),
    const Tema(
      nombre: 'Essay Writing',
      descripcion: 'Introducción, cuerpo y conclusión',
      descripcionEn: 'Introduction, body and conclusion',
      estado: EstadoTema.enProgreso,
    ),
    const Tema(
      nombre: 'Academic Writing',
      descripcion: 'Estilo formal universitario',
      descripcionEn: 'Formal academic style',
      estado: EstadoTema.bloqueado,
    ),
    const Tema(
      nombre: 'Argumentative Essays',
      descripcion: 'Tesis y argumentación',
      descripcionEn: 'Thesis and argumentation',
      estado: EstadoTema.bloqueado,
    ),
    const Tema(
      nombre: 'Research Writing',
      descripcion: 'Citas y referencias APA',
      descripcionEn: 'APA citations and references',
      estado: EstadoTema.bloqueado,
    ),
  ],
};

// =============================================================================
// PANTALLA DE DETALLE DE LECCIÓN
// =============================================================================
class LeccionDetalleScreen extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final double progress;

  /// ─── PASO 5: RECEPCIÓN DE DATOS ──────────────────────────────────────────
  /// Esta pantalla recibe toda la información de la lección seleccionada en 
  /// el paso anterior para saber qué temas mostrar.
  const LeccionDetalleScreen({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.progress,
  });

  @override
  State<LeccionDetalleScreen> createState() => _LeccionDetalleScreenState();
}

class _LeccionDetalleScreenState extends State<LeccionDetalleScreen>
    with IdiomaListenerMixin<LeccionDetalleScreen> {
  String _getBackgroundImage() {
    switch (widget.titulo.toLowerCase()) {
      case 'grammar':
        return 'assets/images/bg_grammar.webp';
      case 'reading':
        return 'assets/images/bg_reading.webp';
      case 'listening':
        return 'assets/images/bg_listening.webp';
      case 'writing':
        return 'assets/images/bg_writing.webp';
      default:
        return 'assets/images/fondo.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ─── PASO 6: CARGA DE TEMAS ESPECÍFICOS ──────────────────────────────────
    // Buscamos en el mapa 'temasLecciones' la lista de temas que corresponden
    // al título de la lección (Grammar, Reading...).
    final temas = temasLecciones[widget.titulo] ?? [];

    if (isDesktop(context)) {
      return _buildDesktopLayout(context, temas);
    }
    return _buildMobileLayout(context, temas);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileLayout(BuildContext context, List<Tema> temas) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.titulo,
          style: AppFonts.poppins(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ══════════════════════════════════════════════════════════════
            // [2] HEADER CARD CON IMAGEN TEMÁTICA
            // ══════════════════════════════════════════════════════════════
            Container(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Imagen temática de la lección
                  Positioned.fill(
                    child: Image.asset(
                      _getBackgroundImage(),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  // Capa oscura para legibilidad
                  Positioned.fill(
                    child: Container(color: Colors.black.withValues(alpha: 0.50)),
                  ),
                  // Contenido del header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.30),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Icon(widget.icon, color: kCream, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.titulo,
                                    style: AppFonts.poppins(
                                      color: kCream,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.subtitulo,
                                    style: AppFonts.poppins(
                                      color: kCreamMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(widget.progress * 100).toInt()}%',
                              style: AppFonts.poppins(
                                color: kCream,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Barra de progreso
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.20),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              kPrimaryRed,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ══════════════════════════════════════════════════════════════
            // [3] TÍTULO SECCIÓN "Temas"
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.tr('Temas', 'Topics'),
                style: AppFonts.poppins(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ══════════════════════════════════════════════════════════════
            // [4] LISTA DE TEMAS
            // ══════════════════════════════════════════════════════════════
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: temas.length,
              itemBuilder: (context, index) {
                final tema = temas[index];
                final estaBloqueado = tema.estado == EstadoTema.bloqueado;

                // Tema activo (clickeable) con textura
                if (!estaBloqueado) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemaDetalleScreen(
                              temaNombre: tema.nombre,
                              leccion: widget.titulo,
                            ),
                          ),
                        );
                      },
                      child: _temaCard(
                        numero: index + 1,
                        nombre: tema.nombre,
                        descripcion: AppStrings.tr(
                          tema.descripcion,
                          tema.descripcionEn,
                        ),
                        estado: tema.estado,
                      ),
                    ),
                  );
                }

                // Tema bloqueado (no clickeable) sin textura
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _temaBloqueadoCard(
                    numero: index + 1,
                    nombre: tema.nombre,
                    descripcion: AppStrings.tr(
                      tema.descripcion,
                      tema.descripcionEn,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — cabecera propia con imagen temática y grilla
  // de temas en 2 columnas. Misma lógica de navegación que el móvil.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context, List<Tema> temas) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
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
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.chevron_left, color: AppColors.textPrimary(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppStrings.tr(
                      'Lecciones · ${widget.titulo}',
                      'Lessons · ${widget.titulo}',
                    ),
                    style: AppFonts.poppins(
                      color: AppColors.textPrimary(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Tarjeta de cabecera con imagen temática ──────────────────
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        _getBackgroundImage(),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withValues(alpha: 0.50)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Icon(widget.icon, color: kCream, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.titulo,
                                  style: AppFonts.poppins(
                                    color: kCream,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.subtitulo,
                                  style: AppFonts.poppins(
                                    color: kCreamMuted,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: widget.progress,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.20,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          kPrimaryRed,
                                        ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            '${(widget.progress * 100).toInt()}%',
                            style: AppFonts.poppins(
                              color: kCream,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                AppStrings.tr('Temas', 'Topics'),
                style: AppFonts.poppins(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ── Grilla de temas (2 columnas) ─────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: temas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 5.0,
                ),
                itemBuilder: (context, index) {
                  final tema = temas[index];
                  final estaBloqueado = tema.estado == EstadoTema.bloqueado;

                  if (!estaBloqueado) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemaDetalleScreen(
                              temaNombre: tema.nombre,
                              leccion: widget.titulo,
                            ),
                          ),
                        );
                      },
                      child: _temaCard(
                        numero: index + 1,
                        nombre: tema.nombre,
                        descripcion: AppStrings.tr(
                          tema.descripcion,
                          tema.descripcionEn,
                        ),
                        estado: tema.estado,
                      ),
                    );
                  }

                  return _temaBloqueadoCard(
                    numero: index + 1,
                    nombre: tema.nombre,
                    descripcion: AppStrings.tr(
                      tema.descripcion,
                      tema.descripcionEn,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET — Tarjeta con textura roja
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _textureCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(4, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
            // Brillo sutil arriba-izquierda (simula luz sobre la superficie)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withValues(alpha: 0.12), Colors.transparent],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET — Tarjeta de tema individual
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _temaCard({
    required int numero,
    required String nombre,
    required String descripcion,
    required EstadoTema estado,
  }) {
    return _textureCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Número del tema en círculo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: AppFonts.poppins(
                  color: kCream,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nombre y descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: AppFonts.poppins(
                    color: kCream,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  descripcion,
                  style: AppFonts.poppins(color: kCreamMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Ícono de estado
          _iconoEstado(estado),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET — Ícono según estado del tema
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _iconoEstado(EstadoTema estado) {
    switch (estado) {
      case EstadoTema.completado:
        return const Icon(
          Icons.check_circle_rounded,
          color: Colors.greenAccent,
          size: 22,
        );
      case EstadoTema.enProgreso:
        return const Icon(
          Icons.play_circle_rounded,
          color: Colors.orangeAccent,
          size: 22,
        );
      case EstadoTema.bloqueado:
        return const Icon(
          Icons.lock_outline_rounded,
          color: kCreamMuted,
          size: 22,
        );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET — Tarjeta de tema bloqueado (sin textura, deshabilitado)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _temaBloqueadoCard({
    required int numero,
    required String nombre,
    required String descripcion,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Número del tema en círculo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBorder(context),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: AppFonts.poppins(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nombre y descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: AppFonts.poppins(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  descripcion,
                  style: AppFonts.poppins(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Ícono de lock
          Icon(Icons.lock_rounded, color: AppColors.iconMuted(context), size: 22),
        ],
      ),
    );
  }
}
