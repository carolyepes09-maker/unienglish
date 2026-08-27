# Auditoría UniEnglish — seguimiento de hallazgos

Checklist de trabajo para la reparación guiada del proyecto. Se actualiza al cerrar cada hallazgo. No forma parte del build ni de la app.

| # | Hallazgo | Estado | Commit | Fecha |
|---|----------|--------|--------|-------|
| 1 | Sin control de versiones (git init) | Resuelto | feaeea8 | 2026-08-26 |
| 2 | Firebase solo configurado para Web (Android/iOS rotos) | Resuelto | 34fbe67, 31f73d2 | 2026-08-26 |
| 3 | Sincronización con pérdida silenciosa de progreso | Resuelto | c38ed13 | 2026-08-26 |
| 4 | "¿Olvidaste tu contraseña?" es un botón muerto | Resuelto | 7617789 | 2026-08-26 |
| 5 | Bug en el progreso del examen (solo Grammar/Reading) | Resuelto | 197cbf0 | 2026-08-26 |
| 6 | Usuario nuevo arranca con estadísticas inventadas | Resuelto | 0a6f339 | 2026-08-26 |
| 7 | Documentación desactualizada y contradictoria | Resuelto | ff183e9, 7368243 | 2026-08-26 |
| 8 | Reglas de Firestore sin validación de esquema | Escrito, sin desplegar | 311e5a2 | 2026-08-26 |
| 9 | Manejo de fallos de arranque se anula a sí mismo | Resuelto (con corrección) | 3a08f5f, efa4357 | 2026-08-26 |
| 10 | Modelo de datos que no escala (doc único en Firestore) | Diagnosticado (ver MIGRACION_DATOS.md) | — | 2026-08-27 |
| 11 | Prácticamente cero pruebas automatizadas | Resuelto | 82783cf, c19b282, 7615a92, 496041f, a13f3a5 | 2026-08-26 |
| 12 | Pantallas gigantes (login_screen.dart, etc.) | Pendiente | — | — |
| 13 | print() en vez de logging real | Pendiente | — | — |
| 14 | Rutas nombradas muertas en main.dart | Pendiente | — | — |
| 15 | Archivos de log viejos en la raíz | Pendiente | — | — |
| 16 | Warnings de lint acumulados (withOpacity, etc.) | Pendiente | — | — |

## Decisiones ya tomadas con Ferek

- Plataformas: Android e iOS sí deben soportarse de verdad (proyecto Firebase correcto: `unienglish1-54948`).
- Identificador de app definitivo: `com.unilibre.unienglish` (Android package name + iOS bundle id).
- Hallazgo 6: valores en cero solo para cuentas **nuevas**; las cuentas ya existentes se dejan tal cual están.
- Hallazgo 3: estrategia de "gana el más reciente" comparando timestamps (no merge completo).

## Notas del hallazgo 11 (tests)

- `test/widget_test.dart` ya fallaba desde el commit inicial (buscaba el login sin esperar el
  `FutureBuilder` de `_AppBootstrap`) -- reparado en a13f3a5, junto con un `RenderFlex overflow`
  preexistente en `login_screen.dart:767` que solo aparecía por el tamaño de superficie por defecto
  de `flutter_test` (se fijó el tamaño del test a uno de teléfono real, sin tocar el layout).
- Se agregó `AuthService.forTesting()` (auth_service.dart) para poder inyectar fakes de Firebase en
  pruebas, autorizado por Ferek. `VocabularioService` ya soportaba inyección de `AuthService` por
  constructor, así que su lógica de sincronización (hallazgo 3) quedó cubierta con tests reales.
- **Limitación conocida**: `ProgresoService` sigue siendo un singleton sin punto de inyección (llama
  directamente a `AuthService()`, no a una instancia inyectada), así que su propia lógica de
  sincronización por timestamp (la mitad del hallazgo 3 que vive en `progreso_service.dart`, en vez de
  en `vocabulario_service.dart`) no tiene test automatizado -- solo la prueba manual que ya se hizo al
  cerrar el hallazgo 3. Convertir `ProgresoService` a un patrón inyectable como `VocabularioService`
  quedaría como trabajo futuro si se quiere cerrar esa brecha.
- Se corrigió durante este hallazgo un bug real introducido en el propio arreglo del hallazgo 9 (ver
  fila 9 de la tabla y el commit efa4357) -- encontrado al planear estos tests, no algo que un test
  automatizado haya atrapado todavía.
