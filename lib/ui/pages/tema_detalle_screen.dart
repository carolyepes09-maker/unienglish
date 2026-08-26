import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/responsive.dart';
import '../../models/grammar_content.dart';
import '../../models/reading_content.dart';
import '../../models/listening_content.dart';
import '../../models/writing_content.dart';
import 'ejercicios_screen.dart';
import '../utils/app_strings.dart';
import '../widgets/audio_player_card.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kDarkCard = Color(0xFF1A0000);
const Color kGoldAccent = Color(0xFF8B6914);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kTextDark = Color(0xFF1C1C1C);
const Color kDesktopCream = Color(0xFFF7EEE0);

// Imagen ilustrativa por tema de Grammar (se muestra en la página de Teoría)
const Map<String, String> kGrammarTopicImages = {
  'Present Simple': 'assets/images/present_simple.jpg',
  'Present Continuous': 'assets/images/present_continuos.jpg',
  'Past Simple': 'assets/images/past_simple.jpg',
  'Present Perfect': 'assets/images/past_present.jpg',
};

/// =============================================================================
/// 📚 PANTALLA: lib/ui/pages/tema_detalle_screen.dart
/// =============================================================================
/// Vista principal de aprendizaje teórico.
/// Adapta su interfaz según el tipo de lección: Gramática, Lectura o Audio.
/// =============================================================================

class TemaDetalleScreen extends StatefulWidget {
  final String temaNombre;
  final String leccion;

  const TemaDetalleScreen({
    super.key,
    required this.temaNombre,
    required this.leccion,
  });

  @override
  State<TemaDetalleScreen> createState() => _TemaDetalleScreenState();
}

class _TemaDetalleScreenState extends State<TemaDetalleScreen>
    with IdiomaListenerMixin<TemaDetalleScreen> {
  // ─── PAGINACIÓN ───────────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ─── SELECCIÓN DINÁMICA DE CONTENIDO ────────────────────────────────────
    // Dependiendo de la pestaña de donde venga el usuario, cargamos el
    // repositorio de datos correspondiente.
    dynamic contenido;

    switch (widget.leccion) {
      case 'Grammar':
        contenido = grammarTopics[widget.temaNombre];
        break;
      case 'Reading':
        contenido = readingTopics[widget.temaNombre];
        break;
      case 'Listening':
        contenido = listeningTopics[widget.temaNombre];
        break;
      case 'Writing':
        contenido = writingTopics[widget.temaNombre];
        break;
      default:
        contenido = null;
    }

    // ── VALIDACIÓN DE ERRORES ──────────────────────────────────────────────
    if (contenido == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.tr('Tema no encontrado', 'Topic not found'),
          ),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            AppStrings.tr(
              'El tema solicitado no existe.',
              'The requested topic does not exist.',
            ),
          ),
        ),
      );
    }

    if (isDesktop(context)) {
      return _buildDesktopLayout(context, contenido);
    }
    return _buildMobileLayout(context, contenido);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileLayout(BuildContext context, dynamic contenido) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          contenido.titulo,
          style: AppFonts.poppins(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildPaginationBar(),
          const Divider(height: 1),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildPageTeoria(contenido),
                _buildPagePractica(contenido),
                _buildPageRefuerzo(contenido),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — cabecera propia centrada con ancho máximo,
  // reutiliza exactamente la misma barra de paginación y páginas (Teoría,
  // Práctica, Refuerzo) que el móvil, sin duplicar la lógica de contenido.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context, dynamic contenido) {
    return Scaffold(
      backgroundColor: kDesktopCream,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.chevron_left, color: kTextDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      contenido.titulo,
                      style: AppFonts.poppins(
                        color: kTextDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPaginationBar(),
                const Divider(height: 1),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildPageTeoria(contenido),
                      _buildPagePractica(contenido),
                      _buildPageRefuerzo(contenido),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BARRA DE PAGINACIÓN — flechas + dots + contador
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPaginationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: _currentPage > 0 ? kPrimaryRed : Colors.grey[300],
                onPressed: _currentPage > 0
                    ? () => _goToPage(_currentPage - 1)
                    : null,
              ),
              ...List.generate(_totalPages, (index) {
                final isActive = index == _currentPage;
                final isDone = index < _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: (isActive || isDone)
                        ? kPrimaryRed
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: _currentPage < _totalPages - 1
                    ? kPrimaryRed
                    : Colors.grey[300],
                onPressed: _currentPage < _totalPages - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              AppStrings.tr(
                'Página ${_currentPage + 1} de $_totalPages',
                'Page ${_currentPage + 1} of $_totalPages',
              ),
              style: AppFonts.poppins(
                color: kTextDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PÁGINA 1 — Teoría: ¿Qué es? + ¿Cuándo se usa?
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPageTeoria(dynamic contenido) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // SECCIÓN: ¿QUÉ ES?
          // ═══════════════════════════════════════════════════════════════
          Text(
            AppStrings.tr('¿Qué es?', 'What is it?'),
            style: AppFonts.poppins(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _textureCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              contenido.queEs,
              style: AppFonts.poppins(
                color: kCream,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // SECCIÓN: ¿CUÁNDO SE USA?
          // ═══════════════════════════════════════════════════════════════
          Text(
            AppStrings.tr('¿Cuándo se usa?', 'When is it used?'),
            style: AppFonts.poppins(
              color: kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            contenido.cuandoSeUsa.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _textureCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppFonts.poppins(
                            color: kCream,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        contenido.cuandoSeUsa[index],
                        style: AppFonts.poppins(
                          color: kCream,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // IMAGEN ILUSTRATIVA DEL TEMA (solo Grammar, si hay una disponible)
          // ═══════════════════════════════════════════════════════════════
          if (widget.leccion == 'Grammar' &&
              kGrammarTopicImages.containsKey(widget.temaNombre)) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                kGrammarTopicImages[widget.temaNombre]!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PÁGINA 2 — Práctica: Estructura/Audio + Ejemplos/Textos
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPagePractica(dynamic contenido) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ═══════════════════════════════════════════════════════════════
            // SECCIÓN: ESTRUCTURA O INFORMACIÓN ESPECÍFICA
            // ═══════════════════════════════════════════════════════════════
            if (widget.leccion == 'Grammar') ...[
              Text(
                AppStrings.tr('Estructura', 'Structure'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _estructuraRow(
                      AppStrings.tr('Afirmativa', 'Affirmative'),
                      contenido.estructura.positiva,
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 10),
                    _estructuraRow(
                      AppStrings.tr('Negativa', 'Negative'),
                      contenido.estructura.negativa,
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 10),
                    _estructuraRow(
                      AppStrings.tr('Pregunta', 'Question'),
                      contenido.estructura.pregunta,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (widget.leccion == 'Reading') ...[
              Text(
                AppStrings.tr('Estructura de lectura', 'Reading structure'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    contenido.estructura.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index < contenido.estructura.length - 1
                            ? 10
                            : 0,
                      ),
                      child: Text(
                        contenido.estructura[index],
                        style: AppFonts.poppins(
                          color: kCream,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (widget.leccion == 'Listening') ...[
              AudioPlayerCard(audioFile: contenido.audioFile as String?),
              const SizedBox(height: 20),
              Text(
                AppStrings.tr('Transcripción', 'Transcript'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    contenido.tecnicasEscucha.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index < contenido.tecnicasEscucha.length - 1
                            ? 10
                            : 0,
                      ),
                      child: Text(
                        contenido.tecnicasEscucha[index],
                        style: AppFonts.poppins(
                          color: kCream,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (widget.leccion == 'Writing') ...[
              Text(
                AppStrings.tr(
                  'Criterios de evaluación',
                  'Evaluation criteria',
                ),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    contenido.criterios.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index < contenido.criterios.length - 1 ? 10 : 0,
                      ),
                      child: Text(
                        contenido.criterios[index],
                        style: AppFonts.poppins(
                          color: kCream,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ═══════════════════════════════════════════════════════════════
            // SECCIÓN: EJEMPLOS O TEXTOS
            // ═══════════════════════════════════════════════════════════════
            if (widget.leccion == 'Grammar') ...[
              Text(
                AppStrings.tr('Ejemplos', 'Examples'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                contenido.ejemplos.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _textureCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${contenido.ejemplos[index].ingles}',
                          style: AppFonts.poppins(
                            color: kCream,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          contenido.ejemplos[index].traduccion,
                          style: AppFonts.poppins(
                            color: kCreamMuted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (widget.leccion == 'Reading') ...[
              Text(
                AppStrings.tr('Texto ejemplo', 'Sample text'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contenido.textoEjemplo.ingles,
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 10),
                    Text(
                      contenido.textoEjemplo.traduccion,
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (widget.leccion == 'Listening') ...[
              Text(
                AppStrings.tr('Transcripción', 'Transcript'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contenido.transcript.ingles,
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 10),
                    Text(
                      contenido.transcript.traduccion,
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (widget.leccion == 'Writing') ...[
              Text(
                AppStrings.tr('Ejemplo modelo', 'Model example'),
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _textureCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contenido.ejemploModelo.ingles,
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 10),
                    Text(
                      contenido.ejemploModelo.traduccion,
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PÁGINA 3 — Refuerzo: Errores comunes + Tips + botón de ejercicios
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPageRefuerzo(dynamic contenido) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ═══════════════════════════════════════════════════════════════
            // SECCIÓN: ERRORES COMUNES
            // ═══════════════════════════════════════════════════════════════
            Text(
              AppStrings.tr('Errores comunes', 'Common mistakes'),
              style: AppFonts.poppins(
                color: kTextDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  contenido.erroresComunes.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < contenido.erroresComunes.length - 1
                          ? 10
                          : 0,
                    ),
                    child: Text(
                      contenido.erroresComunes[index],
                      style: AppFonts.poppins(
                        color: kTextDark,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // SECCIÓN: TIPS PARA RECORDAR
            // ═══════════════════════════════════════════════════════════════
            Text(
              AppStrings.tr('Tips para recordar', 'Tips to remember'),
              style: AppFonts.poppins(
                color: kTextDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: kGoldAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kGoldAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  contenido.tipsParaRecordar.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < contenido.tipsParaRecordar.length - 1
                          ? 10
                          : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ',
                          style: AppFonts.poppins(
                            color: kGoldAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            contenido.tipsParaRecordar[index],
                            style: AppFonts.poppins(
                              color: kTextDark,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // BOTÓN: IR A EJERCICIOS
            // ═══════════════════════════════════════════════════════════════
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EjerciciosScreen(
                      temaNombre: widget.temaNombre,
                      leccion: widget.leccion,
                    ),
                  ),
                );
              },
              child: _textureCard(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                radius: 26,
                child: Center(
                  child: Text(
                    AppStrings.tr('Ir a ejercicios →', 'Go to exercises →'),
                    style: AppFonts.poppins(
                      color: kCream,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _estructuraRow(String tipo, String estructura) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tipo,
          style: AppFonts.poppins(
            color: kGoldAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          estructura,
          style: AppFonts.poppins(color: kCream, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

}

Widget _textureCard({
  required Widget child,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  EdgeInsets padding = const EdgeInsets.all(20),
  double radius = 16,
}) {
  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          offset: const Offset(4, 6),
          blurRadius: 14,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          // Textura roja
          Positioned.fill(
            child: Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
          ),
          // Capa oscura
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.42)),
          ),
          // Brillo sutil arriba-izquierda (simula luz sobre la superficie)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.12), Colors.transparent],
                  stops: const [0.0, 0.55],
                ),
              ),
            ),
          ),
          // Contenido
          Padding(padding: padding, child: child),
        ],
      ),
    ),
  );
}
