/// =============================================================================
/// 🗂️ ARCHIVO: palabra_model.dart
/// =============================================================================
/// Este archivo contiene el modelo de datos para el sistema de Vocabulario.
///
/// CARACTERÍSTICA ÚNICA:
/// - Implementa el algoritmo SM-2 (SuperMemo 2) de repetición espaciada. No es
///   solo una estructura de datos, sino que contiene lógica de aprendizaje.
///
/// RELACIÓN CON EL SISTEMA:
/// - UI: [VocabularioScreen] renderiza las tarjetas basándose en este modelo.
/// - SERVICE: [VocabularioService] maneja la persistencia y carga de estas palabras.
/// =============================================================================
library;

/// [PalabraModel] es el modelo de datos para las flashcards de vocabulario.
class PalabraModel {
  final String id; // Identificador único (UUID)
  final String ingles; // Palabra o frase en inglés
  final String espanol; // Traducción al español
  final String ejemplo; // Oración de ejemplo para dar contexto

  // LÓGICA DE APRENDIZAJE (SM-2):
  // [repeticiones] cuenta los aciertos SEGUIDOS (un fallo la reinicia),
  // [facilidad] es el "ease factor" (qué tan fácil le resulta al usuario esta
  // palabra, mínimo 1.3) e [intervaloDias] los días hasta la próxima revisión.
  int repeticiones;
  double facilidad;
  int intervaloDias;
  DateTime
  proximaRevision; // Fecha calculada en la que el usuario debe repasar esta palabra.
  int vecesCorrectamente; // Contador histórico de aciertos
  int vecesIncorrectamente; // Contador histórico de errores

  static const double facilidadInicial = 2.5;
  static const double facilidadMinima = 1.3;
  static const int nivelMaximo = 5;

  PalabraModel({
    required this.id,
    required this.ingles,
    required this.espanol,
    required this.ejemplo,
    int nivel = 0,
    int? repeticiones,
    this.facilidad = facilidadInicial,
    this.intervaloDias = 0,
    DateTime? proximaRevision,
    this.vecesCorrectamente = 0,
    this.vecesIncorrectamente = 0,
  }) : repeticiones = repeticiones ?? nivel,
       proximaRevision = proximaRevision ?? DateTime.now();

  /// Rango [0-5] de dominio que muestra la UI (puntos, insignia "Nivel x/5"):
  /// son los aciertos seguidos, con tope en 5.
  int get nivel => repeticiones.clamp(0, nivelMaximo);

  /// ─── ALGORITMO SM-2 ────────────────────────────────────────────────────
  /// [calidad] va de 0 (no la recordó) a 5 (respuesta perfecta). La UI de
  /// repaso solo tiene "Lo sabía" / "No lo sabía", que se traducen a 4 y 1.
  void responder(int calidad) {
    final q = calidad.clamp(0, 5);

    if (q >= 3) {
      vecesCorrectamente++;
      if (repeticiones == 0) {
        intervaloDias = 1;
      } else if (repeticiones == 1) {
        intervaloDias = 6;
      } else {
        intervaloDias = (intervaloDias * facilidad).round();
      }
      repeticiones++;
    } else {
      // Fallo: vuelve al principio y se repasa ya mismo.
      vecesIncorrectamente++;
      repeticiones = 0;
      intervaloDias = 0;
    }

    facilidad = facilidad + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (facilidad < facilidadMinima) facilidad = facilidadMinima;

    proximaRevision = DateTime.now().add(Duration(days: intervaloDias));
  }

  /// Atajo para "Lo sabía".
  void respuestaCorrecta() => responder(4);

  /// Atajo para "No lo sabía".
  void respuestaIncorrecta() => responder(1);

  /// ── LÓGICA DE FILTRADO (QUERY) ──────────────────────────────────────────
  /// Determina si la palabra debe aparecer hoy en la lista de estudio.
  bool get necesitaRevision =>
      repeticiones == 0 || !DateTime.now().isBefore(proximaRevision);

  /// Indica si la palabra ha alcanzado el dominio total de memoria.
  bool get dominada => nivel >= nivelMaximo;

  /// ── MAPEADORES DE DATOS (SERIALIZACIÓN) ──────────────────────────────────
  /// Convierte el objeto a formato JSON para ser guardado físicamente.
  Map<String, dynamic> toJson() => {
    'id': id,
    'ingles': ingles,
    'espanol': espanol,
    'ejemplo': ejemplo,
    'repeticiones': repeticiones,
    'facilidad': facilidad,
    'intervaloDias': intervaloDias,
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
    repeticiones: json['repeticiones'] ?? json['nivel'] ?? 0,
    facilidad: (json['facilidad'] as num?)?.toDouble() ?? facilidadInicial,
    intervaloDias: json['intervaloDias'] ?? 0,
    proximaRevision: DateTime.parse(json['proximaRevision']),
    vecesCorrectamente: json['vecesCorrectamente'] ?? 0,
    vecesIncorrectamente: json['vecesIncorrectamente'] ?? 0,
  );
}
