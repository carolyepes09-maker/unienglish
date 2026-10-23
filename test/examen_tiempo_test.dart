// El simulacro debe cerrarse solo al llegar a 00:00 (antes el reloj se
// detenía y se podía seguir respondiendo sin límite) y registrarse una
// sola vez en el progreso.

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluter_app/services/examen_service.dart';
import 'package:fluter_app/services/progreso_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
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
}
