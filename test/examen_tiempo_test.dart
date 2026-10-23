// El simulacro debe cerrarse solo al llegar a 00:00 (antes el reloj se
// detenía y se podía seguir respondiendo sin límite) y registrarse una
// sola vez en el progreso.

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluter_app/services/examen_service.dart';
import 'package:fluter_app/services/progreso_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // rootBundle guarda en caché el Future de cada asset; uno creado dentro
    // del fakeAsync de un test anterior nunca se resuelve en el siguiente.
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({});
    await ProgresoService().initialize();
  });

  test('al agotarse el tiempo el examen se cierra y se registra una vez', () {
    fakeAsync((async) {
      final examen = ExamenService();
      examen.inicializar(nivel: 'A1');
      async.flushMicrotasks();
      expect(examen.enCurso, isTrue);
      expect(examen.totalQuestions, greaterThan(0));

      final examenesAntes = ProgresoService().examenesRealizados;
      async.elapse(Duration(seconds: examen.secondsRemaining + 1));

      expect(examen.enCurso, isFalse);
      expect(examen.tiempoAgotado, isTrue);
      expect(ProgresoService().examenesRealizados, examenesAntes + 1);

      // Ya cerrado: no acepta respuestas ni vuelve a registrarse.
      examen.selectAnswer(0);
      expect(examen.respondida, isFalse);
      examen.finalizar();
      expect(ProgresoService().examenesRealizados, examenesAntes + 1);
      examen.consumirTiempoAgotado();
    });
  });

  test('la habilidad más débil recibe una pregunta extra', () {
    fakeAsync((async) {
      // Grammar, Reading y Writing altos; Listening bajo: es la más débil.
      ProgresoService().registrarExamen(
        {'grammar': 4, 'reading': 4, 'listening': 0, 'writing': 4},
        {'grammar': 4, 'reading': 4, 'listening': 4, 'writing': 4},
      );
      async.flushMicrotasks();

      final examen = ExamenService();
      examen.inicializar(nivel: 'A1');
      async.flushMicrotasks();
      final porHabilidad = <String, int>{};
      for (var i = 0; i < examen.totalQuestions; i++) {
        final skill = examen.preguntaActual!.skill;
        porHabilidad[skill] = (porHabilidad[skill] ?? 0) + 1;
        examen.selectAnswer(0);
        examen.nextQuestion();
      }
      async.flushMicrotasks();

      // A1 = 2 por habilidad, más 1 para la más débil.
      expect(porHabilidad['listening'], 3);
      expect(porHabilidad['grammar'], 2);
    });
  });

  test('no repite las preguntas del simulacro anterior si hay otras', () {
    fakeAsync((async) {
      Set<String> hacerExamen() {
        final examen = ExamenService();
        examen.inicializar(nivel: 'A1');
        async.flushMicrotasks();
        final claves = <String>{};
        for (var i = 0; i < examen.totalQuestions; i++) {
          claves.add(examen.preguntaActual!.clave);
          examen.selectAnswer(0);
          examen.nextQuestion();
        }
        async.flushMicrotasks();
        return claves;
      }

      final primeras = hacerExamen();
      final segundas = hacerExamen();
      // Hay más de 2 preguntas por habilidad en el banco, así que el segundo
      // examen no repite las del primero.
      expect(segundas.intersection(primeras), isEmpty);
    });
  });
}
