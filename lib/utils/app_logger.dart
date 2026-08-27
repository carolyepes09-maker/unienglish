import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// =============================================================================
/// UTILIDAD: lib/utils/app_logger.dart
/// =============================================================================
/// Reemplazo de print() para los logs de depuración de servicios/arranque
/// (hallazgo 13). Usa dart:developer.log (parte del SDK, sin dependencias
/// nuevas) en vez de print():
/// - Se puede filtrar por el tag 'UniEnglish' en las DevTools/logcat.
/// - Solo se emite en modo debug (kDebugMode) -- en un build de release
///   estas llamadas no hacen nada, a diferencia de print() que sigue
///   escribiendo siempre, incluso en producción.
/// =============================================================================
class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'UniEnglish');
    }
  }
}
