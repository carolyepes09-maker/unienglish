import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import 'package:gif/gif.dart';
import 'package:fluter_app/models/palabra_model.dart';
import 'package:fluter_app/services/vocabulario_service.dart';
import 'package:fluter_app/services/progreso_service.dart';
import 'package:fluter_app/ui/pages/agregar_palabra_screen.dart';
import 'package:fluter_app/ui/pages/revision_screen.dart';

const Color kPrimaryRed = Color(0xFFCC0000);
const Color kDarkCard = Color(0xFF1A0000);
const Color kGoldAccent = Color(0xFFD4A017);
const Color kCream = Color(0xFFF5E6D0);
const Color kCreamMuted = Color(0xAAF5E6D0);
const Color kTextDark = Color(0xFF1C1C1C);

/// =============================================================================
/// 📖 PANTALLA: lib/ui/pages/vocabulario_screen.dart
/// =============================================================================
/// Gestiona la biblioteca personal de palabras del usuario.
/// Proporciona acceso al diccionario, estadísticas de dominio y repaso.
/// =============================================================================

class VocabularioScreen extends StatefulWidget {
  // ── REQUERIMIENTOS DE DATOS ──────────────────────────────────────────────
  // El servicio central que orquesta la lectura de archivos y el algoritmo SM-2.
  final VocabularioService vocabularioService;
  const VocabularioScreen({super.key, required this.vocabularioService});

  @override
  State<VocabularioScreen> createState() => _VocabularioScreenState();
}

enum _FiltroPalabras { todas, aprendiendo, dominadas }

class _VocabularioScreenState extends State<VocabularioScreen>
    with
        SingleTickerProviderStateMixin,
        IdiomaListenerMixin<VocabularioScreen> {
  late Future<List<PalabraModel>> _palabrasFuture;
  final ProgresoService _progresoService = ProgresoService();
  late GifController _fireController;
  _FiltroPalabras _filtro = _FiltroPalabras.todas;

  @override
  void initState() {
    super.initState();
    _fireController = GifController(vsync: this);
    // La sincronización con la cuenta puede seguir corriendo en segundo
    // plano cuando esta pantalla ya está abierta con la caché local (ver
    // hallazgo de rendimiento 3) -- este listener refresca la lista sola
    // apenas esa sincronización traiga algo nuevo, en vez de quedarse con
    // datos incompletos hasta salir y volver a entrar.
    widget.vocabularioService.addListener(_loadData);
    _loadData(); // Carga inicial de datos al abrir la pantalla.
  }

  @override
  void dispose() {
    widget.vocabularioService.removeListener(_loadData);
    _fireController.dispose();
    super.dispose();
  }

  // ── MANEJO DEL ESTADO ────────────────────────────────────────────────────
  // Refresca la lista de palabras cuando el usuario vuelve de agregar una nueva
  // o después de una sesión de repaso.
  void _loadData() {
    if (!mounted) return;
    setState(() {
      _palabrasFuture = widget.vocabularioService.cargarPalabras();
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.tr('Vocabulario', 'Vocabulary'),
          style: AppFonts.poppins(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kGoldAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gif(
                    image: const AssetImage('assets/images/Fire.gif'),
                    controller: _fireController,
                    autostart: Autostart.loop,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_progresoService.rachaDias}',
                    style: AppFonts.poppins(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // ── CONSTRUCTOR ASÍNCRONO ──────────────────────────────────────────────
      // Espera a que el sistema de archivos (o LocalStorage) devuelva el JSON.
      body: FutureBuilder<List<PalabraModel>>(
        future: _palabrasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppStrings.tr(
                  'Error: ${snapshot.error}',
                  'Error: ${snapshot.error}',
                ),
              ),
            );
          }

          final palabras = snapshot.data ?? [];

          // ── FILTRADO INTELIGENTE ───────────────────────────────────────────
          // 1. Calculamos las palabras que "tocan" estudiar hoy según el SM-2
          //    (primero las vencidas, luego unas pocas nuevas, con tope).
          final palabrasHoy = VocabularioService.sesionDeHoy(palabras);

          // 2. Contamos cuántas palabras han alcanzado el nivel máximo de memoria.
          final palabrasDominadas = palabras.where((p) => p.dominada).length;

          // 3. Aplicamos el filtro seleccionado (Todas / Aprendiendo / Dominadas)
          final palabrasFiltradas = switch (_filtro) {
            _FiltroPalabras.todas => palabras,
            _FiltroPalabras.aprendiendo => palabras
                .where((p) => !p.dominada)
                .toList(),
            _FiltroPalabras.dominadas => palabras
                .where((p) => p.dominada)
                .toList(),
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── COMPONENTE: TARJETA DE RESUMEN ─────────────────────────────
                _buildResumenCard(
                  palabrasHoy,
                  palabrasDominadas,
                  palabras.length,
                ),
                const SizedBox(height: 16),

                // ── COMPONENTE: BOTÓN AGREGAR ──────────────────────────────────
                _buildAgregarPalabraCard(),
                const SizedBox(height: 20),

                // ── COMPONENTE: TABS DE FILTRO ──────────────────────────────────
                _buildFiltroTabs(),
                const SizedBox(height: 20),

                Text(
                  AppStrings.tr('Mis palabras', 'My words'),
                  style: AppFonts.poppins(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildListaPalabras(palabrasFiltradas),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumenCard(
    List<PalabraModel> palabrasHoy,
    int dominadas,
    int total,
  ) {
    return _textureCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── ANILLO "X DE Y" ──────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '0',
                        style: AppFonts.poppins(
                          color: kCream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        AppStrings.tr(
                          'DE ${palabrasHoy.length}',
                          'OF ${palabrasHoy.length}',
                        ),
                        style: AppFonts.poppins(
                          color: kCreamMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                        '${palabrasHoy.length} palabras para hoy',
                        '${palabrasHoy.length} words for today',
                      ),
                      style: AppFonts.poppins(
                        color: kCream,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.tr(
                        '$dominadas dominadas · $total en total',
                        '$dominadas mastered · $total total',
                      ),
                      style: AppFonts.poppins(
                        color: kCreamMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (palabrasHoy.isNotEmpty) ...[
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RevisionScreen(
                      palabras: palabrasHoy,
                      vocabularioService: widget.vocabularioService,
                    ),
                  ),
                );
                _loadData();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kGoldAccent, Color(0xFF8B6914)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.tr('Iniciar revisión', 'Start review'),
                      style: AppFonts.poppins(
                        color: kDarkCard,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: kDarkCard,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgregarPalabraCard() {
    return GestureDetector(
      onTap: () async {
        // ─── PASO 1 (UI): Navegación al formulario ──────────────────────────
        // El usuario decide agregar una palabra y lo enviamos al formulario.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgregarPalabraScreen(
              vocabularioService: widget.vocabularioService,
            ),
          ),
        );
        _loadData();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimaryRed.withValues(alpha: 0.20), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGoldAccent.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.add, color: kGoldAccent, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.tr('Agregar palabra nueva', 'Add new word'),
              style: AppFonts.poppins(
                color: AppColors.textPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroTabs() {
    Widget tab(String texto, _FiltroPalabras valor) {
      final seleccionado = _filtro == valor;
      return GestureDetector(
        onTap: () => setState(() => _filtro = valor),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: seleccionado ? kDarkCard : kPrimaryRed.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            texto,
            style: AppFonts.poppins(
              color: seleccionado ? kCream : kPrimaryRed,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab(AppStrings.tr('Todas', 'All'), _FiltroPalabras.todas),
        const SizedBox(width: 8),
        tab(
          AppStrings.tr('Aprendiendo', 'Learning'),
          _FiltroPalabras.aprendiendo,
        ),
        const SizedBox(width: 8),
        tab(
          AppStrings.tr('Dominadas', 'Mastered'),
          _FiltroPalabras.dominadas,
        ),
      ],
    );
  }

  Widget _buildListaPalabras(List<PalabraModel> palabras) {
    if (palabras.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            AppStrings.tr(
              'Aún no has agregado ninguna palabra.',
              "You haven't added any word yet.",
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: palabras.length,
      itemBuilder: (context, index) {
        final palabra = palabras[index];
        return Dismissible(
          key: Key(palabra.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            // ELIMINACIÓN: Borra la palabra del Local Storage y de la lista.
            await widget.vocabularioService.eliminarPalabra(palabra.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.tr('Palabra eliminada', 'Word deleted'),
                ),
              ),
            );
            _loadData(); // Refrescamos la UI
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            palabra.ingles,
                            style: AppFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            palabra.espanol,
                            style: AppFonts.poppins(
                              color: AppColors.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildNivelDots(palabra.nivel),
                          if (palabra.necesitaRevision) ...[
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tr('revisa hoy', 'review today'),
                              style: AppFonts.poppins(
                                color: kPrimaryRed,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildNivelBadge(palabra.nivel),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Indicador de dominio: 5 puntos, rellenos según el nivel (0-5) de la palabra.
  Widget _buildNivelDots(int nivel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final relleno = index < nivel;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: relleno ? kGoldAccent : AppColors.cardBorder(context),
          ),
        );
      }),
    );
  }

  Widget _buildNivelBadge(int nivel) {
    String texto;
    Color bg;
    Color fg;
    if (nivel == 0) {
      texto = AppStrings.tr('Nuevo', 'New');
      bg = AppColors.cardBorder(context);
      fg = AppColors.textSecondary(context);
    } else if (nivel < 5) {
      texto = AppStrings.tr('Aprendiendo', 'Learning');
      bg = kGoldAccent.withValues(alpha: 0.18);
      fg = const Color(0xFF8B6914);
    } else {
      texto = AppStrings.tr('Dominado', 'Mastered');
      bg = Colors.green.withValues(alpha: 0.15);
      fg = Colors.green[800]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        texto,
        style: AppFonts.poppins(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _textureCard({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 6),
    EdgeInsets padding = const EdgeInsets.all(20),
    double radius = 20,
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
