/// =============================================================================
/// 🗂️ ARCHIVO: palabra_model.dart
/// =============================================================================
/// Este archivo contiene el modelo de datos para el sistema de Vocabulario.
///
/// CARACTERÍSTICA ÚNICA:
/// - Implementa el algoritmo Spaced Repetition (Repetición Espaciada). No es solo
///   una estructura de datos, sino que contiene lógica de aprendizaje.
///
/// RELACIÓN CON EL SISTEMA:
/// - UI: [VocabularioScreen] renderiza las tarjetas basándose en este modelo.
/// - SERVICE: [VocabularioService] maneja la persistencia y carga de estas palabras.
/// =============================================================================

/// [PalabraModel] es el modelo de datos para las flashcards de vocabulario.
class PalabraModel {
  final String id; // Identificador único (UUID)
  final String ingles; // Palabra o frase en inglés
  final String espanol; // Traducción al español
  final String ejemplo; // Oración de ejemplo para dar contexto

  // LÓGICA DE APRENDIZAJE:
  int nivel; // Rango [0-5]. Indica qué tan bien se conoce la palabra.
  DateTime
  proximaRevision; // Fecha calculada en la que el usuario debe repasar esta palabra.
  int vecesCorrectamente; // Contador histórico de aciertos
  int vecesIncorrectamente; // Contador histórico de errores

  PalabraModel({
    required this.id,
    required this.ingles,
    required this.espanol,
    required this.ejemplo,
    this.nivel = 0,
    DateTime? proximaRevision,
    this.vecesCorrectamente = 0,
    this.vecesIncorrectamente = 0,
  }) : proximaRevision = proximaRevision ?? DateTime.now();

  /// ─── ALGORITMO SM-2 SIMPLIFICADO ────────────────────────────────────────
  /// Incrementa el nivel y calcula la fecha de la próxima revisión.
  /// A mayor nivel, más tiempo pasa antes de la siguiente revisión (Repetición Espaciada).
  void respuestaCorrecta() {
    vecesCorrectamente++;
    nivel = (nivel + 1).clamp(0, 5); // Máximo nivel de dominio = 5

    // ── INTERVALOS DÍA ──────────────────────────────────────────────────
    // nivel 1 = 1 día, nivel 2 = 3 días, nivel 3 = 7 días, nivel 4 = 14 días...
    final intervalos = [0, 1, 3, 7, 14, 30];
    proximaRevision = DateTime.now().add(Duration(days: intervalos[nivel]));
  }

  /// ── REINICIO POR FALLO ──────────────────────────────────────────────────
  /// Reinicia el nivel a 0 si el usuario falla, obligando a repasar pronto.
  void respuestaIncorrecta() {
    vecesIncorrectamente++;
    nivel = 0;
    proximaRevision = DateTime.now();
  }

  /// ── LÓGICA DE FILTRADO (QUERY) ──────────────────────────────────────────
  /// Determina si la palabra debe aparecer hoy en la lista de estudio.
  bool get necesitaRevision =>
      DateTime.now().isAfter(proximaRevision) || nivel == 0;

  /// Indica si la palabra ha alcanzado el dominio total de memoria.
  bool get dominada => nivel >= 5;

  /// ── MAPEADORES DE DATOS (SERIALIZACIÓN) ──────────────────────────────────
  /// Convierte el objeto a formato JSON para ser guardado físicamente.
  Map<String, dynamic> toJson() => {
    'id': id,
    'ingles': ingles,
    'espanol': espanol,
    'ejemplo': ejemplo,
    'nivel': nivel,
    'proximaRevision': proximaRevision.toIso8601String(),
    'vecesCorrectamente': vecesCorrectamente,
    'vecesIncorrectamente': vecesIncorrectamente,
  };

  /// Crea un objeto [PalabraModel] desde un mapa JSON.
  factory PalabraModel.fromJson(Map<String, dynamic> json) => PalabraModel(
    id: json['id'],
    ingles: json['ingles'],
    espanol: json['espanol'],
    ejemplo: json['ejemplo'],
    nivel: json['nivel'] ?? 0,
    proximaRevision: DateTime.parse(json['proximaRevision']),
    vecesCorrectamente: json['vecesCorrectamente'] ?? 0,
    vecesIncorrectamente: json['vecesIncorrectamente'] ?? 0,
  );
}
