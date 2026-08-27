// Tests del algoritmo de repetición espaciada (SM-2 simplificado) en
// PalabraModel. Es lógica pura (sin Firebase/SharedPreferences), así que se
// prueba de forma aislada sin necesitar ningún mock.

import 'package:flutter_test/flutter_test.dart';
import 'package:fluter_app/models/palabra_model.dart';

PalabraModel _nuevaPalabra({
  int nivel = 0,
  DateTime? proximaRevision,
  int vecesCorrectamente = 0,
  int vecesIncorrectamente = 0,
}) => PalabraModel(
  id: 'test-1',
  ingles: 'apple',
  espanol: 'manzana',
  ejemplo: 'I ate an apple.',
  nivel: nivel,
  proximaRevision: proximaRevision,
  vecesCorrectamente: vecesCorrectamente,
  vecesIncorrectamente: vecesIncorrectamente,
);

void main() {
  group('PalabraModel - respuestaCorrecta', () {
    test('sube el nivel de a uno', () {
      final palabra = _nuevaPalabra(nivel: 0);
      palabra.respuestaCorrecta();
      expect(palabra.nivel, 1);
      palabra.respuestaCorrecta();
      expect(palabra.nivel, 2);
    });

    test('no sube el nivel más allá de 5 (tope de dominio)', () {
      final palabra = _nuevaPalabra(nivel: 5);
      palabra.respuestaCorrecta();
      expect(palabra.nivel, 5);
    });

    test('incrementa vecesCorrectamente', () {
      final palabra = _nuevaPalabra();
      expect(palabra.vecesCorrectamente, 0);
      palabra.respuestaCorrecta();
      expect(palabra.vecesCorrectamente, 1);
    });

    test('espacia la próxima revisión según el nivel alcanzado', () {
      // intervalos = [0, 1, 3, 7, 14, 30] -- nivel 2 -> 3, salto a nivel 3 -> 7 días.
      final antes = DateTime.now();
      final palabra = _nuevaPalabra(nivel: 2);
      palabra.respuestaCorrecta();
      final despues = DateTime.now();

      expect(palabra.nivel, 3);
      const diasEsperados = Duration(days: 7);
      expect(
        palabra.proximaRevision.isAfter(antes.add(diasEsperados - const Duration(minutes: 1))),
        isTrue,
        reason: 'la próxima revisión debería quedar ~7 días adelante, no antes',
      );
      expect(
        palabra.proximaRevision.isBefore(despues.add(diasEsperados + const Duration(minutes: 1))),
        isTrue,
        reason: 'la próxima revisión no debería pasarse de ~7 días adelante',
      );
    });
  });

  group('PalabraModel - respuestaIncorrecta', () {
    test('reinicia el nivel a 0 para repaso inmediato', () {
      final palabra = _nuevaPalabra(nivel: 4);
      palabra.respuestaIncorrecta();
      expect(palabra.nivel, 0);
    });

    test('incrementa vecesIncorrectamente', () {
      final palabra = _nuevaPalabra();
      palabra.respuestaIncorrecta();
      expect(palabra.vecesIncorrectamente, 1);
    });

    test('deja la próxima revisión en el momento actual (repaso ya mismo)', () {
      final antes = DateTime.now();
      final palabra = _nuevaPalabra(nivel: 3);
      palabra.respuestaIncorrecta();
      final despues = DateTime.now();

      expect(
        !palabra.proximaRevision.isBefore(antes) &&
            !palabra.proximaRevision.isAfter(despues),
        isTrue,
      );
    });
  });

  group('PalabraModel - necesitaRevision', () {
    test('es true cuando el nivel es 0, sin importar la fecha', () {
      final palabra = _nuevaPalabra(
        nivel: 0,
        proximaRevision: DateTime.now().add(const Duration(days: 30)),
      );
      expect(palabra.necesitaRevision, isTrue);
    });

    test('es false si el nivel > 0 y la próxima revisión es futura', () {
      final palabra = _nuevaPalabra(
        nivel: 2,
        proximaRevision: DateTime.now().add(const Duration(days: 5)),
      );
      expect(palabra.necesitaRevision, isFalse);
    });

    test('es true si el nivel > 0 pero la próxima revisión ya pasó', () {
      final palabra = _nuevaPalabra(
        nivel: 2,
        proximaRevision: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(palabra.necesitaRevision, isTrue);
    });
  });

  group('PalabraModel - dominada', () {
    test('es false por debajo del nivel 5', () {
      expect(_nuevaPalabra(nivel: 4).dominada, isFalse);
    });

    test('es true a partir del nivel 5', () {
      expect(_nuevaPalabra(nivel: 5).dominada, isTrue);
    });
  });

  group('PalabraModel - serialización', () {
    test('toJson/fromJson conservan los datos exactamente', () {
      final original = _nuevaPalabra(nivel: 2);
      original.respuestaCorrecta(); // nivel 3, vecesCorrectamente 1, timestamp real

      final reconstruida = PalabraModel.fromJson(original.toJson());

      expect(reconstruida.id, original.id);
      expect(reconstruida.ingles, original.ingles);
      expect(reconstruida.espanol, original.espanol);
      expect(reconstruida.ejemplo, original.ejemplo);
      expect(reconstruida.nivel, original.nivel);
      expect(reconstruida.vecesCorrectamente, original.vecesCorrectamente);
      expect(reconstruida.vecesIncorrectamente, original.vecesIncorrectamente);
      expect(reconstruida.proximaRevision, original.proximaRevision);
    });
  });
}
