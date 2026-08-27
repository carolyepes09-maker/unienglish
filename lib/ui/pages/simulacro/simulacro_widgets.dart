import 'package:flutter/material.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_strings.dart';

/// =============================================================================
/// WIDGETS: lib/ui/pages/simulacro/simulacro_widgets.dart
/// =============================================================================
/// Helpers compartidos entre SimulacroMobileLayout y SimulacroDesktopLayout,
/// extraídos tal cual (sin cambiar ninguna propiedad visual) desde
/// simulacro_screen.dart.
/// =============================================================================

const Color kPrimaryRed = Color(0xFFCC0000);

/// El examen mezcla Grammar/Reading/Listening/Writing, así que cada pregunta
/// muestra a cuál pertenece.
String etiquetaHabilidad(String skill) {
  switch (skill) {
    case 'grammar':
      return AppStrings.tr('Grammar', 'Grammar');
    case 'listening':
      return AppStrings.tr('Listening', 'Listening');
    case 'writing':
      return AppStrings.tr('Writing', 'Writing');
    case 'reading':
    default:
      return AppStrings.tr('Reading', 'Reading');
  }
}

Widget skillBadge(String skill) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: kPrimaryRed.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kPrimaryRed.withValues(alpha: 0.25), width: 1),
    ),
    child: Text(
      etiquetaHabilidad(skill),
      style: AppFonts.poppins(
        color: kPrimaryRed,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
