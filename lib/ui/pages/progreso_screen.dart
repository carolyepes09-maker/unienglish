import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/progreso_service.dart';
import '../utils/app_strings.dart';

import 'package:gif/gif.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kGoldAccent = Color(0xFF8B6914);
const Color kTextDark = Color(0xFF1A0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);

class ProgresoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ProgresoScreen({super.key, this.onBack});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen>
    with SingleTickerProviderStateMixin, IdiomaListenerMixin<ProgresoScreen> {
  late GifController _fireController;
  final ProgresoService _progresoService = ProgresoService();

  @override
  void initState() {
    super.initState();
    _fireController = GifController(vsync: this);
    _progresoService.addListener(_actualizarUI);
  }

  void _actualizarUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _progresoService.removeListener(_actualizarUI);
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
        title: Text(
          AppStrings.tr('Mi Progreso', 'My Progress'),
          style: AppFonts.poppins(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STAT CARDS — con textura ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    iconWidget: Gif(
                      image: const AssetImage('assets/images/Fire.gif'),
                      controller: _fireController,
                      autostart: Autostart.loop,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    label: AppStrings.tr('Racha', 'Streak'),
                    value: _progresoService.rachaDias.toString(),
                    subtitle: AppStrings.tr(
                      'días consecutivos',
                      'consecutive days',
                    ),
                    iconColor: kGoldAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    iconWidget: const Icon(
                      Icons.access_time,
                      color: kCream,
                      size: 16,
                    ),
                    label: AppStrings.tr('Tiempo total', 'Total time'),
                    value: _progresoService.tiempoTotalHoras.toString(),
                    subtitle: AppStrings.tr(
                      'horas este mes',
                      'hours this month',
                    ),
                    iconColor: kCream,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── GRÁFICA SEMANAL — con textura ───────────────────────────
            _textureCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('Actividad semanal', 'Weekly activity'),
                    style: AppFonts.poppins(
                      color: kCream,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      painter: Bar3DPainter(
                        values: _progresoService.actividadSemanal,
                        maxValue: _progresoService.maxActividad,
                        labels: _progresoService.etiquetasSemana,
                      ),
                      size: const Size(double.infinity, 180),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      AppStrings.tr('Minutos por día', 'Minutes per day'),
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── GRÁFICA RADAR — con textura ─────────────────────────────
            _textureCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('Habilidades', 'Skills'),
                    style: AppFonts.poppins(
                      color: kCream,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        radarBackgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),
                        radarBorderData: const BorderSide(
                          color: Colors.transparent,
                        ),
                        titlePositionPercentageOffset: 0.2,
                        titleTextStyle: AppFonts.poppins(
                          color: kCream,
                          fontSize: 12,
                        ),
                        getTitle: (index, angle) {
                          const titles = [
                            'Grammar',
                            'Reading',
                            'Listening',
                            'Writing',
                            'Speaking',
                          ];
                          return RadarChartTitle(text: titles[index]);
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor: kPrimaryRed.withValues(alpha: 0.35),
                            borderColor: kCream,
                            borderWidth: 2,
                            dataEntries: _progresoService.habilidadesValues.map((v) => RadarEntry(value: v)).toList(),
                          ),
                        ],
                        tickCount: 4,
                        ticksTextStyle: AppFonts.poppins(
                          color: kCreamMuted,
                          fontSize: 8,
                        ),
                        tickBorderData: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                        gridBorderData: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required Widget iconWidget,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.42)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    iconWidget,
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppFonts.poppins(
                        color: iconColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppFonts.poppins(
                    color: kCream,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppFonts.poppins(color: kCreamMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textureCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(4, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
            Padding(padding: const EdgeInsets.all(20), child: child),
          ],
        ),
      ),
    );
  }
}

class Bar3DPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final List<String> labels;

  Bar3DPainter({
    required this.values,
    required this.maxValue,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = size.width / (values.length * 2);
    final double depth = barWidth * 0.4; // profundidad 3D
    final double chartHeight = size.height - 40;

    // ── Eje Y con valores ──
    final List<int> yValues = [0, 20, 40, 60, 80];

    for (int yVal in yValues) {
      final double yPos = chartHeight - (yVal / maxValue) * chartHeight;

      // Línea horizontal sutil
      final Paint linePaint = Paint()
        ..color = const Color(0xFFF5E6D0).withValues(alpha: 0.10)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);

      // Número del eje Y
      final TextPainter yLabel = TextPainter(
        text: TextSpan(
          text: yVal.toString(),
          style: const TextStyle(color: Color(0xAAF5E6D0), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      yLabel.layout();
      yLabel.paint(canvas, Offset(0, yPos - yLabel.height / 2));
    }

    for (int i = 0; i < values.length; i++) {
      final double barHeight = (values[i] / maxValue) * chartHeight;
      final double x = i * (barWidth * 2) + barWidth * 0.5;
      final double y = chartHeight - barHeight;

      // ── Cara lateral derecha (más oscura) ──
      final Paint sidePaint = Paint()
        ..color = const Color(0xFF8B6914).withValues(alpha: 0.70)
        ..style = PaintingStyle.fill;

      final Path sidePath = Path()
        ..moveTo(x + barWidth, y)
        ..lineTo(x + barWidth + depth, y - depth)
        ..lineTo(x + barWidth + depth, chartHeight - depth)
        ..lineTo(x + barWidth, chartHeight)
        ..close();
      canvas.drawPath(sidePath, sidePaint);

      // ── Cara frontal (crema con gradiente) ──
      final Paint frontPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5E6D0), Color(0xFFD4B896), Color(0xFFB8956A)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), frontPaint);

      // ── Techo (más claro) ──
      final Paint topPaint = Paint()
        ..color = const Color(0xFFF5E6D0).withValues(alpha: 0.90)
        ..style = PaintingStyle.fill;

      final Path topPath = Path()
        ..moveTo(x, y)
        ..lineTo(x + depth, y - depth)
        ..lineTo(x + barWidth + depth, y - depth)
        ..lineTo(x + barWidth, y)
        ..close();
      canvas.drawPath(topPath, topPaint);

      // ── Label día debajo ──
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: AppFonts.poppins(color: kCreamMuted, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(x + barWidth / 2 - tp.width / 2, chartHeight + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
