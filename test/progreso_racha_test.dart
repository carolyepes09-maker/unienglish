// La racha, el tiempo y la actividad semanal salen de fechas reales:
// antes la racha subía +1 por cada repaso (5 repasos = "5 días"), cada
// sesión sumaba 1 hora fija y toda la actividad caía en el domingo.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluter_app/services/progreso_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DateTime ahora;

  setUp(() async {
    // Miércoles 14 de octubre de 2026, 10:00.
    ahora = DateTime(2026, 10, 14, 10);
    ProgresoService.reloj = () => ahora;
    SharedPreferences.setMockInitialValues({});
    await ProgresoService().initialize();
  });

  tearDown(() => ProgresoService.reloj = DateTime.now);

  test('varias sesiones el mismo día cuentan como 1 día de racha', () {
    final progreso = ProgresoService();
    progreso.registrarRevision(3);
    progreso.registrarRevision(5);
    progreso.registrarRevision(1);
    expect(progreso.rachaDias, 1);
  });

  test('días seguidos suman racha; saltarse un día la reinicia', () {
    final progreso = ProgresoService();
    progreso.registrarRevision(1);
    ahora = ahora.add(const Duration(days: 1));
    progreso.registrarRevision(1);
    ahora = ahora.add(const Duration(days: 1));
    progreso.registrarRevision(1);
    expect(progreso.rachaDias, 3);

    // Pasan dos días sin estudiar: la racha ya se ve rota...
    ahora = ahora.add(const Duration(days: 2));
    expect(progreso.rachaDias, 0);
    // ...y la siguiente sesión empieza de nuevo en 1.
    progreso.registrarRevision(1);
    expect(progreso.rachaDias, 1);
  });

  test('el tiempo es el medido, no 1 hora fija por sesión', () {
    final progreso = ProgresoService();
    progreso.registrarRevision(1, duracion: const Duration(minutes: 20));
    progreso.registrarRevision(1, duracion: const Duration(minutes: 45));
    expect(progreso.tiempoMesMinutos, 65);
    expect(progreso.tiempoTotalHoras, 1);
  });

  test('la actividad cae en el día real y se reinicia con la semana', () {
    final progreso = ProgresoService();
    progreso.registrarRevision(1, duracion: const Duration(minutes: 30));
    // Miércoles = posición 2 (L, M, X...).
    expect(progreso.actividadSemanal[2], 30);
    expect(progreso.actividadSemanal[6], 0);

    // Lunes de la semana siguiente: la semana anterior ya no se muestra.
    ahora = DateTime(2026, 10, 19, 9);
    expect(progreso.actividadSemanal.every((m) => m == 0), isTrue);
  });

  test('las habilidades también bajan si el rendimiento baja', () {
    final progreso = ProgresoService();
    progreso.registrarExamen({'grammar': 4}, {'grammar': 4});
    final tras100 = progreso.habilidadesValues[0];
    progreso.registrarExamen({'grammar': 0}, {'grammar': 4});
    expect(progreso.habilidadesValues[0], lessThan(tras100));
  });

  test('una lección perfecta llena parte de la barra de nivel', () {
    final progreso = ProgresoService();
    final antes = progreso.progresoHaciaSiguienteNivel;
    progreso.completarLeccion(porcentaje: 1.0, habilidad: 'Grammar');
    expect(progreso.progresoHaciaSiguienteNivel, greaterThan(antes));
    expect(progreso.leccionesCompletadas, 1);
  });
}
