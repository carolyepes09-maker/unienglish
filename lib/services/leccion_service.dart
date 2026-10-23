// =============================================================================
// 📚 SERVICIO: lib/services/leccion_service.dart
// =============================================================================
// Este servicio organiza las categorías principales de aprendizaje.
//
// FUNCIONES PRINCIPALES:
// 1. Categorización: Define los bloques de Grammar, Reading, Listening, etc.
// 2. Progreso real: la barra de cada bloque usa el dominio por habilidad ya
//    calculado por [ProgresoService] (el mismo dato que alimenta el radar
//    de la pantalla Progreso) -- antes eran valores fijos según el nivel
//    seleccionado, iguales para cualquier usuario.
//
// RELACIÓN CON OTRAS CAPAS:
// - UI: [LeccionesScreen] consume este servicio para renderizar la lista
//   de cursos y sus barras de progreso.
// =============================================================================
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

  /// ─── PASO 2: LAS TARJETAS DE HABILIDAD ────────────────────────────────────
  /// [habilidadesValues] es el mismo arreglo (escala 0-100) que usa el radar
  /// de la pantalla Progreso: [Grammar, Reading, Listening, Writing, Speaking].
  /// El nivel (A1/A2/B1/B2) no filtra qué bloques se muestran -- hoy la app
  /// no lleva progreso desglosado por nivel, así que se muestra el dominio
  /// real y general por habilidad, igual en cualquier pestaña de nivel.
  List<LeccionInfo> getLecciones(
    String nivel,
    List<double> habilidadesValues,
  ) {
    double valorDe(int indice) {
      if (indice >= habilidadesValues.length) return 0.0;
      return (habilidadesValues[indice] / 100).clamp(0.0, 1.0);
    }

    // 2.1 GENERACIÓN DE ESTRUCTURAS: Aquí creamos los objetos 'LeccionInfo'
    // que la UI convertirá en tarjetas interactivas.
    return [
      LeccionInfo(
        icon: Icons.menu_book,
        title: 'Grammar',
        subtitle: 'Gramática',
        progress: valorDe(0),
      ),
      LeccionInfo(
        icon: Icons.auto_stories,
        title: 'Reading',
        subtitle: 'Lectura',
        progress: valorDe(1),
      ),
      LeccionInfo(
        icon: Icons.headphones,
        title: 'Listening',
        subtitle: 'Escucha',
        progress: valorDe(2),
      ),
      LeccionInfo(
        icon: Icons.edit_note,
        title: 'Writing',
        subtitle: 'Escritura',
        progress: valorDe(3),
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
