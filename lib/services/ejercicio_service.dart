import 'package:flutter/material.dart';
import '../models/contenido_tema.dart';
import '../models/grammar_content.dart';
import '../models/reading_content.dart';
import '../models/listening_content.dart';
import '../models/writing_content.dart';
import 'actividad_service.dart';

/// =============================================================================
/// 🎓 SERVICIO: lib/services/ejercicio_service.dart
/// =============================================================================
/// Este servicio es el "Motor de Lecciones" de la aplicación. Gestiona el
/// estado de una sesión de ejercicios activa.
///
/// FUNCIONES PRINCIPALES:
/// 1. Carga Dinámica: Selecciona el contenido correcto (Grammar, Reading, etc.)
///    basado en la elección del usuario.
/// 2. Control de Estado: Rastrea en qué pregunta está el usuario y si ya respondió.
/// 3. Validación: Compara la respuesta del usuario con la correcta y suma puntos.
/// 4. Registro: Al finalizar, guarda la actividad en [ActividadService].
///
/// RELACIÓN CON OTRAS CAPAS:
/// - UI: [EjerciciosScreen] escucha este servicio para actualizar la barra
///   de progreso y mostrar el feedback.
/// - MODELS: Utiliza [ContenidoTema] y los diccionarios de temas específicos.
/// =============================================================================

class EjercicioService extends ChangeNotifier {
  ContenidoTema? _contenido; // La lección cargada actualmente
  int _preguntaActual = 0; // Índice de la pregunta en curso
  int? _respuestaSeleccionada; // Índice de la opción que el usuario marcó
  bool _respondida =
      false; // Bloquea cambios una vez que se valida la respuesta
  int _correctas = 0; // Contador de aciertos

  // Getters
  ContenidoTema? get contenido => _contenido;
  int get preguntaActual => _preguntaActual;
  int? get respuestaSeleccionada => _respuestaSeleccionada;
  bool get respondida => _respondida;
  int get correctas => _correctas;
  int get totalPreguntas => _contenido?.ejercicios.length ?? 0;
  double get progreso =>
      totalPreguntas > 0 ? (_preguntaActual + 1) / totalPreguntas : 0;

  /// ─── INICIO DE SESIÓN DE APRENDIZAJE ─────────────────────────────────────
  /// Configura el motor seleccionando el repositorio de datos adecuado
  /// (Gramática, Lectura, etc.) basado en la categoría elegida.
  void iniciarLeccion(String leccion, String temaNombre) {
    switch (leccion) {
      case 'Grammar':
        _contenido = grammarTopics[temaNombre];
        break;
      case 'Reading':
        _contenido = readingTopics[temaNombre];
        break;
      case 'Listening':
        _contenido = listeningTopics[temaNombre];
        break;
      case 'Writing':
        _contenido = writingTopics[temaNombre];
        break;
    }
    // Reiniciamos los contadores para una nueva sesión limpia
    _preguntaActual = 0;
    _respuestaSeleccionada = null;
    _respondida = false;
    _correctas = 0;
    notifyListeners(); // Avisamos a la UI que se prepare para mostrar preguntas
  }

  /// ─── VALIDACIÓN DE RESPUESTA ──────────────────────────────────────────────
  /// Compara el índice seleccionado por el usuario con el índice correcto
  /// definido en el modelo de datos.
  void seleccionarRespuesta(int index) {
    if (!_respondida && _contenido != null) {
      _respuestaSeleccionada = index;
      _respondida = true;

      // Sumamos al contador si el acierto es real
      if (index == _contenido!.ejercicios[_preguntaActual].correcta) {
        _correctas++;
      }
      notifyListeners(); // Actualiza la barra de progreso y colores de botones
    }
  }

  bool siguientePregunta() {
    if (_contenido != null && _preguntaActual < totalPreguntas - 1) {
      _preguntaActual++;
      _respuestaSeleccionada = null;
      _respondida = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// PASO 1: El disparador del registro.
  /// Este método se llama cuando el usuario termina la última pregunta de un ejercicio.
  void finalizar(String leccion, String temaNombre) {
    if (_contenido == null) return;

    // 1.1 CÁLCULO: Determinamos el éxito del usuario para el historial.
    final double porcentajeCorrecto = _correctas / totalPreguntas;

    // 1.2 MANDATO AL SERVICIO: Salimos del motor de ejercicios y enviamos los datos
    // al servicio de actividades para que se guarde parcialmente.
    actividadService.registrarActividad(
      titulo: '$leccion: $temaNombre',
      subtitulo: porcentajeCorrecto == 1.0
          ? 'Completado hoy'
          : '${(porcentajeCorrecto * 100).toInt()}% completado',
      porcentaje: '${(porcentajeCorrecto * 100).toInt()}%',
      esPerfecto: porcentajeCorrecto == 1.0,
    );
  }
}
