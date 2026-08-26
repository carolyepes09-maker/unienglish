# Auditoría UniEnglish — seguimiento de hallazgos

Checklist de trabajo para la reparación guiada del proyecto. Se actualiza al cerrar cada hallazgo. No forma parte del build ni de la app.

| # | Hallazgo | Estado | Commit | Fecha |
|---|----------|--------|--------|-------|
| 1 | Sin control de versiones (git init) | Resuelto | feaeea8 | 2026-08-26 |
| 2 | Firebase solo configurado para Web (Android/iOS rotos) | En progreso | — | — |
| 3 | Sincronización con pérdida silenciosa de progreso | Pendiente | — | — |
| 4 | "¿Olvidaste tu contraseña?" es un botón muerto | Pendiente | — | — |
| 5 | Bug en el progreso del examen (solo Grammar/Reading) | Pendiente | — | — |
| 6 | Usuario nuevo arranca con estadísticas inventadas | Pendiente | — | — |
| 7 | Documentación desactualizada y contradictoria | Pendiente | — | — |
| 8 | Reglas de Firestore sin validación de esquema | Pendiente | — | — |
| 9 | Manejo de fallos de arranque se anula a sí mismo | Pendiente | — | — |
| 10 | Modelo de datos que no escala (doc único en Firestore) | Pendiente | — | — |
| 11 | Prácticamente cero pruebas automatizadas | Pendiente | — | — |
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
