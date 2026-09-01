import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import 'package:fluter_app/models/palabra_model.dart';
import 'package:fluter_app/services/vocabulario_service.dart';
import 'package:fluter_app/services/revision_service.dart';
import 'package:fluter_app/ui/pages/resultado_revision_screen.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kTextDark = Color(0xFF1C1C1C);

/// =============================================================================
/// 🎴 PANTALLA: lib/ui/pages/revision_screen.dart
/// =============================================================================
/// Interfaz de "Flashcards" interactiva.
/// Implementa el ciclo de Repetición Espaciada para el vocabulario.
/// =============================================================================

class RevisionScreen extends StatefulWidget {
  // ── REQUERIMIENTOS DE LA SESIÓN ──────────────────────────────────────────
  final List<PalabraModel>
  palabras; // Diccionario filtrado por fecha de revisión
  final VocabularioService vocabularioService; // Persistencia de datos

  const RevisionScreen({
    super.key,
    required this.palabras,
    required this.vocabularioService,
  });

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen>
    with IdiomaListenerMixin<RevisionScreen> {
  late RevisionService _revisionService; // Controlador de la lógica de negocio

  @override
  void initState() {
    super.initState();
    // ─── INICIALIZACIÓN DEL CONTROLADOR ─────────────────────────────────────
    // Creamos el servicio que llevará la cuenta del índice actual y las notas.
    _revisionService = RevisionService(
      palabras: widget.palabras,
      vocabularioService: widget.vocabularioService,
    );
    _revisionService.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _revisionService.removeListener(_onServiceUpdate);
    _revisionService.dispose();
    super.dispose();
  }

  // ─── ACCIÓN DE RESPUESTA DEL USUARIO ──────────────────────────────────────
  // Procesa si el usuario recordó la palabra correctamente o no.
  void _responder(bool sabia) {
    if (!_revisionService.responder(sabia)) {
      // 🏁 FIN DE LA SESIÓN: Si no hay más palabras, saltamos al resumen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultadoRevisionScreen(
            total: _revisionService.total,
            correctas: _revisionService.correctas,
            incorrectas: _revisionService.incorrectas,
            vocabularioService: widget.vocabularioService,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palabraActual = _revisionService.palabraActual;
    final progreso = _revisionService.progreso;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      // ── BARRA DE PROGRESO VISUAL ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: AppColors.divider(context),
            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryRed),
            minHeight: 8,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ─── ÁREA DE LA TARJETA (FLASHCARD) ────────────────────────────────
            // Al tocar la tarjeta, esta "gira" (toggle) para mostrar el significado.
            Expanded(
              child: GestureDetector(
                onTap: () => _revisionService.toggleReverso(),
                child: _textureCard(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _revisionService.mostrandoReverso
                          ? _buildReverso(palabraActual)
                          : _buildFrente(palabraActual),
                    ),
                  ),
                ),
              ),
            ),
            if (_revisionService.mostrandoReverso)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _responder(false),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.tr('No la sabía', "I didn't know it"),
                              style: AppFonts.poppins(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _responder(true),
                        child: _textureCard(
                          margin: EdgeInsets.zero,
                          child: Center(
                            child: Text(
                              AppStrings.tr('La sabía', 'I knew it'),
                              style: AppFonts.poppins(
                                color: kCream,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildFrente(PalabraModel palabra) {
    return Column(
      key: const ValueKey('frente'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          palabra.ingles,
          textAlign: TextAlign.center,
          style: AppFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kCream,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.tr('Toca para ver traducción', 'Tap to see translation'),
          style: AppFonts.poppins(color: kCreamMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildReverso(PalabraModel palabra) {
    return Column(
      key: const ValueKey('reverso'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          palabra.espanol,
          textAlign: TextAlign.center,
          style: AppFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kCream,
          ),
        ),
        if (palabra.ejemplo.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            palabra.ejemplo,
            textAlign: TextAlign.center,
            style: AppFonts.poppins(
              fontStyle: FontStyle.italic,
              color: kCreamMuted,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          AppStrings.tr(
            'Nivel actual: ${palabra.nivel}/5',
            'Current level: ${palabra.nivel}/5',
          ),
          style: AppFonts.poppins(color: kCreamMuted),
        ),
      ],
    );
  }

  Widget _textureCard({
    required Widget child,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = const EdgeInsets.all(20),
    double radius = 16,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(4, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fondo.webp', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.42)),
            ),
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
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
