import 'package:flutter/material.dart';

/// =============================================================================
/// 🎨 UTILIDAD: lib/ui/utils/app_colors.dart
/// =============================================================================
/// Roles de color que sí cambian entre modo claro y oscuro (fondos de
/// pantalla, tarjetas "limpias", texto, bordes). Las tarjetas con textura
/// (fondo.webp + overlay oscuro, `textureCard`) NO usan este archivo: ya son
/// oscuras en los dos modos, no necesitan variante.
///
/// Cada método lee `Theme.of(context).brightness`, que cambia solo cuando
/// [TemaService] actualiza `themeMode` en el MaterialApp raíz — así los
/// widgets se redibujan automáticamente sin necesitar un listener propio.
/// =============================================================================
class AppColors {
  AppColors._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Fondo de pantalla (Scaffold). Negro neutro a propósito — las tarjetas
  /// con textura roja ya aportan el color de marca, el fondo no debe competir.
  static Color background(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : Colors.white;

  /// Tarjeta "limpia" (sin textura), como la de Configuración en Perfil.
  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color cardBorder(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.10) : Colors.grey[200]!;

  static Color divider(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.08) : Colors.grey[200]!;

  /// Texto principal sobre `background`/`card`.
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? const Color(0xFFF5E6D0) : const Color(0xFF1A0000);

  /// Texto/íconos secundarios (subtítulos, chevrons, footer).
  static Color textSecondary(BuildContext context) =>
      isDark(context) ? const Color(0xAAF5E6D0) : Colors.grey[500]!;

  static Color iconMuted(BuildContext context) =>
      isDark(context) ? const Color(0x88F5E6D0) : Colors.grey[600]!;
}
