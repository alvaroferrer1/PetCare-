# PetCare AI Companion

<div align="center">

**Aplicacion movil para organizar el cuidado de mascotas con Flutter, Supabase e IA.**

Proyecto final del modulo **Desarrollo Vibe Coding**.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)

</div>

---

## Descripcion

**PetCare AI Companion** es una app movil pensada para ayudar a duenos de perros y gatos a centralizar la informacion importante sobre el cuidado de sus mascotas.

La aplicacion permite registrar mascotas, guardar historial de cuidados, anadir notas de salud, consultar recordatorios pendientes y revisar informacion orientativa sobre alimentos seguros, peligrosos o toxicos.

Tambien incluye un asistente con IA que resume el historial de la mascota, organiza prioridades y prepara preguntas utiles para el veterinario.

> La IA no diagnostica, no recomienda medicamentos ni sustituye a un profesional veterinario.

---

## Problema Que Resuelve

Muchas personas gestionan la informacion de sus mascotas de forma dispersa: notas del movil, conversaciones, papeles del veterinario o memoria.

Esto puede provocar:

- Olvidar vacunas, medicaciones o revisiones.
- No tener a mano el historial cuando se visita al veterinario.
- Confundirse con alimentos seguros o toxicos.
- No detectar patrones importantes en sintomas o comportamiento.

PetCare AI Companion propone una solucion sencilla, visual y mantenible para organizar esa informacion en un unico lugar.

---

## Objetivos Del Proyecto

- Crear un MVP funcional y demostrable.
- Usar base de datos real con Supabase.
- Implementar autenticacion con email y contrasena.
- Aplicar arquitectura clara y mantenible.
- Integrar APIs externas de perros y gatos.
- Usar IA de forma responsable y limitada.
- Cubrir funcionalidades clave con tests.
- Preparar el proyecto para una defensa academica y portfolio profesional.

---

## Stack Tecnico

| Area | Tecnologia |
| --- | --- |
| App movil | Flutter 3.x |
| Lenguaje | Dart 3.8+ |
| Backend / BBDD | Supabase |
| Autenticacion | Supabase Auth (JWT) |
| Base de datos | PostgreSQL |
| IA | OpenAI API (gpt-4-mini) via Edge Functions |
| APIs externas | Dog CEO API, The Cat API, Open Pet Food Facts |
| Arquitectura | MVC + Repositories + Services |
| State Management | Riverpod 2.6+ |
| Testing | Unit tests, widget tests, integration tests |
| Control de versiones | Git + GitHub |

### APIs Externas Utilizadas

| API | Propósito | Documentación |
|-----|-----------|---|
| **OpenAI API** | Generación de resúmenes IA inteligentes | https://platform.openai.com/docs/api-reference |
| **Dog CEO API** | Razas de perros e imágenes | https://dog.ceo/dog-api/ |
| **The Cat API** | Razas de gatos e imágenes | https://thecatapi.com/ |
| **Open Pet Food Facts** | Seguridad alimentaria para mascotas | https://world.openpetfoodfacts.org/api/ |
| **Supabase REST API** | CRUD de base de datos | https://supabase.com/docs/guides/api |

---

## Funcionalidades Principales

### Autenticacion

- Registro con email y contrasena.
- Inicio de sesion.
- Perfil del dueno.
- Cierre de sesion seguro.

### Mascotas

- Crear mascotas.
- Editar mascotas.
- Eliminar mascotas.
- Ver detalle de cada mascota.
- Asociar nombre, especie, raza, fecha de nacimiento, peso, foto y notas.

### Historial De Cuidados

Eventos asociados a una mascota:

- Vacunas.
- Visitas veterinarias.
- Medicacion.
- Alimentacion.
- Peluqueria / grooming.
- Desparasitacion.
- Otros cuidados.

Cada evento puede estar en estado:

- Pendiente.
- Completado.
- Cancelado.

### Notas De Salud

Registro de:

- Sintomas.
- Estado de animo.
- Apetito.
- Nivel de energia.
- Notas libres.
- Fecha de la nota.

### Recordatorios

- Lista de cuidados pendientes.
- Ordenacion por fecha.
- Marcado rapido como completado.

### Food Safety

Buscador de alimentos para perros y gatos usando una tabla local en Supabase.

El sistema indica:

- Nombre del alimento.
- Especie.
- Nivel de seguridad.
- Descripcion.
- Fuente.

Niveles:

- `safe`: seguro.
- `caution`: precaucion.
- `toxic`: toxico.
- `unknown`: desconocido.

> Esta informacion es orientativa. Ante sintomas o ingestion peligrosa, contacta con un veterinario.

### APIs De Razas E Imagenes

- **Dog CEO API** para imagenes y razas de perros.
- **The Cat API** para imagenes y razas de gatos.
- Fallback manual si una API externa falla.

### Asistente IA

Boton: **Generar resumen de cuidados**

La IA recibe:

- Datos de la mascota.
- Eventos recientes.
- Notas de salud.
- Recordatorios pendientes.

Devuelve un JSON estructurado:

```json
{
  "summary": "",
  "priorities": [],
  "vet_questions": [],
  "general_recommendations": [],
  "safety_notice": ""
}
```

Reglas:

- No diagnosticar.
- No sustituir al veterinario.
- No recomendar medicamentos ni dosis.
- Recomendar consulta veterinaria ante sintomas preocupantes.
- Guardar el resultado en Supabase.

---

## Arquitectura

El proyecto sigue una arquitectura **MVC** reforzada con capas de repositorio y servicios.

```txt
lib/
  main.dart
  app.dart

  core/
    config/
    constants/
    errors/
    theme/
    widgets/

  models/
    ai_summary_model.dart
    care_event_model.dart
    food_safety_item_model.dart
    health_note_model.dart
    pet_model.dart
    profile_model.dart

  views/
    ai_assistant/
    auth/
    care_events/
    food_safety/
    health_notes/
    home/
    onboarding/
    pets/
    profile/

  controllers/
    ai_controller.dart
    auth_controller.dart
    care_event_controller.dart
    food_safety_controller.dart
    health_note_controller.dart
    pet_controller.dart
    profile_controller.dart

  repositories/
    ai_summary_repository.dart
    auth_repository.dart
    care_event_repository.dart
    food_safety_repository.dart
    health_note_repository.dart
    pet_repository.dart
    profile_repository.dart

  services/
    cat_api_service.dart
    dog_api_service.dart
    openai_service.dart
    supabase_service.dart

  routes/
    app_router.dart
```

---

## Modelo De Datos

Tablas previstas en Supabase:

- `profiles`
- `pets`
- `care_events`
- `health_notes`
- `food_safety_items`
- `ai_summaries`

Relaciones principales:

```txt
profiles 1 -> N pets
pets 1 -> N care_events
pets 1 -> N health_notes
pets 1 -> N ai_summaries
```

Seguridad:

- Claves primarias UUID.
- Relaciones por `user_id` y `pet_id`.
- Campos `created_at` y `updated_at`.
- Row Level Security para que cada usuario acceda solo a sus datos.

---

## Variables De Entorno

El proyecto usara un archivo `.env` local.

Ejemplo:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
THE_CAT_API_KEY=your_cat_api_key_optional
```

> El archivo `.env` no debe subirse a GitHub.

La clave de OpenAI debe configurarse como secreto de Supabase para la Edge Function:

```bash
supabase secrets set OPENAI_API_KEY=your_openai_api_key
```

---

## 🚀 Instalacion Y Ejecucion

### Prerequisitos Requeridos

**Software:**
- Flutter SDK 3.x+ ([Descargar](https://flutter.dev/docs/get-started/install))
- Git ([Descargar](https://git-scm.com/))
- Un navegador o emulador (Android Studio / Xcode)

**Cuentas:**
- GitHub (para clonar el repositorio)
- Supabase ([Crear cuenta gratis](https://supabase.com))
- OpenAI ([Crear API key](https://platform.openai.com))

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/alvaroferrer1/PetCare-.git
cd PetCare-
```

### Paso 2: Instalar Dependencias Flutter

```bash
# Obtiene todas las dependencias del pubspec.yaml
flutter pub get

# Verifica que Flutter esté correctamente instalado
flutter doctor
```

El output de `flutter doctor` debería mostrar:
- ✓ Flutter SDK
- ✓ Dart SDK
- ✓ (Opcional) Android Studio o Xcode

### Paso 3: Configurar Variables de Entorno (.env)

**Crear archivo `.env` en la raíz del proyecto:**

```bash
# Windows (PowerShell)
copy .env.example .env

# macOS/Linux
cp .env.example .env
```

**Editar `.env` con credenciales de Supabase:**

```env
# Obtén estas de https://supabase.com (Settings > API)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Opcional: The Cat API (funciona sin ella)
THE_CAT_API_KEY=live_abc123def456...
```

### Paso 4: Configurar Supabase (Base de Datos)

1. Crea un proyecto en [supabase.com](https://supabase.com)
2. Ve a **SQL Editor**
3. Ejecuta `supabase/schema.sql` para crear tablas:
   ```sql
   -- Copiar contenido completo de supabase/schema.sql
   -- y ejecutar en SQL Editor
   ```
4. Ejecuta `supabase/seed.sql` para poblar datos de alimentos:
   ```sql
   -- Copiar contenido de supabase/seed.sql
   ```
5. Configura **Row Level Security (RLS)** en Supabase:
   - Ve a Auth > Policies
   - Asegúrate de que cada tabla tenga políticas RLS habilitadas

### Paso 5: Ejecutar la Aplicación

**Opción A: En Emulador/Dispositivo Android**
```bash
flutter run
```

**Opción B: En Navegador Web**
```bash
flutter run -d chrome
# o
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

**Opción C: En iOS (solo macOS)**
```bash
cd ios && pod install && cd ..
flutter run -d "iPhone 15"
```

### Verificación y Pruebas

```bash
# Análisis estático de código
flutter analyze

# Ejecutar todos los tests
flutter test

# Tests con output detallado
flutter test -r expanded

# Compilar para web (verifica todo)
flutter build web
```

### Build para Distribución

```bash
# APK para Android
flutter build apk --release

# App para iOS
flutter build ios --release

# Web (puedes hostear en cualquier servidor HTTP)
flutter build web --release
```

### Troubleshooting

| Problema | Solución |
|----------|----------|
| `flutter: command not found` | Agrega Flutter a PATH (ver [docs](https://flutter.dev/docs/get-started/install)) |
| Error de pubspec.lock | `flutter clean && flutter pub get` |
| Imágenes de razas no cargan | Verifica conexión a internet / APIs tienen fallback offline |
| Error "Unauthorized" en Supabase | Revisa SUPABASE_URL y SUPABASE_ANON_KEY en .env |
| Tests fallan | `flutter clean && flutter pub get && flutter test` |
| Hot reload no funciona | Reinicia: `flutter clean && flutter run` |

---

## 🎯 Decisiones Técnicas

### ¿Por qué Flutter?

Flutter fue elegido sobre React Native, Kotlin nativo o Swift porque:

✅ **Multiplataforma**: Una base de código para Android, iOS, Web y Desktop (90%+ código compartido)
✅ **Performance**: Compilación nativa que iguala a código Swift/Kotlin
✅ **Development Experience**: Hot reload para iteración rápida
✅ **UI/UX**: Material Design 3 de serie con componentes de alta calidad
✅ **Comunidad**: Activa, con excelente documentación y soporte de Google

### ¿Por qué Supabase sobre Firebase?

| Criterio | Razón |
|----------|-------|
| **Base de Datos** | PostgreSQL permite relaciones complejas (1-N) mejor que Firestore |
| **Control** | Open source, opción de self-hosting para mayor control |
| **Seguridad** | Row Level Security nativo de PostgreSQL más poderoso |
| **Predicibilidad** | Precios basados en recursos, no en operaciones |
| **SQL** | Acceso a SQL completo para queries complejas |

### Alternativas Consideradas

- ❌ Firebase: Menos flexible para datos relacionales
- ❌ Node.js + Express: Mayor complejidad innecesaria
- ❌ Django/Python: Backend pesado no necesario para MVP
- ✅ **Supabase**: El balance perfecto entre simplicidad y potencia

### Mejoras Futuras Planificadas

**Fase 2 - UI/UX**
- 📅 Calendario visual de eventos
- 📊 Gráficos de tendencias de salud
- 🔔 Notificaciones push (Android & iOS)
- 📤 Exportar historial a PDF

**Fase 3 - Funcionalidad**
- 👨‍👩‍👧 Modo familiar (múltiples usuarios)
- 🏥 Directorio de veterinarios
- 📄 Almacenamiento de documentos (radiografías, análisis)
- 🌍 Soporte multiidioma

**Fase 4 - Integración**
- 🤖 Chat bidireccional con IA
- ⌚ Integración con wearables
- 🏢 Panel para veterinarios
- 📱 Sincronización multi-dispositivo

---

## 🤖 Herramientas de Vibe Coding Utilizadas

Este proyecto fue desarrollado de forma completamente asistida por IA mediante:

### GitHub Copilot en VS Code
- ✅ Generación de estructura de archivos y carpetas
- ✅ Implementación de controllers y servicios
- ✅ Creación de modelos de datos
- ✅ Generación de tests unitarios
- ✅ Documentación de código
- ✅ Debugging y optimización

### Técnicas de Prompt Engineering Aplicadas
1. **Especificación de Arquitectura**: Describir patrón MVC detalladamente
2. **Definición de Contratos**: Interfaces y métodos esperados
3. **Context Injection**: Proporcionar código existente para mantener consistencia
4. **Iteración**: Refinamiento gradual de respuestas
5. **Test-First**: Escribir tests antes del código

### Flujo de Desarrollo Vibe Coding
```
1. Requerimiento en lenguaje natural
   ↓
2. Generación de estructura (Copilot)
   ↓
3. Implementación de lógica (Copilot)
   ↓
4. Creación de tests (Copilot)
   ↓
5. Validación manual
   ↓
6. Refinamiento con feedback
```

---

## Testing

El proyecto incluira:

- Tests unitarios para modelos, validaciones y servicios.
- Widget tests para pantallas y componentes principales.
- Integration tests para flujos completos.

Flujos clave a validar:

- Registro e inicio de sesion.
- Crear y editar mascota.
- Crear eventos de cuidado.
- Registrar notas de salud.
- Buscar alimentos.
- Generar resumen IA.
- Marcar recordatorios como completados.

---

## Roadmap

### MVP

- Autenticacion.
- Perfil del dueno.
- Gestion de perros y gatos.
- Historial de cuidados.
- Notas de salud.
- Recordatorios.
- Food Safety.
- APIs externas de imagenes/razas.
- Asistente IA mediante Edge Function.
- Tests principales.

### Futuras Mejoras

- Soporte para mas especies.
- Subida de documentos veterinarios.
- Calendario visual.
- Exportacion de historial en PDF.
- Modo multiusuario familiar.
- Notificaciones push.
- Panel avanzado para veterinario.

---

---

## Estado Del Proyecto

✅ **MVP COMPLETADO Y FUNCIONAL**

El proyecto se encuentra en estado productivo con todas las funcionalidades principales implementadas:

### Completado ✅
1. ✅ Setup Flutter y arquitectura MVC
2. ✅ Supabase y autenticación JWT
3. ✅ CRUD de mascotas (perros y gatos)
4. ✅ Historial de cuidados
5. ✅ Notas de salud
6. ✅ Recordatorios inteligentes
7. ✅ Food Safety (base de alimentos seguros/tóxicos)
8. ✅ APIs externas (razas e imágenes)
9. ✅ Asistente IA con OpenAI
10. ✅ Tests (unit tests + widget tests)
11. ✅ Documentación técnica completa

### Rama: `incio` (Main)
- Última versión estable y funcional
- Todos los commits validados
- Listo para producción

### Rama: `medio` (Development)
- Rama de desarrollo
- Cambios experimentales

---

## 📚 Documentación Completa

Para documentación técnica exhaustiva, ver:
- [DOCUMENTACION_COMPLETA.md](DOCUMENTACION_COMPLETA.md) - Guía técnica detallada
- Decisiones técnicas
- Diagramas de arquitectura
- Flujos de interacción
- Instrucciones avanzadas

---

## Autor

Proyecto desarrollado por **Alvaro Ferrer** como entrega final del módulo **Desarrollo Vibe Coding**.

📱 **Repositorio**: https://github.com/alvaroferrer1/PetCare-
💻 **Lenguaje**: Dart + Flutter
📅 **Actualización**: Mayo 2026
