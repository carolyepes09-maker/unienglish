import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/utils/app_strings.dart';

/// =============================================================================
/// 🌐 SERVICIO: lib/services/idioma_service.dart
/// =============================================================================
/// Controla el idioma de interfaz (Español/English) de forma global.
/// Se guarda en SharedPreferences (igual que el resto de servicios de la app)
/// para que la preferencia sobreviva a reinicios de la app.
/// =============================================================================

enum AppIdioma { es, en }

class IdiomaService extends ChangeNotifier {
  static final IdiomaService _instance = IdiomaService._internal();
  factory IdiomaService() => _instance;
  IdiomaService._internal();

  static const String _prefsKey = 'idioma_interfaz';

  AppIdioma _idioma = AppIdioma.es;
  AppIdioma get idioma => _idioma;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final guardado = _prefs?.getString(_prefsKey);
      _idioma = guardado == 'en' ? AppIdioma.en : AppIdioma.es;
      AppStrings.current = _idioma;
    } catch (e) {
      debugPrint('❌ Error inicializando IdiomaService: $e');
    }
  }

  /// Cambia el idioma de interfaz y lo persiste. Notifica a todos los
  /// widgets que usan [IdiomaListenerMixin] para que se redibujen.
  Future<void> cambiarIdioma(AppIdioma nuevoIdioma) async {
    if (_idioma == nuevoIdioma) return;
    _idioma = nuevoIdioma;
    AppStrings.current = nuevoIdioma;
    notifyListeners();
    try {
      await _prefs?.setString(
        _prefsKey,
        nuevoIdioma == AppIdioma.en ? 'en' : 'es',
      );
    } catch (e) {
      debugPrint('❌ Error guardando idioma de interfaz: $e');
    }
  }
}
