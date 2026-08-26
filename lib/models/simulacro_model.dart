/// =============================================================================
/// 📝 ARCHIVO: simulacro_model.dart
/// =============================================================================
/// Este archivo contiene el modelo de datos para los Exámenes de Simulacro.
/// 
/// CARACTERÍSTICA ÚNICA:
/// - A diferencia de las lecciones normales, el Simulacro permite "passages" 
///   largos que pueden cambiar por cada pregunta del examen.
/// 
/// RELACIÓN CON EL SISTEMA:
/// - UI: [SimulacroScreen] renderiza el examen usando una lista de estos modelos.
/// - SERVICE: [ExamenService] carga y mezcla las preguntas de simulacro.
/// =============================================================================

import 'contenido_tema.dart';

/// [SimulacroPregunta] es el modelo específico para los exámenes de simulacro global.
class SimulacroPregunta {
  final String? passage;    // Texto largo opcional (Ej: para Reading comprehension)
  final String? audioFile;  // Audio opcional (Ej: para Listening comprehension)
  final String question;    // La pregunta específica a responder
  final List<String> options; // Lista de opciones de respuesta
  final int correctIndex;   // Índice de la respuesta correcta
  final String explanation;  // Por qué esa es la respuesta correcta
  final String skill;        // 'grammar' | 'reading' | 'listening' | 'writing'

  const SimulacroPregunta({
    this.passage,
    this.audioFile,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.skill = 'reading',
  });

  /// Factory para construir la pregunta a partir de los datos crudos del JSON.
  /// Se llama masivamente al iniciar un simulacro en [ExamenService].
  factory SimulacroPregunta.fromJson(Map<String, dynamic> json) {
    return SimulacroPregunta(
      passage: json['passage'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      explanation: json['explanation'],
      skill: json['skill'] ?? 'reading',
    );
  }

  /// Convierte una [Pregunta] de una lección normal (Grammar/Reading/Listening/
  /// Writing) en una pregunta de simulacro, reutilizando el mismo contenido ya
  /// verificado que usan las lecciones en vez de inventar preguntas nuevas.
  /// [passage] se usa para Reading y [audioFile] para Listening, así el
  /// usuario siempre tiene a la vista (o al oído) aquello sobre lo que se le
  /// pregunta, en vez de tener que adivinarlo.
  factory SimulacroPregunta.fromPregunta(
    Pregunta pregunta, {
    required String skill,
    String? passage,
    String? audioFile,
  }) {
    return SimulacroPregunta(
      passage: passage,
      audioFile: audioFile,
      question: pregunta.pregunta,
      options: pregunta.opciones,
      correctIndex: pregunta.correcta,
      explanation: pregunta.explicacion,
      skill: skill,
    );
  }
}
