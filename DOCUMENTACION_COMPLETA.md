# 📱 PetCare AI Companion - Documentación Técnica Completa

## Índice
1. [Descripción General del Sistema](#descripción-general-del-sistema)
2. [Decisiones Técnicas y Aprendizaje](#decisiones-técnicas-y-aprendizaje)
3. [Documentación Adicional](#documentación-adicional)
4. [Funcionamiento del Sistema](#funcionamiento-del-sistema)
5. [Instrucciones de Instalación y Ejecución](#instrucciones-de-instalación-y-ejecución)

---

## 📋 Descripción General del Sistema

### ¿Qué Problema Resuelve?

**PetCare AI Companion** resuelve la **fragmentación en la gestión de información de mascotas**. Actualmente, los dueños de perros y gatos almacenan esta información de forma dispersa:

- 📝 Notas dispersas en el teléfono
- 💬 Conversaciones en chats
- 📄 Papeles físicos del veterinario
- 🧠 Memoria mental (altamente propensa a olvidos)

Esto provoca problemas críticos:
- ❌ Olvidar vacunas, medicaciones o revisiones veterinarias
- ❌ No tener historial completo en consultas veterinarias
- ❌ Confusión con alimentos seguros vs. tóxicos
- ❌ Incapacidad de detectar patrones en síntomas o comportamiento
- ❌ Duplicación de medicamentos o cuidados

### ¿Para Qué Sirve?

**PetCare AI Companion** es una aplicación móvil centralizada que permite:

✅ **Organización Central**: Un único lugar para toda la información de mascotas
✅ **Historial Completo**: Registro de vacunas, medicaciones, visitas veterinarias
✅ **Notas de Salud**: Síntomas, estado de ánimo, apetito, energía
✅ **Recordatorios Inteligentes**: Alertas de cuidados pendientes ordenadas por fecha
✅ **Seguridad Alimentaria**: Base de datos de alimentos seguros/tóxicos para perros y gatos
✅ **Asistente IA**: Resumen automático de cuidados y preparación de preguntas para el veterinario

### Visión Global de la Solución

La solución implementa una **arquitectura moderna en capas** que separa:
- **Presentación (UI)**: Interfaz visual con Flutter
- **Lógica de negocio**: Controllers y Repositories
- **Servicios externos**: APIs e integración con Supabase
- **Persistencia de datos**: PostgreSQL a través de Supabase

```
┌─────────────────────────────────────────────────────┐
│          CAPA PRESENTACIÓN (Flutter UI)             │
│  (Vistas, Widgets, Navegación)                      │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│        CAPA LÓGICA (Controllers)                    │
│  (Gestión de estado con Riverpod)                   │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│      CAPA DATOS (Repositories)                      │
│  (Acceso a datos, caché)                            │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│       CAPA SERVICIOS (Services)                     │
│  - Supabase Service                                 │
│  - OpenAI Service                                   │
│  - Dog/Cat API Services                             │
│  - Food Facts Service                               │
└─────────────────────────────────────────────────────┘
```

### Herramientas de Vibe Coding Utilizadas

Este proyecto fue desarrollado mediante **asistencia IA integrada en VS Code**:

#### 🤖 GitHub Copilot
- **Generación de código**: Controllers, servicios, modelos
- **Documentación**: Comments y docstrings
- **Refactoring**: Optimización de código existente
- **Testing**: Generación de tests unitarios
- **Debugging**: Análisis de errores y soluciones

#### 📝 Prompting Avanzado
Se utilizaron técnicas de prompt engineering para:
- Especificar arquitectura MVC detallada
- Definir contratos de APIs
- Generar código testeable
- Documentar decisiones técnicas

#### 🔄 Flujo de Desarrollo con IA
1. Descripción de requisitos en lenguaje natural
2. Generación de estructura de archivos
3. Implementación de servicios
4. Creación de tests
5. Validación y refinamiento iterativo

### Tecnologías Empleadas para la Implementación

#### **Lenguaje de Programación**
- **Dart 3.8+**: Lenguaje principal para Flutter
  - Características: Tipado fuerte, null-safety, async/await
  - Ventaja: Compilación a código nativo y JavaScript

#### **Frameworks y Frameworks UI**
- **Flutter 3.x**: Framework multiplataforma para UI
  - Características: Hot reload, Material Design 3, rendimiento nativo
  - Plataformas: Android, iOS, Web, Windows, macOS, Linux

- **Riverpod 2.6+**: Gestión de estado reactiva
  - Características: Providers, state management, testing-friendly
  - Alternativa moderna a Provider

#### **Backend y Base de Datos**
- **Supabase**: Backend as a Service (BaaS)
  - PostgreSQL: Base de datos relacional
  - Autenticación: Email/contraseña con JWT
  - Row Level Security: Seguridad a nivel de fila
  - Edge Functions: Ejecución de código en el edge
  - Real-time subscriptions: Sincronización en tiempo real

#### **APIs Externas**

| API | Propósito | Documentación |
|-----|-----------|---------------|
| **OpenAI API** | Generación de resúmenes IA inteligentes | https://platform.openai.com/docs/api-reference |
| **Dog CEO API** | Razas de perros e imágenes | https://dog.ceo/dog-api/ |
| **The Cat API** | Razas de gatos e imágenes | https://thecatapi.com/ |
| **Open Pet Food Facts** | Base de datos de ingredientes de alimentos para mascotas | https://world.openpetfoodfacts.org/api/ |
| **Supabase REST API** | Operaciones CRUD en base de datos | https://supabase.com/docs/guides/api |

#### **Librerías Principales**
```yaml
# State Management
flutter_riverpod: ^2.6.1          # Gestión de estado reactiva

# HTTP & Networking
http: ^1.3.0                      # Cliente HTTP

# Autenticación & Backend
supabase_flutter: ^2.8.4          # SDK de Supabase para Flutter

# Utilidades
flutter_dotenv: ^5.2.1            # Gestión de variables de entorno
intl: ^0.20.2                     # Internacionalización y formato
shared_preferences: ^2.5.3        # Almacenamiento local de datos

# UI
cupertino_icons: ^1.0.8           # Iconos iOS/Material
```

#### **Control de Versiones**
- **Git + GitHub**: Versionado de código
  - Ramas por funcionalidad (feature branches)
  - Pull Requests para code review
  - Rama main (`incio`) y desarrollo (`medio`)

---

## 🎯 Decisiones Técnicas y Aprendizaje

### Decisiones Clave Tomadas

#### 1. **¿Por qué Flutter y no React Native, Kotlin o Swift?**

**Elección: Flutter**

| Aspecto | Flutter | React Native | Kotlin (Android) | Swift (iOS) |
|--------|---------|--------------|------------------|-------------|
| **Plataformas** | Android, iOS, Web, Desktop | Android, iOS (Web experimental) | Android only | iOS only |
| **Performance** | Compilación nativa (excelente) | Bridge JavaScript (más lento) | Nativo (excelente) | Nativo (excelente) |
| **Curva Aprendizaje** | Moderada (Dart es fácil) | Moderada (JavaScript/React) | Moderada (Kotlin) | Alta (Swift específico) |
| **Comunidad** | Excelente (Google respalda) | Buena (Meta respalda) | Buena (JetBrains) | Buena (Apple) |
| **Código Compartido** | 90%+ | 60-70% | 0% (solo Android) | 0% (solo iOS) |
| **Hot Reload** | Sí (muy rápido) | Sí | No | No |
| **UI Design** | Material Design 3 incorporado | Librerías externas | Librerías externas | SwiftUI |

**Ventajas de Flutter elegidas:**
- ✅ Una sola base de código para Android, iOS y Web
- ✅ Rendimiento comparable a código nativo
- ✅ Hot reload para desarrollo ágil
- ✅ Material Design 3 de serie (excelente UX)
- ✅ Ecosistema consolidado de librerías
- ✅ Comunidad muy activa y en crecimiento

#### 2. **¿Por qué Supabase en lugar de Firebase?**

**Elección: Supabase**

| Aspecto | Supabase | Firebase |
|--------|----------|----------|
| **Base de Datos** | PostgreSQL (SQL completo) | Firestore (NoSQL) |
| **Coste** | Predecible, basado en uso | Puede ser más caro con queries complejas |
| **Escalabilidad** | Excelente para datos relacionales | Excelente para datos no estructurados |
| **Control** | Open source, puedes hostear | Solo Google Cloud |
| **Row Level Security** | RLS de PostgreSQL (potente) | Reglas de seguridad Firebase |
| **Autenticación** | Email, OAuth, JWT | Email, OAuth, más opciones |
| **Real-time** | Sí, con subscripciones | Sí, pero más limitado |
| **Documentación** | Muy buena | Excelente |

**Razones de elección:**
- ✅ Datos fuertemente relacionales (perfiles → mascotas → eventos)
- ✅ Control total de la seguridad con RLS
- ✅ Acceso directo a SQL para queries complejas
- ✅ Mejor cumplimiento de RGPD (opción self-hosted)
- ✅ Coste predecible

#### 3. **¿Por qué Riverpod para gestión de estado?**

**Elección: Riverpod (no Provider ni BLoC)**

- ✅ Mejor para testing (no necesita BuildContext)
- ✅ State management más limpio y reactivo
- ✅ Menor boilerplate que Provider
- ✅ Soporte para Freezed y generación de código
- ✅ Mejor rendimiento en recompilaciones de widgets

#### 4. **¿Por qué Edge Functions para la IA?**

**Elección: Supabase Edge Functions (no APIs directas del cliente)**

- ✅ Seguridad: Clave de OpenAI no se expone en cliente
- ✅ Velocidad: Ejecuta en edge (más cercano al usuario)
- ✅ Control: Rate limiting y validación en el servidor
- ✅ Integración: Acceso directo a datos de Supabase

### Alternativas Valoradas

#### **Para la UI**
- ❌ Kotlin Compose: Solo Android
- ❌ React Native: Performance inferior en esta escala
- ❌ Xamarin: Comunidad más pequeña

#### **Para la IA**
- ❌ Llamadas directas desde cliente: Exposición de API key
- ❌ Backend tradicional (Node.js): Complejidad innecesaria
- ✅ Edge Functions: Mejor relación complejidad/seguridad

#### **Para bases de datos**
- ❌ MongoDB: Overkill para datos relacionales
- ❌ DynamoDB: Coste variable impredecible
- ✅ PostgreSQL (Supabase): Perfecto para este caso

#### **Para autenticación**
- ❌ Auth0: Coste adicional innecesario
- ✅ Supabase Auth: Incluido en Supabase

### Funcionalidades y/o Mejoras Futuras

#### **Fase 2 - Mejoras de UX/Product**
- 📅 **Calendario Visual**: Vista mensual de eventos de cuidado (especialmente útil para veterinarios)
- 📊 **Dashboard de Salud**: Gráficos de peso, historial de medicaciones, patrones de síntomas
- 📸 **Galería de Mascotas**: Organización visual de fotos por fecha
- 🔔 **Notificaciones Push**: Recordatorios en tiempo real (Android, iOS)
- 📤 **Exportar PDF**: Descargar historial completo para llevar al veterinario

#### **Fase 3 - Expansión Funcional**
- 👨‍👩‍👧‍👦 **Modo Familiar**: Múltiples usuarios pueden gestionar la misma mascota (madre, padre, abuelos)
- 📋 **Documentos Veterinarios**: Subir radiografías, análisis, informes médicos
- 🏥 **Directorio de Veterinarios**: Búsqueda y reseñas de clínicas veterinarias cercanas
- 🌍 **Múltiples Especies**: Expandir desde perros/gatos a pájaros, reptiles, roedores
- 💬 **Chat con Asistente IA**: Conversación bidireccional (no solo resúmenes)

#### **Fase 4 - Características Avanzadas**
- 📱 **Panel para Veterinarios**: Acceso seguro a historial del paciente (con consentimiento)
- 🤖 **Análisis Predictivo**: Predicción de problemas de salud basada en patrones
- 🌐 **Sincronización Multi-dispositivo**: Acceso desde múltiples teléfonos/tablets
- 🎯 **Integración con APIs de laboratorios**: Importar resultados directamente
- 📡 **Wearables**: Integración con collares inteligentes y monitores de salud

#### **Fase 5 - Monetización y Escalabilidad**
- 💳 **Planes Premium**: Almacenamiento ilimitado, acceso veterinario, análisis avanzado
- 🏢 **SaaS para Clínicas Veterinarias**: Gestión centralizada de pacientes
- 📈 **Analytics Anonimizados**: Investigación de tendencias de salud animal
- 🌐 **Internacionalización**: Soporte multiidioma, bases de datos de alimentos localizadas

---

## 📚 Documentación Adicional

### Exportaciones de Automatizaciones Utilizadas

El proyecto utiliza **automatizaciones a través de GitHub Copilot**:

#### Prompts Utilizados
1. **Inicialización de Proyecto**
   - Estructura MVC completa
   - Configuración de Supabase
   - Setup de Riverpod

2. **Servicios de API**
   - Patrones de manejo de errores
   - Fallbacks automáticos
   - Retry logic

3. **Controllers y State Management**
   - Providers con Riverpod
   - Gestión de async operations
   - Error handling

4. **Testing**
   - Unit tests para modelos
   - Widget tests para UI
   - Mocking de servicios

### Archivos Utilizados como Base de Conocimiento

#### Documentación Consultada
- [Flutter Documentation](https://flutter.dev/docs) - Guía oficial
- [Supabase Docs](https://supabase.com/docs) - Referencia completa
- [Dart Language Tour](https://dart.dev/guides/language/language-tour) - Lenguaje
- [Riverpod Guide](https://riverpod.dev) - State management
- [Material Design 3](https://m3.material.io/) - Diseño UI

#### Bases de Datos de Referencia
- [Dog CEO API Dataset](https://dog.ceo/) - 340+ razas de perros
- [The Cat API Breeds](https://thecatapi.com/breeds) - 67+ razas de gatos
- [Open Pet Food Facts Database](https://world.openpetfoodfacts.org/) - Ingredientes de alimentos

### Documentos de Contexto Utilizados

#### Para el Desarrollo
- **Requisitos Funcionales**: Especificación de MVP en lenguaje natural
- **Wireframes**: Flujos de navegación y pantallas principales
- **Diagrama ER**: Modelo de datos de Supabase
- **Especificación de APIs**: Contratos de servicios externos

#### Para el AI Assistant
- **Prompt de Sistema**: Instrucciones para resúmenes de salud (con disclaimer médico)
- **Ejemplos de Output**: Estructura esperada del JSON de respuesta
- **Restricciones de Seguridad**: No diagnosticar, no recetar, recomendar veterinario

### Documentación de APIs

#### APIs Externas Utilizadas

**1. OpenAI API**
```
Endpoint: https://api.openai.com/v1/chat/completions
Método: POST
Modelo: gpt-4-mini
Autenticación: Bearer Token
Documentación: https://platform.openai.com/docs/api-reference
Caso de uso: Generación de resúmenes de cuidados inteligentes
```

**2. Dog CEO API**
```
Endpoint: https://dog.ceo/api/breeds/list/all
Método: GET (sin autenticación)
Respuesta: Lista de razas de perros
Documentación: https://dog.ceo/dog-api/
Fallback: Lista local de razas comunes
```

**3. The Cat API**
```
Endpoint: https://api.thecatapi.com/v1/breeds
Método: GET (sin autenticación requerida)
Respuesta: Lista de razas de gatos e imágenes
Documentación: https://thecatapi.com/
Fallback: Lista local de razas comunes
```

**4. Open Pet Food Facts API**
```
Endpoint: https://world.openpetfoodfacts.org/cgi/search.pl
Método: GET
Parámetros: search_terms, fields
Documentación: https://world.openpetfoodfacts.org/api/
Caso de uso: Búsqueda de seguridad alimentaria para mascotas
```

**5. Supabase REST API**
```
Autenticación: API Key + JWT
Endpoints: /rest/v1/{tabla}
Documentación: https://supabase.com/docs/guides/api
Métodos: GET, POST, PATCH, DELETE
Con Row Level Security (RLS) habilitado
```

---

## ⚙️ Funcionamiento del Sistema

### Diagrama de Arquitectura Completo

```
┌──────────────────────────────────────────────────────────────┐
│                    DISPOSITIVO DEL USUARIO                   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           FLUTTER APPLICATION (UI Layer)            │   │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────┐   │   │
│  │  │Auth Views  │  │Pet Views   │  │AI Assistant  │   │   │
│  │  │Care Events │  │Food Safety │  │Health Notes  │   │   │
│  │  └────────────┘  └────────────┘  └──────────────┘   │   │
│  └────────────┬───────────────────────────────────────┘   │
│               │                                             │
│  ┌────────────▼───────────────────────────────────────┐   │
│  │         RIVERPOD STATE MANAGEMENT (Logic)          │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  Providers para:                             │  │   │
│  │  │  - user.dart (estado de autenticación)      │  │   │
│  │  │  - pets.dart (lista de mascotas)            │  │   │
│  │  │  - care_events.dart (historial de cuidados) │  │   │
│  │  │  - health_notes.dart (notas de salud)       │  │   │
│  │  │  - food_safety.dart (búsqueda de alimentos) │  │   │
│  │  │  - ai_summary.dart (resúmenes con IA)       │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └────────────┬───────────────────────────────────────┘   │
│               │                                             │
│  ┌────────────▼───────────────────────────────────────┐   │
│  │           REPOSITORIES (Data Access)               │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  auth_repository.dart                        │  │   │
│  │  │  pet_repository.dart                         │  │   │
│  │  │  care_event_repository.dart                  │  │   │
│  │  │  health_note_repository.dart                 │  │   │
│  │  │  food_safety_repository.dart                 │  │   │
│  │  │  ai_summary_repository.dart                  │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └────────────┬───────────────────────────────────────┘   │
│               │                                             │
│  ┌────────────▼───────────────────────────────────────┐   │
│  │    LOCAL STORAGE (Shared Preferences)            │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │ - Datos de sesión                            │  │   │
│  │  │ - Preferencias de usuario                    │  │   │
│  │  │ - Caché de imágenes                          │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └────────────┬───────────────────────────────────────┘   │
└───────────────┼───────────────────────────────────────────┘
                │
   ┌────────────┴────────────┬──────────────┬──────────────┐
   │                         │              │              │
┌──▼───────────────┐  ┌──────▼──────┐ ┌────▼──────┐ ┌──────▼──────┐
│  SUPABASE CLOUD  │  │ DOG CEO API │ │ CAT API   │ │ OPENAI API  │
│                  │  │             │ │           │ │             │
│ ┌──────────────┐ │  │ GET /breeds │ │ GET       │ │ POST /chat/ │
│ │ PostgreSQL   │ │  │ /images     │ │ /breeds   │ │ completions │
│ │ Database     │ │  │             │ │           │ │             │
│ ├──────────────┤ │  └─────────────┘ └───────────┘ │ GPT-4 mini  │
│ │ profiles     │ │                                 │ Generating  │
│ │ pets         │ │                                 │ summaries   │
│ │ care_events  │ │                                 │             │
│ │ health_notes │ │                                 │             │
│ │ food_safety  │ │                                 │             │
│ │ ai_summaries │ │                                 │             │
│ └──────────────┘ │                                 │             │
│ ┌──────────────┐ │                                 │             │
│ │ Auth (JWT)   │ │                                 │             │
│ │ RLS Policies │ │                                 │             │
│ └──────────────┘ │                                 │             │
│ ┌──────────────┐ │                                 │             │
│ │ Edge Function│ │                                 │             │
│ │ (IA Handler) │ │◄─────────────────────────────────              │
│ └──────────────┘ │                                 │             │
└──────────────────┘  (Secure API Key)              └─────────────┘
     │
     └──► REST API / WebSockets (Real-time sync)
```

### Flujo de Autenticación

```
APLICACIÓN                          SUPABASE AUTH
     │                                    │
     │ 1. Usuario ingresa email/contraseña
     │─────────────────────────────────────>
     │                                    │
     │                          2. Valida credenciales
     │                          3. Genera JWT Token
     │<─────────────────────────────────────
     │ (token, user_id, session)          │
     │                                    │
     ├─ Guarda token en Secure Storage    │
     ├─ Actualiza UI (usuario autenticado)│
     │                                    │
     │ 4. Requests posteriores incluyen token
     │─────────────────────────────────────>
     │ (Headers: Authorization: Bearer {token})
     │                                    │
     │                          5. RLS verifica:
     │                          - Token válido
     │                          - user_id coincide
     │                          - Acceso a datos
     │<─────────────────────────────────────
     │ (Datos filtrados por user_id)      │
```

### Cómo Interactúan los Servicios

#### **1. Flujo de Crear Mascota**
```
Usuario clicks "Crear Mascota"
           │
           ▼
    PetView (UI)
           │
           ▼
PetController.addPet()
(Riverpod Provider)
           │
           ▼
PetRepository.createPet()
           │
           ▼
SupabaseService.insertPet()
           │
           ▼
HTTP POST to Supabase
(con auth token)
           │
           ▼
RLS Policy verifica user_id
           │
           ▼
INSERT en tabla pets
           │
           ▼
Response con pet creada
           │
           ▼
Actualiza state en Riverpod
           │
           ▼
UI se reconstruye
(muestra nueva mascota)
```

#### **2. Flujo de Búsqueda de Razas**
```
Usuario selecciona "Raza de perro"
           │
           ▼
DogBreedSelector (UI)
           │
           ▼
PetController.fetchBreeds()
           │
           ▼
DogApiService.fetchBreeds()
           │
           ▼
GET https://dog.ceo/api/breeds/list/all
           │
           ├─ Si falla (sin internet)
           │  └─> Retorna lista local (fallback)
           │
           ├─ Si éxito
           │  └─> Parsea JSON
           │     └─> Ordena alfabéticamente
           │
           ▼
Retorna List<String> de razas
           │
           ▼
Actualiza UI con dropdown
```

#### **3. Flujo de Generación de Resumen IA**
```
Usuario clicks "Generar Resumen"
           │
           ▼
AIAssistantView (UI)
           │
           ▼
AIController.generateSummary(petId)
           │
           ▼
AIRepository.generateSummary()
           │
           ▼
Recopila datos:
├─ Información de mascota
├─ Últimos cuidados
├─ Notas de salud recientes
└─ Recordatorios pendientes
           │
           ▼
SupabaseService.callEdgeFunction()
           │
           ▼
POST to Supabase Edge Function
(con datos + JWT token)
           │
           ▼
Edge Function (en Supabase):
├─ Valida JWT
├─ Formatea prompt
├─ Llama a OpenAI API
│  (con OPENAI_API_KEY segura)
└─ Retorna respuesta
           │
           ▼
Parsea JSON response:
{
  "summary": "...",
  "priorities": [...],
  "vet_questions": [...],
  "recommendations": [...],
  "safety_notice": "..."
}
           │
           ▼
Guarda en BD (ai_summaries)
           │
           ▼
Actualiza UI con resumen
```

---

## 🚀 Instrucciones de Instalación y Ejecución

### Prerrequisitos

#### Sistema Operativo
- **Windows**: 10 o superior (para ejecutar Flutter)
- **macOS**: 10.14 o superior (para compilar iOS)
- **Linux**: Ubuntu 16.04 o superior

#### Software Requerido
- **Flutter SDK**: [Descargar aquí](https://flutter.dev/docs/get-started/install)
  - Incluye Dart automáticamente
- **Git**: [Descargar aquí](https://git-scm.com/)
- **IDE**: VS Code o Android Studio
  - Extensión Flutter para VS Code: `flutter.flutter`
- **Android**: Android Studio o Android SDK CLI (si quieres compilar para Android)
- **Xcode**: (solo macOS, si quieres compilar para iOS)

#### Cuentas Necesarias
- **GitHub**: Para clonar el repositorio
- **Supabase**: Para acceder a la base de datos
  - Crear proyecto en [supabase.com](https://supabase.com)
- **OpenAI**: Para usar el asistente IA
  - Crear API key en [platform.openai.com](https://platform.openai.com)

### Paso 1: Clonar el Repositorio

```bash
# Navega a la carpeta donde quieras el proyecto
cd tu/ruta/preferida

# Clona el repositorio
git clone https://github.com/alvaroferrer1/PetCare-.git
cd PetCare-
```

### Paso 2: Instalar Dependencias de Flutter

```bash
# Obtiene todas las dependencias del pubspec.yaml
flutter pub get

# Verifica que Flutter esté correctamente instalado
flutter doctor
```

### Paso 3: Configurar Variables de Entorno

#### Crear archivo `.env` en la raíz del proyecto

```bash
# Copiar el archivo de ejemplo
cp .env.example .env
```

#### Editar `.env` con tus credenciales:

```env
# ============================================
# SUPABASE CONFIGURATION
# ============================================
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ============================================
# EXTERNAL APIS (Opcionales)
# ============================================
# The Cat API (opcional, si no está configurada usa fallback)
THE_CAT_API_KEY=live_abc123def456...

# OpenAI está configurada en Supabase Edge Function
# (No la pongas aquí por seguridad)
```

#### Obtener credenciales Supabase:
1. Accede a [supabase.com](https://supabase.com)
2. Crea proyecto o accede a uno existente
3. Ve a Settings > API
4. Copia `Project URL` (SUPABASE_URL)
5. Copia `anon public` key (SUPABASE_ANON_KEY)

#### Obtener API key The Cat API:
1. Accede a [thecatapi.com](https://thecatapi.com)
2. Sign up y obtén tu API key
3. (Opcional: funciona sin ella, pero sin imágenes de gatos)

### Paso 4: Configurar Supabase (Base de Datos)

Si es la primera vez, necesitas crear las tablas:

```bash
# Conectarse a Supabase CLI (si está instalado)
supabase login

# Ejecutar migraciones (si existen)
supabase migration list
```

O manualmente en Supabase Console:

1. Abre https://supabase.com
2. Ve a SQL Editor
3. Ejecuta el script `supabase/schema.sql`:

```sql
-- Copiar contenido de supabase/schema.sql
-- y ejecutar en el SQL Editor de Supabase
```

4. Ejecuta seed data `supabase/seed.sql`:

```sql
-- Para poblar datos de ejemplo (alimentos seguros/tóxicos)
-- Copiar contenido de supabase/seed.sql
```

### Paso 5: Verificar Setup

```bash
# Verificar que todo está OK
flutter analyze

# Ejecutar tests para validar setup
flutter test

# Ver qué dispositivos están disponibles
flutter devices
```

### Paso 6: Ejecutar la Aplicación

#### **En Emulador/Dispositivo Android**

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo
flutter run

# O especificar dispositivo
flutter run -d <device-id>
```

#### **En Emulador iOS** (solo macOS)

```bash
# Abre Xcode (primera vez)
cd ios
pod install
cd ..

# Ejecutar
flutter run -d "iPhone 15 Plus"
```

#### **En Web (Navegador)**

```bash
# Ejecutar en navegador
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080

# O simplemente
flutter run -d chrome
```

#### **Build para Release**

```bash
# Para Android
flutter build apk --release

# Para iOS
flutter build ios --release

# Para Web
flutter build web --release
```

### Paso 7: Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests específicos con output detallado
flutter test -r expanded

# Tests de un archivo
flutter test test/model_logic_test.dart
```

### Verificación Final

```bash
# Verificar análisis estático
flutter analyze

# Compilar para web (verifica todo)
flutter build web

# Debería completarse sin errores
```

### Troubleshooting Común

| Problema | Solución |
|----------|----------|
| `pubspec.lock` error | `flutter clean && flutter pub get` |
| No se cargan imágenes de razas | Verifica internet / APIs sin internet usan fallback |
| Error de autenticación | Verifica SUPABASE_URL y SUPABASE_ANON_KEY en .env |
| Tests fallan | `flutter clean && flutter pub get && flutter test` |
| Hot reload no funciona | Reinicia: `flutter clean && flutter run` |

---

## 📊 Resumen Ejecutivo

### Métricas del Proyecto
- **Lenguajes**: Dart (100% del código de la app)
- **Líneas de Código**: ~5,000+ líneas (controllers, services, views, models)
- **Archivos Dart**: 40+ archivos organizados por capas
- **Tests**: 20+ tests unitarios y de widgets
- **APIs Integradas**: 5 APIs externas
- **Bases de datos**: PostgreSQL con 6 tablas principales

### Logros Principales
✅ MVP funcional completamente operativo
✅ Arquitectura limpia y escalable (MVC + Repositories)
✅ Integración con IA (OpenAI) de forma segura
✅ Autenticación y autorización implementadas (JWT + RLS)
✅ Testing automatizado incluido
✅ Preparado para producción
✅ Documentación técnica completa

### Próximos Pasos Recomendados
1. Desplegar en App Stores (Google Play, Apple App Store)
2. Implementar notificaciones push
3. Agregar modo familiar (múltiples usuarios)
4. Optimizar performance en dispositivos antiguos
5. Expandir a más especies de mascotas

---

**Desarrollado por**: Alvaro Ferrer
**Proyecto**: Módulo "Desarrollo Vibe Coding"
**Repositorio**: https://github.com/alvaroferrer1/PetCare-
**Última actualización**: Mayo 2026
