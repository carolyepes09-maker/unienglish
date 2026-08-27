import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// =============================================================================
/// 🌓 SERVICIO: lib/services/tema_service.dart
/// =============================================================================
/// Controla el tema visual (claro/oscuro) de forma global. Mismo patrón que
/// [IdiomaService]: se guarda en SharedPreferences para que la preferencia
/// sobreviva a reinicios de la app.
/// =============================================================================

enum AppTema { claro, oscuro }

class TemaService extends ChangeNotifier {
  static final TemaService _instance = TemaService._internal();
  factory TemaService() => _instance;
  TemaService._internal();

  static const String _prefsKey = 'tema_app';

  AppTema _tema = AppTema.claro;
  AppTema get tema => _tema;
  ThemeMode get themeMode =>
      _tema == AppTema.oscuro ? ThemeMode.dark : ThemeMode.light;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final guardado = _prefs?.getString(_prefsKey);
      _tema = guardado == 'oscuro' ? AppTema.oscuro : AppTema.claro;
    } catch (e) {
      debugPrint('❌ Error inicializando TemaService: $e');
    }
  }

  /// Cambia el tema y lo persiste. Notifica a los widgets que escuchan
  /// (como el MaterialApp raíz) para que se redibujen con el nuevo tema.
  Future<void> cambiarTema(AppTema nuevoTema) async {
    if (_tema == nuevoTema) return;
    _tema = nuevoTema;
    notifyListeners();
    try {
      await _prefs?.setString(
        _prefsKey,
        nuevoTema == AppTema.oscuro ? 'oscuro' : 'claro',
      );
    } catch (e) {
      debugPrint('❌ Error guardando tema: $e');
    }
  }

  Future<void> toggle() =>
      cambiarTema(_tema == AppTema.oscuro ? AppTema.claro : AppTema.oscuro);
}
