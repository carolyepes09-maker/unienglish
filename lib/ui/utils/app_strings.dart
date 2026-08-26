import 'package:flutter/material.dart';
import '../../services/idioma_service.dart';

/// =============================================================================
/// 🌐 UTILIDAD: lib/ui/utils/app_strings.dart
/// =============================================================================
/// Helper de traducción minimalista para el "Idioma de interfaz". En vez de un
/// sistema de claves (.arb), cada texto se traduce en el propio punto de uso
/// con `AppStrings.tr('texto en español', 'text in english')`. Es intencional:
/// mantiene el texto original visible junto a su traducción, así el diff de
/// cada pantalla es mínimo y fácil de revisar.
///
/// `AppStrings.current` se actualiza desde [IdiomaService] cada vez que el
/// usuario cambia el idioma. Los widgets que muestran texto traducido deben
/// usar [IdiomaListenerMixin] para reconstruirse cuando eso ocurra.
/// =============================================================================
class AppStrings {
  AppStrings._();

  static AppIdioma current = AppIdioma.es;

  /// Devuelve [es] o [en] según el idioma de interfaz actual.
  static String tr(String es, String en) =>
      current == AppIdioma.es ? es : en;
}

/// Mixin reutilizable: reconstruye el State cada vez que cambia el idioma de
/// interfaz, para que `AppStrings.tr(...)` se vuelva a evaluar con el nuevo
/// valor. Se agrega con `with IdiomaListenerMixin<MiWidget>` sin afectar el
/// resto del ciclo de vida del widget (llama a super.initState/dispose).
mixin IdiomaListenerMixin<T extends StatefulWidget> on State<T> {
  final IdiomaService _idiomaServiceListener = IdiomaService();

  @override
  void initState() {
    super.initState();
    _idiomaServiceListener.addListener(_onIdiomaChangedByMixin);
  }

  void _onIdiomaChangedByMixin() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _idiomaServiceListener.removeListener(_onIdiomaChangedByMixin);
    super.dispose();
  }
}
