import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import '../../services/auth_service.dart';
import '../../services/vocabulario_service.dart';
import '../../services/progreso_service.dart';
import '../utils/responsive.dart';
import '../utils/app_strings.dart';
import 'home/home_mobile_body.dart';
import 'home/home_desktop_body.dart';

/// =============================================================================
/// 🏠 PANTALLA: lib/ui/pages/home_screen.dart
/// =============================================================================
/// Es el centro de control de la aplicación una vez que el usuario ingresa.
///
/// FUNCIONALIDADES:
/// 1. Resumen de Perfil: Muestra el nombre, nivel y racha actual del estudiante.
/// 2. Acceso Rápido: Botones directos a las áreas principales (Lecciones, etc).
/// 3. Feed de Actividad: Muestra dinámicamente lo último que el usuario practicó
///    consultando el [ActividadService].
/// 4. Gamificación: Barra de progreso visual hacia el siguiente nivel.
///
/// El árbol de widgets de cada layout vive en lib/ui/pages/home/
/// (HomeMobileBody / HomeDesktopBody); esta clase solo posee el
/// GifController (necesita el TickerProvider de este State) y el
/// ProgresoService (para escuchar cambios y disparar el rebuild).
/// =============================================================================

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final VocabularioService vocabularioService;
  final Function(int)? onNavigate;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.vocabularioService,
    this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, IdiomaListenerMixin<HomeScreen> {
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
    if (isDesktop(context)) {
      return HomeDesktopBody(
        authService: widget.authService,
        vocabularioService: widget.vocabularioService,
        onNavigate: widget.onNavigate,
        fireController: _fireController,
        progresoService: _progresoService,
      );
    }
    return HomeMobileBody(
      authService: widget.authService,
      vocabularioService: widget.vocabularioService,
      onNavigate: widget.onNavigate,
      fireController: _fireController,
      progresoService: _progresoService,
    );
  }
}
