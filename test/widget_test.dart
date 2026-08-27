// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:fluter_app/main.dart';

void main() {
  testWidgets('UniEnglish app smoke test', (WidgetTester tester) async {
    // El tamaño de superficie por defecto de flutter_test (800x600) es más
    // angosto que cualquier teléfono real y no es el que la pantalla de
    // login espera -- provoca un overflow de layout que no ocurre en un
    // dispositivo real. Se simula un tamaño de teléfono típico para que el
    // test refleje cómo se ve la app de verdad, sin tocar el layout en sí.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const UniEnglishApp());

    // _AppBootstrap muestra primero una pantalla de carga mientras resuelve
    // su FutureBuilder (Firebase.initializeApp() + servicios). En el entorno
    // de test no hay un canal de plataforma real para Firebase, así que esa
    // llamada falla -- pero el propio manejo de errores de
    // _inicializarServicios() (hallazgo 9) la atrapa y construye AuthWrapper
    // de todas formas. Sin este pumpAndSettle, el test solo alcanza a ver esa
    // pantalla de carga inicial, nunca el login.
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed
    expect(find.text('UniEnglish'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
