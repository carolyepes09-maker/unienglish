/// =============================================================================
/// 📚 SERVICIO: lib/services/leccion_service.dart
/// =============================================================================
/// Este servicio organiza las categorías principales de aprendizaje.
///
/// FUNCIONES PRINCIPALES:
/// 1. Categorización: Define los bloques de Grammar, Reading, Listening, etc.
/// 2. Mocking de Progreso: Simula el progreso por nivel (A1, A2, etc.) para
///    la visualización de los "Cursos" en la UI.
///
/// RELACIÓN CON OTRAS CAPAS:
/// - UI: [LeccionesScreen] consume este servicio para renderizar la lista
///   de cursos y sus barras de progreso.
/// =============================================================================
import 'package:flutter/material.dart';

class LeccionInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final bool isLocked;

  LeccionInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    this.isLocked = false,
  });
}

/// ─── PASO 1: EL SERVICIO (LOGICA DE NEGOCIO) ───────────────────────────────
/// Este es el "Cerebro" que sabe qué lecciones mostrar según el nivel.
class LeccionService extends ChangeNotifier {
  final List<String> niveles = ['A1', 'A2', 'B1', 'B2'];

  /// ─── PASO 2: EL FILTRO POR NIVEL ──────────────────────────────────────────
  /// Cuando el usuario cambia de pestaña (A1, A2...), este método se dispara
  /// para calcular qué contenido es visible basándose en el nivel seleccionado.
  List<LeccionInfo> getLecciones(String nivel) {
    // 2.1 MOCKING DE PROGRESO: Simulamos valores para que la barra se vea llena
    // o vacía dependiendo del nivel actual del usuario.
    double baseProgress = 0.0;
    if (nivel == 'A1') baseProgress = 0.8;
    if (nivel == 'A2') baseProgress = 0.4;

    // 2.2 GENERACIÓN DE ESTRUCTURAS: Aquí creamos los objetos 'LeccionInfo'
    // que la UI convertirá en tarjetas interactivas.
    return [
      LeccionInfo(
        icon: Icons.menu_book,
        title: 'Grammar',
        subtitle: 'Gramática',
        progress: (baseProgress + 0.1).clamp(0.0, 1.0),
      ),
      LeccionInfo(
        icon: Icons.auto_stories,
        title: 'Reading',
        subtitle: 'Lectura',
        progress: (baseProgress - 0.1).clamp(0.0, 1.0),
      ),
      LeccionInfo(
        icon: Icons.headphones,
        title: 'Listening',
        subtitle: 'Escucha',
        progress: (baseProgress - 0.2).clamp(0.0, 1.0),
      ),
      LeccionInfo(
        icon: Icons.edit_note,
        title: 'Writing',
        subtitle: 'Escritura',
        progress: (baseProgress - 0.3).clamp(0.0, 1.0),
      ),
      LeccionInfo(
        icon: Icons.mic,
        title: 'Speaking',
        subtitle: 'Próximamente',
        progress: 0.0,
        isLocked: true, // Bloqueo de contenido en desarrollo (Roadmap).
      ),
    ];
  }
}
