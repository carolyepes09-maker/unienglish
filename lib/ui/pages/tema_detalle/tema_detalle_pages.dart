import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_strings.dart';
import '../../widgets/audio_player_card.dart';
import '../ejercicios_screen.dart';

/// =============================================================================
/// WIDGETS: lib/ui/pages/tema_detalle/tema_detalle_pages.dart
/// =============================================================================
/// Las tres páginas de contenido (Teoría, Práctica, Refuerzo) de
/// TemaDetalleScreen, extraídas tal cual (sin cambiar ninguna propiedad
/// visual) desde tema_detalle_screen.dart para reducir el tamaño de ese
/// archivo. Son compartidas entre el layout móvil y el de escritorio (ambos
/// las muestran dentro del mismo PageView), así que viven aparte en vez de
/// duplicarse.
/// =============================================================================

const Color _kGoldAccent = Color(0xFF8B6914);
const Color _kCream = Color(0xFFF5E6D0);
const Color _kCreamMuted = Color(0xAAF5E6D0);
const Color _kTextDark = Color(0xFF1C1C1C);

// Imagen ilustrativa por tema de Grammar (se muestra en la página de Teoría)
const Map<String, String> kGrammarTopicImages = {
  'Present Simple': 'assets/images/present_simple.jpg',
  'Present Continuous': 'assets/images/present_continuos.jpg',
  'Past Simple': 'assets/images/past_simple.jpg',
  'Present Perfect': 'assets/images/past_present.jpg',
};

// ═══════════════════════════════════════════════════════════════════════════
// PÁGINA 1 — Teoría: ¿Qué es? + ¿Cuándo se usa?
// ═══════════════════════════════════════════════════════════════════════════
Widget buildPageTeoria(
  dynamic contenido, {
  required String leccion,
  required String temaNombre,
}) {
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
            color: _kTextDark,
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
              color: _kCream,
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
            color: _kTextDark,
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
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppFonts.poppins(
                          color: _kCream,
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
                        color: _kCream,
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
        if (leccion == 'Grammar' &&
            kGrammarTopicImages.containsKey(temaNombre)) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              kGrammarTopicImages[temaNombre]!,
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
Widget buildPagePractica(dynamic contenido, {required String leccion}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // ═══════════════════════════════════════════════════════════════
          // SECCIÓN: ESTRUCTURA O INFORMACIÓN ESPECÍFICA
          // ═══════════════════════════════════════════════════════════════
          if (leccion == 'Grammar') ...[
            Text(
              AppStrings.tr('Estructura', 'Structure'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                  Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                  const SizedBox(height: 10),
                  _estructuraRow(
                    AppStrings.tr('Negativa', 'Negative'),
                    contenido.estructura.negativa,
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                  const SizedBox(height: 10),
                  _estructuraRow(
                    AppStrings.tr('Pregunta', 'Question'),
                    contenido.estructura.pregunta,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else if (leccion == 'Reading') ...[
            Text(
              AppStrings.tr('Estructura de lectura', 'Reading structure'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                        color: _kCream,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else if (leccion == 'Listening') ...[
            AudioPlayerCard(audioFile: contenido.audioFile as String?),
            const SizedBox(height: 20),
            Text(
              AppStrings.tr('Transcripción', 'Transcript'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                        color: _kCream,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else if (leccion == 'Writing') ...[
            Text(
              AppStrings.tr(
                'Criterios de evaluación',
                'Evaluation criteria',
              ),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                        color: _kCream,
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
          if (leccion == 'Grammar') ...[
            Text(
              AppStrings.tr('Ejemplos', 'Examples'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                          color: _kCream,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contenido.ejemplos[index].traduccion,
                        style: AppFonts.poppins(
                          color: _kCreamMuted,
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
          ] else if (leccion == 'Reading') ...[
            Text(
              AppStrings.tr('Texto ejemplo', 'Sample text'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                      color: _kCream,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                  const SizedBox(height: 10),
                  Text(
                    contenido.textoEjemplo.traduccion,
                    style: AppFonts.poppins(
                      color: _kCreamMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else if (leccion == 'Listening') ...[
            Text(
              AppStrings.tr('Transcripción', 'Transcript'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                      color: _kCream,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                  const SizedBox(height: 10),
                  Text(
                    contenido.transcript.traduccion,
                    style: AppFonts.poppins(
                      color: _kCreamMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ] else if (leccion == 'Writing') ...[
            Text(
              AppStrings.tr('Ejemplo modelo', 'Model example'),
              style: AppFonts.poppins(
                color: _kTextDark,
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
                      color: _kCream,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                  const SizedBox(height: 10),
                  Text(
                    contenido.ejemploModelo.traduccion,
                    style: AppFonts.poppins(
                      color: _kCreamMuted,
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
Widget buildPageRefuerzo(
  dynamic contenido,
  BuildContext context, {
  required String temaNombre,
  required String leccion,
}) {
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
              color: _kTextDark,
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
                      color: _kTextDark,
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
              color: _kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _kGoldAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _kGoldAccent.withValues(alpha: 0.3),
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
                          color: _kGoldAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          contenido.tipsParaRecordar[index],
                          style: AppFonts.poppins(
                            color: _kTextDark,
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
                    temaNombre: temaNombre,
                    leccion: leccion,
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
                    color: _kCream,
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
          color: _kGoldAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        estructura,
        style: AppFonts.poppins(color: _kCream, fontSize: 13, height: 1.6),
      ),
    ],
  );
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
          // Textura roja
          Positioned.fill(
            child: Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
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
          Padding(padding: padding, child: child),
        ],
      ),
    ),
  );
}
