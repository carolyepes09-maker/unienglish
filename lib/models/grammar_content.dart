/// =============================================================================
/// 📘 ARCHIVO: grammar_content.dart
/// =============================================================================
/// Este archivo contiene la "Base de Datos" estática de lecciones de Gramática.
/// 
/// RELACIÓN CON EL SISTEMA:
/// 1. MODELO: Utiliza las clases [ContenidoTema], [Estructura], [Ejemplo] y [Pregunta] 
///    definidas en `contenido_tema.dart`.
/// 2. NAVEGACIÓN: El mapa [grammarTopics] al final de este archivo es la fuente 
///    de verdad para la categoría "Grammar" en la UI.
/// 3. SERVICIO: Es consumido por [EjercicioService] para inyectar contenido en 
///    los ejercicios interactivos.
/// =============================================================================

import 'contenido_tema.dart';

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - PRESENTE SIMPLE
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema presentSimple = ContenidoTema(
  titulo: 'Present Simple',
  descripcion: 'Oraciones afirmativas y negativas',
  queEs:
      'El Present Simple describe acciones habituales, verdades general es y estados permanentes. Se usa para hablar de lo que haces cada día, lo que sabes que es verdad, y cómo eres.',
  cuandoSeUsa: [
    'Rutinas diarias: "I study English every morning"',
    'Verdades generales: "Water boils at 100 degrees"',
    'Cómo eres o qué te gusta: "I am a university student" / "She loves coffee"',
  ],
  estructura: const Estructura(
    positiva: 'Subject + Base Verb (+s/es en 3ª persona singular)',
    negativa: 'Subject + do/does + not + Base Verb',
    pregunta: 'Do/Does + Subject + Base Verb?',
  ),
  ejemplos: [
    const Ejemplo(
      ingles: 'I study computer science at the university.',
      traduccion: 'Estudio informatica en la universidad.',
    ),
    const Ejemplo(
      ingles: 'She does not understand this concept.',
      traduccion: 'Ella no entiende este concepto.',
    ),
    const Ejemplo(
      ingles: 'Do you attend classes on Monday?',
      traduccion: '¿Asistes a clases el lunes?',
    ),
  ],
  erroresComunes: [
    'Agrega "do/does" en positiva: MAL: "I do study" (solo en negativa/pregunta) BIEN: "I study"',
    'Olvida la "s" en 3ª persona: MAL: "He go" BIEN: "He goes"',
    'Usa "don\'t" con 3ª singular: MAL: "He don\'t like" BIEN: "He doesn\'t like"',
  ],
  tipsParaRecordar: [
    'I/you/we/they = base verb | he/she/it = base + s/es',
    'Negativa y pregunta siempre llevan "do/does"',
    'Es para hábitos, no acciones en este momento',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Complete: "My roommate _______ coffee every morning."',
      opciones: ['drinks', 'drink', 'is drinking', 'drank'],
      correcta: 0,
      explicacion:
          'En 3ª persona singular (he/she/it), agregamos "s" al verbo base: drinks. Es una rutina habitual.',
    ),
    const Pregunta(
      pregunta: 'Which sentence is correct?',
      opciones: [
        'She do not like mathematics.',
        'She does not like mathematics.',
        'She not likes mathematics.',
        'She is not liking mathematics.',
      ],
      correcta: 1,
      explicacion:
          'Con "she" (3ª singular) usamos "does": does + not + like. Los hispanohablantes tienen tendencia a escribir "do not".',
    ),
    const Pregunta(
      pregunta: 'Transform to negative: "They attend the 8 AM lecture."',
      opciones: [
        'They not attend the 8 AM lecture.',
        'They does not attend the 8 AM lecture.',
        'They do not attend the 8 AM lecture.',
        'They are not attending the 8 AM lecture.',
      ],
      correcta: 2,
      explicacion:
          'Con "they" (plural) negativa: do + not + attend. Recuerda: negativa siempre lleva "do/does".',
    ),
    const Pregunta(
      pregunta:
          'Choose the question: "¿Estudias tú inglés los martes?" (Do you...?)',
      opciones: [
        'Do you studies English on Tuesdays?',
        'Do you study English on Tuesdays?',
        'Does you study English on Tuesdays?',
        'Study you English on Tuesdays?',
      ],
      correcta: 1,
      explicacion:
          'Pregunta con "you": Do + you + study (base verb). No agregamos "s" después del sujeto en preguntas.',
    ),
    const Pregunta(
      pregunta:
          '¿Cuál NO es correcta? "It _______ raining right now" (Escoge la que NO funciona con Present Simple)',
      opciones: [
        'rains (pero es raro)',
        'is raining',
        'rains',
        'Ninguna, no va en Present Simple',
      ],
      correcta: 2,
      explicacion:
          'Para "ahora mismo, en este momento", usamos Present Continuous (is raining), NO Present Simple. Present Simple es para hábitos, no acciones en progreso.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - PRESENTE CONTINUO
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema presentContinuous = ContenidoTema(
  titulo: 'Present Continuous',
  descripcion: 'Acciones en progreso',
  queEs:
      'El Present Continuous describe acciones que están sucediendo AHORA MISMO, en este momento. Es el tiempo para hablar de lo que estás haciendo en este instante.',
  cuandoSeUsa: [
    'Acciones en este momento: "I am writing an email right now"',
    'Cambios temporales: "The company is growing rapidly this year"',
    'Planes futuros cercanos: "We are traveling to Cartagena tomorrow"',
  ],
  estructura: const Estructura(
    positiva: 'Subject + am/is/are + verbo+-ing',
    negativa: 'Subject + am/is/are + not + verbo+-ing',
    pregunta: 'Am/Is/Are + Subject + verbo+-ing?',
  ),
  ejemplos: [
    const Ejemplo(
      ingles: 'The professor is explaining the theory right now.',
      traduccion: 'El profesor está explicando la teoría ahora mismo.',
    ),
    const Ejemplo(
      ingles: 'We are not paying attention in class.',
      traduccion: 'No estamos prestando atención en clase.',
    ),
    const Ejemplo(
      ingles: 'Are you studying for the exam this week?',
      traduccion: '¿Estás estudiando para el examen esta semana?',
    ),
  ],
  erroresComunes: [
    'Olvida el "-ing": MAL: "I am go" BIEN: "I am going"',
    'Usa Present Simple en lugar de Continuous: MAL: "What do you do?" (habit) vs BIEN: "What are you doing?" (ahora)',
    'Confunde am/is/are: MAL: "I is running" BIEN: "I am running"',
  ],
  tipsParaRecordar: [
    'I = am | he/she/it = is | you/we/they = are',
    'SIEMPRE termina el verbo en -ing (running, studying, cooking)',
    'Es para AHORA, en este momento, no para hábitos',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Complete: "Right now, the students _______ a difficult exam."',
      opciones: ['take', 'are taking', 'takes', 'are take'],
      correcta: 1,
      explicacion:
          '"Right now" indica una acción en progreso. Usamos: are + taking (verbo+-ing). Con "students" (plural) = "are".',
    ),
    const Pregunta(
      pregunta: 'Which is WRONG?',
      opciones: [
        'I am studying right now.',
        'She is write an essay.',
        'They are preparing for the presentation.',
        'We are not sleeping in class.',
      ],
      correcta: 1,
      explicacion:
          '"She is write" es incorrecto. Debe ser "She is writing". El verbo después de am/is/are SIEMPRE lleva -ing.',
    ),
    const Pregunta(
      pregunta: 'Transform to negative: "The teacher is grading papers."',
      opciones: [
        'The teacher not is grading papers.',
        'The teacher is not grading papers.',
        'The teacher does not grading papers.',
        'The teacher is grading not papers.',
      ],
      correcta: 1,
      explicacion:
          'Negativa: am/is/are + not + verbo+-ing. El "not" va entre "is" y "grading".',
    ),
    const Pregunta(
      pregunta:
          'Which sentence uses Present Continuous CORRECTLY for a future plan?',
      opciones: [
        'I am going to the cafeteria tomorrow.',
        'I am working on the project next week.',
        'I am attending the seminar this Friday.',
        'All are correct',
      ],
      correcta: 3,
      explicacion:
          'El Present Continuous puede usarse para planes futuros cercanos. "tomorrow", "next week", "this Friday" son todos válidos para planes próximos.',
    ),
    const Pregunta(
      pregunta:
          '¿Cuál es la forma correcta de la pregunta? "¿Qué estás haciendo?" (What...?)',
      opciones: [
        'What are you doing?',
        'What you are doing?',
        'What do you doing?',
        'What you doing?',
      ],
      correcta: 0,
      explicacion:
          'Pregunta con Present Continuous: Are + you + doing + object. "Are" va primero, luego el sujeto.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - PASADO SIMPLE
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema pastSimple = ContenidoTema(
  titulo: 'Past Simple',
  descripcion: 'Eventos en el pasado',
  queEs:
      'El Past Simple describe acciones completadas en el pasado. Se usa para contar historias, describir hechos pasados y eventos que ya terminaron.',
  cuandoSeUsa: [
    'Acciones completadas: "I studied yesterday and passed the test"',
    'Eventos históricos: "The university was founded in 1923"',
    'Narrativas: "He went to the library, found the book, and came back home"',
  ],
  estructura: const Estructura(
    positiva: 'Subject + Past Verb (base+ed, o irregular)',
    negativa: 'Subject + did not + Base Verb',
    pregunta: 'Did + Subject + Base Verb?',
  ),
  ejemplos: [
    const Ejemplo(
      ingles:
          'Yesterday, I attended a conference about artificial intelligence.',
      traduccion:
          'Ayer asistí a una conferencia sobre inteligencia artificial.',
    ),
    const Ejemplo(
      ingles: 'She did not finish the project on time.',
      traduccion: 'Ella no terminó el proyecto a tiempo.',
    ),
    const Ejemplo(
      ingles: 'Did you go to the library last week?',
      traduccion: '¿Fuiste a la biblioteca la semana pasada?',
    ),
  ],
  erroresComunes: [
    'Agrega "-ed" a verbos irregulares: MAL: "He goed" BIEN: "He went"',
    'Olvida "-ed" en verbos regulares: MAL: "I work" (past) BIEN: "I worked"',
    'Usa "did not + pasado": MAL: "I did not went" BIEN: "I did not go"',
  ],
  tipsParaRecordar: [
    'Regulares: base + -ed (studied, worked). Irregulares: memoriza (went, saw, took)',
    'Negativa y pregunta: did + base verb (SIN -ed)',
    'Busca palabras clave: yesterday, last week, two days ago, in 2019',
  ],
  ejercicios: [
    const Pregunta(
      pregunta:
          'Complete: "Last month, she _______ her thesis and presented it to the committee."',
      opciones: ['finished', 'finishes', 'was finishing', 'had finished'],
      correcta: 0,
      explicacion:
          '"Last month" es pasado, acción completada. "finished" (regular: finish + ed). No es ongoing (-ing).',
    ),
    const Pregunta(
      pregunta: 'Which is correct?',
      opciones: [
        'Did you went to the seminar?',
        'You did not went to the seminar.',
        'Did you go to the seminar?',
        'You did not go in the seminar.',
      ],
      correcta: 2,
      explicacion:
          'Pregunta Past Simple: Did + you + GO (base verb). Con "did", el verbo NO lleva -ed. Los hispanohablantes tienden a agregar -ed después de "did".',
    ),
    const Pregunta(
      pregunta:
          'Transform to negative: "They took an important exam yesterday."',
      opciones: [
        'They did not took an important exam yesterday.',
        'They did not take an important exam yesterday.',
        'They not took an important exam yesterday.',
        'They did not took an exam important yesterday.',
      ],
      correcta: 1,
      explicacion:
          'Negativa Past Simple: did + not + base verb. "Take" es irregular (took en afirmativa), pero en negativa va el base verb.',
    ),
    const Pregunta(
      pregunta:
          'Which sentence is CORRECT? (Look for the regular verb pattern)',
      opciones: [
        'The conference last week was very interesting; many students learned new skills.',
        'The professor changed the exam date; everybody were happy.',
        'Last semester, I was passed my English test.',
        'We studied the book because we needed for the class.',
      ],
      correcta: 0,
      explicacion:
          'Solo la opción A es correcta. "learned" es el past simple regular de "learn". Las otras tienen errores gramaticales (conjugación incorrecta o construcción equivocada).',
    ),
    const Pregunta(
      pregunta:
          'Translate: "¿Hablaste con tu prof de lo que pasó en clase?" (Did you...?)',
      opciones: [
        'Did you talk with your professor about what happened in class?',
        'Did you talked with your professor about what happened in class?',
        'Do you talk with your professor about what happened in class?',
        'Did you speaking with your professor about what happened in class?',
      ],
      correcta: 0,
      explicacion:
          'Did + you + TALK (base verb). "Happened" también es Past Simple de "happen". Con "did" no agregamos -ed.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - PRESENTE PERFECTO
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema presentPerfect = ContenidoTema(
  titulo: 'Present Perfect',
  descripcion: 'Experiencias y resultados',
  queEs:
      'El Present Perfect conecta el pasado con el presente. Lo usas cuando una acción pasada tiene importancia AHORA: algo que hiciste, algo que te ha pasado, o experiencias que has tenido.',
  cuandoSeUsa: [
    'Experiencias de vida: "I have never lived abroad, but I have traveled to three countries"',
    'Resultados presentes: "The website has crashed; the team is fixing it now"',
    'Cambios recientes: "The price of coffee has increased this month"',
  ],
  estructura: const Estructura(
    positiva: 'Subject + have/has + Past Participle',
    negativa: 'Subject + have/has + not + Past Participle',
    pregunta: 'Have/Has + Subject + Past Participle?',
  ),
  ejemplos: [
    const Ejemplo(
      ingles: 'I have studied three programming languages in university.',
      traduccion:
          'He estudiado tres lenguajes de programación en la universidad.',
    ),
    const Ejemplo(
      ingles: 'She has not submitted her essay yet.',
      traduccion: 'Ella aún no ha entregado su ensayo.',
    ),
    const Ejemplo(
      ingles: 'Have you ever attended a virtual conference?',
      traduccion: '¿Alguna vez has asistido a una conferencia virtual?',
    ),
  ],
  erroresComunes: [
    'Usa Past Simple en lugar de Present Perfect: MAL: "I went to Paris" (pero vives ahí) BIEN: "I have been to Paris"',
    'Olvida el Past Participle: MAL: "I have study" BIEN: "I have studied"',
    'Confunde have/has: MAL: "He have worked" BIEN: "He has worked"',
  ],
  tipsParaRecordar: [
    'I/you/we/they = have | he/she/it = has',
    'Past Participle: regulares = base+ed (studied, worked). Irregulares = memoriza (been, gone, done, seen)',
    'Busca "yet", "already", "never", "ever" — indican Present Perfect',
  ],
  ejercicios: [
    const Pregunta(
      pregunta:
          'Complete: "The professor _______ not _______ our homework yet."',
      opciones: [
        'have returned',
        'has not returned',
        'have not returned',
        'has not returned',
      ],
      correcta: 3,
      explicacion:
          'Con "the professor" (3ª singular): has + not + past participle. "Posted" ya fue entregado pero aún no está disponible (tiene relevancia ahora).',
    ),
    const Pregunta(
      pregunta: 'Which is CORRECT?',
      opciones: [
        'I have never go to the science museum.',
        'I have went to the science museum twice.',
        'I have been to the science museum three times.',
        'I been to the science museum.',
      ],
      correcta: 2,
      explicacion:
          'Only option C is correct. "been" is the past participle of "be". Options A and B use base verbs (go/went) instead of the participle (been/gone).',
    ),
    const Pregunta(
      pregunta:
          'Transform to affirmative: "She has not finished her research."',
      opciones: [
        'She has finished her research.',
        'She finished her research.',
        'She has been finished her research.',
        'She does finished her research.',
      ],
      correcta: 0,
      explicacion:
          'Affirmative Present Perfect: has + finished. La investigación tiene relevancia ahora (por eso no Past Simple).',
    ),
    const Pregunta(
      pregunta:
          'Choose the correct question: "¿Alguna vez has tomado un examen IELTS?" (Have you ever...?)',
      opciones: [
        'Have you ever take an IELTS exam?',
        'Have you ever taken an IELTS exam?',
        'Did you ever taken an IELTS exam?',
        'Have you taken ever an IELTS exam?',
      ],
      correcta: 1,
      explicacion:
          '"ever" + Present Perfect = "have you ever + taken (participle)". Es sobre experiencia de vida, no un evento pasado específico.',
    ),
    const Pregunta(
      pregunta:
          'Which sentence correctly uses Present Perfect to show recent change?',
      opciones: [
        'The tuition fees increased last year.',
        'The tuition fees have increased this semester, and students are worried.',
        'The tuition fees were increasing.',
        'The tuition fees increase every semester.',
      ],
      correcta: 1,
      explicacion:
          'Present Perfect muestra un cambio reciente con impacto AHORA: "have increased this semester, and students are worried" conecta pasado reciente con presente. Las otras opciones no muestran esa conexión.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - TIEMPOS FUTUROS
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema futureTenses = ContenidoTema(
  titulo: 'Future Tenses',
  descripcion: 'Will, going to, present continuous',
  queEs:
      'Inglés tiene varias formas de hablar del futuro, cada una con un uso específico. "Will" es para predicciones; "going to" es para planes decididos; Present Continuous es para planes muy concretos.',
  cuandoSeUsa: [
    'Will: predicciones, decisiones momentáneas: "I think it will rain tomorrow"',
    'Going to: planes ya decididos: "We are going to visit the museum next week"',
    'Present Continuous: planes muy concretos con fecha exacta: "I am attending the conference on March 15th"',
  ],
  estructura: const Estructura(
    positiva:
        'will + base verb | am/is/are + going to + base verb | am/is/are + -ing',
    negativa:
        'will not + base verb | am/is/are + not going to + base verb | am/is/are + not + -ing',
    pregunta:
        'Will + subject + base verb? | Are/Is + subject + going to + base verb? | Are/Is + subject + -ing?',
  ),
  ejemplos: [
    const Ejemplo(
      ingles: 'The company will launch a new product next month.',
      traduccion: 'La empresa lanzará un nuevo producto el próximo mes.',
    ),
    const Ejemplo(
      ingles: 'We are going to study together for the final exam.',
      traduccion: 'Vamos a estudiar juntos para el examen final.',
    ),
    const Ejemplo(
      ingles: 'I am attending the workshop on Friday; it is already confirmed.',
      traduccion: 'Estoy asistiendo al taller el viernes; ya está confirmado.',
    ),
  ],
  erroresComunes: [
    'Confunde "will" con "going to": MAL: "I will go to the store" (ya decidido) — mejor BIEN: "I am going to go to the store"',
    'Usa Present Simple para futuro: MAL: "The exam is next week" (cierto, pero confuso) vs BIEN: "The exam will be next week"',
    'Olvida el base verb con "to": MAL: "I going to study" BIEN: "I am going to study"',
  ],
  tipsParaRecordar: [
    '"Will" = más inmediato, decisión reciente | "Going to" = ya tienes planes',
    'Present Continuous + fecha = ya está confirmado, muy seguro',
    'Will + respuesta corta: "Will you come?" "Yes, I will"',
  ],
  ejercicios: [
    const Pregunta(
      pregunta:
          'Complete: "Next semester, they _______ introduce a new curriculum in the engineering department."',
      opciones: [
        'are going to',
        'will',
        'are introducing',
        'Both "a" and "b" are correct',
      ],
      correcta: 3,
      explicacion:
          'Ambas son válidas. "are going to introduce" = ya tomaron la decisión. "will introduce" = predicción probable. Si es una decisión ya tomada (departamento ya lo decidió), "going to" es mejor.',
    ),
    const Pregunta(
      pregunta: 'Which is CORRECT?',
      opciones: [
        'I will attend to the party tomorrow.',
        'I will attending the party tomorrow.',
        'I will attend the party tomorrow.',
        'I am go to attend the party tomorrow.',
      ],
      correcta: 2,
      explicacion:
          'Will + base verb (attend). NO llevas "to" después de "attend" (attend the party, not "attend to"). NO usas -ing con will.',
    ),
    const Pregunta(
      pregunta:
          'Transform to negative: "She is going to participate in the research project."',
      opciones: [
        'She will not going to participate in the research project.',
        'She is not going to participate in the research project.',
        'She not is going to participate in the research project.',
        'She going to not participate in the research project.',
      ],
      correcta: 1,
      explicacion:
          'Going to + negativa: am/is/are + NOT + going to + base verb. El "not" va después del verbo de estado (is/are).',
    ),
    const Pregunta(
      pregunta:
          'Choose the BEST answer: "I _______ the exam on Friday. I\'ve already booked my spot."',
      opciones: ['will take', 'am going to take', 'am taking', 'take'],
      correcta: 2,
      explicacion:
          '"I\'ve already booked my spot" muestra que es MUY confirmado, concreto. Present Continuous es la forma más apropiada. Es un plan con fecha exacta (Friday) ya asegurado.',
    ),
    const Pregunta(
      pregunta:
          'Translate: "¿Seguirás estudiando en la universidad el próximo año?" (Will you...?)',
      opciones: [
        'Will you continue studying at the university next year?',
        'Will you continuing study at the university next year?',
        'Do you will continue studying at the university next year?',
        'Are you going to continuing study at the university next year?',
      ],
      correcta: 0,
      explicacion:
          'Will + you + continue (base verb) + studying. "Continue" es el verbo principal, "studying" es el gerundio como objeto. Con will, NUNCA agregamos -ing al verbo principal.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - MODAL VERBS
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema modalVerbs = ContenidoTema(
  titulo: 'Modal Verbs',
  descripcion: 'Habilidad, posibilidad y obligación',
  queEs:
      'Los modal verbs (can, could, may, might, must, should, have to) expresan habilidad, posibilidad, permiso, obligación o consejo. Van siempre seguidos del verbo base, sin "to" y sin "s" en 3ª persona.',
  cuandoSeUsa: [
    'Habilidad: "I can speak two languages"',
    'Posibilidad: "It might rain this afternoon"',
    'Obligación/consejo: "You must submit the essay by Friday" / "You should study more"',
  ],
  estructura: const Estructura(
    positiva: 'Subject + modal + base verb (can go, must study, should ask)',
    negativa: 'Subject + modal + not + base verb (cannot go, must not study)',
    pregunta: 'Modal + Subject + base verb? (Can you go? Should I ask?)',
  ),
  ejemplos: [
    const Ejemplo(
      ingles: 'Students must register before the semester starts.',
      traduccion: 'Los estudiantes deben registrarse antes de que empiece el semestre.',
    ),
    const Ejemplo(
      ingles: 'You should ask the professor if you have doubts.',
      traduccion: 'Deberías preguntarle al profesor si tienes dudas.',
    ),
    const Ejemplo(
      ingles: 'She might join the study group tonight.',
      traduccion: 'Puede que ella se una al grupo de estudio esta noche.',
    ),
  ],
  erroresComunes: [
    'Agrega "to" después del modal: MAL: "I can to speak" BIEN: "I can speak"',
    'Agrega "s" en 3ª persona: MAL: "She cans swim" BIEN: "She can swim"',
    'Confunde "must" (obligación fuerte, interna) con "have to" (obligación externa): ambos son válidos, pero no son intercambiables en todos los contextos.',
  ],
  tipsParaRecordar: [
    'Los modales NUNCA cambian de forma: I can, he can, they can (nunca "cans")',
    '"Must" = regla que tú mismo impones o es muy fuerte. "Have to" = regla externa (la universidad, la ley)',
    '"Should" = consejo, no obligación. "Must" = obligación',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Complete: "All students _______ submit their ID before the exam."',
      opciones: ['must', 'must to', 'musts', 'are must'],
      correcta: 0,
      explicacion:
          'Modal "must" + base verb, sin "to" y sin cambios de forma. Es una regla obligatoria de la universidad.',
    ),
    const Pregunta(
      pregunta: 'Which sentence is correct?',
      opciones: [
        'He can speaks three languages.',
        'He can to speak three languages.',
        'He can speak three languages.',
        'He cans speak three languages.',
      ],
      correcta: 2,
      explicacion:
          'Modal + base verb, sin "s" ni "to". "Can speak" es correcto incluso con "he" (3ª persona).',
    ),
    const Pregunta(
      pregunta: 'Choose the best modal for ADVICE (not obligation): "_______ you talk to your advisor about this?"',
      opciones: ['Must', 'Should', 'Have to', 'Can\'t'],
      correcta: 1,
      explicacion:
          '"Should" es para consejo/sugerencia, no obligación estricta. "Must"/"have to" implican que es obligatorio, no una simple recomendación.',
    ),
    const Pregunta(
      pregunta: 'Transform to negative: "You must use your phone during the exam."',
      opciones: [
        'You must not use your phone during the exam.',
        'You not must use your phone during the exam.',
        'You don\'t must use your phone during the exam.',
        'You mustn\'t to use your phone during the exam.',
      ],
      correcta: 0,
      explicacion:
          'Negativa de modales: modal + not + base verb. "Must not" (mustn\'t) indica prohibición, no simple ausencia de obligación.',
    ),
    const Pregunta(
      pregunta:
          'Translate: "Puede que el profesor cancele la clase mañana" (uncertain possibility)',
      opciones: [
        'The professor must cancel class tomorrow.',
        'The professor might cancel class tomorrow.',
        'The professor should cancel class tomorrow.',
        'The professor can cancel class tomorrow.',
      ],
      correcta: 1,
      explicacion:
          '"Might" expresa posibilidad incierta, no confirmada — exactamente "puede que". "Must" sería una conclusión casi segura, no una posibilidad.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO GRAMMAR - CONDITIONALS
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema conditionals = ContenidoTema(
  titulo: 'Conditionals',
  descripcion: 'Oraciones condicionales (if)',
  queEs:
      'Las oraciones condicionales usan "if" para hablar de situaciones reales, probables o hipotéticas. El Zero Conditional habla de hechos generales, el First Conditional de situaciones futuras probables, y el Second Conditional de situaciones hipotéticas o improbables.',
  cuandoSeUsa: [
    'Zero Conditional (hechos generales): "If you heat water, it boils"',
    'First Conditional (futuro probable): "If I study hard, I will pass the exam"',
    'Second Conditional (hipotético): "If I had more time, I would learn another language"',
  ],
  estructura: const Estructura(
    positiva: 'If + present simple, present simple (zero) | If + present simple, will + base verb (first) | If + past simple, would + base verb (second)',
    negativa: 'If + subject + do/does not..., ... not... (según el tipo de condicional)',
    pregunta: 'What will you do if...? / What would you do if...?',
  ),
  ejemplos: [
    const Ejemplo(
      ingles: 'If students attend all classes, they usually understand the material better.',
      traduccion: 'Si los estudiantes asisten a todas las clases, generalmente entienden mejor el material.',
    ),
    const Ejemplo(
      ingles: 'If I finish my project early, I will help you with yours.',
      traduccion: 'Si termino mi proyecto temprano, te ayudaré con el tuyo.',
    ),
    const Ejemplo(
      ingles: 'If I had a scholarship, I would study abroad.',
      traduccion: 'Si tuviera una beca, estudiaría en el extranjero.',
    ),
  ],
  erroresComunes: [
    'Usa "will" en la cláusula con "if": MAL: "If it will rain, I will stay home" BIEN: "If it rains, I will stay home"',
    'Confunde First y Second Conditional: First = probable ("if I study" + will); Second = hipotético ("if I studied" + would)',
    'Olvida "would" en la Second Conditional: MAL: "If I had money, I buy a car" BIEN: "If I had money, I would buy a car"',
  ],
  tipsParaRecordar: [
    'Zero: hecho siempre cierto → present + present',
    'First: probable en el futuro → if + present, will + base verb',
    'Second: hipotético/improbable → if + past simple, would + base verb (aunque hable de presente/futuro)',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Complete (First Conditional): "If she _______ hard, she will pass the course."',
      opciones: ['will study', 'studies', 'studied', 'would study'],
      correcta: 1,
      explicacion:
          'En First Conditional, la cláusula con "if" usa present simple ("studies"), NUNCA "will". El "will" va en la otra cláusula.',
    ),
    const Pregunta(
      pregunta: 'Which is a Zero Conditional (general fact)?',
      opciones: [
        'If you mix red and blue, you get purple.',
        'If I have time tomorrow, I will call you.',
        'If I were you, I would apologize.',
        'If she had studied, she would have passed.',
      ],
      correcta: 0,
      explicacion:
          'Zero Conditional describe un hecho siempre verdadero: present simple + present simple. Mezclar rojo y azul SIEMPRE da morado.',
    ),
    const Pregunta(
      pregunta:
          'Complete (Second Conditional, hypothetical): "If I _______ more free time, I would join a sports team."',
      opciones: ['have', 'had', 'will have', 'would have'],
      correcta: 1,
      explicacion:
          'Second Conditional: if + PAST SIMPLE ("had"), aunque hable del presente/futuro hipotético. Es una situación improbable o imaginaria.',
    ),
    const Pregunta(
      pregunta: 'Which sentence correctly uses First Conditional?',
      opciones: [
        'If it rains tomorrow, we will cancel the trip.',
        'If it will rain tomorrow, we cancel the trip.',
        'If it rained tomorrow, we will cancel the trip.',
        'If it rains tomorrow, we would cancel the trip.',
      ],
      correcta: 0,
      explicacion:
          'If + present simple ("rains"), will + base verb ("will cancel"). Es una situación futura real y probable.',
    ),
    const Pregunta(
      pregunta:
          'Translate: "Si tuviera un trabajo de tiempo completo, no podría estudiar tanto" (hypothetical)',
      opciones: [
        'If I have a full-time job, I cannot study as much.',
        'If I had a full-time job, I would not be able to study as much.',
        'If I will have a full-time job, I will not study as much.',
        'If I have had a full-time job, I would not study as much.',
      ],
      correcta: 1,
      explicacion:
          'Situación hipotética (no tiene el trabajo): Second Conditional. If + past simple ("had"), would + base verb ("would not be able").',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// MAP CENTRAL DE TEMAS GRAMMAR
// ══════════════════════════════════════════════════════════════════════════════
final Map<String, ContenidoTema> grammarTopics = {
  'Present Simple': presentSimple,
  'Present Continuous': presentContinuous,
  'Past Simple': pastSimple,
  'Present Perfect': presentPerfect,
  'Future Tenses': futureTenses,
  'Modal Verbs': modalVerbs,
  'Conditionals': conditionals,
};
