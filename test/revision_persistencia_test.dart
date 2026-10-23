// El resultado de un repaso debe quedar guardado: antes RevisionService
// escribía en la tarjeta y no en la lista de progreso, así que al recargar
// todas las palabras volvían a "por repasar" y ninguna llegaba a dominada.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluter_app/models/palabra_model.dart';
import 'package:fluter_app/services/auth_service.dart';
import 'package:fluter_app/services/revision_service.dart';
import 'package:fluter_app/services/vocabulario_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'palabras_usuario':
          '[{"id":"u1","palabra_termino":"apple","traduccion_definicion":"manzana"}]',
      'progreso_vocabulario': '[]',
    });
  });

  test('"Lo sabía" persiste y la palabra deja de estar pendiente', () async {
    final vocabulario = VocabularioService(AuthService());
    await vocabulario.precargarLocal();

    final pendientes = await vocabulario.obtenerPalabrasParaRepasar();
    final apple = pendientes.firstWhere((p) => p.id == 'u1');

    RevisionService(palabras: [apple], vocabularioService: vocabulario)
        .responder(true);
    await Future<void>.delayed(Duration.zero);

    final recargada = (await vocabulario.cargarPalabras()).firstWhere(
      (p) => p.id == 'u1',
    );
    expect(recargada.nivel, 1);
    expect(recargada.vecesCorrectamente, 1);
    expect(recargada.necesitaRevision, isFalse);

    // Y sobrevive a un "reinicio" (nueva instancia leyendo SharedPreferences).
    final otraInstancia = VocabularioService(AuthService());
    await otraInstancia.precargarLocal();
    final tras = (await otraInstancia.cargarPalabras()).firstWhere(
      (p) => p.id == 'u1',
    );
    expect(tras.nivel, 1);
    expect(tras.intervaloDias, 1);
  });

  test('también guarda el progreso de las palabras del sistema', () async {
    final vocabulario = VocabularioService(AuthService());
    await vocabulario.precargarLocal();
    final sistema = (await vocabulario.cargarPalabras())
        .where((p) => p.id != 'u1')
        .toList();
    if (sistema.isEmpty) return; // Sin vocabulario base no hay qué probar.

    final palabra = sistema.first..respuestaCorrecta();
    await vocabulario.registrarRespuesta(palabra);

    final recargada = (await vocabulario.cargarPalabras()).firstWhere(
      (p) => p.id == palabra.id,
    );
    expect(recargada.nivel, 1);
  });

  test('la sesión de hoy pone primero las vencidas y limita las nuevas', () {
    PalabraModel palabra(String id, {int repeticiones = 0, int fallos = 0}) =>
        PalabraModel(
          id: id,
          ingles: id,
          espanol: id,
          ejemplo: '',
          repeticiones: repeticiones,
          vecesIncorrectamente: fallos,
          proximaRevision: DateTime.now().subtract(const Duration(days: 1)),
        );

    final palabras = [
      for (var i = 0; i < 30; i++) palabra('nueva$i'),
      palabra('vencida', repeticiones: 2),
      palabra('fallada', fallos: 1),
    ];
    final sesion = VocabularioService.sesionDeHoy(palabras);

    expect(sesion.first.id, 'fallada');
    expect(sesion[1].id, 'vencida');
    expect(
      sesion.where((p) => p.id.startsWith('nueva')).length,
      VocabularioService.maxNuevasPorSesion,
    );
    expect(sesion.length, lessThanOrEqualTo(VocabularioService.maxTarjetasPorSesion));
  });
}
