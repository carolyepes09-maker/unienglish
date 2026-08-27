import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/responsive.dart';
import '../../services/ejercicio_service.dart';
import 'resultado_screen.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kTextDark = Color(0xFF1C1C1C);
const Color kDesktopCream = Color(0xFFF7EEE0);

class EjerciciosScreen extends StatefulWidget {
  final String temaNombre;
  final String leccion;

  const EjerciciosScreen({
    super.key,
    required this.temaNombre,
    required this.leccion,
  });

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen>
    with IdiomaListenerMixin<EjerciciosScreen> {
  final EjercicioService _ejercicioService = EjercicioService();

  @override
  void initState() {
    super.initState();
    _ejercicioService.iniciarLeccion(widget.leccion, widget.temaNombre);
    _ejercicioService.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ejercicioService.removeListener(_onServiceUpdate);
    _ejercicioService.dispose();
    super.dispose();
  }

  /// ─── NAVEGACIÓN DE PREGUNTAS ───────────────────────────────────────────
  /// Decide si continuar con la siguiente pregunta o finalizar la lección.
  void _siguientePregunta() {
    if (!_ejercicioService.siguientePregunta()) {
      // 1. FINALIZACIÓN: Si no hay más preguntas, guardamos el log en el historial.
      _ejercicioService.finalizar(widget.leccion, widget.temaNombre);

      // 2. CAMBIO DE PANTALLA: Enviamos al usuario a la vista de resultados.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultadoScreen(
            correctas: _ejercicioService.correctas,
            total: _ejercicioService.totalPreguntas,
            temaNombre: widget.temaNombre,
            leccion: widget.leccion,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga mientras se procesa el JSON de lecciones.
    if (_ejercicioService.contenido == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isDesktop(context)) {
      return _buildDesktopLayout(context);
    }
    return _buildMobileLayout(context);
  }

  /// Layout original de teléfono — sin ningún cambio.
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      // ── BARRA SUPERIOR DINÁMICA ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _ejercicioService.contenido?.titulo ?? '',
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
        child: _buildContent(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — cabecera propia centrada con ancho máximo,
  // reutiliza exactamente el mismo contenido de pregunta/opciones que móvil.
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      _ejercicioService.contenido?.titulo ?? '',
                      style: AppFonts.poppins(
                        color: AppColors.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CONTENIDO COMPARTIDO: pregunta, opciones, explicación y botón ───────
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // ── INDICADORES DE AVANCE: TEXTO Y BARRA ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.tr(
                    'Pregunta ${_ejercicioService.preguntaActual + 1} de ${_ejercicioService.totalPreguntas}',
                    'Question ${_ejercicioService.preguntaActual + 1} of ${_ejercicioService.totalPreguntas}',
                  ),
                  style: AppFonts.poppins(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(_ejercicioService.progreso * 100).toInt()}%',
                  style: AppFonts.poppins(
                    color: kPrimaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Barra de progreso visual que se llena pregunta tras pregunta.
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _ejercicioService.progreso,
                backgroundColor: AppColors.divider(context),
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryRed),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 24),

            // ── ENUNCIADO DE LA PREGUNTA: DISEÑO PREMIUM ─────────────────────
            _textureCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                _ejercicioService
                        .contenido
                        ?.ejercicios[_ejercicioService.preguntaActual]
                        .pregunta ??
                    '',
                style: AppFonts.poppins(
                  color: kCream,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── BLOQUE DE OPCIONES: LISTA DINÁMICA ────────────────────────────
            ...List.generate(
              _ejercicioService
                      .contenido
                      ?.ejercicios[_ejercicioService.preguntaActual]
                      .opciones
                      .length ??
                  0,
              (index) {
                final isSelected =
                    _ejercicioService.respuestaSeleccionada == index;
                final esCorrecta =
                    index ==
                    _ejercicioService
                        .contenido
                        ?.ejercicios[_ejercicioService.preguntaActual]
                        .correcta;
                final mostrarResultado = _ejercicioService.respondida;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: !_ejercicioService.respondida
                        ? () => _ejercicioService.seleccionarRespuesta(index)
                        : null,
                    child: _opcionCard(
                      texto: _ejercicioService
                          .contenido!
                          .ejercicios[_ejercicioService.preguntaActual]
                          .opciones[index],
                      isSelected: isSelected,
                      mostrarResultado: mostrarResultado,
                      esCorrecta: esCorrecta,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── RETROALIMENTACIÓN: EXPLICACIÓN PEDAGÓGICA ─────────────────────
            // Solo se muestra cuando el usuario ya ha tomado una decisión.
            if (_ejercicioService.respondida)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          _ejercicioService
                                  .contenido
                                  ?.ejercicios[_ejercicioService.preguntaActual]
                                  .explicacion ??
                              '',
                          style: AppFonts.poppins(
                            color: AppColors.textPrimary(context),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // ── CONTROL DE FLUJO: BOTÓN SIGUIENTE ────────────────────────────
            if (_ejercicioService.respondida)
              GestureDetector(
                onTap: _siguientePregunta,
                child: _textureCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  radius: 26,
                  child: Center(
                    child: Text(
                      _ejercicioService.preguntaActual <
                              _ejercicioService.totalPreguntas - 1
                          ? AppStrings.tr(
                              'Siguiente pregunta →',
                              'Next question →',
                            )
                          : AppStrings.tr(
                              'Ver resultados →',
                              'View results →',
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

            const SizedBox(height: 20),
      ],
    );
  }

  // ─── COMPONENTE: TARJETA DE RESPUESTA ────────────────────────────────────
  // Cambia de color dinámicamente: Verde (ACIERTO), Rojo (ERROR), Azul (SÉLEC).
  Widget _opcionCard({
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
        // Opción correcta - verde
        bgColor = isDark ? Colors.green.withValues(alpha: 0.18) : Colors.green[100]!;
        borderColor = isDark ? Colors.green.withValues(alpha: 0.6) : Colors.green[400]!;
        textColor = isDark ? Colors.green[200]! : Colors.green[900]!;
        iconData = Icons.check_circle_rounded;
      } else if (isSelected) {
        // Opción seleccionada pero incorrecta - rojo
        bgColor = isDark ? Colors.red.withValues(alpha: 0.18) : Colors.red[100]!;
        borderColor = isDark ? Colors.red.withValues(alpha: 0.6) : Colors.red[400]!;
        textColor = isDark ? Colors.red[200]! : Colors.red[900]!;
        iconData = Icons.close_rounded;
      } else {
        // Opción no seleccionada
        bgColor = AppColors.card(context);
        borderColor = AppColors.cardBorder(context);
        textColor = AppColors.textSecondary(context);
      }
    } else if (isSelected) {
      // Seleccionada pero sin responder aún
      bgColor = const Color(0xFF1A0000);
      borderColor = kPrimaryRed;
      textColor = kCream;
      iconData = Icons.check_circle_rounded;
    } else {
      bgColor = AppColors.card(context);
      borderColor = AppColors.cardBorder(context);
      textColor = AppColors.textPrimary(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: AppFonts.poppins(
                color: textColor,
                fontSize: 14,
                fontWeight: isSelected || mostrarResultado
                    ? FontWeight.w600
                    : null,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET — Tarjeta con textura roja
  // ═══════════════════════════════════════════════════════════════════════════
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
}
