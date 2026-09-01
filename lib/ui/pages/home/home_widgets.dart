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

/// Tarjeta con textura de fondo (fondo.webp + overlay + relieve), usada como
/// base visual tanto de los accesos rápidos (móvil) como de la actividad
/// reciente (móvil y escritorio).
Widget textureCard({
  required Widget child,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  EdgeInsets padding = const EdgeInsets.all(20),
  double radius = 16,
  Color? overlayColor, // Nuevo parámetro para el tinte
  // fondo.webp es una foto vertical (600x900) con un brillo cálido cerca
  // de la parte de arriba y esquinas oscuras. Con BoxFit.cover, entre más
  // ancha y baja sea la tarjeta, más delgada es la franja que se recorta:
  // Alignment.center (el de siempre, no cambia nada de lo existente) cae
  // en la franja del medio, más plana; Alignment.topCenter captura esa
  // zona de brillo y se nota mucho más como una foto real.
  Alignment imageAlignment = Alignment.center,
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
          color: Colors.black.withValues(alpha: 0.42),
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
            child: Image.asset(
              'assets/images/fondo.webp',
              fit: BoxFit.cover,
              alignment: imageAlignment,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withValues(alpha: 0.42),
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
                    Colors.white.withValues(alpha: 0.18),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.22),
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
              color: Colors.white.withValues(alpha: 0.28),
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
  Alignment imageAlignment = Alignment.center,
}) {
  // Color según el porcentaje: solo tiñe el chip del porcentaje, no la
  // tarjeta completa (antes todo el fondo de la tarjeta cambiaba de color).
  final int val = int.tryParse(percentage.replaceAll('%', '')) ?? 0;
  final Color colorChip;
  if (val >= 80) {
    colorChip = const Color(0xFF2E7D32); // verde
  } else if (val >= 50) {
    colorChip = const Color(0xFFB8860B); // ámbar
  } else {
    colorChip = const Color(0xFFC62828); // rojo
  }

  return textureCard(
    imageAlignment: imageAlignment,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
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
            color: colorChip,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            percentage,
            style: AppFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
