// =============================================================================
// 📁 CARPETA: lib/models/
// =============================================================================
// Esta carpeta contiene las "plantillas" o estructuras de datos de la app.
// 
// RELACIÓN CON OTRAS CAPAS:
// 1. UI (lib/ui/): Las pantallas usan estas clases para saber qué mostrar (textos, opciones).
// 2. SERVICES (lib/services/): Los servicios transforman datos crudos (JSON/Maps) 
//    en estos objetos para que la UI no tenga que lidiar con lógica compleja.
// 3. DATA (assets/data/): Es la fuente de información que luego se mapea a estos modelos.
// =============================================================================

/// [Ejemplo] representa un par de oraciones para mostrar uso práctico.
/// Se usa principalmente en la sección de "Examples" de cada lección.
class Ejemplo {
  final String ingles;
  final String traduccion;
  const Ejemplo({required this.ingles, required this.traduccion});
}

/// [Pregunta] define la estructura de cada ejercicio interactivo.
/// Se llama desde [EjercicioService] para validar respuestas en la UI.
class Pregunta {
  final String pregunta;      // El enunciado del ejercicio
  final List<String> opciones; // Las 2 o 4 opciones de respuesta
  final int correcta;         // Índice (0, 1, 2...) de la respuesta correcta
  final String explicacion;    // Feedback que aparece después de responder
  
  const Pregunta({
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    required this.explicacion,
  });
}

/// [Estructura] define la gramática técnica de un tiempo verbal.
/// Es la base de las lecciones de la categoría "Grammar".
class Estructura {
  final String positiva;
  final String negativa;
  final String pregunta;
  const Estructura({
    required this.positiva,
    required this.negativa,
    required this.pregunta,
  });
}

/// [ContenidoTema] es la clase MAESTRA que unifica todo el contenido de una lección.
/// Se utiliza en:
/// - [TemaDetalleScreen]: Para mostrar la parte teórica.
/// - [EjerciciosScreen]: Para cargar la lista de [Pregunta].
/// - [EjercicioService]: Para gestionar el flujo de la lección actual.
class ContenidoTema {
  final String titulo;               // Ej: "Present Simple"
  final String? descripcion;         // Breve resumen
  final String queEs;                // Definición teórica
  final List<String>? cuandoSeUsa;   // Reglas de uso
  final dynamic estructura;          // Puede ser [Estructura] o String (Reading/Listening)
  final List<Ejemplo>? ejemplos;     // Lista de oraciones de ejemplo
  final List<String> erroresComunes; // Lo que el estudiante debe evitar
  final List<String> tipsParaRecordar;// Trucos mnemotécnicos
  final List<Pregunta> ejercicios;   // Cuestionario interactivo
  
  // Campos específicos para Listening/Reading/Writing (Polimorfismo dinámico)
  final dynamic tecnicasEscucha;     // Pasos para mejorar el listening
  final dynamic transcript;          // Texto del audio
  final dynamic textoEjemplo;        // Texto para lectura (Reading)
  final dynamic criterios;           // Reglas de evaluación (Writing)
  final dynamic ejemploModelo;       // Ensayo de ejemplo (Writing)
  final String? audioFile;           // Ruta al archivo .mp4 o .mp3

  const ContenidoTema({
    required this.titulo,
    this.descripcion,
    required this.queEs,
    this.cuandoSeUsa,
    this.estructura,
    this.ejemplos,
    required this.erroresComunes,
    required this.tipsParaRecordar,
    required this.ejercicios,
    this.tecnicasEscucha,
    this.transcript,
    this.textoEjemplo,
    this.criterios,
    this.ejemploModelo,
    this.audioFile,
  });
}
