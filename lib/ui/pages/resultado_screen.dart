import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import '../utils/responsive.dart';
import '../../models/grammar_content.dart';
import '../../models/reading_content.dart';
import '../../models/listening_content.dart';
import '../../models/writing_content.dart';
import 'ejercicios_screen.dart';
import 'tema_detalle_screen.dart';
import 'simulacro_screen.dart';

// ─── SISTEMA DE DISEÑO (COLORES) ──────────────────────────────────────────
const Color kPrimaryRed = Color(0xFFCC0000); // Rojo institucional (Libre)
const Color kGoldAccent = Color(0xFF8B6914); // Dorado para detalles premium
const Color kCream = Color(0xFFF5E6D0); // Fondo color crema para textos
const Color kCreamMuted = Color(0xAAF5E6D0); // Crema con transparencia
const Color kTextDark = Color(0xFF1C1C1C); // Negro elegante para legibilidad
const Color kDesktopCream = Color(0xFFF7EEE0);

/// =============================================================================
/// 🏆 PANTALLA: lib/ui/pages/resultado_screen.dart
/// =============================================================================
/// Se activa cuando un usuario termina un set de ejercicios (Grammar, Reading, etc).
/// Proporciona feedback visual inmediato y opciones de navegación para continuar.
/// =============================================================================

class ResultadoScreen extends StatelessWidget {
  // ── ATRIBUTOS DE RESULTADO ────────────────────────────────────────────────
  final int correctas; // Aciertos del usuario
  final int total; // Cantidad total de preguntas
  final String temaNombre; // Identificador de la lección (ej: "Present Simple")
  final String leccion; // Categoría del aprendizaje
  final dynamic authService;

  // El progreso lo registra quien termina la sesión (EjerciciosScreen o
  // ExamenService), no esta pantalla: así un simulacro no cuenta además
  // como lección, y un constructor que se ejecute dos veces no suma doble.
  const ResultadoScreen({
    super.key,
    required this.correctas,
    required this.total,
    required this.temaNombre,
    required this.leccion,
    this.authService,
  });

  // ─── LÓGICA DE PRESENTACIÓN ────────────────────────────────────────────────
  // Métodos que ayudan a decidir qué colores, iconos y textos mostrar según la nota.
  double get porcentaje => (correctas / total) * 100;

  String get mensaje {
    final pct = porcentaje;
    if (pct == 100) {
      return AppStrings.tr(
        '¡Perfecto! Dominas este tema',
        "Perfect! You've mastered this topic",
      );
    }
    if (pct >= 80) {
      return AppStrings.tr(
        '¡Muy bien! Entiendes el concepto',
        'Great! You understand the concept',
      );
    }
    if (pct >= 60) {
      return AppStrings.tr(
        'Buen intento. Repasa los puntos clave',
        'Good try. Review the key points',
      );
    }
    return AppStrings.tr(
      'Necesitas más práctica. ¡Vuelve a intentar!',
      'You need more practice. Try again!',
    );
  }

  IconData get iconDesempeno {
    final pct = porcentaje;
    if (pct == 100) return Icons.emoji_events_rounded;
    if (pct >= 80) return Icons.thumb_up_rounded;
    if (pct >= 60) return Icons.psychology_rounded;
    return Icons.refresh_rounded;
  }

  Color get colorDesempeno {
    final pct = porcentaje;
    if (pct == 100) return const Color(0xFFFFD700); // Oro (Perfecto)
    if (pct >= 80) return Colors.green; // Verde (Excelente)
    if (pct >= 60) return const Color(0xFFFFA500); // Naranja (Aprobado)
    return kPrimaryRed; // Rojo (Reintentar)
  }

  @override
  Widget build(BuildContext context) {
    // ─── PREPARACIÓN DE NAVEGACIÓN ──────────────────────────────────────────
    // Buscamos cuál es la categoría correcta para poder redirigir al usuario
    // a una lección adyacente o volver al inicio.
    Map<String, dynamic>? temasMap;
    bool esSimulacro = leccion.toLowerCase() == 'simulacro';

    if (!esSimulacro) {
      switch (leccion) {
        case 'Grammar':
          temasMap = grammarTopics;
          break;
        case 'Reading':
          temasMap = readingTopics;
          break;
        case 'Listening':
          temasMap = listeningTopics;
          break;
        case 'Writing':
          temasMap = writingTopics;
          break;
        default:
          temasMap = grammarTopics;
      }
    }

    final temas = temasMap?.keys.toList() ?? [];
    final indiceActual = temas.indexOf(temaNombre);
    final siguienteTema =
        (!esSimulacro && indiceActual != -1 && indiceActual < temas.length - 1)
        ? temas[indiceActual + 1]
        : null;

    if (isDesktop(context)) {
      return _buildDesktopLayout(context, esSimulacro, siguienteTema);
    }
    return _buildMobileLayout(context, esSimulacro, siguienteTema);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileLayout(
    BuildContext context,
    bool esSimulacro,
    String? siguienteTema,
  ) {
    return PopScope(
      // Deshabilita el botón/gesto atrás: obliga a usar los botones propios
      // de la pantalla. PopScope (a diferencia de WillPopScope) sí participa
      // en la animación del gesto predictivo de Android, así que el swipe se
      // ve fluido y "rebota" en vez de quedar la pantalla colgada a medias.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.background(context),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            AppStrings.tr('Resultados', 'Results'),
            style: AppFonts.poppins(
              color: AppColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildContent(context, esSimulacro, siguienteTema),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — tarjeta de resultado centrada con ancho
  // máximo, reutiliza exactamente el mismo contenido que el móvil.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(
    BuildContext context,
    bool esSimulacro,
    String? siguienteTema,
  ) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.tr('Resultados', 'Results'),
                    style: AppFonts.poppins(
                      color: AppColors.textPrimary(context),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildContent(context, esSimulacro, siguienteTema),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── CONTENIDO COMPARTIDO: ícono, puntuación, mensaje y botones ──────────
  Widget _buildContent(
    BuildContext context,
    bool esSimulacro,
    String? siguienteTema,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
              const SizedBox(height: 20),

              // ÍCONO DE DESEMPEÑO
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorDesempeno.withValues(alpha: 0.15),
                  border: Border.all(color: colorDesempeno, width: 3),
                ),
                child: Icon(iconDesempeno, color: colorDesempeno, size: 40),
              ),

              const SizedBox(height: 24),

              // PUNTUACIÓN GRANDE
              Text(
                '$correctas/$total',
                style: AppFonts.poppins(
                  color: AppColors.textPrimary(context),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // PORCENTAJE
              Container(
                decoration: BoxDecoration(
                  color: colorDesempeno.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorDesempeno.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  '${porcentaje.toStringAsFixed(0)}%',
                  style: AppFonts.poppins(
                    color: colorDesempeno,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BARRA DE PROGRESO VISUAL
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? correctas / total : 0,
                  backgroundColor: AppColors.divider(context),
                  valueColor: AlwaysStoppedAnimation<Color>(colorDesempeno),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 24),

              // MENSAJE
              _textureCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.tr(
                        'Respondiste correctamente $correctas de $total preguntas',
                        'You answered $correctas out of $total questions correctly',
                      ),
                      textAlign: TextAlign.center,
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // DETALLES DE RESPUESTAS
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.check_circle_rounded,
                      label: AppStrings.tr('Correctas', 'Correct'),
                      valor: '$correctas',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context: context,
                      icon: Icons.close_rounded,
                      label: AppStrings.tr('Incorrectas', 'Incorrect'),
                      valor: '${total - correctas}',
                      color: kPrimaryRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // BOTONES DE ACCIÓN

              // Botón 1: Volver a intentar
              GestureDetector(
                onTap: () {
                  if (esSimulacro) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SimulacroScreen(
                          authService:
                              authService, // Usar el authService pasado desde la pantalla anterior
                        ),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EjerciciosScreen(
                          temaNombre: temaNombre,
                          leccion: leccion,
                        ),
                      ),
                    );
                  }
                },
                child: _textureCard(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  radius: 26,
                  child: Center(
                    child: Text(
                      AppStrings.tr('Volver a intentar', 'Try again'),
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Botón 2: Siguiente lección (Solo si NO es simulacro y HAY siguiente tema)
              if (!esSimulacro && siguienteTema != null)
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TemaDetalleScreen(
                          temaNombre: siguienteTema,
                          leccion: leccion,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: kGoldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: kGoldAccent.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        AppStrings.tr(
                          'Siguiente lección: $siguienteTema →',
                          'Next lesson: $siguienteTema →',
                        ),
                        style: AppFonts.poppins(
                          color: kGoldAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Botón 3: Regresar (Siempre visible)
              GestureDetector(
                onTap: () {
                  if (esSimulacro) {
                    // Si es simulacro, usamos pushReplacementNamed('/main') para evitar la pantalla en blanco
                    // ya que el simulacro reemplazó la estructura principal de navegación.
                    Navigator.of(context).pushReplacementNamed('/main');
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.cardBorder(context), width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      esSimulacro
                          ? AppStrings.tr(
                              'Salir del simulacro',
                              'Exit simulation',
                            )
                          : AppStrings.tr(
                              'Regresar a lecciones',
                              'Back to lessons',
                            ),
                      style: AppFonts.poppins(
                        color: AppColors.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
      ],
    );
  }

  Widget _statCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String valor,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: AppFonts.poppins(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppFonts.poppins(
              color: AppColors.textPrimary(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textureCard({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    EdgeInsets padding = const EdgeInsets.all(20),
    double radius = 16,
  }) {
    return Container(
      width: double.infinity,
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
