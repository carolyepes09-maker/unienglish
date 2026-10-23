// Si el registro creó la cuenta de Firebase Auth pero falló al guardar el
// perfil en Firestore, la cuenta quedaba inutilizable: no se podía iniciar
// sesión (sin perfil) ni volver a registrarse (correo ya en uso).

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluter_app/services/auth_service.dart';

void main() {
  test('una cuenta sin perfil se repara al restaurar la sesión', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'huerfana', email: 'ana@unilibre.edu.co'),
      signedIn: true,
    );
    final authService = AuthService.forTesting(auth: auth, firestore: firestore);

    await authService.initialize();

    expect(authService.estaAutenticado, isTrue);
    final doc = await firestore.collection('usuarios').doc('huerfana').get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['usuario_id'], 'huerfana');
    expect(doc.data()!['nombre_completo'], 'ana');
    // No aceptó la política en este flujo: se le pedirá al entrar.
    expect(doc.data()!['acepto_politica_datos'], isFalse);
  });
}
