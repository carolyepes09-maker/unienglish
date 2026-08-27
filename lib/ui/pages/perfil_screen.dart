import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import 'package:gif/gif.dart';
import '../../services/auth_service.dart';
import '../../services/progreso_service.dart';
import '../../services/idioma_service.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kGoldAccent = Color(0xFF8B6914);
const Color kTextDark = Color(0xFF1A0000);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);

/// =============================================================================
/// 👤 PANTALLA: lib/ui/pages/perfil_screen.dart
/// =============================================================================
/// Visualiza la identidad y los logros detallados del estudiante.
///
/// FUNCIONALIDADES:
/// 1. Información Académica: Muestra nombre, código y facultad del usuario.
/// 2. Estadísticas de "Gaming": Presenta la racha de días, horas de estudio y
///    lecciones completadas.
/// 3. Radar de Habilidades: Gráfico circular que muestra el dominio en
///    las 5 áreas del lenguaje.
/// =============================================================================

class PerfilScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback? onBack;

  const PerfilScreen({super.key, required this.authService, this.onBack});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin, IdiomaListenerMixin<PerfilScreen> {
  late GifController _fireController;
  final ProgresoService _progresoService = ProgresoService();
  final IdiomaService _idiomaService = IdiomaService();

  @override
  void initState() {
    super.initState();
    _fireController = GifController(vsync: this);
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  /// Obtiene las iniciales del nombre completo
  String _obtenerIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    } else if (partes.isNotEmpty) {
      return partes[0][0].toUpperCase();
    }
    return '';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TEMPORAL -- solo para que Ferek vea cómo se ve una cuenta avanzada.
  // Sobrescribe el progreso/vocabulario/actividad de LA CUENTA CON SESIÓN
  // ACTIVA con datos de demostración realistas (usando el mismo método que
  // ya usa toda la app para guardar en Firestore, así que respeta las
  // reglas de seguridad -- cada quien solo puede escribir su propio
  // documento). Se borra de perfil_screen.dart en cuanto se confirme que
  // se ve bien.
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _confirmarYCargarDatosDemo() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cargar datos de demostración'),
        content: const Text(
          'Esto SOBRESCRIBE el progreso, vocabulario y actividad reciente '
          'de la cuenta con la que tienes sesión iniciada ahora mismo, con '
          'datos de ejemplo realistas. No se puede deshacer desde aquí.\n\n'
          '¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, cargar datos',
              style: TextStyle(color: kPrimaryRed),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final usuarioId = widget.authService.usuarioActualId;
    if (usuarioId == null) return;

    final ahora = DateTime.now();

    Map<String, dynamic> palabra({
      required String id,
      required String en,
      required String es,
      required String ejemplo,
      required int facilidad,
      required int diasParaProximaRevision,
      required int correctas,
      required int incorrectas,
    }) {
      return {
        'id': id,
        'palabra_termino': en,
        'traduccion_definicion': es,
        'ejemplo_uso': ejemplo,
        'fecha_creacion': ahora
            .subtract(Duration(days: 60 - correctas))
            .toIso8601String(),
        'tipo_tarjeta': 'usuario',
      };
    }

    Map<String, dynamic> progresoPalabra({
      required String id,
      required int facilidad,
      required int diasParaProximaRevision,
      required int correctas,
      required int incorrectas,
    }) {
      return {
        'tarjeta_id': id,
        'facilidad': facilidad,
        'intervalo_dias': diasParaProximaRevision.abs(),
        'repeticiones': correctas,
        'proxima_revision': ahora
            .add(Duration(days: diasParaProximaRevision))
            .toIso8601String(),
        'total_revisiones': correctas + incorrectas,
        'total_correctas': correctas,
        'total_incorrectas': incorrectas,
      };
    }

    // (id, inglés, español, ejemplo, facilidad 0-5, días hasta el próximo
    // repaso (negativo = ya venció), aciertos, fallos)
    final vocabulario = <List<Object>>[
      ['demo-1', 'nevertheless', 'sin embargo', 'The exam was hard; nevertheless, she passed.', 5, 25, 9, 1],
      ['demo-2', 'furthermore', 'además', 'Furthermore, the results support our hypothesis.', 5, 20, 8, 0],
      ['demo-3', 'outcome', 'resultado', 'The outcome of the experiment was unexpected.', 5, 18, 7, 1],
      ['demo-4', 'curriculum', 'currículo', 'The university updated its curriculum this semester.', 5, 22, 8, 0],
      ['demo-5', 'semester', 'semestre', 'I have four courses this semester.', 5, 14, 10, 0],
      ['demo-6', 'assignment', 'tarea/trabajo', 'The assignment is due next Monday.', 5, 16, 9, 1],
      ['demo-7', 'deadline', 'fecha límite', 'We missed the deadline for the report.', 4, 9, 6, 1],
      ['demo-8', 'controversial', 'controvertido', 'It is a controversial topic among students.', 4, 7, 5, 2],
      ['demo-9', 'assumption', 'suposición', 'That is a reasonable assumption to make.', 3, 4, 4, 2],
      ['demo-10', 'feasible', 'factible', 'Is it feasible to finish this by Friday?', 3, 3, 3, 2],
      ['demo-11', 'comprehensive', 'integral / completo', 'We need a comprehensive review of the data.', 3, 2, 3, 3],
      ['demo-12', 'elaborate', 'elaborar / explicar', 'Could you elaborate on your last point?', 2, 1, 2, 3],
      ['demo-13', 'thesis', 'tesis', 'Her thesis focuses on renewable energy.', 2, 1, 2, 2],
      ['demo-14', 'plagiarism', 'plagio', 'Plagiarism is taken very seriously at this university.', 1, -1, 1, 3],
      ['demo-15', 'citation', 'cita (referencia)', 'Every claim needs a proper citation.', 1, -1, 1, 4],
      ['demo-16', 'peer review', 'revisión por pares', 'The article is currently under peer review.', 0, -2, 0, 3],
      ['demo-17', 'albeit', 'aunque', 'The plan worked, albeit slowly.', 0, -3, 0, 4],
      ['demo-18', 'subsequently', 'posteriormente', 'She studied abroad and subsequently found a job here.', 0, -2, 0, 3],
    ];

    final tarjetas = vocabulario
        .map(
          (w) => palabra(
            id: w[0] as String,
            en: w[1] as String,
            es: w[2] as String,
            ejemplo: w[3] as String,
            facilidad: w[4] as int,
            diasParaProximaRevision: w[5] as int,
            correctas: w[6] as int,
            incorrectas: w[7] as int,
          ),
        )
        .toList();
    final progresos = vocabulario
        .map(
          (w) => progresoPalabra(
            id: w[0] as String,
            facilidad: w[4] as int,
            diasParaProximaRevision: w[5] as int,
            correctas: w[6] as int,
            incorrectas: w[7] as int,
          ),
        )
        .toList();

    final actividadesRecientes = [
      {
        'titulo': 'Present Perfect',
        'subtitulo': 'Grammar · Ejercicios',
        'porcentaje': '90%',
        'esPerfecto': false,
        'timestamp': ahora.subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'titulo': 'Simulacro Global',
        'subtitulo': 'Simulacro · B1',
        'porcentaje': '78%',
        'esPerfecto': false,
        'timestamp': ahora.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'titulo': 'Repaso de vocabulario',
        'subtitulo': '12 palabras repasadas',
        'porcentaje': '100%',
        'esPerfecto': true,
        'timestamp': ahora.subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];

    final exito = await widget.authService.actualizarUsuario(usuarioId, {
      'nivel_actual': 'B1',
      'racha_dias': 12,
      'tiempo_total_horas': 27,
      'lecciones_completadas': 34,
      'examenes_realizados': 6,
      'habilidades_values': [78.0, 71.0, 65.0, 69.0, 45.0],
      'actividad_semanal': [40.0, 65.0, 30.0, 80.0, 55.0, 20.0, 70.0],
      'progreso_siguiente_nivel': 0.62,
      'siguiente_nivel': 'B2',
      'progreso_actualizado_en': ahora.toIso8601String(),
      'vocabulario_tarjetas_usuario': tarjetas,
      'vocabulario_progreso_tarjetas': progresos,
      'vocabulario_actualizado_en': ahora.toIso8601String(),
      'actividades_recientes': actividadesRecientes,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito
              ? 'Datos de demostración cargados. Vuelve a entrar (o refresca) para verlos.'
              : 'No se pudo guardar -- revisa la conexión e inténtalo de nuevo.',
        ),
        backgroundColor: exito ? Colors.green[700] : Colors.red[700],
      ),
    );
  }

  /// Abre el selector de idioma de interfaz y aplica el cambio de inmediato.
  void _mostrarSelectorIdioma() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.tr(
                      'Idioma de interfaz',
                      'Interface language',
                    ),
                    style: AppFonts.poppins(
                      color: kTextDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _opcionIdioma(
                label: 'Español',
                seleccionado: _idiomaService.idioma == AppIdioma.es,
                onTap: () {
                  _idiomaService.cambiarIdioma(AppIdioma.es);
                  Navigator.pop(sheetContext);
                },
              ),
              _opcionIdioma(
                label: 'English',
                seleccionado: _idiomaService.idioma == AppIdioma.en,
                onTap: () {
                  _idiomaService.cambiarIdioma(AppIdioma.en);
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _opcionIdioma({
    required String label,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppFonts.poppins(
                  color: kTextDark,
                  fontSize: 15,
                  fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (seleccionado)
              const Icon(Icons.check_circle, color: kPrimaryRed, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.authService.usuarioActual;
    final programa = usuario?['facultad_programa'] ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ══════════════════════════════════════════════════════════════
            // HEADER — textura roja con avatar, nombre, nivel
            // ══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  // Textura roja
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/bg_perfil.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  // Capa oscura
                  Positioned.fill(
                    child: Container(color: Colors.black.withValues(alpha: 0.60)),
                  ),
                  // Contenido
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          // Botón back
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: kCream,
                                ),
                                onPressed: () {
                                  if (widget.onBack != null) {
                                    widget.onBack!();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ),

                          // Avatar con textura interna
                          Container(
                            width: 96,
                            height: 96,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 3,
                              ),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/fondo.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.20),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    _obtenerIniciales(
                                      usuario?['nombre_completo'] ?? '',
                                    ),
                                    style: AppFonts.poppins(
                                      color: kCream,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Nombre
                          const SizedBox(height: 12),
                          Text(
                            usuario?['nombre_completo'] ?? 'Usuario',
                            style: AppFonts.poppins(
                              color: kCream,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Código
                          Text(
                            AppStrings.tr(
                              'Código: ${widget.authService.usuarioActual?['codigo_estudiante'] ?? 'N/A'}',
                              'Code: ${widget.authService.usuarioActual?['codigo_estudiante'] ?? 'N/A'}',
                            ),
                            style: AppFonts.poppins(
                              color: kCreamMuted,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Badge nivel
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kGoldAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              usuario?['nivel_actual'] ?? 'A1',
                              style: AppFonts.poppins(
                                color: kCream,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Programa
                          if (programa.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: kCreamMuted,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  programa,
                                  style: AppFonts.poppins(
                                    color: kCreamMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ══════════════════════════════════════════════════════════════
            // STATS ROW — con textura
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                      child: Container(color: Colors.black.withValues(alpha: 0.42)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem(
                            iconWidget: Gif(
                              image: const AssetImage('assets/images/Fire.gif'),
                              controller: _fireController,
                              autostart: Autostart.loop,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                            value: AppStrings.tr(
                              '${_progresoService.rachaDias} días',
                              '${_progresoService.rachaDias} days',
                            ),
                            label: AppStrings.tr('Racha', 'Streak'),
                            iconColor: kGoldAccent,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _statItem(
                            iconWidget: const Icon(
                              Icons.menu_book,
                              color: kCream,
                              size: 22,
                            ),
                            value: _progresoService.leccionesCompletadas
                                .toString(),
                            label: AppStrings.tr('Lecciones', 'Lessons'),
                            iconColor: kCream,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          _statItem(
                            iconWidget: const Icon(
                              Icons.timer,
                              color: kCream,
                              size: 22,
                            ),
                            value: _progresoService.examenesRealizados
                                .toString(),
                            label: AppStrings.tr('Exámenes', 'Exams'),
                            iconColor: kCream,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════
            // CONFIGURACIÓN — fondo blanco limpio
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.tr('Configuración', 'Settings'),
                  style: AppFonts.poppins(
                    color: kTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _settingsItem(
                      icon: Icons.notifications_outlined,
                      label: AppStrings.tr(
                        'Notificaciones',
                        'Notifications',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    _settingsItem(
                      icon: Icons.language,
                      label: AppStrings.tr(
                        'Idioma de interfaz',
                        'Interface language',
                      ),
                      onTap: _mostrarSelectorIdioma,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _idiomaService.idioma == AppIdioma.en
                                ? 'English'
                                : 'Español',
                            style: AppFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    _settingsItem(
                      icon: Icons.logout,
                      label: AppStrings.tr('Cerrar sesión', 'Log out'),
                      iconColor: kPrimaryRed,
                      labelColor: kPrimaryRed,
                      onTap: () async {
                        // Mostrar confirmación
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              AppStrings.tr('Cerrar sesión', 'Log out'),
                            ),
                            content: Text(
                              AppStrings.tr(
                                '¿Estás seguro de que deseas cerrar sesión?',
                                'Are you sure you want to log out?',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppStrings.tr('Cancelar', 'Cancel'),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await widget.authService.cerrarSesion();
                                  // AuthWrapper redirigirá automáticamente a LoginScreen
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/',
                                    );
                                  }
                                },
                                child: Text(
                                  AppStrings.tr('Cerrar sesión', 'Log out'),
                                  style: const TextStyle(color: kPrimaryRed),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // TEMPORAL -- ver _confirmarYCargarDatosDemo(). Se quita
                    // de aquí en cuanto se confirme que los datos se ven
                    // bien.
                    Divider(height: 1, color: Colors.grey[200]),
                    _settingsItem(
                      icon: Icons.construction,
                      label: '🔧 Cargar datos de demostración (temporal)',
                      iconColor: Colors.orange[800],
                      labelColor: Colors.orange[800],
                      onTap: _confirmarYCargarDatosDemo,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Universidad Libre',
                    style: AppFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stat item ─────────────────────────────────────────────────────────────
  Widget _statItem({
    required Widget iconWidget,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        iconWidget,
        const SizedBox(height: 6),
        Text(
          value,
          style: AppFonts.poppins(
            color: kCream,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppFonts.poppins(color: kCreamMuted, fontSize: 11),
        ),
      ],
    );
  }

  // ── Settings item ─────────────────────────────────────────────────────────
  Widget _settingsItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    Color? iconColor,
    Color? labelColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.grey[500], size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppFonts.poppins(
                  color: labelColor ?? kTextDark,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
