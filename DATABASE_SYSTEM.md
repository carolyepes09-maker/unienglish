# Sistema de Base de Datos Local con JSON

## 📋 Resumen Ejecutivo

Has implementado un sistema simple de "base de datos" usando archivos JSON donde:
- **Se guarda**: Todos los usuarios (iniciales + nuevos registrados)
- **Se consulta**: El mismo archivo para login y validación
- **Se persiste**: Entre cierres y reaperturas de la app

---

## 🗂️ Estructura de Carpetas

```
Tu Proyecto
└── assets/
    └── data/
        └── usuarios.json ← Datos iniciales (LECTURA SOLO)
```

**Durante ejecución (en el dispositivo/emulador):**

```
/data/user/0/com.example.fluter_app/app_flutter/
├── app_data/
│   └── usuarios.json ← Base de datos EDITABLE (aquí guarda cambios)
└── usuarios_guardados/ (después de exportar)
    └── usuarios.json ← Copia visible exportada
```

---

## 🔄 Flujo de Datos Paso a Paso

### 1️⃣ **Al iniciar la app** (initialize())

```dart
// En main.dart - AuthService.initialize()
```

**Proceso:**
1. Lee `assets/data/usuarios.json` → Carga 2 usuarios iniciales
2. Crea carpeta `app_data/` en documentos si no existe
3. Busca archivo `app_data/usuarios.json`
   - ✅ Si existe: Carga usuarios adicionales del archivo
   - ❌ Si NO existe: Crea el archivo con los 2 usuarios iniciales
4. Fusiona ambas listas (sin duplicados)
5. Carga usuario autenticado desde SharedPreferences (si existe)

**Salida en consola:**
```
📁 Carpeta de datos: /data/user/0/com.example.fluter_app/app_flutter/app_data
📄 Base de datos: /data/user/0/com.example.fluter_app/app_flutter/app_data/usuarios.json
📄 Usuarios cargados desde assets: 2
✅ Base de datos guardada en: /data/user/0/com.example.fluter_app/app_flutter/app_data/usuarios.json
📊 Total usuarios en base de datos: 2
👤 Usuario logueado: null
```

---

### 2️⃣ **Cuando registras un nuevo usuario** (registrarUsuario())

```dart
// En login_screen.dart - al hacer tap en "Registrarse"
final resultado = await _authService.registrarUsuario(
  email: "nuevo@example.com",
  password: "123456",
  nombreCompleto: "Juan Pérez"
);
```

**Proceso:**
1. Valida que email, password y nombre no estén vacíos
2. Verifica que el email no exista en la lista
3. Crea nuevo usuario con UUID único y campos iniciales
4. **Agrega a la lista en memoria** (_usuarios.add())
5. **Guarda TODA la lista** en `app_data/usuarios.json`
6. Retorna `{'success': true, 'usuario_id': 'uuid-del-nuevo'}`

**Cambio en archivo usuarios.json:**
```json
// ANTES (2 usuarios):
[
  { "usuario_id": "550e8400-...", "nombre_completo": "Test User", ... },
  { "usuario_id": "550e8400-...", "nombre_completo": "María García", ... }
]

// DESPUÉS (3 usuarios):
[
  { "usuario_id": "550e8400-...", "nombre_completo": "Test User", ... },
  { "usuario_id": "550e8400-...", "nombre_completo": "María García", ... },
  { "usuario_id": "xyz123-...", "nombre_completo": "Juan Pérez", "fecha_registro": "2024-04-21T..." }
]
```

**Salida en consola:**
```
✅ Base de datos guardada en: /data/user/0/com.example.fluter_app/app_flutter/app_data/usuarios.json
📊 Total usuarios en base de datos: 3
```

---

### 3️⃣ **Cuando inicias sesión** (iniciarSesion())

```dart
// En login_screen.dart - al hacer tap en "Entrar"
final resultado = await _authService.iniciarSesion(
  email: "nuevo@example.com",
  password: "123456"
);
```

**Proceso:**
1. Busca usuario en la lista `_usuarios` con email y password
2. Si encuentra: 
   - Guarda usuario_id en SharedPreferences
   - Actualiza `ultima_conexion` en la lista
   - **Guarda la lista actualizada** en el archivo
   - Retorna `{'success': true, 'usuario_id': 'xyz123-...'}`
3. Si no encuentra:
   - Retorna `{'success': false, 'error': 'Email o contraseña incorrectos'}`

---

### 4️⃣ **Al cerrar la app y reabrir**

**Proceso:**
1. App se cierra → variables en memoria se pierden
2. App se reabre → corre initialize() nuevamente
3. Lee `assets/data/usuarios.json` → 2 usuarios iniciales
4. Lee `app_data/usuarios.json` → 3 usuarios guardados
5. Fusiona y obtiene lista completa de 3 usuarios ✅

**Resultado:** El usuario nuevo se encuentra en la lista y puede iniciar sesión

---

## 📝 Métodos Principales del AuthService

### Lectura y Escritura

```dart
// Obtener la ruta del archivo de base de datos
String getUsuariosPath() 
// Retorna: /data/user/0/com.example.fluter_app/app_flutter/app_data/usuarios.json

// Guardar la base de datos (se llama automáticamente)
Future<void> _guardarUsuariosLocal()
// Guarda TODOS los usuarios en el archivo

// Exportar a una carpeta visible
Future<String?> exportarBaseDatos()
// Copia el archivo a: /data/user/0/com.example.fluter_app/app_flutter/usuarios_guardados/usuarios.json

// Ver el contenido como string
Future<String> obtenerContenidoBaseDatos()
// Retorna el JSON formateado como texto
```

---

## ✅ Ventajas de este sistema

| Aspecto | Ventaja |
|--------|---------|
| **Visibilidad** | Puedes ver exactamente dónde se guardan los datos |
| **Persistencia** | Los datos se guardan en archivo, no se pierden al cerrar la app |
| **Simplicidad** | No necesitas servidor, todo es local |
| **Portabilidad** | El archivo JSON es portable, puedes inspeccionarlo |
| **Debugging** | Los logs muestran exactamente qué está pasando |
| **Educación** | Perfecto para mostrar a tu profesor cómo funciona |

---

## 🐛 Cómo verificar que funciona

### Test 1: Verificar que los datos se guardan

1. Abre la app
2. Registra un nuevo usuario:
   - Email: `test123@example.com`
   - Password: `123456`
   - Nombre: `Test User 123`
3. Verifica en los logs que aparezca:
   ```
   ✅ Base de datos guardada en: /data/user/0/com.example.fluter_app/app_flutter/app_data/usuarios.json
   📊 Total usuarios en base de datos: 3
   ```

### Test 2: Verificar que se persisten después de reinicio

1. Registra un nuevo usuario (como en Test 1)
2. Presiona `q` en la terminal para cerrar la app
3. Ejecuta `flutter run` nuevamente
4. En los logs deberías ver:
   ```
   📄 Usuarios cargados desde assets: 2
   💾 Usuarios cargados desde archivo: 1
   📊 Total usuarios en base de datos: 3
   ```
5. Intenta iniciar sesión con `test123@example.com` / `123456`
6. ✅ Debería funcionar

### Test 3: Exportar y ver el archivo

1. Desde la app (o agregando un botón), llama:
   ```dart
   await _authService.exportarBaseDatos();
   ```
2. El archivo se copia a:
   ```
   /data/user/0/com.example.fluter_app/app_flutter/usuarios_guardados/usuarios.json
   ```
3. Descarga con adb:
   ```bash
   adb pull /data/user/0/com.example.fluter_app/app_flutter/usuarios_guardados/usuarios.json ./usuarios.json
   ```
4. Abre `usuarios.json` en tu editor de código

---

## 🔧 Cómo mostrar esto a tu profesor

### Opción 1: Mostrar el código

1. Abre `lib/services/auth_service.dart`
2. Muestra estos métodos:
   - `initialize()` - Carga datos al iniciar
   - `registrarUsuario()` - Guarda nuevo usuario
   - `_guardarUsuariosLocal()` - Guarda en archivo
   - `iniciarSesion()` - Consulta el archivo

### Opción 2: Mostrar los logs

1. Ejecuta `flutter run`
2. Registra un usuario
3. Muestra los logs en consola que dicen:
   - Dónde se guardan los datos
   - Cuántos usuarios hay en la base de datos
   - Confirmación de guardado

### Opción 3: Mostrar el archivo físico

1. Ejecuta `_authService.exportarBaseDatos()`
2. Descarga el archivo con:
   ```bash
   adb pull /data/user/0/com.example.fluter_app/app_flutter/usuarios_guardados/usuarios.json ./usuarios.json
   ```
3. Abre `usuarios.json` en VS Code
4. Muestra que contiene los 2 iniciales + cualquier nuevo

### Opción 4: Pantalla de depuración

Agrega un botón en tu app que abre `TestDatabaseScreen`:
- Muestra la ubicación del archivo
- Muestra el contenido JSON actual
- Botón para exportar
- Explicación de cómo funciona

---

## 📂 Árbol de archivos relevantes

```
lib/
├── main.dart
│   └── AuthService.initialize() en initState
├── services/
│   └── auth_service.dart ← AQUÍ ESTÁ LA LÓGICA
│       ├── initialize()
│       ├── registrarUsuario()
│       ├── iniciarSesion()
│       ├── _cargarUsuariosDesdeJSON()
│       ├── _cargarUsuariosDelArchivo()
│       ├── _guardarUsuariosLocal()
│       ├── exportarBaseDatos()
│       └── obtenerContenidoBaseDatos()
├── screens/
│   ├── login_screen.dart
│   │   └── Llama a registrarUsuario() e iniciarSesion()
│   └── test_database_screen.dart ← PANTALLA DE PRUEBA
└── ...

assets/
└── data/
    └── usuarios.json ← 2 usuarios iniciales

En el dispositivo/emulador:
/data/user/0/com.example.fluter_app/app_flutter/
├── app_data/usuarios.json ← Base de datos que crece
└── usuarios_guardados/usuarios.json ← Copia exportada
```

---

## 🎯 Conclusión

Has implementado exitosamente un sistema de "base de datos" JSON que:
- ✅ Lee datos iniciales desde `assets/data/usuarios.json`
- ✅ Guarda nuevos usuarios en `app_data/usuarios.json`
- ✅ Persiste datos entre cierres de la app
- ✅ Permite consultar usuarios para login
- ✅ Muestra logs claros de cada operación
- ✅ Es educativo y fácil de entender

**Próximos pasos:**
1. Prueba registrando un usuario
2. Cierra la app y reabre
3. Intenta login con el usuario nuevo
4. Exporta el archivo para mostrarlo a tu profesor
