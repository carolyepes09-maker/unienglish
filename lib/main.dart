import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/utils/app_fonts.dart';
import 'ui/utils/app_strings.dart';
import 'utils/app_logger.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/progreso_service.dart';
import 'services/vocabulario_service.dart';
import 'services/actividad_service.dart';
import 'services/idioma_service.dart';
import 'ui/pages/login_screen.dart';
import 'ui/pages/home_screen.dart';
import 'ui/pages/lecciones_screen.dart';
import 'ui/pages/progreso_screen.dart';
import 'ui/pages/simulacro_screen.dart';
import 'ui/pages/perfil_screen.dart';
import 'ui/pages/leccion_detalle_screen.dart';
import 'ui/pages/tema_detalle_screen.dart';
import 'ui/pages/ejercicios_screen.dart';
import 'ui/pages/resultado_screen.dart';
import 'ui/utils/responsive.dart';

// Servicios globales
late final AuthService _authService;
late final ProgresoService _progresoService;
late final VocabularioService _vocabularioService;
late final ActividadService _actividadService;
final IdiomaService _idiomaService = IdiomaService();

// =============================================================================
// CONSTANTES DE COLORES - UniEnglish Design System
// =============================================================================
const kPrimaryRed = Color(0xFF8B0000);
const kDarkCard = Color(0xFF1C0A00);
const kGoldAccent = Color(0xFF8B7A2F);
const kBackground = Color(0xFFFFFFFF);
const kLightBackground = Color(0xFFF5F5F5);
const kTextDark = Color(0xFF1C1C1C);

// ─── INICIALIZACIÓN ASÍNCRONA (Firebase + servicios) ───────────────────────
// Antes esta lógica se esperaba por completo ANTES de llamar a runApp(), lo
// que dejaba al usuario viendo una pantalla en blanco mientras se resolvían
// las llamadas de red (Firebase + Firestore). Ahora runApp() se llama de
// inmediato y este Future se espera dentro del árbol de widgets (ver
// _AppBootstrap), mostrando una pantalla de carga mientras tanto.
Future<void> _inicializarServicios() async {
  // Los servicios se construyen SIEMPRE, pase lo que pase con Firebase más
  // abajo: son solo instancias de singleton (sin I/O en el constructor). Si
  // esto quedara dentro del try y Firebase.initializeApp() fallara antes de
  // llegar aquí, estas variables late final nunca se asignarían, y
  // AuthWrapper truena con LateInitializationError apenas las lee -- el
  // "seguir funcionando a pesar del error" de más abajo no serviría de nada.
  _authService = AuthService();
  _progresoService = ProgresoService();
  _vocabularioService = VocabularioService(_authService);
  _actividadService = ActividadService();

  try {
    AppLogger.log('🔄 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
    AppLogger.log('✅ Firebase inicializado');

    // ActividadService necesita el uid que restaura AuthService.initialize()
    // para poder sincronizar 'actividades_recientes' desde Firestore, así que
    // se espera primero. Los otros 3 no dependen entre sí durante su
    // initialize() (cada uno solo toca SharedPreferences/rootBundle/Firestore
    // de forma aislada), así que siguen en paralelo entre ellos.
    AppLogger.log('🔄 Inicializando servicios...');
    await _authService.initialize();
    await Future.wait([
      _progresoService.initialize(),
      _vocabularioService.initialize(),
      _actividadService.initialize(),
      _idiomaService.initialize(),
    ]);

    AppLogger.log('✅ Todos los servicios inicializados exitosamente');
  } catch (e, stackTrace) {
    AppLogger.log('❌ ERROR DURANTE INICIALIZACION: $e');
    AppLogger.log('Stack trace: $stackTrace');
    AppLogger.log('⚠️ IMPORTANTE: Continuando con la app a pesar del error');
    // NO hacer rethrow - continuamos con la app de todas formas
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniEnglishApp());
}

// =============================================================================
// BOOTSTRAP — Espera Firebase + servicios mostrando una pantalla de carga en
// vez de bloquear runApp(). Solo una vez resuelto el Future se construye
// AuthWrapper (y con él, cualquier pantalla que dependa de los servicios
// globales ya inicializados).
// =============================================================================
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  // Red de seguridad adicional: cada llamada a Firestore ya tiene su propio
  // límite de tiempo (ver auth_service.dart), pero este timeout general
  // garantiza que la pantalla de carga nunca quede colgada para siempre
  // sin importar qué falle.
  late final Future<void> _initFuture = _inicializarServicios().timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      AppLogger.log('⚠️ Timeout general inicializando la app, continuando de todas formas');
    },
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }
        return const AuthWrapper();
      },
    );
  }
}

// ─── PANTALLA DE CARGA ───────────────────────────────────────────────────────
// Se muestra mientras se resuelven Firebase.initializeApp() y los servicios
// globales (auth, progreso, vocabulario, actividad).
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkCard,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'UniEnglish',
              style: AppFonts.poppins(
                color: kBackground,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: kGoldAccent),
          ],
        ),
      ),
    );
  }
}

class UniEnglishApp extends StatefulWidget {
  const UniEnglishApp({super.key});

  @override
  State<UniEnglishApp> createState() => _UniEnglishAppState();
}

class _UniEnglishAppState extends State<UniEnglishApp> {
  // Reconstruye toda la app (MaterialApp incluido) cuando el usuario cambia
  // el idioma de interfaz en Perfil, para que el `locale` de los widgets de
  // Flutter (selección de texto, diálogos del sistema, etc.) también cambie.
  @override
  void initState() {
    super.initState();
    _idiomaService.addListener(_onIdiomaChanged);
  }

  void _onIdiomaChanged() => setState(() {});

  @override
  void dispose() {
    _idiomaService.removeListener(_onIdiomaChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idiomaActual = _idiomaService.idioma == AppIdioma.en
        ? const Locale('en')
        : const Locale('es');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniEnglish',
      locale: idiomaActual,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimaryRed,
        textTheme: AppFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: kBackground,
          elevation: 0,
          iconTheme: const IconThemeData(color: kTextDark),
          titleTextStyle: AppFonts.poppins(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const _AppBootstrap(),
      routes: {
        '/main': (context) => const MainNavigation(),
        '/simulacro_test': (context) =>
            SimulacroScreen(authService: _authService),
        '/leccion_detalle': (context) => const LeccionDetalleScreen(
          titulo: 'Grammar',
          subtitulo: 'Gramática',
          icon: Icons.abc,
          progress: 0.75,
        ),
        '/tema_detalle': (context) => const TemaDetalleScreen(
          temaNombre: 'Present Simple',
          leccion: 'grammar',
        ),
        '/ejercicios': (context) => const EjerciciosScreen(
          temaNombre: 'Present Simple',
          leccion: 'grammar',
        ),
        '/resultado': (context) => ResultadoScreen(
          correctas: 5,
          total: 5,
          temaNombre: 'Present Simple',
          leccion: 'grammar',
        ),
      },
    );
  }
}

// =============================================================================
// MAIN NAVIGATION - Bottom Navigation Bar con 5 tabs
// =============================================================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with IdiomaListenerMixin<MainNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String _navLabel(int index) {
    switch (index) {
      case 0:
        return AppStrings.tr('Home', 'Home');
      case 1:
        return AppStrings.tr('Lecciones', 'Lessons');
      case 2:
        return AppStrings.tr('Simulacros', 'Mock Tests');
      case 3:
        return AppStrings.tr('Progreso', 'Progress');
      case 4:
        return AppStrings.tr('Perfil', 'Profile');
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Cambia de pestaña de forma programática (tap en la barra de navegación,
  /// onBack de una pantalla, etc.) animando el PageView para que se vea
  /// igual de fluido que un swipe manual.
  void _irAPantalla(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // Cada pantalla va envuelta en su propio RepaintBoundary: así, mientras el
  // PageView la desplaza durante el swipe, el motor solo mueve/compone su
  // capa ya pintada en vez de repintar todo el árbol de widgets en cada
  // frame — es lo que hace que el gesto se sienta fluido y no retardado.
  List<Widget> get _screens => [
    RepaintBoundary(
      child: HomeScreen(
        authService: _authService,
        vocabularioService: _vocabularioService,
        onNavigate: _irAPantalla,
      ),
    ),
    RepaintBoundary(
      child: LeccionesScreen(
        authService: _authService,
        onBack: () => _irAPantalla(0),
      ),
    ),
    RepaintBoundary(
      child: SimulacroScreen(
        authService: _authService,
        onBack: () => _irAPantalla(0),
      ),
    ),
    RepaintBoundary(
      child: ProgresoScreen(onBack: () => _irAPantalla(0)),
    ),
    RepaintBoundary(
      child: PerfilScreen(
        authService: _authService,
        onBack: () => _irAPantalla(0),
      ),
    ),
  ];

  static const List<_NavItemData> _navItems = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItemData(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'Lecciones',
    ),
    _NavItemData(icon: Icons.timer_outlined, activeIcon: Icons.timer, label: 'Simulacros'),
    _NavItemData(
      icon: Icons.trending_up_outlined,
      activeIcon: Icons.trending_up,
      label: 'Progreso',
    ),
    _NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return _buildDesktopLayout(context);
    }
    return _buildMobileLayout(context);
  }

  /// Layout de teléfono — ahora con PageView para poder deslizar el dedo
  /// entre pestañas (izquierda/derecha), sincronizado con la barra inferior.
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      // Deja que el contenido llegue hasta abajo, por debajo de la barra de
      // vidrio, para que esta quede flotando sobre él en vez de empujarlo
      // con un borde duro (parte del efecto de vidrio).
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const PageScrollPhysics(),
        // false (por defecto): cada pestaña trae su propia animación en
        // loop (el GIF de racha en Home/Progreso/Perfil). Con esto en true
        // dos o tres quedaban corriendo a la vez de fondo compitiendo por
        // el mismo frame que el swipe, y ESE era el origen del lag — no la
        // construcción de la pantalla vecina en sí (esa ya se prepara sola
        // en cuanto el dedo empieza a moverse, sin necesitar esta bandera).
        allowImplicitScrolling: false,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      // ── BARRA DE NAVEGACIÓN CON ESTILO VIDRIO ESMERILADO ──────────────
      // ClipRRect recorta las esquinas superiores redondeadas y también
      // acota el BackdropFilter (si no, el blur se filtraría fuera de la
      // barra). Encima va un panel semitransparente con un borde clarito
      // arriba para simular el filo de un vidrio, y la barra de navegación
      // en sí queda transparente para dejar ver ese panel.
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.62),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.75),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _irAPantalla,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: kPrimaryRed,
              unselectedItemColor: Colors.grey[700],
              selectedLabelStyle: AppFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: AppFonts.poppins(fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: _navLabel(0),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.menu_book_outlined),
                  activeIcon: const Icon(Icons.menu_book),
                  label: _navLabel(1),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.timer_outlined),
                  activeIcon: const Icon(Icons.timer),
                  label: _navLabel(2),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.trending_up_outlined),
                  activeIcon: const Icon(Icons.trending_up),
                  label: _navLabel(3),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: _navLabel(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LAYOUT DE ESCRITORIO (PC) — barra lateral fija + panel de contenido.
  // Reemplaza la barra inferior por una navegación lateral, sin tocar la
  // lógica de navegación (mismo _currentIndex, mismos _screens).
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context) {
    final usuario = _authService.usuarioActual;
    final nombre = usuario?['nombre_completo'] ?? 'Usuario';
    final nivel = usuario?['nivel_actual'] ?? 'A1';

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6B1010), Color(0xFF2E0808)],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UniEnglish',
                          style: AppFonts.poppins(
                            color: const Color(0xFFF5E6D0),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'U. LIBRE',
                          style: AppFonts.poppins(
                            color: const Color(0xFFD4A017),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final selected = index == _currentIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: selected
                                ? const Color(0xFFD4A017)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _irAPantalla(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected ? item.activeIcon : item.icon,
                                      color: selected
                                          ? const Color(0xFF2E0808)
                                          : const Color(0xFFF5E6D0),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _navLabel(index),
                                      style: AppFonts.poppins(
                                        color: selected
                                            ? const Color(0xFF2E0808)
                                            : const Color(0xFFF5E6D0),
                                        fontSize: 14,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () => _irAPantalla(4),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFD4A017),
                            child: Text(
                              nivel,
                              style: AppFonts.poppins(
                                color: const Color(0xFF2E0808),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombre,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.poppins(
                                    color: const Color(0xFFF5E6D0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppStrings.tr(
                                    'Nivel $nivel · Ver perfil',
                                    'Level $nivel · View profile',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.poppins(
                                    color: const Color(0xAAF5E6D0),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// =============================================================================
// AUTH WRAPPER - Verifica autenticación y redirige a la pantalla apropiada
// =============================================================================
/// Widget que verifica el estado de autenticación y muestra la pantalla correspondiente.
/// Si el usuario está autenticado, muestra MainNavigation.
/// Si no, muestra LoginScreen.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    AppLogger.log('🎨 AuthWrapper building...');
    AppLogger.log('   estaAutenticado: ${_authService.estaAutenticado}');
    AppLogger.log('   usuarioActualId: ${_authService.usuarioActualId}');
    // Verificar si hay usuario autenticado
    if (_authService.estaAutenticado) {
      AppLogger.log('✅ AuthWrapper: Usuario autenticado, mostrando MainNavigation');
      return const MainNavigation();
    }

    // Usuario no autenticado - pasar el AuthService global
    AppLogger.log('❌ AuthWrapper: Usuario no autenticado, mostrando LoginScreen');
    return LoginScreen(
      authService: _authService,
      vocabularioService: _vocabularioService,
    );
  }
}
