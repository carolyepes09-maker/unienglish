import 'package:flutter_test/flutter_test.dart';
import 'package:fluter_app/services/leccion_service.dart';

void main() {
  group('LeccionService.getLecciones - progreso real (no simulado)', () {
    test('el progreso de cada habilidad viene de habilidadesValues, no de un valor fijo por nivel', () {
      final servicio = LeccionService();
      final habilidadesValues = [80.0, 40.0, 20.0, 60.0, 0.0];

      final lecciones = servicio.getLecciones('A1', habilidadesValues);

      expect(lecciones.firstWhere((l) => l.title == 'Grammar').progress, 0.8);
      expect(lecciones.firstWhere((l) => l.title == 'Reading').progress, 0.4);
      expect(lecciones.firstWhere((l) => l.title == 'Listening').progress, 0.2);
      expect(lecciones.firstWhere((l) => l.title == 'Writing').progress, 0.6);
    });

    test('el nivel seleccionado (A1/A2/B1/B2) no altera el progreso mostrado', () {
      final servicio = LeccionService();
      final habilidadesValues = [50.0, 50.0, 50.0, 50.0, 0.0];

      final progresoA1 = servicio
          .getLecciones('A1', habilidadesValues)
          .map((l) => l.progress)
          .toList();
      final progresoB2 = servicio
          .getLecciones('B2', habilidadesValues)
          .map((l) => l.progress)
          .toList();

      expect(progresoA1, progresoB2);
    });

    test('Speaking se muestra bloqueado y en 0, sin importar habilidadesValues', () {
      final servicio = LeccionService();
      final lecciones = servicio.getLecciones('B1', [10.0, 10.0, 10.0, 10.0, 90.0]);

      final speaking = lecciones.firstWhere((l) => l.title == 'Speaking');
      expect(speaking.isLocked, true);
      expect(speaking.progress, 0.0);
    });

    test('un usuario nuevo (sin progreso) ve todas las barras en 0, no valores inventados', () {
      final servicio = LeccionService();
      final lecciones = servicio.getLecciones('A1', [0, 0, 0, 0, 0]);

      for (final leccion in lecciones) {
        expect(leccion.progress, 0.0);
      }
    });
  });
}
