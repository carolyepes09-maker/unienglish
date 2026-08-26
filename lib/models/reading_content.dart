// ═════════════════════════════════════════════════════════════════════════════════
// MODELOS DE DATOS PARA CONTENIDO DE READING
// ═════════════════════════════════════════════════════════════════════════════════

/// =============================================================================
/// 📖 ARCHIVO: reading_content.dart
/// =============================================================================
/// Este archivo contiene la "Base de Datos" de lecciones de Lectura (Reading).
/// 
/// CARACTERÍSTICA ESPECIAL:
/// - A diferencia de Grammar, aquí el campo "textoEjemplo" contiene el pasaje 
///   de lectura principal que el estudiante debe analizar.
/// 
/// RELACIÓN CON EL SISTEMA:
/// - UI: Consumido por [TemaDetalleScreen] para mostrar el texto de lectura.
/// - SERVICE: [EjercicioService] utiliza los cuestionarios al final de este archivo.
/// =============================================================================

import 'contenido_tema.dart';

class Texto {
  final String ingles;
  final String traduccion;
  final String tema;

  const Texto({
    required this.ingles,
    required this.traduccion,
    required this.tema,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO READING - SKIMMING
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema skimming = ContenidoTema(
  titulo: 'Skimming',
  descripcion: 'Lectura rapida',
  queEs:
      'Skimming es leer un texto rapidamente para entender la idea general sin leer cada palabra. Usas los ojos para encontrar palabras clave, titulos y estructura para captar el sentido general en segundos.',
  cuandoSeUsa: [
    'Revisar titulares de noticias para ver cuales te interesan',
    'Hojear un articulo academico para decidir si lo necesitas',
    'Escanear un email largo para entender el tema principal',
  ],
  estructura: [
    '1. Lee el titulo y subtitulos para identificar el tema',
    '2. Mira parrafos: lee primera y ultima frase',
    '3. Busca numeros, nombres propios, palabras en bold',
    '4. Forma una idea general sin leer todo',
  ],
  textoEjemplo: const Texto(
    ingles:
        'Artificial intelligence is changing how universities teach and how students learn. Many institutions now use AI tools to personalize education, providing custom learning paths for each student. Professors use AI to create adaptive quizzes that adjust difficulty based on student performance. This technology helps identify struggling students early and provides targeted support. However, universities must maintain academic integrity and ensure students develop critical thinking skills, not just rely on AI solutions.',
    traduccion:
        'La inteligencia artificial esta cambiando como las universidades ensenian y como los estudiantes aprenden. Muchas instituciones ahora usan herramientas de IA para personalizar la educacion, proporcionando rutas de aprendizaje personalizadas para cada estudiante. Los profesores usan IA para crear pruebas adaptativas que ajustan la dificultad segun el desempeno del estudiante. Esta tecnologia ayuda a identificar estudiantes con dificultades temprano y proporciona apoyo dirigido. Sin embargo, las universidades deben mantener la integridad academica y asegurar que los estudiantes desarrollen pensamiento critico, no solo dependan de soluciones de IA.',
    tema: 'AI in Education',
  ),
  erroresComunes: [
    'Intentar entender cada palabra — esto RALENTIZA. Salta palabras desconocidas si no cambian el sentido.',
    'No usar titulos y estructura — los profesores ponen informacion importante ahi primero.',
    'Leer palabra por palabra como un principiante. Usa grupos de palabras y patrones visuales.',
  ],
  tipsParaRecordar: [
    'Titulo = tema principal. Primera frase de cada parrafo = idea del parrafo',
    '30 segundos por pagina es el objetivo. Si tardas mas, vas muy lento',
    'Busca palabras GRANDES y palabras REPETIDAS — son importantes',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Based on skimming the text, what is the MAIN topic?',
      opciones: [
        'How to use AI to cheat exams',
        'AI tools improving university education',
        'Why universities should ban technology',
        'How students should avoid homework',
      ],
      correcta: 1,
      explicacion:
          'El titulo y primeras frases mencionan "AI changing how universities teach". Skimming te da esta idea sin leer todo. Las otras opciones estan fuera del contexto.',
    ),
    const Pregunta(
      pregunta:
          'When skimming this text, which sentence would you read carefully?',
      opciones: [
        'A sentence in the middle of a paragraph about grammar rules',
        'The first sentence of each paragraph explaining the main idea',
        'Random sentences with short words',
        'Sentences with all words you don\'t know',
      ],
      correcta: 1,
      explicacion:
          'Skimming estrategico: lee PRIMERAS frases que tienen la idea del parrafo. Eso te da el contenido principal rapido.',
    ),
    const Pregunta(
      pregunta:
          'What should you do if you encounter an unknown word while skimming?',
      opciones: [
        'Stop and look it up in the dictionary immediately',
        'Read it letter by letter slowly',
        'Skip it and continue if it doesn\'t block comprehension',
        'Go back and re-read the whole paragraph',
      ],
      correcta: 2,
      explicacion:
          'Skimming es rapido. Una palabra desconocida no es importante si entiendes el significado general. Los hispanohablantes tienden a pausar en palabras desconocidas, perdiendo velocidad.',
    ),
    const Pregunta(
      pregunta: 'According to the AI text, which is an advantage mentioned?',
      opciones: [
        'AI prevents students from learning',
        'AI provides personalized learning paths for students',
        'AI removes all human teachers',
        'AI makes exams impossible to pass',
      ],
      correcta: 1,
      explicacion:
          'Skimming el texto: "personalize education, providing custom learning paths" esta en segundo parrafo. La respuesta es clara si lees estructura, no palabras.',
    ),
    const Pregunta(
      pregunta:
          'Skimming time limit: How many seconds should you spend on ONE page?',
      opciones: [
        '5-10 seconds for quick overview',
        '30 seconds to capture main ideas',
        '2-3 minutes for careful reading',
        '10-15 minutes for deep comprehension',
      ],
      correcta: 1,
      explicacion:
          'Skimming objetivo: 25-35 segundos por pagina. Si tardas mas, no estias skimming, estis leyendo normal. Esto es difícil para hispanohablantes acostumbrados a leer cada palabra.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO READING - SCANNING
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema scanning = ContenidoTema(
  titulo: 'Scanning',
  descripcion: 'Busqueda de informacion especifica',
  queEs:
      'Scanning es buscar informacion ESPECIFICA en un texto sin leer todo. Buscas una palabra clave exacta o numero. Es diferente de skimming: skimming es para idea general, scanning es para DATOS PRECISOS.',
  cuandoSeUsa: [
    'Buscar un numero telefonico o adresa en un documento',
    'Encontrar una fecha especifica en un articulo historico',
    'Localizar un nombre de autor en una Bibliografia',
    'Buscar precios en un menu o catalogo',
  ],
  estructura: [
    '1. Define exactamente QUE buscas (palabra, numero, fecha)',
    '2. Mueve los ojos rapidamente por la pagina',
    '3. Busca patrones visuales: MAYUSCULAS, bold, numeros',
    '4. Lee alrededor cuando encuentres la palabra clave',
  ],
  textoEjemplo: const Texto(
    ingles:
        'The International Conference on Climate Change will be held from June 15-18, 2024, in Copenhagen, Denmark. Dr. Sarah Mitchell, lead researcher from Oxford University, will present findings on carbon emissions. Registration fees are USD 250 for students and USD 450 for professionals. The conference website at www.climateforum.org has the full schedule. Early bird discounts end on May 1st. Contact: info@climateforum.org for questions.',
    traduccion:
        'La Conferencia Internacional sobre Cambio Climatico se realizara del 15 al 18 de junio de 2024, en Copenhague, Dinamarca. La Dra. Sarah Mitchell, investigadora principal de la Universidad de Oxford, presentara hallazgos sobre emisiones de carbono. Las tarifas de registro son USD 250 para estudiantes y USD 450 para profesionales. El sitio web de la conferencia en www.climateforum.org tiene el horario completo. Los descuentos anticipados terminan el 1 de mayo. Contacto: info@climateforum.org para preguntas.',
    tema: 'Conference Information',
  ),
  erroresComunes: [
    'Leer el texto completo buscando informacion — esto derrota el proposito. Move los ojos RAPIDAMENTE sin enfocarte.',
    'No saber QUE estis buscando. Define exactamente la palabra/numero/dato ANTES de empezar.',
    'Detenerse en palabras desconocidas cerca del dato. Scan significa: ignora todo lo irrelevante.',
  ],
  tipsParaRecordar: [
    'DEFINE tu objetivo antes de scanning. "Busco un precio, una fecha, un nombre"',
    'Busca patrones: Numeros empiezan diferente (USD, 2024), nombres tienen mayusculas',
    'URLs, emails, numeros = faciles de encontrar porque visualmente diferentes',
  ],
  ejercicios: [
    const Pregunta(
      pregunta:
          'What specific date should you scan for if looking for the conference END date?',
      opciones: ['May 1st', 'June 18, 2024', 'June 15-18', 'Before May 1st'],
      correcta: 1,
      explicacion:
          'Scanning el rango "June 15-18". La fecha final (END) es June 18. Buscas el numero mas grande en ese rango.',
    ),
    const Pregunta(
      pregunta:
          'If scanning for PRICE information, what pattern helps you find it fastest?',
      opciones: [
        'Long sentences describing the conference',
        "Dollar signs (\$) or \"USD\" followed by numbers",
        'The word "information" repeated multiple times',
        'Paragraphs at the beginning of the text',
      ],
      correcta: 1,
      explicacion:
          'Scanning patrones visuales: USD y numeros destacan. Dollar sign y numeros son faciles de ver rapidamente. Los hispanohablantes tienden a leer contexto, pero scanning solo necesita patrones.',
    ),
    const Pregunta(
      pregunta: 'Where would you look FIRST if scanning for a website address?',
      opciones: [
        'The title of the document',
        'Middle of paragraphs with general information',
        'Look for "www.", ".org", or ".com" patterns',
        'The very last word of the text',
      ],
      correcta: 2,
      explicacion:
          'URLs tienen patrones unicas: www., punto, dominios. Busca esos patrones visuales. Scanning = busca FORMA, no contenido.',
    ),
    const Pregunta(
      pregunta:
          'To scan for "Early bird discounts end on May 1st", what target would you seek?',
      opciones: [
        'The word "conference"',
        'A date pattern: numbers with month names (May 1, May 15, etc)',
        'The name "Sarah Mitchell"',
        'The price "250"',
      ],
      correcta: 1,
      explicacion:
          'Tu objetivo: una FECHA. Buscas patrones de fecha: numero + mes. Scanning entrena los ojos a buscar formas, no significado.',
    ),
    const Pregunta(
      pregunta:
          'Scanning vs Skimming: Which would you use to answer "What day does the conference START?"',
      opciones: [
        'Skimming to understand overall dates',
        'Reading every word carefully',
        'Scanning for the START date specifically in the text',
        'Using a dictionary for every date word',
      ],
      correcta: 2,
      explicacion:
          'Necesitas un dato EXACTO (fecha de inicio). Eso es scanning. Skimming seria para "aprox cuando es la conferencia". Scanning = datos precisos.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO READING - INFERENCE
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema inference = ContenidoTema(
  titulo: 'Inference',
  descripcion: 'Comprender lo NO escrito',
  queEs:
      'Inference es entender lo que el texto SUGIERE pero no dice explicitamente. Usas el contexto para adivinar significados, animos, o razones. Es leer entre lineas usando pistas (clues).',
  cuandoSeUsa: [
    'Entender por que un personaje en una historia esta triste sin que lo diga',
    'Saber que un producto es caro porque dice "premium" o "exclusive"',
    'Deducir que una empresa tiene problemas porque sus empleados estan buscando otro trabajo',
  ],
  estructura: [
    '1. Lee el texto directamente: Qué DICE exactamente?',
    '2. Busca pistas (clues): palabras emotivas, acciones, contexto',
    '3. Conecta pistas: Qué sugieren juntas?',
    '4. Forma conclusión: Qué se IMPLICA aunque no este escrito?',
  ],
  textoEjemplo: const Texto(
    ingles:
        'Professor Johnson has been teaching Engineering for 25 years. Last week, he was offered a position at a tech company as a consultant, but he politely declined. "My students keep me young," he said with a smile. He stays for lunch every day to help students with projects, and he never charges extra for tutoring. His office door is always open, even on weekends.',
    traduccion:
        'El profesor Johnson ha estado ensenando Ingenieria durante 25 anos. La semana pasada, le ofrecieron un puesto en una empresa tecnologica como consultor, pero educadamente lo rechazo. "Mis estudiantes me mantienen joven", dijo con una sonrisa. Se queda a almorzar todos los dias para ayudar a los estudiantes con proyectos, y nunca cobra extra por tutorias. Su puerta de oficina siempre esta abierta, incluso los fines de semana.',
    tema: 'Professor Values Students',
  ),
  erroresComunes: [
    'No hacer inferencias — solo leer lo literal. "El profesor declino el trabajo" sin entender por QUE.',
    'Hacer inferencias INCORRECTAS basadas en prejuicios, no evidencia del texto.',
    'Pensar que inference = adivinanza. NO. Las pistas estan EN el texto.',
  ],
  tipsParaRecordar: [
    'Pistas estan en el texto: acciones, palabras, lo que NO dicen. Usa eso.',
    'Inference no es "adivinar". Es sacar conclusiones desde evidencia.',
    'Lee ENTRE LINEAS: Si alguien declina un trabajo bien pagado, valora otras cosas. Qué? El texto lo demuestra.',
  ],
  ejercicios: [
    const Pregunta(
      pregunta:
          'What does the professor\'s decision to decline the tech company job IMPLY about his priorities?',
      opciones: [
        'He is not interested in technology or money',
        'He values his students and teaching more than a higher salary',
        'He is afraid of change and new challenges',
        'The tech company was not professional enough',
      ],
      correcta: 1,
      explicacion:
          'Pistas: declino un buen trabajo, pero "mis estudiantes me mantienen joven". Inference: El profesor valora sus estudiantes MAS que dinero. Esto no esta escrito, pero se implica.',
    ),
    const Pregunta(
      pregunta:
          'Based on the professor staying for lunch and tutoring without charge, what can you infer?',
      opciones: [
        'He has no other activities or income',
        'He is forced by the university to tutor students',
        'He genuinely cares about student success beyond his job requirements',
        'He is trying to impress others to get promoted',
      ],
      correcta: 2,
      explicacion:
          'Las acciones IMPLICAN motivacion. No cobra, se queda voluntariamente, su puerta esta abierta. Esto sugiere motivacion interna: le importan los estudiantes.',
    ),
    const Pregunta(
      pregunta:
          'The text says his office door is "always open, even on weekends." What does this SUGGEST?',
      opciones: [
        'The university makes him work weekends',
        'He has no family or personal activities',
        'He is accessible to students beyond normal working hours and prioritizes their needs',
        'He forgot to close his office door many times',
      ],
      correcta: 2,
      explicacion:
          '"Even on weekends" es la pista importante. IMPLICA que va alla voluntariamente en su tiempo personal. Inference: sus estudiantes son prioridad.',
    ),
    const Pregunta(
      pregunta:
          'Why might the professor say "My students keep me young" with a SMILE (not angrily)?',
      opciones: [
        'He is sad about his age',
        'He is being forced to work with students',
        'He genuinely enjoys the interaction and finds it positive and energizing',
        'He is making a joke because he dislikes teaching',
      ],
      correcta: 2,
      explicacion:
          'El TONO (smile) es pista crucial. Una sonrisa + esa frase = positivo, gratificante. Sin la sonrisa, seria sarcasmo. Inference requiere TONO y CONTEXTO.',
    ),
    const Pregunta(
      pregunta:
          'What does the combination of ALL these actions suggest about his character?',
      opciones: [
        'He is wealthy and can afford to work without payment',
        'He is dedicated, compassionate, and motivated by student success rather than financial gain',
        'He secretly wants a promotion and is working hard to get noticed',
        'He is unsure about his career and avoids new opportunities',
      ],
      correcta: 1,
      explicacion:
          'INFERENCE >= conectar pistas. 25 anos ensenando + declina trabajo mejor pagado + tutora gratis + always available = conclusion: motivos de COMPASION y DEDICACION profunda. No solo dinero.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// MAPA UNIFICADO DE TEMAS PARA READING
// ══════════════════════════════════════════════════════════════════════════════
final Map<String, ContenidoTema> readingTopics = {
  'Skimming': skimming,
  'Scanning': scanning,
  'Inference': inference,
};
