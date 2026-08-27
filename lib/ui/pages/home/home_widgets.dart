import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';

/// =============================================================================
/// WIDGETS: lib/ui/pages/home/home_widgets.dart
/// =============================================================================
/// Helpers visuales compartidos entre HomeMobileBody y HomeDesktopBody,
/// extraídos tal cual (sin cambiar ninguna propiedad visual) desde
/// home_screen.dart. Ambos layouts los usan, así que viven en un archivo
/// aparte en vez de duplicarse en cada uno.
/// =============================================================================

/// Tarjeta con textura de fondo (fondo.jpg + overlay + relieve), usada como
/// base visual tanto de los accesos rápidos (móvil) como de la actividad
/// reciente (móvil y escritorio).
Widget textureCard({
  required Widget child,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  EdgeInsets padding = const EdgeInsets.all(20),
  double radius = 16,
  Color? overlayColor, // Nuevo parámetro para el tinte
}) {
  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      // Sombra proyectada para dar sensación de profundidad. No se usa
      // un `border` con lados de distinto color/ancho porque Flutter no
      // puede combinarlo con esquinas redondeadas (dibuja un borde
      // rectangular "roto" que ignora el radius).
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.42),
          offset: const Offset(5, 8),
          blurRadius: 18,
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
            child: Container(
              color: overlayColor ?? Colors.black.withOpacity(0.42),
            ),
          ),
          // Relieve sobre la textura: luz arriba-izquierda y sombra
          // abajo-derecha en el mismo degradado — se lee como bisel sin
          // usar Border (respeta las esquinas porque vive dentro del
          // ClipRRect).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.transparent,
                    Colors.black.withOpacity(0.22),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Filo claro de 1.5px arriba — el "borde iluminado".
          Positioned(
            top: 0,
            left: radius,
            right: radius,
            child: Container(
              height: 1.5,
              color: Colors.white.withOpacity(0.28),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    ),
  );
}

/// Fila de "actividad reciente" (icono + título/subtítulo + porcentaje),
/// usada tanto en el layout móvil como en el de escritorio.
Widget activityTile({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required String percentage,
}) {
  // Calcular color de fondo según el porcentaje
  final int val = int.tryParse(percentage.replaceAll('%', '')) ?? 0;
  Color overlayColor;

  if (val >= 80) {
    overlayColor = const Color(
      0xFF003300,
    ).withOpacity(0.6); // Tinte verde oscuro
  } else if (val >= 50) {
    overlayColor = const Color(
      0xFF442200,
    ).withOpacity(0.6); // Tinte ámbar/marrón
  } else {
    overlayColor = const Color(
      0xFF330000,
    ).withOpacity(0.6); // Tinte rojo oscuro
  }

  return textureCard(
    overlayColor: overlayColor,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.poppins(
                  color: const Color(0xFFF5E6D0),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppFonts.poppins(
                  color: const Color(0xAAF5E6D0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            percentage,
            style: AppFonts.poppins(
              color: const Color(0xFFF5E6D0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
