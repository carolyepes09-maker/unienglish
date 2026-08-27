import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import 'package:fluter_app/models/palabra_model.dart';
import 'package:fluter_app/services/vocabulario_service.dart';
import 'package:fluter_app/ui/pages/agregar_palabra_screen.dart';
import 'package:fluter_app/services/progreso_service.dart';

const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);

/// =============================================================================
/// 📊 PANTALLA: lib/ui/pages/resultado_revision_screen.dart
/// =============================================================================
/// Se muestra al finalizar una sesión de repaso (Flashcards).
/// Resume el desempeño del usuario y actualiza su progreso global.
/// =============================================================================

class ResultadoRevisionScreen extends StatelessWidget {
  final int total;
  final int correctas;
  final int incorrectas;
  final VocabularioService vocabularioService;

  ResultadoRevisionScreen({
    super.key,
    required this.total,
    required this.correctas,
    required this.incorrectas,
    required this.vocabularioService,
  }) {
    // ─── ACTUALIZACIÓN DE LOGROS ──────────────────────────────────────────
    // Al instanciar esta pantalla, notificamos al sistema de progreso que
    // el usuario ha completado una sesión de repaso para actualizar su racha.
    ProgresoService().registrarRevision(correctas);
  }

  // ─── LÓGICA DE FEEDBACK DINÁMICO ──────────────────────────────────────────
  // Calcula un mensaje personalizado basado en la precisión del usuario.
  String get _mensajeRendimiento {
    final porcentaje = correctas / total;
    if (porcentaje == 1) {
      return AppStrings.tr('¡Excelente memoria!', 'Excellent memory!');
    }
    if (porcentaje >= 0.7) {
      return AppStrings.tr('Muy bien, sigue así', 'Very good, keep it up');
    }
    if (porcentaje >= 0.5) {
      return AppStrings.tr('Buen esfuerzo', 'Good effort');
    }
    return AppStrings.tr('Sigue practicando', 'Keep practicing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── TARJETA DE RESUMEN (SCORECARD) ────────────────────────────
              // Muestra el desglose de aciertos y errores con colores semánticos.
              _textureCard(
                child: Column(
                  children: [
                    Text(
                      _mensajeRendimiento,
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.tr('Revisadas: $total', 'Reviewed: $total'),
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      AppStrings.tr(
                        'Correctas: $correctas',
                        'Correct: $correctas',
                      ),
                      style: AppFonts.poppins(
                        color: Colors.greenAccent,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      AppStrings.tr(
                        'Incorrectas: $incorrectas',
                        'Incorrect: $incorrectas',
                      ),
                      style: AppFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ─── INFORMACIÓN DE REPETICIÓN ESPACIADA ───────────────────
                    // Consulta al servicio cuántas palabras estarán disponibles
                    // para repasar en el futuro cercano según el algoritmo SM-2.
                    FutureBuilder<List<PalabraModel>>(
                      future: vocabularioService.obtenerPalabrasParaRepasar(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final proximas = (snapshot.data as List<PalabraModel>)
                            .where((p) => !p.necesitaRevision)
                            .length;
                        return Text(
                          AppStrings.tr(
                            'Vuelve mañana para revisar $proximas palabras',
                            'Come back tomorrow to review $proximas words',
                          ),
                          textAlign: TextAlign.center,
                          style: AppFonts.poppins(color: kCreamMuted),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // ─── ACCIÓN DE EXPANSIÓN ───────────────────────────────────────
              // Permite al usuario ir directamente a agregar más vocabulario.
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgregarPalabraScreen(
                        vocabularioService: vocabularioService,
                      ),
                    ),
                  );
                },
                child: _textureCard(
                  radius: 26,
                  child: Center(
                    child: Text(
                      AppStrings.tr('Agregar más palabras', 'Add more words'),
                      style: AppFonts.poppins(
                        color: kCream,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(AppStrings.tr('Volver al inicio', 'Back to home')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textureCard({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 6),
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
              child: Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
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
