import 'package:flutter/material.dart';
import '../models/palabra_model.dart';
import 'vocabulario_service.dart';

/// =============================================================================
/// 🔄 SERVICIO: lib/services/revision_service.dart
/// =============================================================================
/// Este servicio gestiona una "Sesión de Repaso" de flashcards.
///
/// FUNCIONES PRINCIPALES:
/// 1. Navegación de Flashcards: Controla el paso de una tarjeta a otra.
/// 2. Lógica de Respuesta: Actualiza el [PalabraModel] basándose en si el
///    usuario "sabía" o "no sabía" la palabra.
/// 3. Sincronización: Envía las actualizaciones al [VocabularioService]
///    para persistencia inmediata.
///
/// RELACIÓN CON OTRAS CAPAS:
/// - UI: [RevisionScreen] (o similar) usa este servicio para manejar el
///   estado visual de las tarjetas (reverso/anverso) y el progreso.
/// =============================================================================

class RevisionService extends ChangeNotifier {
  final List<PalabraModel> palabras; // Lista de palabras a repasar hoy
  final VocabularioService vocabularioService; // Para guardar cambios

  int _indiceActual = 0; // Palabra que se está viendo
  int _correctas = 0; // Contador de "lo sabía"
  int _incorrectas = 0; // Contador de "no lo sabía"
  bool _mostrandoReverso = false; // Estado de la tarjeta actual

  RevisionService({required this.palabras, required this.vocabularioService});

  // Getters
  int get indiceActual => _indiceActual;
  int get correctas => _correctas;
  int get incorrectas => _incorrectas;
  bool get mostrandoReverso => _mostrandoReverso;
  int get total => palabras.length;
  PalabraModel get palabraActual => palabras[_indiceActual];

  /// Cálculo de cuánto ha avanzado el usuario en la sesión actual.
  double get progreso => (_indiceActual + 1) / palabras.length;

  /// Indica si ya se terminaron todas las tarjetas de la sesión.
  bool get haTerminado => _indiceActual >= palabras.length - 1;

  /// Da la vuelta a la tarjeta para mostrar la traducción.
  void toggleReverso() {
    _mostrandoReverso = !_mostrandoReverso;
    notifyListeners();
  }

  /// ─── LÓGICA DE RESPUESTA: MÉTODO CIENTÍFICO ──────────────────────────────
  /// Procesa la interacción del usuario basándose en SM-2.
  bool responder(bool sabia) {
    final palabra = palabras[_indiceActual];
    if (sabia) {
      // 1. ÉXITO: Si sabía la palabra, el nivel de recordación sube.
      palabra.respuestaCorrecta();
      _correctas++;
    } else {
      // 2. FALLO: Si no la sabía, el nivel vuelve a 0 para repaso inmediato.
      palabra.respuestaIncorrecta();
      _incorrectas++;
    }

    // ─── SINCRONIZACIÓN (UPDATE) ───────────────────────────────────────────
    // Actualizamos el estado en el servicio global para que el cambio persista
    vocabularioService.actualizarPalabra(palabra.id, {
      'facilidad': sabia ? 5 : 1,
      'total_correctas': sabia
          ? (palabra.vecesCorrectamente + 1)
          : palabra.vecesCorrectamente,
      'total_incorrectas': sabia
          ? palabra.vecesIncorrectamente
          : (palabra.vecesIncorrectamente + 1),
    });

    if (_indiceActual < palabras.length - 1) {
      // 3. NAVEGACIÓN: Pasamos a la siguiente flashcard de la pila.
      _indiceActual++;
      _mostrandoReverso = false; // Reset de la vista para la siguiente palabra.
      notifyListeners();
      return true; // Continuar sesión.
    } else {
      return false; // Sesión de repaso completada.
    }
  }
}
