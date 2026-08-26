import 'package:flutter/material.dart';

/// =============================================================================
/// 🔤 UTILIDAD: lib/ui/utils/app_fonts.dart
/// =============================================================================
/// Reemplazo local de `GoogleFonts.poppins()` / `GoogleFonts.poppinsTextTheme()`.
///
/// Antes la app usaba el paquete `google_fonts`, que por defecto DESCARGA el
/// archivo .ttf desde fonts.gstatic.com la primera vez que se usa cada peso.
/// Eso agrega una petición de red al arranque (lenta o inexistente en algunos
/// entornos) antes de poder pintar el texto con la tipografía correcta.
///
/// Aquí usamos exactamente la misma fuente (Poppins) pero empaquetada en
/// `assets/fonts/` y declarada en `pubspec.yaml`, así que Flutter la carga
/// desde el propio bundle de la app, sin red. El resultado visual es idéntico;
/// solo cambia de dónde sale el archivo de la fuente.
/// =============================================================================
class AppFonts {
  AppFonts._();

  static TextStyle poppins({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    textStyle ??= const TextStyle();
    return textStyle.copyWith(
      fontFamily: 'Poppins',
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  /// Aplica la familia Poppins a cada estilo de un [TextTheme], igual que
  /// hacía `GoogleFonts.poppinsTextTheme()`.
  static TextTheme poppinsTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: poppins(textStyle: textTheme.displayLarge),
      displayMedium: poppins(textStyle: textTheme.displayMedium),
      displaySmall: poppins(textStyle: textTheme.displaySmall),
      headlineLarge: poppins(textStyle: textTheme.headlineLarge),
      headlineMedium: poppins(textStyle: textTheme.headlineMedium),
      headlineSmall: poppins(textStyle: textTheme.headlineSmall),
      titleLarge: poppins(textStyle: textTheme.titleLarge),
      titleMedium: poppins(textStyle: textTheme.titleMedium),
      titleSmall: poppins(textStyle: textTheme.titleSmall),
      bodyLarge: poppins(textStyle: textTheme.bodyLarge),
      bodyMedium: poppins(textStyle: textTheme.bodyMedium),
      bodySmall: poppins(textStyle: textTheme.bodySmall),
      labelLarge: poppins(textStyle: textTheme.labelLarge),
      labelMedium: poppins(textStyle: textTheme.labelMedium),
      labelSmall: poppins(textStyle: textTheme.labelSmall),
    );
  }
}
