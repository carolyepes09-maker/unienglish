import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_colors.dart';
import '../../widgets/audio_player_card.dart';
import '../../../services/examen_service.dart';
import '../../../models/simulacro_model.dart';
import 'simulacro_widgets.dart';

/// =============================================================================
/// WIDGET: lib/ui/pages/simulacro/simulacro_mobile_layout.dart
/// =============================================================================
/// Layout de teléfono de SimulacroScreen, extraído tal cual (sin cambiar
/// ninguna propiedad visual) desde simulacro_screen.dart para reducir el
/// tamaño de ese archivo. Toda la lógica de negocio (temporizador, avance de
/// preguntas, navegación a resultados) se queda en SimulacroScreen; este
/// widget solo recibe el estado ya resuelto.
/// =============================================================================

const Color _kCream = Color(0xFFF5E6D0);
const Color _kCreamMuted = Color(0xAAF5E6D0);

class SimulacroMobileLayout extends StatelessWidget {
  final ExamenService examenService;
  final SimulacroPregunta pregunta;
  final dynamic authService;
  final VoidCallback? onBack;
  final VoidCallback onFinalizarExamen;

  const SimulacroMobileLayout({
    super.key,
    required this.examenService,
    required this.pregunta,
    required this.authService,
    required this.onBack,
    required this.onFinalizarExamen,
  });

  // ─── TARJETA DE OPCIÓN CON FEEDBACK ─────────────────────────────────────
  // Verde cuando es la correcta, rojo si el usuario marcó la incorrecta,
  // gris para el resto — mismo esquema que usan las lecciones normales
  // (ejercicios_screen.dart) para que el feedback se sienta consistente en
  // toda la app.
  Widget _opcionSimulacro({
    required BuildContext context,
    required String texto,
    required bool isSelected,
    required bool mostrarResultado,
    required bool esCorrecta,
  }) {
    final isDark = AppColors.isDark(context);
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? iconData;

    if (mostrarResultado) {
      if (esCorrecta) {
        bgColor = isDark ? Colors.green.withValues(alpha: 0.18) : Colors.green[100]!;
        borderColor = isDark ? Colors.green.withValues(alpha: 0.6) : Colors.green[400]!;
        textColor = isDark ? Colors.green[200]! : Colors.green[900]!;
        iconData = Icons.check_circle_rounded;
      } else if (isSelected) {
        bgColor = isDark ? Colors.red.withValues(alpha: 0.18) : Colors.red[100]!;
        borderColor = isDark ? Colors.red.withValues(alpha: 0.6) : Colors.red[400]!;
        textColor = isDark ? Colors.red[200]! : Colors.red[900]!;
        iconData = Icons.close_rounded;
      } else {
        bgColor = AppColors.card(context);
        borderColor = AppColors.cardBorder(context);
        textColor = AppColors.textSecondary(context);
      }
    } else {
      bgColor = AppColors.card(context);
      borderColor = AppColors.cardBorder(context);
      textColor = AppColors.textPrimary(context);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: AppFonts.poppins(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (iconData != null)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(iconData, color: textColor, size: 20),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const SizedBox.shrink(),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ── TIMER con textura ──────────────────────────────────
                  // Recorte circular explícito con ClipOval (mismo patrón
                  // que ya usa el sello del login), en vez de depender del
                  // recorte automático de Container+BoxShape.circle.
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/fondo.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.38),
                              ),
                            ),
                            Center(
                              child: Text(
                                examenService.formattedTime,
                                style: AppFonts.poppins(
                                  color: examenService.secondsRemaining < 300
                                      ? Colors.orange
                                      : _kCream,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Título ─────────────────────────────────────────────
                  Text(
                    AppStrings.tr(
                      'Simulacro ${authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                      'Mock Exam ${authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                    ),
                    style: AppFonts.poppins(
                      color: AppColors.textPrimary(context),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.tr(
                          'Pregunta ${examenService.currentQuestion} de ${examenService.totalQuestions}',
                          'Question ${examenService.currentQuestion} of ${examenService.totalQuestions}',
                        ),
                        style: AppFonts.poppins(
                          color: AppColors.textSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                      skillBadge(pregunta.skill),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Barra de progreso ──────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: examenService.progress,
                      backgroundColor: AppColors.divider(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kPrimaryRed,
                      ),
                      minHeight: 5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── TARJETA PREGUNTA con textura ───────────────────────
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/fondo.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.42),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Instrucción de lectura: solo aplica cuando la
                              // pregunta trae un pasaje (Reading). Grammar,
                              // Listening y Writing no lo necesitan.
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

                              // Bloque de texto cita (solo si tiene passage)
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
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      height: 1.6,
                                    ),
                                  ),
                                ),

                              // Reproductor de audio: solo aplica cuando la
                              // pregunta es de Listening. Antes se preguntaba
                              // por un audio que no aparecía en ningún lado;
                              // ahora se puede escuchar aquí mismo.
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── OPCIONES DE RESPUESTA ──────────────────────────────
                  ...List.generate(examenService.answers.length, (index) {
                    final isSelected = examenService.selectedAnswer == index;
                    final esCorrecta = index == pregunta.correctIndex;
                    final mostrarResultado = examenService.respondida;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: !examenService.respondida
                            ? () => examenService.selectAnswer(index)
                            : null,
                        child: _opcionSimulacro(
                          context: context,
                          texto: examenService.answers[index],
                          isSelected: isSelected,
                          mostrarResultado: mostrarResultado,
                          esCorrecta: esCorrecta,
                        ),
                      ),
                    );
                  }),

                  // ── RETROALIMENTACIÓN: EXPLICACIÓN PEDAGÓGICA ──────────
                  // Solo se muestra apenas el usuario elige una respuesta,
                  // igual que en las lecciones normales.
                  if (examenService.respondida) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.isDark(context)
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.isDark(context)
                              ? Colors.blue.withValues(alpha: 0.40)
                              : Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('💡 Explicación', '💡 Explanation'),
                            style: AppFonts.poppins(
                              color: AppColors.textPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pregunta.explanation,
                            style: AppFonts.poppins(
                              color: AppColors.textPrimary(context),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── BOTÓN SIGUIENTE con textura ────────────────────────────────
          // Padding inferior de 80 (no 24): esta pantalla vive dentro de
          // MainNavigation, cuya barra de navegación inferior es flotante y
          // se superpone sobre el contenido (mismo motivo por el que
          // HomeScreen reserva 80px al final de su scroll). Con solo 24px,
          // el botón quedaba debajo de esa barra flotante -- la barra
          // absorbía el toque antes de que llegara al botón, y por eso
          // tampoco se sentía bien el gesto de scroll en esa zona.
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: examenService.respondida
                  ? Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/fondo.webp',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.35),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (!examenService.nextQuestion()) {
                                  onFinalizarExamen();
                                }
                              },
                              child: Center(
                                child: Text(
                                  examenService.currentQuestion ==
                                          examenService.totalQuestions
                                      ? AppStrings.tr(
                                          'Finalizar simulacro',
                                          'Finish exam',
                                        )
                                      : AppStrings.tr(
                                          'Siguiente pregunta',
                                          'Next question',
                                        ),
                                  style: AppFonts.poppins(
                                    color: _kCream,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: AppColors.card(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.tr('Siguiente pregunta', 'Next question'),
                        style: AppFonts.poppins(
                          color: AppColors.textSecondary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
