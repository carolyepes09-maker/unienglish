import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_strings.dart';
import '../../widgets/audio_player_card.dart';
import '../../../services/examen_service.dart';
import '../../../models/simulacro_model.dart';
import 'simulacro_widgets.dart';

/// =============================================================================
/// WIDGET: lib/ui/pages/simulacro/simulacro_desktop_layout.dart
/// =============================================================================
/// Layout de escritorio de SimulacroScreen, extraído tal cual (sin cambiar
/// ninguna propiedad visual) desde simulacro_screen.dart. Cabecera con
/// temporizador en píldora, tarjeta de pregunta con gradiente y opciones en
/// filas con distintivo de letra. Misma lógica de selección/avance que el
/// móvil, que se queda en SimulacroScreen.
/// =============================================================================

const Color _kTextDark = Color(0xFF1A0000);
const Color _kCream = Color(0xFFF5E6D0);
const Color _kCreamMuted = Color(0xAAF5E6D0);
const Color _kDesktopCream = Color(0xFFF7EEE0);

class SimulacroDesktopLayout extends StatelessWidget {
  final ExamenService examenService;
  final SimulacroPregunta pregunta;
  final dynamic authService;
  final VoidCallback? onBack;
  final VoidCallback onFinalizarExamen;

  const SimulacroDesktopLayout({
    super.key,
    required this.examenService,
    required this.pregunta,
    required this.authService,
    required this.onBack,
    required this.onFinalizarExamen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDesktopCream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabecera ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (onBack != null) {
                          onBack!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.chevron_left, color: _kTextDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr(
                            'Simulacro ${authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                            'Mock Exam ${authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                          ),
                          style: AppFonts.poppins(
                            color: _kTextDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              AppStrings.tr(
                                'Pregunta ${examenService.currentQuestion} de ${examenService.totalQuestions}',
                                'Question ${examenService.currentQuestion} of ${examenService.totalQuestions}',
                              ),
                              style: AppFonts.poppins(
                                color: Colors.brown[300],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 10),
                            skillBadge(pregunta.skill),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          examenService.formattedTime,
                          style: AppFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: examenService.progress,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryRed),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              // ── Tarjeta de pregunta con textura ─────────────────────────
              Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/fondo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.42),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pregunta.passage != null) ...[
                            Text(
                              'Read the following passage and answer the question:',
                              style: AppFonts.poppins(
                                color: _kCreamMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (pregunta.passage != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                pregunta.passage!,
                                style: AppFonts.poppins(
                                  color: _kCream,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          if (pregunta.audioFile != null) ...[
                            Text(
                              AppStrings.tr(
                                'Escucha el audio y responde la pregunta:',
                                'Listen to the audio and answer the question:',
                              ),
                              style: AppFonts.poppins(
                                color: _kCreamMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AudioPlayerCard(
                              key: ValueKey(pregunta.audioFile),
                              audioFile: pregunta.audioFile,
                              standalone: false,
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            pregunta.question,
                            style: AppFonts.poppins(
                              color: _kCream,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Opciones de respuesta ───────────────────────────────────
              // Igual que en móvil: verde/rojo/gris según acierto una vez
              // respondida, con el mismo círculo con letra que ya usaba
              // esta pantalla de escritorio.
              ...List.generate(examenService.answers.length, (index) {
                final isSelected = examenService.selectedAnswer == index;
                final esCorrecta = index == pregunta.correctIndex;
                final mostrarResultado = examenService.respondida;
                final letra = String.fromCharCode(65 + index);

                Color circleColor = _kDesktopCream;
                Color letraColor = Colors.brown[400]!;
                Color cardColor = Colors.white;
                Color borderColor = Colors.grey[300]!;
                IconData? iconoResultado;

                if (mostrarResultado && esCorrecta) {
                  circleColor = Colors.green[400]!;
                  letraColor = Colors.white;
                  cardColor = Colors.green[50]!;
                  borderColor = Colors.green[400]!;
                  iconoResultado = Icons.check_circle_rounded;
                } else if (mostrarResultado && isSelected) {
                  circleColor = kPrimaryRed;
                  letraColor = Colors.white;
                  cardColor = const Color(0xFFFBEAEA);
                  borderColor = kPrimaryRed;
                  iconoResultado = Icons.close_rounded;
                } else if (isSelected) {
                  circleColor = kPrimaryRed;
                  letraColor = Colors.white;
                  cardColor = const Color(0xFFFBEAEA);
                  borderColor = kPrimaryRed;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: !examenService.respondida
                          ? () => examenService.selectAnswer(index)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: circleColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                letra,
                                style: AppFonts.poppins(
                                  color: letraColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                examenService.answers[index],
                                style: AppFonts.poppins(
                                  color: _kTextDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (iconoResultado != null)
                              Icon(iconoResultado, color: borderColor, size: 20)
                            else if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: kPrimaryRed,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // ── Explicación (escritorio) ────────────────────────────────
              if (examenService.respondida) ...[
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr('💡 Explicación', '💡 Explanation'),
                        style: AppFonts.poppins(
                          color: _kTextDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pregunta.explanation,
                        style: AppFonts.poppins(
                          color: _kTextDark,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // ── Botón siguiente ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: examenService.respondida
                      ? () {
                          if (!examenService.nextQuestion()) {
                            onFinalizarExamen();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRed,
                    disabledBackgroundColor: _kDesktopCream,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    examenService.currentQuestion ==
                            examenService.totalQuestions
                        ? AppStrings.tr('Finalizar simulacro', 'Finish exam')
                        : AppStrings.tr(
                            'Siguiente pregunta',
                            'Next question',
                          ),
                    style: AppFonts.poppins(
                      color: examenService.respondida
                          ? Colors.white
                          : Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
