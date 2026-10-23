import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../../services/examen_service.dart';
import 'resultado_screen.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import 'simulacro/simulacro_mobile_layout.dart';
import 'simulacro/simulacro_desktop_layout.dart';

const Color kPrimaryRed = Color(0xFFCC0000);

/// =============================================================================
/// ⏱️ PANTALLA: lib/ui/pages/simulacro_screen.dart
/// =============================================================================
/// Interfaz para la toma de exámenes globales (Simulacros).
/// Implementa un entorno de alta presión con tiempo límite de 60 minutos.
///
/// El árbol de widgets de cada layout vive en lib/ui/pages/simulacro/
/// (SimulacroMobileLayout / SimulacroDesktopLayout); esta clase se queda con
/// el temporizador/estado del examen (ExamenService) y la navegación a
/// resultados.
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
    // Si ya hay un examen en curso (el usuario cambió de pestaña y volvió),
    // se retoma tal cual en vez de empezar otro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_examenService.tiempoAgotado) {
        _finalizarExamen();
      } else if (!_examenService.enCurso) {
        final nivel =
            widget.authService?.usuarioActual?['nivel_actual'] as String? ??
            'A1';
        _examenService.inicializar(nivel: nivel);
      }
    });
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    if (_examenService.tiempoAgotado) {
      _finalizarExamen();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    // El reloj NO se detiene aquí: el examen sigue corriendo aunque el
    // usuario cambie de pestaña, como en un examen real. ExamenService lo
    // detiene al finalizar.
    _examenService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  // ─── TRANSICIÓN A RESULTADOS ───────────────────────────────────────────
  // Envía al usuario a la pantalla de puntaje final tras completar el examen.
  void _finalizarExamen() {
    _examenService.consumirTiempoAgotado();
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
      return SimulacroDesktopLayout(
        examenService: _examenService,
        pregunta: pregunta,
        authService: widget.authService,
        onBack: widget.onBack,
        onFinalizarExamen: _finalizarExamen,
      );
    }
    return SimulacroMobileLayout(
      examenService: _examenService,
      pregunta: pregunta,
      authService: widget.authService,
      onBack: widget.onBack,
      onFinalizarExamen: _finalizarExamen,
    );
  }
}
