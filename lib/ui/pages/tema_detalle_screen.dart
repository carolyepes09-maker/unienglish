import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/responsive.dart';
import '../../models/grammar_content.dart';
import '../../models/reading_content.dart';
import '../../models/listening_content.dart';
import '../../models/writing_content.dart';
import '../utils/app_strings.dart';
import 'tema_detalle/tema_detalle_pages.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kTextDark = Color(0xFF1C1C1C);
const Color kDesktopCream = Color(0xFFF7EEE0);

/// =============================================================================
/// 📚 PANTALLA: lib/ui/pages/tema_detalle_screen.dart
/// =============================================================================
/// Vista principal de aprendizaje teórico.
/// Adapta su interfaz según el tipo de lección: Gramática, Lectura o Audio.
///
/// Las tres páginas de contenido (Teoría/Práctica/Refuerzo) viven en
/// lib/ui/pages/tema_detalle/tema_detalle_pages.dart -- son compartidas entre
/// el layout móvil y el de escritorio, así que no se duplican aquí.
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
                buildPageTeoria(
                  contenido,
                  leccion: widget.leccion,
                  temaNombre: widget.temaNombre,
                ),
                buildPagePractica(contenido, leccion: widget.leccion),
                buildPageRefuerzo(
                  contenido,
                  context,
                  temaNombre: widget.temaNombre,
                  leccion: widget.leccion,
                ),
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
                      buildPageTeoria(
                        contenido,
                        leccion: widget.leccion,
                        temaNombre: widget.temaNombre,
                      ),
                      buildPagePractica(contenido, leccion: widget.leccion),
                      buildPageRefuerzo(
                        contenido,
                        context,
                        temaNombre: widget.temaNombre,
                        leccion: widget.leccion,
                      ),
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
}
