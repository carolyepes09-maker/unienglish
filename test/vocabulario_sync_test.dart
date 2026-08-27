// Tests de la sincronización por timestamp de VocabularioService
// (hallazgo 3): gana el lado (local vs. Firestore) que tenga la
// modificación más reciente, no simplemente "¿hay algo local?".
//
// Usa fakes de Firebase (firebase_auth_mocks / fake_cloud_firestore) más
// AuthService.forTesting -- ningún test aquí toca un proyecto Firebase real.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluter_app/services/auth_service.dart';
import 'package:fluter_app/services/vocabulario_service.dart';

const _uid = 'usuario-de-prueba';

/// Crea un AuthService independiente (no el singleton global) con sesión ya
/// iniciada como [_uid], respaldado por el Firestore falso que se le pase.
Future<AuthService> _authConSesionFalsa(FakeFirebaseFirestore firestore) async {
  final auth = MockFirebaseAuth(
    mockUser: MockUser(uid: _uid, email: 'ferek@test.com'),
    signedIn: true,
  );
  final authService = AuthService.forTesting(auth: auth, firestore: firestore);
  await authService.initialize(); // Carga _usuarioActualId desde el mock user.
  return authService;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VocabularioService - sincronización por timestamp (hallazgo 3)', () {
    test(
      'un dispositivo con caché vieja NO sobrescribe un vocabulario más nuevo ya guardado en la cuenta',
      () async {
        SharedPreferences.setMockInitialValues({
          // Este "dispositivo" tiene datos locales, pero viejos.
          'palabras_usuario': '[{"id":"1","palabra_termino":"old-word"}]',
          'progreso_vocabulario': '[]',
          'vocabulario_uid': _uid,
          'vocabulario_actualizado_en': DateTime(2020, 1, 1).toIso8601String(),
        });

        final firestore = FakeFirebaseFirestore();
        await firestore.collection('usuarios').doc(_uid).set({
          'vocabulario_tarjetas_usuario': [
            {'id': '2', 'palabra_termino': 'new-word'},
          ],
          'vocabulario_progreso_tarjetas': [],
          // La cuenta tiene algo MÁS RECIENTE que este dispositivo.
          'vocabulario_actualizado_en': DateTime.now().toIso8601String(),
        });

        final authService = await _authConSesionFalsa(firestore);
        final vocabularioService = VocabularioService(authService);
        await vocabularioService.initialize();

        final palabras = await vocabularioService.cargarPalabras();
        expect(
          palabras.any((p) => p.ingles == 'new-word'),
          isTrue,
          reason: 'debió traer el vocabulario más reciente de la cuenta',
        );
        expect(
          palabras.any((p) => p.ingles == 'old-word'),
          isFalse,
          reason:
              'no debió quedarse con la caché vieja de este dispositivo',
        );
      },
    );

    test(
      'un dispositivo con datos más nuevos SÍ los sube, sin que la cuenta (más vieja) los pise',
      () async {
        SharedPreferences.setMockInitialValues({
          'palabras_usuario': '[{"id":"1","palabra_termino":"new-word"}]',
          'progreso_vocabulario': '[]',
          'vocabulario_uid': _uid,
          // Este dispositivo tiene lo más reciente.
          'vocabulario_actualizado_en': DateTime.now().toIso8601String(),
        });

        final firestore = FakeFirebaseFirestore();
        await firestore.collection('usuarios').doc(_uid).set({
          'vocabulario_tarjetas_usuario': [
            {'id': '2', 'palabra_termino': 'old-word'},
          ],
          'vocabulario_progreso_tarjetas': [],
          // La cuenta tiene algo más VIEJO que este dispositivo.
          'vocabulario_actualizado_en': DateTime(2020, 1, 1).toIso8601String(),
        });

        final authService = await _authConSesionFalsa(firestore);
        final vocabularioService = VocabularioService(authService);
        await vocabularioService.initialize();

        final doc = await firestore.collection('usuarios').doc(_uid).get();
        final tarjetas = doc.data()!['vocabulario_tarjetas_usuario'] as List;
        expect(
          tarjetas.any((t) => t['palabra_termino'] == 'new-word'),
          isTrue,
          reason: 'debió subir el vocabulario más reciente del dispositivo',
        );
        expect(
          tarjetas.any((t) => t['palabra_termino'] == 'old-word'),
          isFalse,
          reason: 'no debió quedarse con el dato viejo que ya había en la cuenta',
        );
      },
    );

    test(
      'una cuenta recién creada (sin timestamp en ningún lado) no falla y no inventa datos',
      () async {
        SharedPreferences.setMockInitialValues({});

        final firestore = FakeFirebaseFirestore();
        await firestore.collection('usuarios').doc(_uid).set({
          'nombre_completo': 'Cuenta nueva',
        }); // Sin campos de vocabulario todavía.

        final authService = await _authConSesionFalsa(firestore);
        final vocabularioService = VocabularioService(authService);
        await vocabularioService.initialize();

        final palabras = await vocabularioService.cargarPalabras();
        // Solo debe tener el vocabulario del sistema (palabras.json), nada
        // de usuario inventado.
        expect(palabras.every((p) => p.vecesCorrectamente == 0), isTrue);
      },
    );
  });
}
