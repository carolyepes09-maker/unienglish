# Hallazgo 10 — Diagnóstico: modelo de datos que no escala

**Solo diagnóstico y plan por escrito. No se migró nada. No se tocó código ni Firestore.**

## 1. Qué hay hoy

Todo lo del usuario vive en **un único documento** `usuarios/{uid}`:

- Perfil (nombre, correo, nivel, fechas) — pequeño y acotado, esto no es un problema.
- Progreso (`racha_dias`, `tiempo_total_horas`, `habilidades_values`, etc.) — también pequeño y acotado (arrays de longitud fija, 5 y 7 elementos).
- `actividades_recientes` — **ya está acotado en el propio código** a un máximo de 3 entradas (`actividad_service.dart:15`, `_kMaxActividades = 3`). Esta parte del hallazgo, en la práctica, no crece sin control.
- `vocabulario_tarjetas_usuario` + `vocabulario_progreso_tarjetas` — **estos dos SÍ crecen sin límite**: una entrada por cada palabra que el estudiante agregue a su diccionario personal, para siempre, sin ningún tope en el código.

Cada guardado (`actualizarUsuario`, en cualquiera de los tres servicios) reescribe el documento completo vía `set(..., SetOptions(merge: true))`.

## 2. El problema concreto (con números, no solo teoría)

### 2.1 El límite duro de Firestore

Un documento de Firestore no puede superar **1 MiB (1,048,576 bytes)**.

Cada palabra de vocabulario ocupa, entre la tarjeta y su progreso SM-2 (contando los nombres de campo, que Firestore almacena tal cual en cada documento — no los comprime entre documentos):

| Campo | Bytes aprox. |
|---|---|
| tarjeta (`id`, `palabra_termino`, `traduccion_definicion`, `ejemplo_uso`, `fecha_creacion`, `tipo_tarjeta` + nombres de campo) | ~350-450 |
| progreso (`tarjeta_id`, `facilidad`, `intervalo_dias`, `repeticiones`, `proxima_revision`, `total_revisiones`, `total_correctas`, `total_incorrectas` + nombres de campo) | ~200-250 |
| **Total por palabra** | **~600-700 bytes** |

Con el resto del documento (perfil + progreso) ocupando quizás 5-10 KB, queda espacio para aproximadamente:

```
(1,048,576 - 10,000) / 650 ≈ 1,600 palabras por estudiante
```

**No es una emergencia inmediata** (un estudiante típico de un semestre no llega a esa cifra), pero **sí es un techo real y silencioso**: el estudiante más dedicado, o alguien que use la app por varios semestres, puede llegar a acercarse. Y cuando lo golpee, la escritura falla de golpe — sin aviso previo, sin degradación gradual.

### 2.2 El problema que SÍ es real hoy, no solo a futuro

Cada vez que `ProgresoService` o `VocabularioService` sincronizan al abrir la app (`obtenerUsuarioPorId`), **descargan el documento completo** — incluidas las ~1,000+ palabras de vocabulario, si las hay — solo para leer un campo de progreso o comparar un timestamp. Esto ya es ineficiente hoy, no depende de si se llega o no al límite de 1 MiB: más lento para el estudiante, más lecturas/ancho de banda facturado en Firebase de lo necesario.

### 2.3 Lo que NO es un problema (para que quede claro qué sí está bien)

- `actividades_recientes`: acotado en código a 3, no crece.
- Los arrays de progreso (`habilidades_values`, `actividad_semanal`): longitud fija (5 y 7), no crecen.
- Escrituras concurrentes de los 3 servicios en paralelo (se inicializan con `Future.wait` en `main.dart`): cada una hace `merge` sobre campos distintos: Firestore resuelve esto de forma atómica por escritura individual, no se pisan entre sí.

## 3. Plan de migración propuesto (NO ejecutado)

Mover el vocabulario a una subcolección, dejando el resto del documento tal cual:

```
usuarios/{uid}                          <- perfil + progreso (como hoy, sin cambios)
usuarios/{uid}/vocabulario/{tarjetaId}   <- una palabra por documento (tarjeta + su progreso SM-2 juntos)
```

Una subcolección no comparte el límite de 1 MiB con el documento padre — cada tarjeta es su propio documento pequeño, y la colección en sí puede crecer indefinidamente.

### Pasos (en orden, cada uno como un cambio separado y reversible el día que se decida ejecutar esto)

1. **Respaldo completo de Firestore** antes de tocar nada (`gcloud firestore export` o desde la consola de Firebase). Este paso es obligatorio y no negociable antes de escribir una sola línea de este plan.
2. Agregar reglas de seguridad para la subcolección nueva (`match /usuarios/{uid}/vocabulario/{tarjetaId}`), con la misma validación de dueño (`auth.uid == uid`) que ya existe.
3. Migración de datos: por cada usuario, leer `vocabulario_tarjetas_usuario` + `vocabulario_progreso_tarjetas` del documento viejo y escribir cada palabra como un documento nuevo en la subcolección. Puede hacerse:
   - **Con un script de administración** (Firebase Admin SDK, corre una sola vez sobre todos los usuarios), o
   - **De forma perezosa**, en el propio `VocabularioService.initialize()`: si detecta las listas viejas en el documento y la subcolección aún vacía, migra esa cuenta en ese momento y luego borra las listas viejas del documento padre.
4. Reescribir `VocabularioService` para leer/escribir la subcolección en vez de los dos arrays embebidos. Esto cambia bastante su lógica interna (ya no hace falta comparar timestamps del documento completo para el vocabulario -- cada tarjeta se sincroniza sola).
5. Una vez migradas todas las cuentas activas y confirmado que nadie perdió datos, quitar `vocabulario_tarjetas_usuario` / `vocabulario_progreso_tarjetas` del documento padre y de `firestore.rules`.

### Por qué esto no se hizo hoy

Es un cambio de arquitectura de datos, no una corrección puntual: toca el modelo de datos en producción, la lógica de sincronización que ya se corrigió en el hallazgo 3, y necesita una migración de datos reales de usuarios ya existentes con su propio plan de rollback. Encaja mejor como un proyecto aparte, con su propio tiempo dedicado, que como un hallazgo más de esta ronda de reparación.

## 4. Recomendación de prioridad

**No es urgente hoy.** Con el uso actual de la app, ningún usuario está cerca del límite de 1 MiB. Vale la pena revisitar esto si:
- El número de usuarios activos crece de forma sostenida, o
- Alguien reporta lentitud notable al abrir la app (síntoma del problema de la sección 2.2, que ya existe hoy en menor escala), o
- Se acerca al semestre 2-3 de uso continuo por los mismos estudiantes (vocabularios más grandes).
