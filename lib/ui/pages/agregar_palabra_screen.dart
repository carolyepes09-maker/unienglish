import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_strings.dart';
import '../utils/app_colors.dart';
import 'package:fluter_app/models/palabra_model.dart';
import 'package:fluter_app/services/vocabulario_service.dart';

/// =============================================================================
/// ➕ PANTALLA: lib/ui/pages/agregar_palabra_screen.dart
/// =============================================================================
/// Formulario interactivo para expandir el diccionario personal del usuario.
///
/// FUNCIONALIDADES:
/// 1. Captura de Datos: Recopila la palabra en inglés, su traducción y un ejemplo.
/// 2. Validación de Formulario: Asegura que no se guarden campos vacíos.
/// 3. Conversión a Modelo: Transforma el texto de la UI en un [PalabraModel].
/// 4. Persistencia: Delega al [VocabularioService] el guardado físico del dato.
/// =============================================================================

const Color kCream = Color(0xFFF5E6D0);
const Color kTextDark = Color(0xFF1C1C1C);

/// ─── PANTALLA DE AGREGAR PALABRA (FORMULARIO) ───────────────────────────────
/// Interfaz sencilla para que el usuario ingrese una palabra en inglés
/// y su significado en español para guardarla en el diccionario local.
class AgregarPalabraScreen extends StatefulWidget {
  // El servicio global donde se persistirá la nueva palabra.
  final VocabularioService vocabularioService;
  const AgregarPalabraScreen({super.key, required this.vocabularioService});

  @override
  State<AgregarPalabraScreen> createState() => _AgregarPalabraScreenState();
}

class _AgregarPalabraScreenState extends State<AgregarPalabraScreen>
    with IdiomaListenerMixin<AgregarPalabraScreen> {
  // Manejadores para validar el formulario y capturar el texto de los campos.
  final _formKey = GlobalKey<FormState>();
  final _inglesController = TextEditingController();
  final _espanolController = TextEditingController();
  final _ejemploController = TextEditingController();

  @override
  void dispose() {
    // Liberar memoria de los controladores cuando la pantalla se cierra.
    _inglesController.dispose();
    _espanolController.dispose();
    _ejemploController.dispose();
    super.dispose();
  }

  /// ─── PASO 1 (LÓGICA): PROCESO DE GUARDADO ────────────────────────────────
  /// Se activa al presionar el botón de "Guardar".
  Future<void> _guardarPalabra() async {
    // Validamos que los campos obligatorios estén llenos pulsando el motor de Flutter.
    if (_formKey.currentState!.validate()) {
      // ─── PASO 2 (MODELADO): Creación del Objeto ───────────────────────────
      // Convertimos el texto ingresado en un modelo de datos estructurado.
      final nuevaPalabra = PalabraModel(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // ID único basado en tiempo
        ingles: _inglesController.text.trim(),
        espanol: _espanolController.text.trim(),
        ejemplo: _ejemploController.text.trim(),
      );

      // ─── PASO 3 (PERSISTENCIA): Envío al Servicio ─────────────────────────
      // Le entregamos el modelo al VocabularioService para que lo guarde en el JSON.
      await widget.vocabularioService.guardarPalabra(nuevaPalabra);

      // Cerramos la pantalla y notificamos al usuario del éxito.
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.tr(
                '✅ Palabra agregada a tu diccionario personal',
                '✅ Word added to your personal dictionary',
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      // ─── DISEÑO: BARRA SUPERIOR ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.tr('Agregar palabra', 'Add word'),
          style: AppFonts.poppins(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // ─── CUERPO: FORMULARIO DE ENTRADA ───────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Asignamos la llave para validación global
          child: Column(
            children: [
              // Campo para la palabra original en Inglés
              TextFormField(
                controller: _inglesController,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(
                    'Palabra en inglés',
                    'English word',
                  ),
                ),
                validator: (value) => value!.isEmpty
                    ? AppStrings.tr('Campo requerido', 'Required field')
                    : null,
              ),
              const SizedBox(height: 16),
              // Campo para la traducción al Español
              TextFormField(
                controller: _espanolController,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(
                    'Traducción en español',
                    'Spanish translation',
                  ),
                ),
                validator: (value) => value!.isEmpty
                    ? AppStrings.tr('Campo requerido', 'Required field')
                    : null,
              ),
              const SizedBox(height: 16),
              // Campo opcional para dar contexto a la palabra
              TextFormField(
                controller: _ejemploController,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(
                    'Ejemplo de uso (opcional)',
                    'Usage example (optional)',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // ─── BOTÓN ACCIÓN: GUARDAR ─────────────────────────────────────
              // Botón estilizado que utiliza una textura personalizada.
              GestureDetector(
                onTap: _guardarPalabra,
                child: _textureCard(
                  child: Center(
                    child: Text(
                      AppStrings.tr('Guardar', 'Save'),
                      style: AppFonts.poppins(
                        color: kCream,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ─── COMPONENTE VISUAL: TARJETA CON TEXTURA ─────────────────────────────
  /// Este widget crea un contenedor con una imagen de fondo (textura)
  /// y una capa de oscurecimiento para que el texto sea legible.
  Widget _textureCard({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 6),
    EdgeInsets padding = const EdgeInsets.all(20),
    double radius = 26,
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
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
