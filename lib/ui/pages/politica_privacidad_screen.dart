import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../utils/app_colors.dart';

/// =============================================================================
/// 🔒 PANTALLA: lib/ui/pages/politica_privacidad_screen.dart
/// =============================================================================
/// Política de Tratamiento de Datos Personales + Términos de Uso.
///
/// IMPORTANTE — antes de considerar este texto definitivo, completa los
/// datos marcados abajo (responsable real, correo de contacto, programa).
/// Esto NO reemplaza una revisión jurídica formal si la universidad se
/// involucra oficialmente en el proyecto.
/// =============================================================================

// ─── DATOS A COMPLETAR ──────────────────────────────────────────────────────
const String kNombreResponsable = '[Tu nombre completo]';
const String kProgramaAcademico = '[Tu programa académico]';
const String kCorreoContacto = '[tu-correo-de-contacto@ejemplo.com]';

class PoliticaPrivacidadScreen extends StatelessWidget {
  const PoliticaPrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        title: Text(
          'Privacidad y términos',
          style: AppFonts.poppins(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo(context, 'Política de Tratamiento de Datos Personales'),
            _parrafo(
              context,
              'Última actualización: consulta la fecha de esta versión con el responsable.',
              cursiva: true,
            ),
            _seccion(context, '1. Responsable del tratamiento',
                'UniEnglish es un proyecto de grado desarrollado por '
                '$kNombreResponsable, estudiante de $kProgramaAcademico en la '
                'Universidad Libre, quien actúa como responsable del '
                'tratamiento de los datos personales recolectados a través de '
                'esta aplicación, conforme a la Ley 1581 de 2012 y el Decreto '
                '1377 de 2013.\n\n'
                'UniEnglish es un proyecto académico independiente: no es un '
                'servicio oficial operado por la Universidad Libre.\n\n'
                'Contacto: $kCorreoContacto'),
            _seccion(context, '2. Datos que se recolectan',
                '• Datos de identificación: nombre completo, correo '
                'electrónico, código estudiantil, programa académico o '
                'facultad.\n'
                '• Datos de acceso: contraseña, almacenada de forma cifrada '
                'por Firebase Authentication (nunca en texto plano ni '
                'accesible por el responsable).\n'
                '• Datos de uso académico: nivel de inglés, racha de días de '
                'estudio, progreso por habilidad (Grammar, Reading, '
                'Listening, Writing), resultados de exámenes y ejercicios, '
                'vocabulario personal agregado por el usuario, actividad '
                'reciente dentro de la app.\n'
                '• Preferencias: idioma de interfaz y modo de visualización '
                '(claro/oscuro), guardadas localmente en tu dispositivo.'),
            _seccion(context, '3. Finalidad del tratamiento',
                'Tus datos se usan exclusivamente para:\n'
                '• Prestar el servicio educativo de la app (autenticación, '
                'seguimiento de progreso, contenido según tu nivel).\n'
                '• Calcular estadísticas de aprendizaje visibles únicamente '
                'para ti.\n'
                '• Fines académicos del proyecto de grado (evaluar el '
                'funcionamiento de la app), sin usar datos identificables en '
                'el documento de tesis sin anonimizar.\n\n'
                'No se usan tus datos con fines publicitarios, no se venden '
                'ni se comparten con terceros distintos de los proveedores '
                'técnicos necesarios para operar la app (ver sección 5).'),
            _seccion(context, '4. Tus derechos (Habeas Data)',
                'Como titular de tus datos personales, tienes derecho a:\n'
                '• Conocer, actualizar y rectificar tus datos.\n'
                '• Solicitar prueba de la autorización otorgada.\n'
                '• Ser informado sobre el uso que se le ha dado a tus '
                'datos.\n'
                '• Presentar quejas ante la Superintendencia de Industria y '
                'Comercio (SIC) por infracciones a la ley.\n'
                '• Revocar la autorización y/o solicitar la supresión de tus '
                'datos, cuando no exista un deber legal que impida '
                'eliminarlos.\n'
                '• Acceder de forma gratuita a tus datos personales.\n\n'
                'Para ejercer estos derechos, escribe a $kCorreoContacto '
                'indicando tu solicitud. Se atenderá en un plazo razonable.'),
            _seccion(context, '5. Transferencia internacional de datos',
                'Esta app usa Firebase (Google LLC) para autenticación y '
                'almacenamiento de datos (Firestore). Esto implica que tus '
                'datos se almacenan y procesan en servidores de Google '
                'ubicados fuera de Colombia. Al aceptar esta política, '
                'autorizas expresamente esta transferencia internacional, '
                'necesaria para el funcionamiento del servicio. Google actúa '
                'como encargado del tratamiento bajo sus propios términos de '
                'servicio y estándares de seguridad.'),
            _seccion(context, '6. Conservación de los datos',
                'Tus datos se conservarán mientras tu cuenta permanezca '
                'activa o hasta que solicites su eliminación. Al eliminar tu '
                'cuenta, los datos personales asociados serán suprimidos de '
                'la base de datos activa, salvo la información que deba '
                'conservarse por obligación legal.'),
            _seccion(context, '7. Menores de edad',
                'El registro en esta app está dirigido a personas mayores de '
                '18 años. Al registrarte, declaras ser mayor de edad. Si '
                'tienes conocimiento de que un menor de edad ha creado una '
                'cuenta, contáctanos para proceder a su eliminación.'),
            _seccion(context, '8. Seguridad de la información',
                'Se aplican medidas técnicas razonables (autenticación '
                'cifrada, reglas de acceso a nivel de base de datos) para '
                'proteger tus datos frente a accesos no autorizados. Ninguna '
                'transmisión de datos por internet es 100% segura, pero se '
                'toman las medidas disponibles según el estado de la '
                'técnica.'),
            _seccion(context, '9. Modificaciones',
                'Esta política puede actualizarse. Los cambios sustanciales '
                'se notificarán dentro de la app.'),

            const SizedBox(height: 32),
            _titulo(context, 'Términos de Uso'),
            _seccion(context, '1. Objeto',
                'UniEnglish es una aplicación educativa de práctica de '
                'inglés, desarrollada como proyecto de grado. Su uso es '
                'gratuito y voluntario.'),
            _seccion(context, '2. Naturaleza del proyecto',
                'Esta app es un prototipo académico en desarrollo activo. '
                'Puede contener errores, cambios frecuentes o '
                'interrupciones del servicio sin previo aviso.'),
            _seccion(context, '3. Uso aceptable',
                'Te comprometes a usar la app de forma personal, no '
                'comercial, y a no intentar vulnerar su seguridad ni '
                'acceder a datos de otros usuarios.'),
            _seccion(context, '4. Propiedad intelectual',
                'El contenido educativo, diseño y código de la app son '
                'propiedad de su autor, desarrollado en el marco de un '
                'trabajo de grado para la Universidad Libre.'),
            _seccion(context, '5. Limitación de responsabilidad',
                'Al ser un proyecto académico, no se garantiza '
                'disponibilidad continua del servicio ni la exactitud '
                'absoluta del contenido educativo. Su uso es bajo '
                'responsabilidad propia del usuario.'),
            _seccion(context, '6. Contacto',
                'Para dudas, sugerencias o solicitudes relacionadas con tus '
                'datos, escribe a $kCorreoContacto.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _titulo(BuildContext context, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          texto,
          style: AppFonts.poppins(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _parrafo(BuildContext context, String texto, {bool cursiva = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          texto,
          style: AppFonts.poppins(
            color: AppColors.textSecondary(context),
            fontSize: 12,
            fontStyle: cursiva ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );

  Widget _seccion(BuildContext context, String titulo, String cuerpo) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppFonts.poppins(
                color: AppColors.textPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cuerpo,
              style: AppFonts.poppins(
                color: AppColors.textSecondary(context),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
}
