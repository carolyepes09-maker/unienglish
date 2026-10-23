// ═════════════════════════════════════════════════════════════════════════════════
// MODELOS DE DATOS PARA CONTENIDO DE LISTENING
// ═════════════════════════════════════════════════════════════════════════════════

// =============================================================================
// 🎧 ARCHIVO: listening_content.dart
// =============================================================================
// Este archivo contiene la "Base de Datos" de lecciones de Escucha (Listening).
// 
// CARACTERÍSTICAS ESPECIALES:
// 1. Campo "audioFile": Ruta al archivo de reprodución (.mp4/mp3).
// 2. Campo "transcript": Texto completo de lo que se narra en el audio.
// 3. Campo "tecnicasEscucha": Consejos específicos para entender el audio.
// 
// RELACIÓN CON EL SISTEMA:
// - UI: Consumido por [TemaDetalleScreen] para el reproductor de audio.
// - SERVICE: [EjercicioService] carga las preguntas de comprensión auditiva.
// =============================================================================

import 'contenido_tema.dart';

class Transcript {
  final String ingles;
  final String traduccion;
  final String escena;

  const Transcript({
    required this.ingles,
    required this.traduccion,
    required this.escena,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO LISTENING - BASIC CONVERSATIONS
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema basicConversations = ContenidoTema(
  titulo: 'Basic Conversations',
  descripcion: 'Dialogos cotidianos',
  queEs:
      'Escuchar y comprender conversaciones normales entre dos o mas personas. Usas contexto, palabras clave, y entonacion para entender de que hablan. Perfecto para entrenar comprension rapida.',
  cuandoSeUsa: [
    'Platicar con companeros de clase o colegas en la universidad',
    'Llamadas telefonicas para hacer citas o preguntar informacion',
    'Conversaciones sociales en cafeterias, pasillos, o eventos',
  ],
  tecnicasEscucha: [
    'Escucha el PRIMER dicho de cada persona para entender quienes hablan',
    'Busca palabras clave: preguntas (qué, cuándo, dónde), verbos principales',
    'Presta atencion a cambios de voz: pregunta vs respuesta, entusiasmo vs desacuerdo',
    'En diálogos normales, muchas palabras NO importan. Ignora rellenos como "um, like, you know"',
  ],
  transcript: const Transcript(
    ingles:
        'Student A: "Hey! Did you finish the programming assignment yet?" Student B: "Not yet, man. The deadline is tomorrow at midnight, right?" Student A: "Yeah, but I heard the professor might extend it because many students have conflicts." Student B: "Really? That would be great! I honestly spent most of my time on the chemistry test because it was worth more points." Student A: "I get it. That test was brutal. So you\'re going to work on the code tonight?" Student B: "Yeah, probably start around 8 PM. Want to study together?" Student A: "Sure! Let\'s meet in the library at 7:30." Student B: "Perfect. See you then!"',
    traduccion:
        'Estudiante A: "Hey! Ya terminaste la tarea de programacion?" Estudiante B: "Todavia no, hombre. La fecha limite es manana a medianoche, verdad?" Estudiante A: "Si, pero escuche que el profesor podria extenderla porque muchos estudiantes tienen conflictos." Estudiante B: "Enserio? Eso seria genial! Honestamente pase la mayor parte del tiempo en el examen de quimica porque valia mas puntos." Estudiante A: "Entiendo. Ese examen fue brutal. Asi que vas a trabajar en el codigo esta noche?" Estudiante B: "Si, probablemente comience alrededor de las 8 PM. Quieres estudiar juntos?" Estudiante A: "Claro! Nos vemos en la biblioteca a las 7:30." Estudiante B: "Perfecto. Nos vemos alli!"',
    escena: 'Campus Conversation',
  ),
  erroresComunes: [
    'Intentar entender CADA palabra. Las conversaciones tienen "um, like, you know" — ignora eso. Busca el punto principal.',
    'Perder enfoque si no conoces una palabra. En listening real, el contexto SIGUIENTE te da la informacion.',
    'No distinguir entre pregunta y respuesta. Escucha cambios de entonacion — preguntas suben, respuestas bajan (en ingles).',
  ],
  tipsParaRecordar: [
    'Busca palabras FAMILIARES dentro de la oracion. Si entiendes "assignment" y "deadline", entiendes la idea general.',
    'Entonacion = significado. Subida de voz = pregunta. Bajada = afirmacion. Rapido = sorpresa o prisa.',
    'NO necesitas 100% comprension. 60-70% de palabras clave = entiendes el tema.',
  ],
  audioFile: 'assets/audio/basic.mp4',
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the main topic they are discussing?',
      opciones: [
        'A chemistry test that was difficult',
        'A programming assignment and its deadline',
        'Meeting at the library to study',
        'Why exams are worth more points',
      ],
      correcta: 1,
      explicacion:
          'La conversacion comienza con "Did you finish the programming assignment?" Esa es la idea principal, aunque discuten otras cosas. Listening busca el TEMA CENTRAL.',
    ),
    const Pregunta(
      pregunta: 'According to the conversation, WHEN will they meet?',
      opciones: [
        'At 8 PM at the student A\'s room',
        'At 7:30 PM at the library',
        'At midnight for the assignment deadline',
        'Tomorrow morning at the chemistry lab',
      ],
      correcta: 1,
      explicacion:
          'Frase exacta: "Let\'s meet in the library at 7:30". Buscas una HORA + LUGAR. En conversaciones reales, estos detalles claves se repiten.',
    ),
    const Pregunta(
      pregunta: 'Why did Student B spend more time on chemistry?',
      opciones: [
        'The professor told him to',
        'He didn\'t have time for programming',
        'Chemistry test was worth more points (more important)',
        'He likes chemistry more than programming',
      ],
      correcta: 2,
      explicacion:
          'Audio: "I spent most of my time on the chemistry test because it was worth more points." La razon esta clara. Listening aqui requiere CAUSA-EFECTO.',
    ),
    const Pregunta(
      pregunta:
          'What HOPE does Student B express about the programming deadline?',
      opciones: [
        'He hopes the professor will cancel the assignment',
        'He hopes Student A will do his work for him',
        'He hopes the professor might extend the deadline',
        'He hopes he can sleep instead of working',
      ],
      correcta: 2,
      explicacion:
          'Student A dice: "I heard the professor might extend it". Student B responde "Really? That would be great!" IMPLICA que espera esa extension. Inference en listening.',
    ),
    const Pregunta(
      pregunta: 'What can you INFER about their relationship?',
      opciones: [
        'They are competitors who don\'t like each other',
        'They are close friends who study together and support each other',
        'Student A is the teacher and Student B is the student',
        'They met for the first time today',
      ],
      correcta: 1,
      explicacion:
          'Pistas: hablan casualmente ("hey, man"), ofrecen estudiar juntos, dicen "Sure! Let\'s meet" rapidamente. Esto sugiere cercania. Listening no es solo palabras, tambien relaciones.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO LISTENING - ACCENTS & PRONUNCIATION
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema accentsAndPronunciation = ContenidoTema(
  titulo: 'Accents & Pronunciation',
  descripcion: 'Comprender diferentes acentos',
  queEs:
      'Entrenar el oido para comprender ingles con diferentes acentos y pronunciaciones: americano, britanico, australiano, o no nativo. Aprende variaciones en sonidos, entonacion y ritmo.',
  cuandoSeUsa: [
    'Ver peliculas o series de paises angloparlantes diferentes',
    'Escuchar profesores internacionales en conferencias universitarias',
    'Ver videos de YouTube desde creadores de distintos paises',
  ],
  tecnicasEscucha: [
    'Primera vez: No intentes entender perfecto. Solo familiariza tu oido con el RITMO.',
    'Segunda vez: Busca palabras clave en medio del nuevo ritmo y pronunciacion.',
    'Repite lo que escuchas (shadowing) para entrenar tu pronunciacion con ese acento.',
    'Busca PATRONES en el acento: britanico suena mas formal, australiano mas coloquial.',
  ],
  transcript: const Transcript(
    ingles:
        'British Professor: "Right then, we\'ll examine how academic writing develops across different cultures. The Americans, you see, prefer directness in their essays—straight to the point. The British, historically, use more elaborate structures. Now, Australians tend to be quite informal in their academic discourse. It\'s rather fascinating, isn\'t it? What we must understand is that understanding these variations is crucial for your studies."',
    traduccion:
        'Profesor Britanico: "Bien, entonces examinaremos como la escritura academica se desarrolla en diferentes culturas. Los estadounidenses, ves, prefieren la directividad en sus ensayos — al punto. Los britanicos, historicamente, usan estructuras mas elaboradas. Ahora, los australianos tienden a ser bastante informales en su discurso academico. Es bastante fascinante, verdad? Lo que debemos entender es que entender estas variaciones es crucial para tus estudios."',
    escena: 'University Lecture about Writing',
  ),
  erroresComunes: [
    'Esperar que TODOS los angloparlantes suenen como peliculas de Hollywood. NO. Hay muchos acentos.',
    'Rendirse cuando no entiendes. Los acentos REQUIEREN entrenamiento. Escucha 3-4 veces minimo.',
    'No notar que algunas palabras se ELIDEN (se comen). "You\'re going to" = "You\'re gonna" o Australian "gonna" suena diferente.',
  ],
  tipsParaRecordar: [
    'Acento britanico: R\'s suave, vocales mas largas. Acento americano: R\'s duro, ritmo mas rapido.',
    'Australiano: SUBE entonacion al final de frases (parece pregunta pero no es). Adapta tus expectativas.',
    'Escucha el mismo texto con DIFERENTES acentos. Tu cerebro se adapta mas rapido viendo variaciones.',
  ],
  ejercicios: [
    const Pregunta(
      pregunta:
          'Based on the British accent in the lecture, what can you identify about British English pronunciation?',
      opciones: [
        'Identical to American English pronunciation',
        'Uses softer "R" sounds and maintains more formal tone',
        'Faster and less structured than other English varieties',
        'Drop most vowels to speak quickly',
      ],
      correcta: 1,
      explicacion:
          'Caracteristicas britanicas: R\'s suave (hear = "heah"), entonacion formal elevada, estructura cuidadosa. Listening entrena el oido a estas características unicas.',
    ),
    const Pregunta(
      pregunta: 'What is the professor\'s main point about academic writing?',
      opciones: [
        'British English is the only correct academic writing',
        'Americans write more efficiently than other cultures',
        'Different cultures have different writing styles—understanding these variations is important',
        'All academic writing should be informal and direct',
      ],
      correcta: 2,
      explicacion:
          'Professor: "understanding these variations is crucial". La idea principal esta al final after explaining examples. En listening con acentos, a veces el punto viene despacio.',
    ),
    const Pregunta(
      pregunta:
          'How does the British professor describe American academic writing?',
      opciones: [
        'Inferior and confusing',
        'Direct—straight to the point (very efficient)',
        'Too elaborate and difficult to read',
        'Informal and unprofessional',
      ],
      correcta: 1,
      explicacion:
          'Frase: "The Americans prefer directness in their essays—straight to the point." Es una descripcion objetiva. Pronunciacion britanica "directness" suena como "diREKTness" con enfasis diferente al americano "DErectness".',
    ),
    const Pregunta(
      pregunta:
          'What adjective does the professor use for Australian academic writing?',
      opciones: [
        'Formal and rigid',
        'Quite informal (coloquial)',
        'International and balanced',
        'Poorly structured',
      ],
      correcta: 1,
      explicacion:
          'Audio: "Australians tend to be quite informal in their academic discourse." En britanico, "quite" significa "bastante" (fuerte). En americano significa "algo" (debil). PRONUNCIACION y SIGNIFICADO juntos en listening.',
    ),
    const Pregunta(
      pregunta:
          'Based on listening to different English accents, why is accent training important for YOUR university?',
      opciones: [
        'To sound exactly like native speakers',
        'To understand professors and international students from various countries',
        'Because only British English is used in universities',
        'Accents don\'t matter—vocabulary is everything',
      ],
      correcta: 1,
      explicacion:
          'Razon practica: universidades tienen profesores y estudiantes internacionales. Necesitas entrenar tu oido para MULTIPLES acentos. No es vanidad, es NECESIDAD academica.',
    ),
  ],
  audioFile: 'assets/audio/accents.mp4',
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO LISTENING - NEWS & MEDIA
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema newsAndMedia = ContenidoTema(
  titulo: 'News & Media',
  descripcion: 'Noticias y medios',
  queEs:
      'Comprender noticias, podcasts, y contenido de medios. Los locutores hablan claro y estructurado, pero RAPIDO. Aprende a identificar titular, detalles, y contexto en poco tiempo.',
  cuandoSeUsa: [
    'Ver BBC News, NPR, DW News (canales de noticias en ingles)',
    'Escuchar podcasts sobre tecnologia, ciencia, actualidad',
    'Entender videos de YouTube Noticiero o reportajes',
  ],
  tecnicasEscucha: [
    'PRIMER minuto es crucial: locutor da TITULO + 3-4 datos principales. Enfócate alli.',
    'Estructura de noticia: QUIEN hizo QUE, DONDE, CUANDO, POR QUE. Busca esos elementos.',
    'El ritmo es RAPIDO pero sistematico. Los medios no usan coloquialismos — lenguaje formal.',
  ],
  transcript: const Transcript(
    ingles:
        'Anchor: "This is World Science Update. Researchers at Cambridge University announced today a breakthrough in renewable energy technology. The new solar panels can convert 45 percent of sunlight into electricity, surpassing previous records by 8 percent. Dr. Emily Chen, lead scientist on the project, stated that commercial applications could begin within five years. The innovation addresses the global demand for sustainable power sources as nations move toward carbon-neutral goals. Energy experts predict this could revolutionize the solar industry. That report comes to you from our science desk in London."',
    traduccion:
        'Presentador: "Este es la Actualizacion Cientifica Mundial. Investigadores de la Universidad de Cambridge anunciaron hoy un avance en tecnologia de energias renovables. Los nuevos paneles solares pueden convertir el 45 por ciento de la luz solar en electricidad, superando los registros anteriores por 8 por ciento. La Dra. Emily Chen, cientifica principal del proyecto, indico que las aplicaciones comerciales podrian comenzar en cinco anos. La innovacion aborda la demanda global de fuentes de energia sostenibles mientras las naciones se mueven hacia objetivos neutrales en carbono. Los expertos en energia predicen que esto podria revolucionar la industria solar. Ese reportaje llega a ustedes desde nuestro escritorio de ciencia en Londres."',
    escena: 'Science News Broadcast',
  ),
  erroresComunes: [
    'Pensar que entender TODO es necesario. En noticias, 3-4 datos clave = suficiente comprension.',
    'No reconocer la ESTRUCTURA de noticia. Perioticos repiten: TITULO, QUIEN, DATO, CONSEQUENCIA. Aprende este patron.',
    'Lenguaje formal distinto de conversaciones. "Surpassing records" (noticia) vs "doing better" (amigos). Acostumbrate a formal.',
  ],
  tipsParaRecordar: [
    'Primer oracion de noticia = SUMARIO (summary). Eso es lo mas importante. Todo lo demas expande ese punto.',
    'Busca numeros exactos (45 percent, 5 years, 8 percent). Esos son datos duros — apréndenlos.',
    'Locutores en noticias tienen DICCION clara y RITMO consistente. Tu cerebro se adapta rapido a las noticias.',
  ],
  audioFile: 'assets/audio/news.mp4',
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the main news announced in this report?',
      opciones: [
        'Cambridge University is closing its energy department',
        'A breakthrough in solar panel technology with 45% efficiency achieved',
        'New laws about carbon-neutral goals were passed',
        'Dr. Emily Chen founded a new company',
      ],
      correcta: 1,
      explicacion:
          'Primer dato en la noticia: "breakthrough in renewable energy technology" + "45 percent efficiency". El titulo de la noticia es LO PRIMERO. En News Media, escucha los primeros 15 segundos.',
    ),
    const Pregunta(
      pregunta: 'By how much did this new technology surpass previous records?',
      opciones: [
        '8 percent improvement',
        '45 percent improvement',
        '5 percent improvement',
        'It did not surpass previous records',
      ],
      correcta: 0,
      explicacion:
          'Audio exacto: "surpassing previous records by 8 percent". Busca la palabra "by" + numero. En noticias, estos DATOS EXACTOS son cruciales. No adivines — escucha el numero.',
    ),
    const Pregunta(
      pregunta:
          'According to Dr. Emily Chen, when could commercial applications begin?',
      opciones: [
        'Immediately—next month',
        'Within two years',
        'Within five years',
        'Never—this is purely theoretical',
      ],
      correcta: 2,
      explicacion:
          'Audio: "Dr. Emily Chen...stated that commercial applications could begin within five years." "Within five years" = el marco de tiempo. En listening de noticias, TIMEFRAMES son detalles clave.',
    ),
    const Pregunta(
      pregunta: 'What global issue does this innovation address?',
      opciones: [
        'Unemployment in the energy sector',
        'The demand for sustainable power sources and carbon-neutral goals',
        'Pollution in universities',
        'Weather patterns worldwide',
      ],
      correcta: 1,
      explicacion:
          'Audio: "The innovation addresses the global demand for sustainable power sources as nations move toward carbon-neutral goals." Noticia CONTEXTUALIZA por que importa. Esta es la relevancia global.',
    ),
    const Pregunta(
      pregunta:
          'Based on the tone and structure, what type of program is this?',
      opciones: [
        'Entertainment talk show',
        'Casual podcast between friends',
        'Professional news broadcast or media program',
        'Classroom lecture',
      ],
      correcta: 2,
      explicacion:
          'Pistas: "Anchor" (presentador formal), estructura profesional, locucion clara y ritmatica, "This comes to you from our science desk". Esthetic formal = MEDIO PROFESIONAL. Listening identifica GENERO de contenido.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO LISTENING - ACADEMIC LECTURES
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema academicLectures = ContenidoTema(
  titulo: 'Academic Lectures',
  descripcion: 'Conferencias universitarias',
  queEs:
      'Las conferencias universitarias son más largas y estructuradas que una conversación: un profesor presenta un tema, lo desarrolla con ejemplos, y llega a una conclusión. Requieren tomar notas mentales de la estructura mientras escuchas.',
  cuandoSeUsa: [
    'Clases magistrales dictadas en inglés',
    'Conferencias invitadas o seminarios académicos',
    'Charlas tipo TED o webinars universitarios',
  ],
  tecnicasEscucha: [
    'Identifica la INTRODUCCIÓN del tema en los primeros 30 segundos — ahí el profesor anuncia de qué va a hablar.',
    'Escucha marcadores de estructura: "first", "another important point", "to sum up" — señalan cambios de sección.',
    'No necesitas cada palabra: enfócate en el CONCEPTO principal y 2-3 ejemplos que lo sostienen.',
    'La conclusión suele repetir la idea principal — es una segunda oportunidad de confirmar que entendiste.',
  ],
  transcript: const Transcript(
    ingles:
        'Professor: "Today we\'re going to talk about cognitive load theory and why it matters for how you study. Cognitive load refers to the amount of mental effort being used in your working memory. Now, there are three types: intrinsic load, which comes from the difficulty of the material itself; extraneous load, caused by how information is presented—poor slides, for example; and germane load, the effort your brain uses to actually build understanding. The key takeaway is this: if you reduce extraneous load—by using clear notes, simple diagrams, one idea at a time—you free up mental resources for germane load, which is where real learning happens. To sum up, studying smarter isn\'t about working harder, it\'s about managing what your brain has to process at once."',
    traduccion:
        'Profesor: "Hoy vamos a hablar sobre la teoría de la carga cognitiva y por qué importa para cómo estudias. La carga cognitiva se refiere a la cantidad de esfuerzo mental usado en tu memoria de trabajo. Hay tres tipos: carga intrínseca, que viene de la dificultad del material mismo; carga extraña, causada por cómo se presenta la información — diapositivas pobres, por ejemplo; y carga generativa, el esfuerzo que usa tu cerebro para realmente construir comprensión. La conclusión clave es esta: si reduces la carga extraña — usando notas claras, diagramas simples, una idea a la vez — liberas recursos mentales para la carga generativa, que es donde ocurre el aprendizaje real. En resumen, estudiar más inteligentemente no se trata de trabajar más duro, se trata de manejar lo que tu cerebro tiene que procesar a la vez."',
    escena: 'University Lecture on Learning Science',
  ),
  erroresComunes: [
    'Intentar escribir cada palabra como transcripción. En una conferencia real, es imposible — enfócate en ideas, no palabras.',
    'Perderse cuando el profesor da un ejemplo largo. Los ejemplos apoyan la idea principal, no son información nueva independiente.',
    'No reconocer las palabras de transición ("to sum up", "in other words") que anuncian resúmenes o repeticiones — son tus "salvavidas" de comprensión.',
  ],
  tipsParaRecordar: [
    'Estructura típica: Introducción del tema → Desarrollo con ejemplos → Conclusión que resume.',
    '"To sum up" o "in conclusion" = el profesor va a repetir la idea principal. Presta atención extra ahí.',
    'Si te pierdes un detalle, sigue escuchando — casi siempre hay una segunda mención o ejemplo que lo aclara.',
  ],
  audioFile: null, // Pendiente: Ferek agregará el archivo de audio real aquí.
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the main topic of this lecture?',
      opciones: [
        'How to take better notes in class',
        'Cognitive load theory and how it affects studying',
        'The history of psychology',
        'How professors should design slides',
      ],
      correcta: 1,
      explicacion:
          'El profesor lo anuncia directamente al inicio: "we\'re going to talk about cognitive load theory and why it matters for how you study". El tema principal siempre se anuncia temprano en una conferencia.',
    ),
    const Pregunta(
      pregunta: 'How many types of cognitive load does the professor mention?',
      opciones: ['Two', 'Three', 'Four', 'Five'],
      correcta: 1,
      explicacion:
          'El profesor enumera tres: "intrinsic load", "extraneous load", y "germane load". En listening académico, contar enumeraciones te ayuda a organizar la información mentalmente.',
    ),
    const Pregunta(
      pregunta: 'What causes "extraneous load", according to the lecture?',
      opciones: [
        'The natural difficulty of the material',
        'The effort of building real understanding',
        'How information is presented, like poor slides',
        'Not sleeping enough before studying',
      ],
      correcta: 2,
      explicacion:
          'Audio: "extraneous load, caused by how information is presented—poor slides, for example". Es sobre la PRESENTACIÓN, no la dificultad del contenido en sí.',
    ),
    const Pregunta(
      pregunta:
          'According to the professor, what should you do to free up mental resources for real learning?',
      opciones: [
        'Study for longer hours',
        'Reduce extraneous load with clear notes and simple diagrams',
        'Avoid taking notes completely',
        'Focus only on intrinsic load',
      ],
      correcta: 1,
      explicacion:
          'Frase clave: "if you reduce extraneous load...you free up mental resources for germane load, which is where real learning happens." Esta es la recomendación práctica de la conferencia.',
    ),
    const Pregunta(
      pregunta:
          'What phrase signals that the professor is about to give the CONCLUSION?',
      opciones: ['"Today we\'re going to talk about"', '"Now, there are three types"', '"To sum up"', '"For example"'],
      correcta: 2,
      explicacion:
          '"To sum up" es un marcador clásico de conclusión en conferencias académicas — anuncia que viene un resumen de la idea principal. Reconocer estas frases es clave en Academic Lectures.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO LISTENING - IELTS LISTENING
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema ieltsListening = ContenidoTema(
  titulo: 'IELTS Listening',
  descripcion: 'Formato de examen oficial',
  queEs:
      'La sección de Listening del examen IELTS tiene un formato específico y predecible: 4 secciones que van de conversaciones cotidianas a conferencias académicas, con un solo intento de escucha. Practicar este formato te prepara tanto para IELTS como para exámenes de suficiencia similares.',
  cuandoSeUsa: [
    'Prepararte para presentar el examen IELTS u otro examen de suficiencia con formato similar',
    'Practicar escuchar UNA sola vez, sin repetir — como en el examen real',
    'Entrenar la habilidad de leer las preguntas ANTES de escuchar el audio',
  ],
  tecnicasEscucha: [
    'Lee las preguntas ANTES de que empiece el audio — sabes qué información buscar.',
    'El audio da la información EN ORDEN: las respuestas suelen aparecer en la misma secuencia que las preguntas.',
    'Presta atención a números, fechas, nombres propios y deletreos — son las respuestas más comunes en IELTS.',
    'Si te pierdes una respuesta, NO te detengas a pensar en ella — sigue escuchando la siguiente pregunta. El audio no se repite.',
  ],
  transcript: const Transcript(
    ingles:
        'Receptionist: "Good morning, Student Services, how can I help you?" Student: "Hi, I\'d like to register for the academic writing workshop." Receptionist: "Sure, can I have your full name please?" Student: "Yes, it\'s Daniela Restrepo, that\'s R-E-S-T-R-E-P-O." Receptionist: "Great, and your student ID number?" Student: "It\'s 2024015." Receptionist: "Perfect. The workshop runs every Tuesday from 3 to 5 PM, starting next week, in Room 214. There\'s a materials fee of 15,000 pesos, payable at the front desk before the first session." Student: "Got it, thank you very much." Receptionist: "You\'re welcome. We\'ll send a confirmation email within 24 hours."',
    traduccion:
        'Recepcionista: "Buenos días, Servicios Estudiantiles, ¿en qué puedo ayudarle?" Estudiante: "Hola, quisiera inscribirme al taller de escritura académica." Recepcionista: "Claro, ¿me da su nombre completo por favor?" Estudiante: "Sí, es Daniela Restrepo, eso es R-E-S-T-R-E-P-O." Recepcionista: "Genial, ¿y su número de identificación estudiantil?" Estudiante: "Es 2024015." Recepcionista: "Perfecto. El taller es todos los martes de 3 a 5 PM, empezando la próxima semana, en el Salón 214. Hay una cuota de materiales de 15,000 pesos, pagadera en recepción antes de la primera sesión." Estudiante: "Entendido, muchas gracias." Recepcionista: "De nada. Enviaremos un correo de confirmación dentro de 24 horas."',
    escena: 'IELTS-style Listening: Registration Call',
  ),
  erroresComunes: [
    'No leer las preguntas antes del audio — en el examen real, pierdes segundos valiosos buscando qué información necesitas.',
    'Escribir el número o nombre mal por no prestar atención al deletreo explícito ("R-E-S-T-R-E-P-O").',
    'Detenerte mentalmente en una respuesta perdida — esto te hace perder las siguientes 2-3 respuestas también.',
  ],
  tipsParaRecordar: [
    'Formato IELTS: información aparece EN ORDEN. Pregunta 1 se responde antes que pregunta 2.',
    'Números, fechas y deletreos son las respuestas MÁS comunes — entrena tu oído para captarlos con precisión.',
    'Practica escuchar SOLO UNA VEZ, como en el examen real — no repitas el audio mientras practicas.',
  ],
  audioFile: null, // Pendiente: Ferek agregará el archivo de audio real aquí.
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the student registering for?',
      opciones: [
        'A scholarship application',
        'The academic writing workshop',
        'A student ID card',
        'A room reservation',
      ],
      correcta: 1,
      explicacion:
          'Primera frase clara: "I\'d like to register for the academic writing workshop". En formato IELTS, la primera intención del hablante suele ser la respuesta a la primera pregunta.',
    ),
    const Pregunta(
      pregunta: 'What is the student\'s ID number?',
      opciones: ['2024015', '2024150', '2014025', '2024105'],
      correcta: 0,
      explicacion:
          'Audio exacto: "It\'s 2024015". En IELTS, los números se dicen despacio y claro exactamente por esta razón — son datos que debes anotar con precisión total.',
    ),
    const Pregunta(
      pregunta: 'On which day and time does the workshop take place?',
      opciones: [
        'Mondays from 3 to 5 PM',
        'Tuesdays from 2 to 4 PM',
        'Tuesdays from 3 to 5 PM',
        'Wednesdays from 3 to 5 PM',
      ],
      correcta: 2,
      explicacion:
          '"The workshop runs every Tuesday from 3 to 5 PM". Formato típico IELTS: día + rango de hora exacto. Presta atención a AMBOS datos, no solo uno.',
    ),
    const Pregunta(
      pregunta: 'How much is the materials fee, and when must it be paid?',
      opciones: [
        '15,000 pesos, before the first session',
        '50,000 pesos, after the workshop ends',
        '15,000 pesos, on the last day of class',
        'There is no materials fee',
      ],
      correcta: 0,
      explicacion:
          '"materials fee of 15,000 pesos, payable at the front desk before the first session." Dos datos juntos: cantidad Y fecha límite. IELTS frecuentemente combina dos datos en una sola respuesta.',
    ),
    const Pregunta(
      pregunta: 'How will the student receive confirmation of the registration?',
      opciones: [
        'A phone call within the hour',
        'A confirmation email within 24 hours',
        'A text message immediately',
        'She must call back tomorrow to confirm',
      ],
      correcta: 1,
      explicacion:
          'Última línea: "We\'ll send a confirmation email within 24 hours." En IELTS, la información final de una conversación suele ser una pregunta de examen — no dejes de escuchar hasta el final.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// MAPA CENTRAL DE TEMAS LISTENING
// ══════════════════════════════════════════════════════════════════════════════
final Map<String, ContenidoTema> listeningTopics = {
  'Basic Conversations': basicConversations,
  'Accents & Pronunciation': accentsAndPronunciation,
  'News & Media': newsAndMedia,
  'Academic Lectures': academicLectures,
  'IELTS Listening': ieltsListening,
};
