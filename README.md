
# UniEnglish — Plataforma de Aprendizaje de Inglés para Universitarios

UniEnglish es una aplicación educativa desarrollada en Flutter cuyo objetivo es facilitar el aprendizaje efectivo del inglés universitario a través de lecciones estructuradas, ejercicios interactivos y seguimiento personalizado del progreso. El enfoque está en la comprensión, producción y práctica de las cuatro habilidades clave: Grammar, Reading, Listening y Writing, con contenido contextualizado para estudiantes universitarios.

---

## Objetivo del Proyecto

Crear una plataforma móvil moderna, intuitiva y visualmente atractiva que permita a estudiantes universitarios mejorar su inglés académico y comunicativo, mediante:
- Lecciones temáticas con explicaciones claras y ejemplos reales.
- Ejercicios autocorregibles y retroalimentación inmediata.
- Seguimiento de progreso y repetición espaciada de vocabulario.
- Diseño adaptativo y motivador, alineado con principios de UX/UI modernos.

## Estructura General del Proyecto

```
lib/
	main.dart                # Punto de entrada, configuración de rutas y tema
	firebase_options.dart    # Configuración de Firebase (web, Android, iOS)
	models/                  # Modelos de datos educativos
	services/                # Lógica de negocio y acceso a datos (Firebase Auth/Firestore, SharedPreferences)
	ui/
	  pages/                 # Pantallas principales de la app
	  widgets/               # Widgets reutilizables
	  utils/                 # Utilidades de UI (fuentes, textos, responsivo)
assets/images/             # Recursos gráficos y fondos
pubspec.yaml               # Dependencias y configuración Flutter
```

## Principales Módulos y Componentes

### 1. Modelos de Datos (`lib/models/`)
- **contenido_tema.dart**: Modelo central para representar un tema educativo (título, descripción, estructura, ejemplos, errores comunes, tips, ejercicios, etc.).
- **grammar_content.dart, reading_content.dart, listening_content.dart, writing_content.dart**: Definen el contenido específico de cada habilidad, con ejemplos, ejercicios y explicaciones adaptadas.
- **palabra_model.dart**: Modelo para la gestión de vocabulario personalizado, con algoritmo de repetición espaciada (SM-2 simplificado).
- **simulacro_model.dart**: Modelo de pregunta para el Simulacro de examen.

### 2. Servicios (`lib/services/`)
- **auth_service.dart**: Autenticación (Firebase Authentication) y perfil de usuario (Cloud Firestore).
- **progreso_service.dart**: Estadísticas de progreso del usuario (racha, horas, lecciones, exámenes, gráfico de habilidades).
- **vocabulario_service.dart**: Guarda, carga y sincroniza el vocabulario personalizado del usuario.
- **ejercicio_service.dart, leccion_service.dart, examen_service.dart, revision_service.dart, actividad_service.dart, idioma_service.dart**: Lógica de ejercicios, lecciones, el Simulacro de examen, repaso de vocabulario, actividad reciente e idioma de interfaz.

### 3. Pantallas Principales (`lib/ui/pages/`)
- **login_screen.dart**: Pantalla de autenticación con diseño responsivo y fondo personalizado.
- **home_screen.dart**: Pantalla principal con acceso a lecciones, progreso y vocabulario.
- **lecciones_screen.dart**: Lista de lecciones organizadas por nivel (A1, A2, B1, B2).
- **leccion_detalle_screen.dart**: Detalle de cada lección, mostrando temas y progreso.
- **tema_detalle_screen.dart**: Explicación detallada de un tema (estructura, ejemplos, errores, tips).
- **ejercicios_screen.dart**: Ejercicios interactivos autocorregibles para cada tema.
- **resultado_screen.dart, resultado_revision_screen.dart**: Resultados y retroalimentación tras ejercicios/repasos.
- **simulacro_screen.dart**: Examen de simulacro cronometrado.
- **progreso_screen.dart**: Visualización gráfica del avance del usuario (usando `fl_chart`).
- **perfil_screen.dart**: Perfil del usuario, avatar, nivel y estadísticas.
- **agregar_palabra_screen.dart, vocabulario_screen.dart, revision_screen.dart**: Gestión y repaso de vocabulario personalizado.

### 4. Widgets y utilidades de UI (`lib/ui/widgets/`, `lib/ui/utils/`)
- **audio_player_card.dart**: Reproductor de audio con transcripción, usado en las lecciones de Listening.
- **app_fonts.dart, app_strings.dart, responsive.dart**: Tipografía (Poppins, empaquetada localmente), textos bilingües (ES/EN) y utilidades de diseño responsivo (móvil/escritorio).

## Navegación y Flujo de la App

La navegación se gestiona mediante rutas nombradas en `main.dart`, permitiendo transiciones claras entre login, home, lecciones, temas, ejercicios y resultados. El flujo típico es:

1. **Login** → 2. **Home** → 3. **Lecciones** → 4. **Tema Detalle** → 5. **Ejercicios** → 6. **Resultados**

El usuario puede consultar su progreso, acceder a su perfil y gestionar su vocabulario en cualquier momento.

## Diseño y Experiencia de Usuario

- **Colores y tipografía**: Basados en un sistema de diseño propio (ver constantes en `main.dart`), usando la tipografía Poppins (empaquetada localmente) y paleta universitaria (rojo, dorado, crema, blanco, negro).
- **Visuales**: Uso de imágenes, overlays y animaciones GIF para motivar y dar feedback visual.
- **Responsivo**: Adaptado a móvil y desktop, con tamaños y paddings dinámicos.

## Funcionalidades Educativas Clave

- **Lecciones estructuradas**: Cada lección contiene explicación, ejemplos, errores comunes, tips y ejercicios autocorregibles.
- **Ejercicios interactivos**: Preguntas de opción múltiple con retroalimentación inmediata y explicación.
- **Vocabulario personalizado**: El usuario puede agregar palabras, practicar y repasar según el algoritmo de repetición espaciada.
- **Seguimiento de progreso**: Gráficas y estadísticas motivacionales.
- **Contenido contextualizado**: Ejemplos y textos adaptados a situaciones universitarias reales.

## Dependencias Principales

- **Flutter SDK**
- **firebase_core, firebase_auth, cloud_firestore**: Autenticación y base de datos en la nube (ver sección "Arquitectura y stack tecnológico" más abajo).
- **fl_chart**: Gráficas de progreso.
- **shared_preferences**: Persistencia local (caché rápida/offline) de vocabulario y progreso.
- **audioplayers**: Reproducción de audio para las lecciones de Listening.
- **lottie, gif**: Animaciones y feedback visual.
- Tipografía Poppins empaquetada como fuente local del proyecto (no usa el paquete `google_fonts`).

## ¿Qué busca lograr UniEnglish?

- Democratizar el acceso a recursos de inglés académico de calidad.
- Motivar el aprendizaje autónomo y personalizado.
- Facilitar la práctica realista y contextualizada.
- Medir y visualizar el avance para mantener la motivación.

## Licencia

MIT.

---

# Descripción Detallada del Sistema (insumo para IA — Anteproyecto)

> Esta sección es un insumo de contexto pensado para entregar a un modelo de IA como base factual y detallada del sistema, de modo que pueda redactar con precisión las secciones del Anteproyecto (Descripción del problema, Justificación, Objetivos, Delimitación, Marco Referencial/Metodológico, etc.) según la Guía 1 de la Universidad Libre. Describe el sistema **tal como está implementado hoy**, sin inventar funcionalidades que no existen.

## 1. Contexto y problema que origina el proyecto

La Universidad Libre exige a sus estudiantes acreditar un nivel de inglés como requisito para optar al título de grado. La vía normal para cumplir este requisito es cursar inglés a través de alianzas certificadas con institutos externos. Sin embargo, una parte de los estudiantes **no puede acceder a esas alianzas certificadas**, ya sea por:

- **Restricción económica**: los cursos de las alianzas certificadas tienen un costo que no todos los estudiantes pueden asumir.
- **Restricción de tiempo**: estudiantes que trabajan, tienen alta carga académica u otras responsabilidades no pueden cumplir con los horarios fijos de los cursos presenciales/certificados.

Estos estudiantes quedan entonces obligados a una **vía alterna**: presentar directamente un **examen de validación/suficiencia de inglés** definido por la universidad, sin haber pasado por un proceso formal de preparación específico para ese examen. Esto genera una desventaja real: llegan al examen sin conocer su formato, su nivel de exigencia, el tipo de preguntas ni haber practicado bajo condiciones similares (tiempo límite, mezcla de habilidades, comprensión de lectura extensa, etc.), lo que incrementa el riesgo de reprobar y retrasar su graduación.

**UniEnglish nace específicamente para atender a este segmento de estudiantes**: no busca reemplazar un curso de inglés general desde cero, sino **preparar de forma dirigida, autónoma y gratuita a los estudiantes que van a presentar ese examen de validación**, dándoles contenido estructurado por nivel (A1-B2), práctica de las cuatro habilidades evaluadas y, en particular, un **simulacro de examen bajo condiciones reales** (tiempo límite, formato mixto) que reproduce la experiencia del examen real antes de que el estudiante se enfrente a él.

## 2. ¿Qué es UniEnglish? (descripción general del sistema)

UniEnglish es una aplicación educativa multiplataforma (funciona igual en navegador web/escritorio y en dispositivos móviles) desarrollada en **Flutter/Dart**, con backend en **Firebase** (Authentication + Cloud Firestore), cuyo propósito es preparar a estudiantes universitarios para un examen de suficiencia/validación de inglés, mediante lecciones estructuradas por nivel, ejercicios autocalificados, un simulacro de examen cronometrado, y seguimiento de progreso personalizado atado a la cuenta del usuario (no al dispositivo).

## 3. Usuarios y alcance (para Delimitación del proyecto)

- **Población objetivo**: estudiantes de la Universidad Libre que deben acreditar un nivel de inglés para grado y no acceden (por dinero o tiempo) a los cursos de las alianzas certificadas, y por tanto deben presentar el examen de validación institucional.
- **Espacio**: aplicación web (accesible desde cualquier navegador, con interfaz adaptada a escritorio y a móvil) desplegada en Firebase Hosting; también ejecutable como app móvil (Android/iOS) al compartir la misma base de código Flutter.
- **Temática**: preparación en inglés académico/comunicativo por niveles del Marco Común Europeo (A1, A2, B1, B2), enfocada en las cuatro habilidades: Grammar (gramática), Reading (comprensión de lectura), Listening (comprensión auditiva) y Writing (escritura).
- **Tiempo**: los datos del usuario (progreso, vocabulario, actividad) se conservan de forma indefinida mientras la cuenta exista, permitiendo un proceso de preparación continuo a lo largo del tiempo, no solo una sesión aislada.
- **Nivel de implementación actual**: sistema funcional y desplegado en producción (no es un prototipo estático); autenticación real, persistencia real en la nube, contenido de las cuatro habilidades cargado y navegable, simulacro funcional con banco de preguntas.

## 4. Funcionalidades del sistema

### 4.1 Autenticación y cuenta de usuario
- Registro e inicio de sesión con correo y contraseña (Firebase Authentication).
- Perfil de usuario persistido en Firestore (nombre, correo, código estudiantil, facultad/programa, nivel actual, fecha de registro, última conexión).
- La sesión y **todos los datos de uso** (progreso, vocabulario, actividad reciente) están atados a la cuenta, no al navegador/dispositivo: un estudiante puede iniciar sesión desde el computador de la universidad, su celular o cualquier otro equipo (incluyendo modo incógnito) y ve exactamente el mismo avance, sin depender de que ese dispositivo específico tenga los datos guardados localmente.

### 4.2 Sistema de niveles
- Cuatro niveles seleccionables: **A1, A2, B1, B2**.
- El nivel seleccionado por el estudiante determina el contenido de las lecciones que se le presentan.

### 4.3 Lecciones estructuradas por habilidad
Cuatro módulos de habilidad — **Grammar, Reading, Listening, Writing** — cada uno con varios temas (por ejemplo, en Grammar: Present Simple, Present Continuous, Past Simple, Present Perfect, Future Tenses). Cada tema se presenta en tres etapas de aprendizaje dentro de la misma pantalla (navegación por páginas):

1. **Teoría**: explicación de "¿Qué es?" el concepto y "¿Cuándo se usa?" (reglas de uso), con imagen ilustrativa cuando aplica.
2. **Práctica**: estructura gramatical (afirmativa/negativa/interrogativa) para Grammar, técnicas de lectura para Reading, reproductor de audio con transcripción y técnicas de escucha para Listening, o criterios de evaluación y ejemplo modelo para Writing; incluye ejemplos bilingües (inglés/español).
3. **Refuerzo**: errores comunes que se deben evitar, tips para recordar, y botón de acceso directo a los ejercicios del tema.

### 4.4 Ejercicios interactivos autocalificados
- Preguntas de opción múltiple por cada tema, con retroalimentación inmediata: indica si la respuesta fue correcta o incorrecta y muestra una **explicación pedagógica** de por qué.
- Barra de progreso durante la sesión de ejercicios.
- Al finalizar, el estudiante es dirigido a una pantalla de **Resultados** con puntaje, porcentaje de acierto, desglose de correctas/incorrectas, y accesos directos para reintentar o continuar con el siguiente tema.

### 4.5 Simulacro de examen (funcionalidad central para el problema que resuelve el proyecto)
- Examen global cronometrado (entre 10 y 60 minutos, según la cantidad de preguntas del nivel del estudiante) que mezcla preguntas de las distintas habilidades, incluyendo comprensión de lectura con pasajes de texto ("passages"), replicando el formato y la presión de tiempo de un examen real de validación.
- Las preguntas se aleatorizan en cada intento.
- Al finalizar (o al agotarse el tiempo), se calculan y muestran los resultados, y se actualiza el progreso general del estudiante (estadísticas de exámenes realizados, habilidades).
- Este módulo es el que traduce directamente el objetivo del proyecto: darle al estudiante una experiencia de práctica lo más parecida posible al examen real de validación de la universidad, antes de presentarlo.

### 4.6 Vocabulario personal con repetición espaciada
- El estudiante puede agregar sus propias palabras (término, traducción, ejemplo de uso) a un diccionario personal.
- Sesiones de repaso tipo flashcard (memoria/tarjetas), donde el estudiante indica si "sabía" o "no sabía" cada palabra.
- Algoritmo de repetición espaciada (inspirado en SM-2): las palabras que el estudiante domina se espacian más en el tiempo, y las que falla vuelven a aparecer antes, priorizando el repaso de lo que realmente necesita reforzar.

### 4.7 Seguimiento de progreso y gamificación
- Racha de días de uso consecutivo.
- Tiempo total invertido, lecciones completadas, exámenes/simulacros realizados.
- Gráfico de habilidades (tipo radar) por competencia: Grammar, Reading, Listening, Writing, Speaking.
- Porcentaje de avance hacia el siguiente nivel (ej. de A1 a A2).
- Historial de las últimas actividades realizadas (lecciones/exámenes completados recientemente).

### 4.8 Diseño adaptado a web y móvil
- La interfaz se adapta automáticamente según el tamaño de pantalla: en escritorio/web presenta una barra de navegación lateral persistente y diseño de tarjetas en cuadrícula aprovechando el espacio horizontal; en móvil usa navegación inferior por pestañas, optimizada para pantallas verticales.
- Sistema de diseño visual propio, con paleta institucional (rojo, dorado, crema) y tipografía Poppins, manteniendo consistencia visual en ambas versiones.

## 5. Arquitectura y stack tecnológico (para Marco Metodológico / Marco Teórico técnico)

- **Frontend/aplicación**: Flutter (Dart), lo que permite una única base de código para web, Android e iOS.
- **Backend como servicio (BaaS)**: Firebase.
  - **Firebase Authentication**: gestión de identidad (correo/contraseña).
  - **Cloud Firestore**: base de datos NoSQL en la nube donde se guarda el documento de cada usuario (perfil, nivel, progreso, vocabulario, actividad reciente), protegido por reglas de seguridad que solo permiten a cada usuario leer/escribir su propio documento.
  - **Firebase Hosting**: despliegue de la versión web de la aplicación.
- **Persistencia híbrida**: los datos se guardan localmente (caché rápida, funcionamiento sin conexión inmediata) y se sincronizan con Firestore como fuente de verdad definitiva ligada a la cuenta, con lógica para evitar pérdida o mezcla de datos entre distintas cuentas que usen el mismo navegador.
- **Arquitectura por capas**: separación entre modelos de datos (`lib/models/`), servicios de lógica de negocio (`lib/services/`, con patrón *singleton* y `ChangeNotifier` para estado reactivo) y pantallas/interfaz (`lib/ui/pages/`).
- **Otras dependencias relevantes**: `fl_chart` (gráficas de progreso), `audioplayers` (reproducción de audio para Listening), `shared_preferences` (persistencia local), `gif`/`lottie` (animaciones y feedback visual), `uuid` (identificadores únicos de vocabulario).

## 6. Flujo de uso típico

1. El estudiante se registra o inicia sesión.
2. Selecciona su nivel (A1-B2) en la sección de Lecciones.
3. Recorre los temas de las cuatro habilidades: teoría → práctica → refuerzo → ejercicios.
4. Revisa su progreso y refuerza vocabulario con las sesiones de repaso.
5. Cuando se siente preparado, realiza el **Simulacro** cronometrado para practicar en condiciones similares a las del examen real de validación de la universidad.
6. Repite el ciclo reforzando las habilidades donde el sistema muestra menor dominio (según el gráfico de habilidades), hasta sentirse listo para presentar el examen institucional real.

## 7. Justificación / valor diferencial (insumo para esa sección del Anteproyecto)

- **Gratuito y accesible**: elimina la barrera económica de los cursos certificados para quienes solo necesitan prepararse para el examen de validación, no tomar un curso completo.
- **Sin restricción de horario**: al ser autónomo, no depende de asistir a clases en horarios fijos, resolviendo la barrera de tiempo.
- **Enfocado en el examen real**: a diferencia de un curso general de inglés, el Simulacro está diseñado específicamente para simular las condiciones (tiempo límite, formato, mezcla de habilidades) del examen de validación que la universidad exige, que es el punto de fricción real que enfrentan estos estudiantes.
- **Seguimiento medible**: el estudiante puede ver objetivamente en qué habilidad está más débil y enfocar su tiempo de estudio limitado de forma más eficiente antes del examen.
- **Continuidad entre dispositivos**: al estar todo atado a la cuenta (no al dispositivo), el estudiante puede estudiar en ratos libres desde cualquier equipo disponible (biblioteca, sala de cómputo, su propio celular) sin perder avance.

