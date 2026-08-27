// Tests de ProgresoService.registrarExamen() (hallazgo 5): cada habilidad
// del examen debe actualizar su propia posición en habilidadesValues
// (Grammar=0, Reading=1, Listening=2, Writing=3, Speaking=4), no siempre
// las mismas dos posiciones sin importar qué se preguntó.
//
// No necesita mocks de Firebase: como en este test nadie inicia sesión en
// el singleton AuthService(), _guardarEnFirestore() encuentra
// usuarioActualId == null y no llega a tocar Firestore -- solo
// SharedPreferences (mockeado) recibe el guardado local.
//
// ProgresoService es un singleton real (misma instancia en toda la
// suite), así que cada test mide el CAMBIO relativo a su propio "antes" en
// vez de asumir un estado en cero -- evita que el orden de ejecución de
// los tests afecte el resultado.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluter_app/services/progreso_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ProgresoService().initialize();
  });

  group('ProgresoService.registrarExamen - hallazgo 5', () {
    test(
      'un examen con preguntas de Listening y Writing sube esas dos posiciones, no Grammar/Reading',
      () {
        final progreso = ProgresoService();
        final antes = List<double>.from(progreso.habilidadesValues);

        progreso.registrarExamen(
          {'listening': 3, 'writing': 2}, // correctas
          {'listening': 4, 'writing': 2}, // total
        );

        // Índices: 0 Grammar, 1 Reading, 2 Listening, 3 Writing, 4 Speaking.
        expect(
          progreso.habilidadesValues[0],
          antes[0],
          reason: 'Grammar no se preguntó en este examen, no debería cambiar',
        );
        expect(
          progreso.habilidadesValues[1],
          antes[1],
          reason: 'Reading no se preguntó en este examen, no debería cambiar',
        );
        expect(
          progreso.habilidadesValues[2],
          greaterThan(antes[2]),
          reason: 'Listening sí se preguntó y tuvo aciertos, debe subir',
        );
        expect(
          progreso.habilidadesValues[3],
          greaterThan(antes[3]),
          reason: 'Writing sí se preguntó y tuvo aciertos, debe subir',
        );
        expect(
          progreso.habilidadesValues[4],
          antes[4],
          reason: 'Speaking nunca lo evalúa el examen, no debería cambiar',
        );
      },
    );

    test('un examen con las 4 habilidades actualiza las 4, no solo 2', () {
      final progreso = ProgresoService();
      final antes = List<double>.from(progreso.habilidadesValues);

      progreso.registrarExamen(
        {'grammar': 2, 'reading': 1, 'listening': 2, 'writing': 2},
        {'grammar': 2, 'reading': 2, 'listening': 2, 'writing': 2},
      );

      expect(progreso.habilidadesValues[0], greaterThan(antes[0])); // Grammar
      expect(progreso.habilidadesValues[1], greaterThan(antes[1])); // Reading
      expect(
        progreso.habilidadesValues[2],
        greaterThan(antes[2]),
      ); // Listening
      expect(progreso.habilidadesValues[3], greaterThan(antes[3])); // Writing
      expect(
        progreso.habilidadesValues[4],
        antes[4],
      ); // Speaking, el examen nunca lo toca
    });

    test('una habilidad con 0 preguntas respondidas no se toca (evita división por cero)', () {
      final progreso = ProgresoService();
      final antes = List<double>.from(progreso.habilidadesValues);

      progreso.registrarExamen(
        {'writing': 0},
        {'writing': 0}, // 0 preguntas de writing en este examen
      );

      expect(progreso.habilidadesValues[3], antes[3]);
    });

    test('incrementa examenesRealizados en cada llamada', () {
      final progreso = ProgresoService();
      final antes = progreso.examenesRealizados;

      progreso.registrarExamen({'grammar': 1}, {'grammar': 1});

      expect(progreso.examenesRealizados, antes + 1);
    });
  });
}
