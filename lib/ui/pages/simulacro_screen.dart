import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../../services/examen_service.dart';
import '../../models/simulacro_model.dart';
import 'resultado_screen.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import '../widgets/audio_player_card.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kTextDark = Color(0xFF1A0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kLightBackground = Color(0xFFF5F5F5);
const Color kDesktopCream = Color(0xFFF7EEE0);

/// =============================================================================
/// ⏱️ PANTALLA: lib/ui/pages/simulacro_screen.dart
/// =============================================================================
/// Interfaz para la toma de exámenes globales (Simulacros).
/// Implementa un entorno de alta presión con tiempo límite de 60 minutos.
/// =============================================================================

class SimulacroScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final dynamic authService;
  const SimulacroScreen({super.key, this.onBack, this.authService});

  @override
  State<SimulacroScreen> createState() => _SimulacroScreenState();
}

class _SimulacroScreenState extends State<SimulacroScreen>
    with IdiomaListenerMixin<SimulacroScreen> {
  // ─── CONTROLADOR DE EXAMEN ──────────────────────────────────────────────
  // Encapsula el temporizador y la gestión del banco de preguntas.
  final ExamenService _examenService = ExamenService();

  @override
  void initState() {
    super.initState();
    _examenService.addListener(_onServiceUpdate);

    // ─── CONFIGURACIÓN INICIAL ──────────────────────────────────────────────
    // Cargamos el banco de preguntas después de que el widget se monte,
    // escalado según el nivel actual del usuario (más preguntas/tiempo
    // cuanto más avanzado el nivel).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nivel =
          widget.authService?.usuarioActual?['nivel_actual'] as String? ??
          'A1';
      _examenService.inicializar(nivel: nivel);
    });
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _examenService.removeListener(_onServiceUpdate);
    // ⏱️ LIMPIEZA: Detenemos el reloj para evitar fugas de memoria.
    _examenService.stopTimer();
    super.dispose();
  }

  // ─── TRANSICIÓN A RESULTADOS ───────────────────────────────────────────
  // Envía al usuario a la pantalla de puntaje final tras completar el examen.
  void _finalizarExamen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadoScreen(
          correctas: _examenService.correctas,
          total: _examenService.totalQuestions,
          temaNombre: 'Simulacro Global',
          leccion: 'simulacro',
          authService: widget.authService,
        ),
      ),
    );
  }

  // ─── ETIQUETA DE HABILIDAD ──────────────────────────────────────────────
  // El examen ahora mezcla Grammar/Reading/Listening/Writing, así que cada
  // pregunta muestra a cuál pertenece.
  String _etiquetaHabilidad(String skill) {
    switch (skill) {
      case 'grammar':
        return AppStrings.tr('Grammar', 'Grammar');
      case 'listening':
        return AppStrings.tr('Listening', 'Listening');
      case 'writing':
        return AppStrings.tr('Writing', 'Writing');
      case 'reading':
      default:
        return AppStrings.tr('Reading', 'Reading');
    }
  }

  Widget _skillBadge(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimaryRed.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryRed.withOpacity(0.25), width: 1),
      ),
      child: Text(
        _etiquetaHabilidad(skill),
        style: AppFonts.poppins(
          color: kPrimaryRed,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─── TARJETA DE OPCIÓN CON FEEDBACK ─────────────────────────────────────
  // Verde cuando es la correcta, rojo si el usuario marcó la incorrecta,
  // gris para el resto — mismo esquema que usan las lecciones normales
  // (ejercicios_screen.dart) para que el feedback se sienta consistente en
  // toda la app.
  Widget _opcionSimulacro({
    required String texto,
    required bool isSelected,
    required bool mostrarResultado,
    required bool esCorrecta,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? iconData;

    if (mostrarResultado) {
      if (esCorrecta) {
        bgColor = Colors.green[100]!;
        borderColor = Colors.green[400]!;
        textColor = Colors.green[900]!;
        iconData = Icons.check_circle_rounded;
      } else if (isSelected) {
        bgColor = Colors.red[100]!;
        borderColor = Colors.red[400]!;
        textColor = Colors.red[900]!;
        iconData = Icons.close_rounded;
      } else {
        bgColor = Colors.grey[100]!;
        borderColor = Colors.grey[300]!;
        textColor = Colors.grey[700]!;
      }
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey[300]!;
      textColor = kTextDark;
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
    // ── PANTALLA DE CARGA ─────────────────────────────────────────────────
    if (_examenService.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryRed)),
      );
    }

    final pregunta = _examenService.preguntaActual;
    if (pregunta == null) {
      return Scaffold(
        body: Center(
          child: Text(
            AppStrings.tr(
              'No hay preguntas disponibles',
              'No questions available',
            ),
            style: AppFonts.poppins(),
          ),
        ),
      );
    }

    if (isDesktop(context)) {
      return _buildDesktopLayout(context, pregunta);
    }
    return _buildMobileLayout(context, pregunta);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileLayout(BuildContext context, SimulacroPregunta pregunta) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
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
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
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
                              color: Colors.black.withOpacity(0.38),
                            ),
                          ),
                          Center(
                            child: Text(
                              _examenService.formattedTime,
                              style: AppFonts.poppins(
                                color: _examenService.secondsRemaining < 300
                                    ? Colors.orange
                                    : kCream,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Título ─────────────────────────────────────────────
                  Text(
                    AppStrings.tr(
                      'Simulacro ${widget.authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                      'Mock Exam ${widget.authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                    ),
                    style: AppFonts.poppins(
                      color: kTextDark,
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
                          'Pregunta ${_examenService.currentQuestion} de ${_examenService.totalQuestions}',
                          'Question ${_examenService.currentQuestion} of ${_examenService.totalQuestions}',
                        ),
                        style: AppFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                      _skillBadge(pregunta.skill),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Barra de progreso ──────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _examenService.progress,
                      backgroundColor: Colors.grey[200],
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
                            'assets/images/fondo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.42),
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
                                    color: kCreamMuted,
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
                                    color: Colors.white.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    pregunta.passage!,
                                    style: AppFonts.poppins(
                                      color: kCream,
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
                                    color: kCreamMuted,
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
                                  color: kCream,
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
                  ...List.generate(_examenService.answers.length, (index) {
                    final isSelected = _examenService.selectedAnswer == index;
                    final esCorrecta = index == pregunta.correctIndex;
                    final mostrarResultado = _examenService.respondida;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: !_examenService.respondida
                            ? () => _examenService.selectAnswer(index)
                            : null,
                        child: _opcionSimulacro(
                          texto: _examenService.answers[index],
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
                  if (_examenService.respondida) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('💡 Explicación', '💡 Explanation'),
                            style: AppFonts.poppins(
                              color: kTextDark,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pregunta.explanation,
                            style: AppFonts.poppins(
                              color: kTextDark,
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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: _examenService.respondida
                  ? Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
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
                              color: Colors.black.withOpacity(0.35),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (!_examenService.nextQuestion()) {
                                  _finalizarExamen();
                                }
                              },
                              child: Center(
                                child: Text(
                                  _examenService.currentQuestion ==
                                          _examenService.totalQuestions
                                      ? AppStrings.tr(
                                          'Finalizar simulacro',
                                          'Finish exam',
                                        )
                                      : AppStrings.tr(
                                          'Siguiente pregunta',
                                          'Next question',
                                        ),
                                  style: AppFonts.poppins(
                                    color: kCream,
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
                        disabledBackgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.tr('Siguiente pregunta', 'Next question'),
                        style: AppFonts.poppins(
                          color: Colors.grey[400],
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

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — cabecera con temporizador en píldora,
  // tarjeta de pregunta con gradiente y opciones en filas con distintivo
  // de letra. Misma lógica de selección/avance que el móvil.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context, SimulacroPregunta pregunta) {
    return Scaffold(
      backgroundColor: kDesktopCream,
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
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.chevron_left, color: kTextDark),
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
                            'Simulacro ${widget.authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                            'Mock Exam ${widget.authService?.usuarioActual?['nivel_actual'] ?? 'A1'}',
                          ),
                          style: AppFonts.poppins(
                            color: kTextDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              AppStrings.tr(
                                'Pregunta ${_examenService.currentQuestion} de ${_examenService.totalQuestions}',
                                'Question ${_examenService.currentQuestion} of ${_examenService.totalQuestions}',
                              ),
                              style: AppFonts.poppins(
                                color: Colors.brown[300],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _skillBadge(pregunta.skill),
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
                          _examenService.formattedTime,
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
                  value: _examenService.progress,
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
                        color: Colors.black.withOpacity(0.42),
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
                                color: kCreamMuted,
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
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                pregunta.passage!,
                                style: AppFonts.poppins(
                                  color: kCream,
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
                                color: kCreamMuted,
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
                              color: kCream,
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
              ...List.generate(_examenService.answers.length, (index) {
                final isSelected = _examenService.selectedAnswer == index;
                final esCorrecta = index == pregunta.correctIndex;
                final mostrarResultado = _examenService.respondida;
                final letra = String.fromCharCode(65 + index);

                Color circleColor = kDesktopCream;
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
                      onTap: !_examenService.respondida
                          ? () => _examenService.selectAnswer(index)
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
                                _examenService.answers[index],
                                style: AppFonts.poppins(
                                  color: kTextDark,
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
              if (_examenService.respondida) ...[
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
                          color: kTextDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pregunta.explanation,
                        style: AppFonts.poppins(
                          color: kTextDark,
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
                  onPressed: _examenService.respondida
                      ? () {
                          if (!_examenService.nextQuestion()) {
                            _finalizarExamen();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRed,
                    disabledBackgroundColor: kDesktopCream,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    _examenService.currentQuestion ==
                            _examenService.totalQuestions
                        ? AppStrings.tr('Finalizar simulacro', 'Finish exam')
                        : AppStrings.tr(
                            'Siguiente pregunta',
                            'Next question',
                          ),
                    style: AppFonts.poppins(
                      color: _examenService.respondida
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
