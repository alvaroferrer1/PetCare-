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
| App movil | Flutter |
| Lenguaje | Dart |
| Backend / BBDD | Supabase |
| Autenticacion | Supabase Auth |
| Base de datos | PostgreSQL |
| IA | OpenAI API mediante Supabase Edge Function |
| APIs externas | Dog CEO API, The Cat API |
| Arquitectura | MVC + Repositories + Services |
| Testing | Unit tests, widget tests, integration tests |
| Control de versiones | Git + GitHub |

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

## Instalacion Y Ejecucion

```bash
flutter pub get
flutter run
```

Para probar en navegador:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

Para ejecutar tests:

```bash
flutter test
```

Comprobaciones actuales verificadas:

```bash
flutter analyze
flutter test -r expanded
flutter build web
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

## Estado Del Proyecto

Proyecto en desarrollo con primer MVP funcional.

Este repositorio forma parte del proyecto final del modulo **Desarrollo Vibe Coding** y se ira completando por fases:

1. Setup Flutter y arquitectura. Completado.
2. Supabase y autenticacion. Preparado con SQL, RLS y `.env`.
3. CRUD de mascotas. Implementado.
4. Historial y recordatorios. Implementado.
5. Food Safety. Implementado con base local y seed.
6. APIs externas. Servicios preparados con fallback.
7. Asistente IA. Preparado con Supabase Edge Function.
8. Tests, README final y pulido. En progreso.

---

## Autor

Proyecto desarrollado por **Alvaro Ferrer** como entrega final del modulo **Desarrollo Vibe Coding**.

GitHub: [alvaroferrer1](https://github.com/alvaroferrer1)
