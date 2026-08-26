import 'package:flutter/widgets.dart';

/// =============================================================================
/// 📐 UTILIDAD: lib/ui/utils/responsive.dart
/// =============================================================================
/// Punto único de verdad para decidir si la app debe mostrar el layout de
/// escritorio (PC) o el layout móvil original. Se basa en el ancho lógico
/// de la pantalla (MediaQuery), que es la forma estándar en Flutter Web/Desktop
/// de distinguir un navegador/ventana ancha de una pantalla de teléfono.
/// =============================================================================

/// Ancho a partir del cual se considera "PC" (escritorio/tablet grande).
/// Por debajo de este valor la app se comporta EXACTAMENTE igual que antes
/// (layout móvil intacto).
const double kDesktopBreakpoint = 900;

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= kDesktopBreakpoint;
}
