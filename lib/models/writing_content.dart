// ═════════════════════════════════════════════════════════════════════════════════
// MODELOS DE DATOS PARA CONTENIDO DE WRITING
// ═════════════════════════════════════════════════════════════════════════════════

// =============================================================================
// ✍️ ARCHIVO: writing_content.dart
// =============================================================================
// Este archivo contiene la "Base de Datos" de lecciones de Escritura (Writing).
// 
// CARACTERÍSTICAS ESPECIALES:
// 1. Campo "criterios": Explica al estudiante qué se evalúa (coherencia, gramática).
// 2. Campo "ejemploModelo": Un ensayo o texto "perfecto" para que el estudiante 
//    tenga una referencia clara.
// 
// RELACIÓN CON EL SISTEMA:
// - UI: Consumido por [TemaDetalleScreen] para guiar la producción escrita.
// - SERVICE: [EjercicioService] carga los retos de escritura y preguntas asociadas.
// =============================================================================

import 'contenido_tema.dart';

class EjemploTexto {
  final String ingles;
  final String traduccion;
  final String tipo;

  const EjemploTexto({
    required this.ingles,
    required this.traduccion,
    required this.tipo,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO WRITING - PARAGRAPH STRUCTURE
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema paragraphStructure = ContenidoTema(
  titulo: 'Paragraph Structure',
  descripcion: 'Estructura del parrafo',
  queEs:
      'Todo parrafo en ingles tiene estructura: TOPIC SENTENCE (idea principal), SUPPORTING SENTENCES (detalles que apoyan), y CONCLUSION SENTENCE (resumen o cierre). Esta estructura hace tu escritura CLARA y organizada.',
  cuandoSeUsa: [
    'Escribir ensayos academicos para tus clases',
    'Responder preguntas en examenes escritos con multiples parrafos',
    'Escribir emails profesionales o reportes en el trabajo',
  ],
  criterios: [
    '1. TOPIC SENTENCE: Primera frase CLARA que resume el parrafo en UNA idea',
    '2. SUPPORTING SENTENCES: 2-3 frases con ejemplos, detalles, o evidencia',
    '3. TRANSITIONS: Conectores que ligan un ejemplo al siguiente (First, Second, For example)',
    '4. CONCLUSION: Ultima frase que cierra el parrafo reforzando la idea principal',
  ],
  ejemploModelo: const EjemploTexto(
    ingles:
        'Social media has both positive and negative effects on university students. First, platforms like Instagram and TikTok help students connect with friends and share academic resources. For example, many study groups coordinate study sessions through WhatsApp. However, excessive use creates procrastination and reduces concentration during studying. Furthermore, addiction to likes and comments damages mental health and self-esteem. In conclusion, while social media offers benefits for connection, students must manage usage carefully to maintain academic balance.',
    traduccion:
        'Las redes sociales tienen efectos positivos y negativos en los estudiantes universitarios. Primero, plataformas como Instagram y TikTok ayudan a los estudiantes a conectarse con amigos y compartir recursos academicos. Por ejemplo, muchos grupos de estudio coordinan sesiones de estudio a traves de WhatsApp. Sin embargo, el uso excesivo crea procrastinacion y reduce la concentracion durante el estudio. Ademas, la adiccion a los likes y comentarios dana la salud mental y la autoestima. En conclusion, mientras que las redes sociales ofrecen beneficios para la conexion, los estudiantes deben gestionar el uso cuidadosamente para mantener el equilibrio academico.',
    tipo: 'Academic Paragraph with Balance',
  ),
  erroresComunes: [
    'Escribir multiples ideas en UN parrafo. Cada parrafo = UNA idea principal. Si cambias de tema, nuevo parrafo.',
    'Olvidar la TOPIC SENTENCE. Sin ella, el lector no sabe de que es el parrafo. Hazla clara y simple.',
    'Saltar de idea a idea sin CONECTORES (First, Also, However, For example). Esto hace la escritura FRAGMENTADA.',
    'No tener conclusion en el parrafo. Parrafos sin cierre parecen INCOMPLETOS y confusos.',
  ],
  tipsParaRecordar: [
    'TOPIC SENTENCE = resumen del parrafo en 1 frase. Si la quitas, entiendes el parrafo? Si no, reescribela.',
    'Conectores son ARO: First, Also, However, For example, Unfortunately, Therefore, In conclusion.',
    'Revisa: primera frase clara? Cada frase apoya esa idea? Ultima frase cierra? Si SÍ a todo = parrafo correcto.',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the TOPIC SENTENCE in the example paragraph?',
      opciones: [
        '"First, platforms like Instagram help students connect"',
        '"Social media has both positive and negative effects on university students"',
        '"Excessive use creates procrastination"',
        '"Therefore, social media is bad for everyone"',
      ],
      correcta: 1,
      explicacion:
          'TOPIC SENTENCE es la PRIMERA frase que resume El TEMA del parrafo. La opcion B es una oracion general que resume positivos Y negativos (el tema completo).',
    ),
    const Pregunta(
      pregunta: 'Identify the SUPPORTING SENTENCES in the paragraph.',
      opciones: [
        'Only the sentence about WhatsApp',
        'Only negative effects sentences',
        'Sentences with examples: WhatsApp groups, likes/comments addiction, etc.',
        'Only sentences with the word "however"',
      ],
      correcta: 2,
      explicacion:
          'Supporting sentences = frases que PRUEBAN la idea principal con DETALLES y EJEMPLOS. "WhatsApp group example", "addiction damages health" — esos APOYAN la idea de efectos positivos/negativos.',
    ),
    const Pregunta(
      pregunta:
          'Which CONNECTOR would be appropriate after discussing positive effects and BEFORE discussing negative effects?',
      opciones: [
        '"First of all"',
        '"Obviously"',
        '"However" or "On the other hand"',
        '"Also" or "Furthermore"',
      ],
      correcta: 2,
      explicacion:
          'However, On the other hand = mostrar CONTRASTE. Vas de "positivos" a "negativos" — CONTRASTE perfecto. Also/Furthermore = agregar MAS de lo mismo (no aplica aqui).',
    ),
    const Pregunta(
      pregunta:
          'What is wrong with this paragraph if you remove the last sentence (conclusion)?',
      opciones: [
        'Nothing—the paragraph is still complete',
        'The length is too short',
        'The paragraph feels incomplete and the main idea is not reinforced',
        'The first sentence becomes weak',
      ],
      correcta: 2,
      explicacion:
          'Parrafos sin CIERRE parecen cortados. ultima frase (conclusion) refuerza la idea principal y cierra el tema. Sin ella, el lector pensa "y que? No entendi el punto final".',
    ),
    const Pregunta(
      pregunta: 'How many IDEAS PRINCIPALES should a single paragraph contain?',
      opciones: [
        'As many as you can fit',
        'One main idea with supporting details',
        'At least three different ideas for variety',
        'Multiple ideas as long as sentences are long',
      ],
      correcta: 1,
      explicacion:
          'REGLA FUNDAMENTAL: 1 parrafo = 1 idea principal. Si tienes 2+ ideas, creas CONFUSIONE. El ejemplo tiene 1 idea: "redes sociales tienen efectos positivos Y negativos" (1 tema complejo, no 2 temas).',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO WRITING - ESSAY WRITING
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema essayWriting = ContenidoTema(
  titulo: 'Essay Writing',
  descripcion: 'Ensayos academicos',
  queEs:
      'Un essay es un texto largo (3-5 parrafos o mas) donde ARGUMENTAS una idea con evidencia. Tiene INTRODUCCION (Thesis), BODY (parrafos de sustento), y CONCLUSION (resumen + reflexion final). Diferente de un simple parrafo porque PROFUNDIZA.',
  cuandoSeUsa: [
    'Ensayos para clases de escritura o literatura',
    'Examenes finales que piden analisis escrito',
    'Aplicaciones a programas de postgrado con ensayos de motivacion',
  ],
  criterios: [
    '1. INTRODUCTION: Presenta el TEMA y la TESIS (punto central que defenderás)',
    '2. BODY PARAGRAPHS: 2-3 parrafos, cada uno con argumento + evidencia diferente',
    '3. TRANSITIONS entre parrafos: conecta ideas de forma fluida',
    '4. CONCLUSION: resume argumentos y reflexiona sobre la importancia del tema',
  ],
  ejemploModelo: const EjemploTexto(
    ingles:
        "INTRODUCTION: Technology is revolutionizing education, but its impact on critical thinking among university students remains debated. While technology offers tools for learning, excessive reliance and passive consumption weaken students' independent reasoning skills. This essay argues that universities must balance technological integration with emphasis on critical thinking development. BODY 1: Technology provides access to infinite information, which seems beneficial. However, students often accept online information without verification or analysis. BODY 2: Additionally, algorithmic learning systems adapt to student abilities, but they eliminate struggle—the essential component for deep learning. CONCLUSION: Technology is a tool, not a solution. Universities must intentionally design programs that blend technological resources with activities that demand critical thinking. The future of education depends on this balance.",
    traduccion:
        "INTRODUCCION: La tecnologia esta revolucionando la educacion, pero su impacto en el pensamiento critico entre estudiantes universitarios sigue siendo debatido. Aunque la tecnologia ofrece herramientas para aprender, la dependencia excesiva y el consumo pasivo debilitan las habilidades de razonamiento independiente de los estudiantes. Este ensayo argumenta que las universidades deben equilibrar la integracion tecnologica con enfasis en el desarrollo del pensamiento critico. CUERPO 1: La tecnologia proporciona acceso a informacion infinita, lo que parece beneficioso. Sin embargo, los estudiantes a menudo aceptan informacion en linea sin verificacion o analisis. CUERPO 2: Ademas, los sistemas de aprendizaje algoritmico se adaptan a las habilidades del estudiante, pero eliminan la lucha — el componente esencial para el aprendizaje profundo. CONCLUSION: La tecnologia es una herramienta, no una solucion. Las universidades deben diseniar intencionalmente programas que mezclen recursos tecnologicos con actividades que demanden pensamiento critico. El futuro de la educacion depende de este equilibrio.",
    tipo: 'Academic 5-Paragraph Essay',
  ),
  erroresComunes: [
    'No tener TESIS clara en introduccion. Lectores no saben cual es tu ARGUMENTO principal. Define clarity en primera lectura.',
    'Body parrafos repetitivos. Si todos los parrafos dicen "la tecnologia es buena", es aburrido y debil. Varia: USA CONTRAPUNTOS, NO solo acuerdos.',
    'Conclusion que solo REPITE. Conclusion debe REFLEXIONAR, no copiar y pegar parrafos. "So what?" — por que importa tu argumento?',
    'Falta de TRANSICIONES entre ideas. Lee: "... students accept information without verification. Additionally, algorithmic systems..." — "Additionally" CONECTA ideas.',
  ],
  tipsParaRecordar: [
    'TESIS CLARA = sentence (1-2 oraciones) que resume tu argumento COMPLETO. Lectores deben entenderlo en 10 segundos.',
    'ESTRUCTURA: Intro (Tesis) → Body 1 (Argumento + Evidencia) → Body 2 (Argumento diferente o contraargumento) → Conclusion (Resumen + Reflexion)',
    'Numeros e EVIDENCIA > opinion. Escribe "Research shows 65% of..." NO "I think many..."',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the THESIS of this example essay?',
      opciones: [
        '"Technology is revolutionizing education"',
        '"Technology is bad and should be rejected"',
        '"Universities must balance technological integration with critical thinking development"',
        '"Students don\'t verify information online"',
      ],
      correcta: 2,
      explicacion:
          'TESIS es el ARGUMENTO principal que el autor defiende. La opcion C es la opinion especifica del autor (no solo que tecnologia existe, sino HOW to use it wisely). Thesis = tu posicion, no solo observacion.',
    ),
    const Pregunta(
      pregunta: 'How many BODY PARAGRAPHS would this essay typically have?',
      opciones: [
        'Only one showing all examples together',
        '2-3 paragraphs, each with a different argument or angle',
        'As many as needed without organization',
        'None—body paragraphs are optional',
      ],
      correcta: 1,
      explicacion:
          'Estructura de essay: Intro → 2-3 Body (cada uno desarrolla diferente aspecto del argumento) → Conclusion. El ejemplo muestra BODY 1 (acceso a informacion) y BODY 2 (sistemas pasivos). Separacion clara.',
    ),
    const Pregunta(
      pregunta:
          'What problem does the author identify with passive consumption in Body 1?',
      opciones: [
        'Students have too much technology access',
        'Students accept online information without verification or analysis',
        'Information on the internet is always incorrect',
        'Universities provide too many technological tools',
      ],
      correcta: 1,
      explicacion:
          'Body 1: "students often accept online information without verification or analysis". Esto es EVIDENCIA de por que tecnologia tiene riesgo. El argumento es: acceso sin pensamiento critico = peligro.',
    ),
    const Pregunta(
      pregunta:
          'According to the essay, what is MISSING when algorithmic learning systems adapt to students?',
      opciones: [
        'Fun and entertainment',
        'Struggle—the essential component for deep learning',
        'Advanced mathematics content',
        'Human interaction',
      ],
      correcta: 1,
      explicacion:
          'Body 2 argumento: "they eliminate struggle—the essential component for deep learning". El autor usa un CONTRAARGUMENTO: Si bien sistemas se adaptan (positivo), ELIMINAN dificultad que es necesaria para aprender profundo.',
    ),
    const Pregunta(
      pregunta: 'What does the CONCLUSION do in this essay?',
      opciones: [
        'Introduces a completely new idea',
        'Repeats all previous paragraphs word-for-word',
        'Synthesizes the argument and reflects on the importance: balance is necessary for the future',
        'Asks rhetorical questions without answering',
      ],
      correcta: 2,
      explicacion:
          'Conclusion: resume (tecnologia = herramienta), reflexiona (futuro depende de balance). Conclusion FUERTE = NO repite, sino SINTETIZA y responde "SO WHAT?" — por que esto importa al mundo?',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO WRITING - ACADEMIC WRITING
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema academicWriting = ContenidoTema(
  titulo: 'Academic Writing',
  descripcion: 'Escritura academica formal',
  queEs:
      'Academic writing es formal, objetiva, y basada en EVIDENCIA. Evita coloquialismos, contracciones, y opinion personal sin sustento. Usa tono profesional y estructura rigurosa: introduce un problema ACADEMICO, presenta investigacion, y propone soluciones o analisis.',
  cuandoSeUsa: [
    'Investigaciones universitarias y tesis',
    'Articulos para journals o revistas academicas',
    'Reportes tecnico para empresas o instituciones',
  ],
  criterios: [
    '1. TONO FORMAL: No uses "I think" o "In my opinion". Usa "Research indicates" o "It has been demonstrated"',
    '2. EVIDENCIA: TODO debe estar soportado. Citas (Citations), datos (data), estudios (research).',
    '3. ESTRUCTURA: Problema-Investigacion-Solucion o Analisis-Conclusion',
    '4. CLARIDAD sobre COMPLEJIDAD: Explica conceptos complejos de forma clara sin perder precision',
  ],
  ejemploModelo: const EjemploTexto(
    ingles:
        'ABSTRACT: This research examines the correlation between sleep deprivation and academic performance in university students. A quantitative study of 250 participants reveals significant negative correlation (r = -0.67, p < 0.001) between reduced sleep and test scores. INTRODUCTION: Sleep is regulated by circadian rhythms and affects cognitive function. Previous research (Smith et al., 2022) demonstrates that 7-8 hours of sleep enhance memory consolidation. METHODOLOGY: Participants reported sleep hours and academic metrics over a semester. FINDINGS: Students sleeping less than 6 hours showed 23% lower average grades compared to those with 8+ hours sleep. DISCUSSION: The implications suggest universities should implement sleep awareness programs. Future research should investigate intervention strategies.',
    traduccion:
        'RESUMEN: Esta investigacion examina la correlacion entre la privacion del sueno y el desempeno academico en estudiantes universitarios. Un estudio cuantitativo de 250 participantes revela una correlacion negativa significativa entre el sueno reducido y las puntuaciones de examenes. INTRODUCCION: El sueno esta regulado por ritmos circadianos y afecta la funcion cognitiva. Investigacion previa demuestra que 7-8 horas de sueno mejoran la consolidacion de la memoria. METODOLOGIA: Los participantes informaron horas de sueno y metricas academicas durante un semestre. HALLAZGOS: Los estudiantes que dormian menos de 6 horas mostraron 23% de calificaciones promedio mas bajas en comparacion con los que duermen 8+ horas. DISCUSION: Las implicaciones sugieren que las universidades deben implementar programas de conciencia del sueno. Investigaciones futuras deben investigar estrategias de intervencion.',
    tipo: 'Research Article Structure',
  ),
  erroresComunes: [
    'Usar "I" y opinion sin evidencia. "I believe" es debil. "Research demonstrates" es forte.',
    'Contracciones como "don\'t", "it\'s". Academic writing usa: "do not", "it is".',
    'Lenguaje vago: "many students", "some research". ESPECIFICO: "75% of students", "Smith et al. (2023)".',
    'Mezclar evidencia con opinion sin distinguir. Diferencia clara entre HECHOS y ANALISIS es crucial.',
  ],
  tipsParaRecordar: [
    'Academic = FORMAL. Imagina escribiendo para un profesor riguroso. Elimina coloquialismos, abreviaturas, emojis.',
    'Citas son PODER. Cada afirmacion nueva debe citar fuente. "According to [Author], [claim]"',
    'Estructura CLARA: Problema → Investigacion → Resultados → Implicacion. Lectores deben seguir logica rigidamente.',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Which statement uses APPROPRIATE academic tone?',
      opciones: [
        '"I think sleep is super important for grades"',
        '"Honestly, students don\'t get enough sleep"',
        '"Research demonstrates a significant negative correlation between sleep deprivation and academic performance"',
        '"Everyone knows sleep matters, right?"',
      ],
      correcta: 2,
      explicacion:
          'Academic tone: formal vocabulary ("demonstrates"), basado en evidencia ("research"), estructurado ("significant correlation"). Las otras son coloquiales, sin sustento, o dirigidas a audiencia casual.',
    ),
    const Pregunta(
      pregunta: 'In academic writing, how should you present personal belief?',
      opciones: [
        '"I believe universities should help students with sleep"',
        '"Everyone agrees that sleep is important"',
        '"The implications of this research suggest that institutions should consider implementing sleep awareness programs"',
        '"Obviously, sleep is critical for success"',
      ],
      correcta: 2,
      explicacion:
          'Academic writing NO presenta creencias personales como opinion. Las presenta como IMPLICACIONES de investigacion. "implications suggest" es neutral: basa tu idea en datos, no en "creo".',
    ),
    const Pregunta(
      pregunta:
          'What statistic from the example demonstrates ACADEMIC PRECISION?',
      opciones: [
        '"Sleep is important"',
        '"Some students don\'t sleep enough"',
        '"Students sleeping less than 6 hours showed 23% lower average grades"',
        '"Most research shows sleep matters"',
      ],
      correcta: 2,
      explicacion:
          'Academic = NUMEROS EXACTOS, no vagas. "23% lower average grades" vs "some don\'t sleep"? PRECISION wins. Tambien: especifica el GRUPO (6 hours) y COMPARACION (vs 8+ hours).',
    ),
    const Pregunta(
      pregunta:
          'Which is an appropriate use of CONTRACTIONS in academic writing?',
      opciones: [
        '"Students don\'t get enough sleep"',
        '"Research doesn\'t show significant results"',
        '"Sleep isn\'t as important as exercise"',
        'NONE—academic writing avoids contractions entirely',
      ],
      correcta: 3,
      explicacion:
          'Academic writing NO usa contracciones (don\'t, isn\'t, don\'t). USA formas completas: do not, is not, do not. Esto mantiene formalidad y seriedad academica.',
    ),
    const Pregunta(
      pregunta:
          'In the example abstract, what makes it ACADEMIC rather than casual?',
      opciones: [
        'It mentions numbers and statistics',
        'The formal structure (Abstract, Methodology, Findings) and evidence-based claims without personal opinion',
        'It is longer than casual writing',
        'It uses difficult vocabulary for no reason',
      ],
      correcta: 1,
      explicacion:
          'Academic = ESTRUCTURA consistente (Abstract-Intro-Methodology-Findings-Discussion), NUMEROS exactos, LENGUAJE neutral (no "I think"), y cada claim soportado. Esto NO es casual — es riguroso.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO WRITING - ARGUMENTATIVE ESSAYS
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema argumentativeEssays = ContenidoTema(
  titulo: 'Argumentative Essays',
  descripcion: 'Tesis y argumentación',
  queEs:
      'Un ensayo argumentativo defiende una postura (thesis) con razones y evidencia, y responde a los contraargumentos más fuertes. A diferencia de un ensayo descriptivo, aquí debes CONVENCER al lector, no solo informar.',
  cuandoSeUsa: [
    'Ensayos de opinión en clases de inglés o debate',
    'Responder preguntas de examen que piden "argue whether..."',
    'Escribir cartas o artículos de opinión defendiendo una postura',
  ],
  criterios: [
    '1. THESIS STATEMENT: tu postura clara, generalmente al final de la introducción',
    '2. ARGUMENTOS: 2-3 razones principales, cada una en su propio párrafo con evidencia',
    '3. COUNTERARGUMENT: reconoce el argumento contrario más fuerte y explica por qué tu postura sigue siendo válida',
    '4. CONCLUSIÓN: reafirma la tesis y deja una idea final memorable',
  ],
  ejemploModelo: const EjemploTexto(
    ingles:
        'Universities should make attendance optional for lecture-based courses. First, mandatory attendance treats adult students like children, when in fact they are capable of managing their own learning. Second, forcing students to attend lectures they could review more efficiently through recorded material wastes valuable time that could go toward internships or part-time jobs. Admittedly, some argue that attendance ensures engagement and reduces dropout rates. However, engagement should be measured through performance, not physical presence; a student who masters the material independently should not be penalized for choosing an efficient study method. For these reasons, universities should trust students to manage their own attendance.',
    traduccion:
        'Las universidades deberían hacer la asistencia opcional para cursos basados en clases magistrales. Primero, la asistencia obligatoria trata a estudiantes adultos como niños, cuando de hecho son capaces de manejar su propio aprendizaje. Segundo, obligar a los estudiantes a asistir a clases que podrían repasar más eficientemente mediante material grabado desperdicia tiempo valioso que podría destinarse a prácticas o trabajos de medio tiempo. Es cierto que algunos argumentan que la asistencia asegura el compromiso y reduce las tasas de deserción. Sin embargo, el compromiso debería medirse por el desempeño, no por la presencia física; un estudiante que domina el material de forma independiente no debería ser penalizado por elegir un método de estudio eficiente. Por estas razones, las universidades deberían confiar en que los estudiantes manejen su propia asistencia.',
    tipo: 'Argumentative Essay with Counterargument',
  ),
  erroresComunes: [
    'No incluir un counterargument. Un ensayo argumentativo sin reconocer la postura contraria parece débil, no fuerte.',
    'Usar solo opiniones ("I think this is bad") sin razones específicas o evidencia que las apoye.',
    'Tesis vaga o poco clara: MAL: "There are good and bad things about this" BIEN: "Universities should make attendance optional"',
  ],
  tipsParaRecordar: [
    'Tu thesis debe ser una POSTURA, no un tema. "Social media" no es tesis. "Social media harms academic focus" sí lo es.',
    'Usa "Admittedly" o "Some argue that" para introducir el counterargument, y "However" para responderlo.',
    'Cada párrafo de argumento = UNA razón + evidencia/ejemplo que la sostenga.',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'What is the THESIS of the example essay?',
      opciones: [
        'Attendance policies vary by university',
        'Universities should make attendance optional for lecture-based courses',
        'Students dislike attending class',
        'Recorded lectures are always better than live ones',
      ],
      correcta: 1,
      explicacion:
          'La tesis es la postura clara del autor, dicha en la primera frase: "Universities should make attendance optional for lecture-based courses". Todo el ensayo defiende esta idea específica.',
    ),
    const Pregunta(
      pregunta: 'Which sentence introduces the COUNTERARGUMENT?',
      opciones: [
        '"First, mandatory attendance treats adult students like children"',
        '"Admittedly, some argue that attendance ensures engagement and reduces dropout rates"',
        '"For these reasons, universities should trust students"',
        '"Second, forcing students to attend lectures...wastes valuable time"',
      ],
      correcta: 1,
      explicacion:
          '"Admittedly" señala que el autor va a reconocer un punto de vista opuesto antes de refutarlo — es la estructura clásica del counterargument en ensayos argumentativos.',
    ),
    const Pregunta(
      pregunta: 'How does the author RESPOND to the counterargument?',
      opciones: [
        'By ignoring it completely',
        'By agreeing that attendance should be mandatory after all',
        'By arguing that engagement should be measured by performance, not physical presence',
        'By saying the counterargument is stupid',
      ],
      correcta: 2,
      explicacion:
          'Después de "However", el autor da una razón específica por la que el counterargument no invalida su tesis: el compromiso se mide por desempeño, no asistencia física. Esta es una refutación efectiva, no un ataque personal.',
    ),
    const Pregunta(
      pregunta:
          'Which of these is the STRONGEST thesis statement for an argumentative essay?',
      opciones: [
        'Technology is used in many universities today.',
        'Some people like online classes and some do not.',
        'Universities should require all first-year students to take at least one fully online course.',
        'Online classes are a topic worth discussing.',
      ],
      correcta: 2,
      explicacion:
          'Una tesis fuerte toma una POSTURA CLARA y específica ("should require"), no solo menciona un tema. Las otras opciones son observaciones neutras, no argumentos defendibles.',
    ),
    const Pregunta(
      pregunta:
          'What connector would best introduce a SECOND supporting argument (after "First,...")?',
      opciones: ['"However"', '"Second," or "Furthermore,"', '"Admittedly"', '"In conclusion"'],
      correcta: 1,
      explicacion:
          '"Second" o "Furthermore" indican que agregas OTRO argumento del mismo lado (a favor de tu tesis) — no contraste ("However") ni concesión ("Admittedly").',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// CONTENIDO WRITING - RESEARCH WRITING
// ══════════════════════════════════════════════════════════════════════════════
final ContenidoTema researchWriting = ContenidoTema(
  titulo: 'Research Writing',
  descripcion: 'Citas y referencias APA',
  queEs:
      'Research Writing es escribir usando fuentes externas de forma correcta: citando dentro del texto (in-text citations) y listando las referencias completas al final, siguiendo un formato como APA. Esto le da credibilidad a tu trabajo y evita el plagio.',
  cuandoSeUsa: [
    'Escribir trabajos de investigación o monografías universitarias',
    'Citar fuentes dentro de un ensayo para apoyar tus argumentos',
    'Crear la lista de referencias (Reference List) al final de un documento académico',
  ],
  criterios: [
    '1. IN-TEXT CITATION: (Author, Year) inmediatamente después de la idea citada — ej: (Chen, 2022)',
    '2. PARAPHRASING vs QUOTING: prefiere parafrasear (con tus propias palabras) sobre citar textualmente; usa comillas SOLO si citas exacto',
    '3. REFERENCE LIST: al final del documento, orden alfabético por apellido del autor, formato completo',
    '4. Cada fuente citada en el texto DEBE aparecer en la Reference List, y viceversa',
  ],
  ejemploModelo: const EjemploTexto(
    ingles:
        'Recent research suggests that spaced repetition significantly improves long-term vocabulary retention compared to massed practice (Chen, 2022). This finding aligns with earlier work showing that distributed learning schedules produce stronger memory traces than concentrated study sessions (Alvarez & Kim, 2019). However, Chen (2022) also notes that the effectiveness of spaced repetition depends on consistent daily engagement, which many students struggle to maintain without external reminders.\n\nReferences:\nAlvarez, M., & Kim, J. (2019). Distributed practice in second language acquisition. Journal of Applied Linguistics, 14(2), 45-61.\nChen, L. (2022). Spaced repetition and vocabulary retention in university students. Language Learning Review, 30(1), 12-29.',
    traduccion:
        'Investigaciones recientes sugieren que la repetición espaciada mejora significativamente la retención de vocabulario a largo plazo comparada con la práctica masiva (Chen, 2022). Este hallazgo coincide con trabajos anteriores que muestran que los horarios de aprendizaje distribuido producen huellas de memoria más fuertes que las sesiones de estudio concentradas (Alvarez & Kim, 2019). Sin embargo, Chen (2022) también señala que la efectividad de la repetición espaciada depende del compromiso diario constante, algo que muchos estudiantes luchan por mantener sin recordatorios externos.\n\nReferencias:\nAlvarez, M., & Kim, J. (2019). Distributed practice in second language acquisition. Journal of Applied Linguistics, 14(2), 45-61.\nChen, L. (2022). Spaced repetition and vocabulary retention in university students. Language Learning Review, 30(1), 12-29.',
    tipo: 'Academic Paragraph with APA Citations',
  ),
  erroresComunes: [
    'Copiar texto exacto de una fuente sin comillas ni cita — esto es plagio, incluso si no fue intencional.',
    'Citar en el texto pero olvidar agregar la fuente completa en la Reference List (o viceversa).',
    'Usar solo el apellido del autor sin el año: MAL: "(Chen)" BIEN: "(Chen, 2022)". El año es obligatorio en formato APA.',
  ],
  tipsParaRecordar: [
    'Regla de oro: si la idea NO es tuya, necesita una cita — aunque la parafrasees con tus propias palabras.',
    'Formato in-text: (Apellido, Año). Si citas texto exacto, agrega también el número de página: (Chen, 2022, p. 15)',
    'Reference List = orden alfabético por apellido. In-text citation y Reference List deben coincidir siempre.',
  ],
  ejercicios: [
    const Pregunta(
      pregunta: 'Which is the CORRECT APA in-text citation format?',
      opciones: ['(Chen)', '(Chen, 2022)', '(2022, Chen)', '(L. Chen 2022)'],
      correcta: 1,
      explicacion:
          'Formato APA in-text: (Apellido, Año). "Chen" solo (sin año) es incompleto — el año es obligatorio para identificar la fuente exacta.',
    ),
    const Pregunta(
      pregunta:
          'According to the example, what does Chen (2022) say about spaced repetition\'s effectiveness?',
      opciones: [
        'It works only for advanced students',
        'It has no real effect on memory',
        'It depends on consistent daily engagement, which many students struggle to maintain',
        'It is worse than massed practice',
      ],
      correcta: 2,
      explicacion:
          'El texto atribuye esta idea específicamente a Chen (2022): "the effectiveness...depends on consistent daily engagement, which many students struggle to maintain". Research Writing requiere atribuir cada idea a su fuente correcta.',
    ),
    const Pregunta(
      pregunta:
          'If you use an author\'s EXACT words (not your own paraphrase), what must you add besides the citation?',
      opciones: [
        'Nothing else is needed',
        'Quotation marks around the exact text',
        'A footnote at the bottom of the page',
        'The author\'s email address',
      ],
      correcta: 1,
      explicacion:
          'Texto citado EXACTO siempre necesita comillas ("..."), además de la cita (Autor, Año). Sin comillas, aunque cites la fuente, se considera plagio porque no queda claro que son palabras exactas de otra persona.',
    ),
    const Pregunta(
      pregunta: 'In the Reference List, how are sources typically ordered?',
      opciones: [
        'By the order they appear in the text',
        'Alphabetically by the author\'s last name',
        'By publication date, newest first',
        'Randomly',
      ],
      correcta: 1,
      explicacion:
          'APA ordena la Reference List alfabéticamente por apellido del primer autor. "Alvarez & Kim" va antes que "Chen" porque A viene antes que C.',
    ),
    const Pregunta(
      pregunta:
          'What is the main risk if you cite a source in your text but FORGET to add it to the Reference List?',
      opciones: [
        'No risk—it is optional to include all sources',
        'The reader cannot verify or find your source, which weakens academic credibility and may be seen as improper citation',
        'The essay becomes automatically longer',
        'Nothing happens if the source is well-known',
      ],
      correcta: 1,
      explicacion:
          'Cada cita en el texto DEBE tener su entrada correspondiente en la Reference List. Si falta, el lector no puede verificar la fuente — esto compromete la credibilidad académica de tu trabajo.',
    ),
  ],
);

// ══════════════════════════════════════════════════════════════════════════════
// MAPA UNIFICADO DE TEMAS PARA WRITING
// ══════════════════════════════════════════════════════════════════════════════
final Map<String, ContenidoTema> writingTopics = {
  'Paragraph Structure': paragraphStructure,
  'Essay Writing': essayWriting,
  'Academic Writing': academicWriting,
  'Argumentative Essays': argumentativeEssays,
  'Research Writing': researchWriting,
};
