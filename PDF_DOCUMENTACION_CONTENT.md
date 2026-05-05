# 📋 PetCare AI Companion - Documentación de la Aplicación

## a) Descripción General del Sistema

### ¿Qué Problema Resuelve?

La gestión de información de mascotas se realiza actualmente de forma **fragmentada y desorganizada**:

- 📝 Notas dispersas en notas del teléfono
- 💬 Conversaciones en chats sin historial estructurado
- 📄 Papeles físicos del veterinario sin orden
- 🧠 Información guardada en la memoria (propensa a olvidos)

Esto provoca problemas críticos:
- ❌ **Olvidos**: Perder vacunas, medicaciones o revisiones programadas
- ❌ **Falta de contexto**: No tener historial en consultas veterinarias
- ❌ **Confusión**: No saber qué alimentos son seguros o tóxicos
- ❌ **Pérdida de patrones**: Incapacidad de detectar problemas de salud recurrentes
- ❌ **Duplicación**: Riesgo de sobredosis o medicamentos repetidos

**PetCare AI Companion** resuelve esto centralizando toda la información en una única plataforma accesible y organizada.

### ¿Para Qué Sirve?

**PetCare AI Companion** es una aplicación móvil que permite:

🎯 **Centralización**: Un único lugar para toda la información de mascotas
📊 **Historial Completo**: Registro permanente de:
  - Vacunas y calendario de inmunización
  - Visitas veterinarias y diagnósticos
  - Medicaciones y tratamientos
  - Alimentación especial y restricciones
  - Cuidados de grooming y desparasitación

🏥 **Notas de Salud**: Registro de síntomas, comportamiento, apetito, energía
⏰ **Recordatorios Inteligentes**: Alertas de cuidados pendientes ordenadas por fecha
🍖 **Seguridad Alimentaria**: Base de datos de alimentos seguros, peligrosos y tóxicos
🤖 **Asistente IA**: Resúmenes inteligentes que preparan preguntas para el veterinario

### Visión Global de la Solución

**PetCare AI Companion** implementa una **arquitectura moderna en capas** que garantiza:

1. **Separación de responsabilidades**: UI, lógica, datos, servicios
2. **Escalabilidad**: Fácil agregar nuevas features sin romper lo existente
3. **Seguridad**: Autenticación JWT, Row Level Security, credenciales protegidas
4. **Performance**: Compilación nativa, state management reactivo
5. **Confiabilidad**: 20+ tests automatizados, manejo de errores robusto

```
┌─────────────────────────────────────────────────────┐
│          CAPA DE PRESENTACIÓN (UI)                  │
│  Vistas en Material Design 3 con Flutter            │
│  - Auth screens                                     │
│  - Pet management                                   │
│  - Care history                                     │
│  - Health notes & Reminders                         │
│  - Food safety search                               │
│  - AI Assistant                                     │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│    CAPA DE LÓGICA DE NEGOCIO (Controllers)          │
│  State Management con Riverpod Providers            │
│  - Gestión de estado reactivo                       │
│  - Orquestación de operaciones                      │
│  - Validaciones de negocio                          │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│    CAPA DE DATOS (Repositories)                     │
│  Acceso abstracción a datos                         │
│  - Caché local                                      │
│  - Lógica de persistencia                           │
│  - Mapeo de datos                                   │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│    CAPA DE SERVICIOS (Services)                     │
│  Integración con sistemas externos                  │
│  - Supabase (BD + Auth)                             │
│  - OpenAI (IA)                                      │
│  - Dog CEO API (razas perros)                       │
│  - The Cat API (razas gatos)                        │
│  - Open Pet Food Facts (alimentos)                  │
└─────────────────────────────────────────────────────┘
```

### Herramientas de Vibe Coding Utilizadas

Este proyecto fue desarrollado **completamente con asistencia de IA**:

#### 🤖 GitHub Copilot en VS Code
- **Generación de código**: Estructura de archivos, controllers, servicios
- **Documentación**: Docstrings, comments, ejemplos
- **Testing**: Generación de tests unitarios y widget tests
- **Debugging**: Análisis de errores y sugerencias de fixes
- **Refactoring**: Optimización de código existente

#### 📝 Técnicas de Prompt Engineering
1. **Especificación Detallada**: Describir arquitectura deseada en natural
2. **Context Injection**: Proporcionar código existente para mantener consistencia
3. **Test-First**: Escribir pruebas antes del código
4. **Iteración**: Refinamiento gradual con feedback
5. **Ejemplo-Driven**: Proporcionar ejemplos de input/output esperado

#### 🔄 Flujo de Desarrollo Vibe Coding
```
Requerimiento en Lenguaje Natural
              ↓
Generación de Estructura (Copilot)
              ↓
Implementación de Lógica (Copilot)
              ↓
Creación de Tests (Copilot)
              ↓
Validación Manual
              ↓
Refinamiento con Feedback
              ↓
✅ Código Listo
```

**Resultado**: ~5,000 líneas de código en 40+ archivos, todos derivados de asistencia IA + validación manual.

### Tecnologías Empleadas para la Implementación

#### **Lenguaje de Programación**
- **Dart 3.8+**
  - Tipado fuerte con type inference
  - Null-safety (evita NPE - NullPointerExceptions)
  - Async/await para operaciones asincrónicas
  - Compilación a código nativo + JavaScript

#### **Frameworks**
- **Flutter 3.x** - Framework UI multiplataforma
  - Compilación nativa para Android, iOS, Web, Windows, macOS, Linux
  - Hot reload para desarrollo ágil (0.5s)
  - 90%+ código compartido entre plataformas
  - Material Design 3 integrado

- **Riverpod 2.6+** - Gestión de estado reactiva
  - State management sin BuildContext
  - Providers para lógica de negocio
  - Testing-friendly (no necesita mocks complejos)
  - Mejor que Provider por sua legibilidad y power

#### **Backend y Base de Datos**
- **Supabase** - Backend as a Service
  - PostgreSQL: Base de datos relacional robusta
  - Supabase Auth: Autenticación con JWT
  - Row Level Security: Seguridad a nivel de fila
  - Edge Functions: Ejecución de código en el edge
  - Real-time subscriptions: Sincronización en vivo

#### **APIs Externas**

| API | Propósito | Documentación | Integración |
|-----|-----------|---|---|
| **OpenAI API** | Generación de resúmenes IA inteligentes del historial | https://platform.openai.com/docs/api-reference | Edge Function (seguro) |
| **Dog CEO API** | Razas de perros e imágenes | https://dog.ceo/dog-api/ | HTTP directo + fallback local |
| **The Cat API** | Razas de gatos e imágenes | https://thecatapi.com/ | HTTP directo + fallback local |
| **Open Pet Food Facts API** | Base de datos de seguridad alimentaria | https://world.openpetfoodfacts.org/api/ | HTTP + caché local |
| **Supabase REST API** | Operaciones CRUD en base de datos | https://supabase.com/docs/guides/api | Cliente Supabase Flutter |

#### **Librerías Principales**
```yaml
# State Management
flutter_riverpod: ^2.6.1          # Providers reactivos

# HTTP & Networking  
http: ^1.3.0                      # Cliente HTTP para APIs

# Backend Integration
supabase_flutter: ^2.8.4          # SDK oficial de Supabase

# Utilities
flutter_dotenv: ^5.2.1            # Variables de entorno
intl: ^0.20.2                     # Internacionalización
shared_preferences: ^2.5.3        # Almacenamiento local

# UI
cupertino_icons: ^1.0.8           # Iconos Material + iOS
```

#### **Control de Versiones**
- **Git**: Versionado distribuido
- **GitHub**: Repositorio remoto + colaboración
- **Ramas**: Estrategia `main` + `develop`
- **Commits**: Mensajes descriptivos y atómicos

---

## b) Decisiones Técnicas y Aprendizaje

### Decisiones Clave Tomadas

#### 1️⃣ **¿Por qué Flutter en lugar de React Native?**

| Aspecto | Flutter | React Native | Decisión |
|--------|---------|--------------|----------|
| **Plataformas** | Android, iOS, Web, Desktop, Linux | Android, iOS (Web experimental) | ✅ Flutter - Mayor cobertura |
| **Performance** | Compilación nativa (excelente) | Bridge JavaScript (más lento) | ✅ Flutter - Mejor rendimiento |
| **Código Compartido** | 90%+ | 60-70% | ✅ Flutter - Menos duplicación |
| **Hot Reload** | Sí (0.5s) | Sí (más lento) | ✅ Flutter - Desarrollo más rápido |
| **UI Design** | Material Design 3 nativo | Librerías externas | ✅ Flutter - UX superior |
| **Comunidad** | Excelente (Google respalda) | Buena (Meta respalda) | ✅ Flutter - Comunidad más grande |
| **Curva Aprendizaje** | Moderada (Dart es fácil) | Moderada (JavaScript/React) | ✅ Flutter - Más consistente |

**Razones de la Elección:**
- ✅ Una base de código para múltiples plataformas (MVP eficiente)
- ✅ Performance nativo comparable a Swift/Kotlin
- ✅ Material Design 3 de serie (excelente UX)
- ✅ Hot reload acelera iteración en desarrollo
- ✅ Comunidad activa con documentación excelente

#### 2️⃣ **¿Por qué Supabase en lugar de Firebase?**

| Criterio | Supabase | Firebase | Decisión |
|----------|----------|----------|----------|
| **Base de Datos** | PostgreSQL (SQL completo) | Firestore (NoSQL) | ✅ Supabase - Mejor para relaciones |
| **Escalabilidad** | Excelente para datos relacionales | Excelente para no-estructurados | ✅ Supabase - Caso de uso perfecto |
| **Control** | Open source, auto-hosted option | Solo Google Cloud | ✅ Supabase - Mayor control |
| **Row Level Security** | RLS de PostgreSQL (poderoso) | Reglas Firebase (básicas) | ✅ Supabase - Más seguro |
| **Coste** | Predecible (recursos) | Variable (operaciones) | ✅ Supabase - Más económico |
| **Documentación** | Muy buena | Excelente | ✅ Ambas buenas |

**Razones de la Elección:**
- ✅ Datos de mascotas tienen relaciones complejas (1-N)
- ✅ PostgreSQL permite queries SQL complejas si es necesario
- ✅ RLS es más potente que reglas Firebase
- ✅ Mejor cumplimiento RGPD (opción self-hosted)
- ✅ Coste predecible sin sorpresas por uso elevado

#### 3️⃣ **¿Por qué Riverpod para State Management?**

| Aspecto | Riverpod | Provider | BLoC | Decisión |
|---------|----------|----------|------|----------|
| **Testing** | Sin BuildContext | Requiere mock | Boilerplate | ✅ Riverpod - Más fácil |
| **Boilerplate** | Minimal | Moderado | Excesivo | ✅ Riverpod - Menos código |
| **Reactividad** | Excelente | Buena | Buena | ✅ Riverpod - Más limpia |
| **Performance** | Óptimo | Bueno | Bueno | ✅ Riverpod - Mejor performance |

**Razones de la Elección:**
- ✅ State management reactivo y limpio
- ✅ Tests unitarios sin mocks complejos
- ✅ Menor boilerplate que Provider/BLoC
- ✅ Soporte para Freezed (generación de código)

#### 4️⃣ **¿Por qué Edge Functions para OpenAI?**

**Opción 1: Llamadas directas desde cliente**
- ❌ API key expuesta en el código (seguridad crítica)
- ❌ Rate limiting del lado del cliente
- ❌ Sin validación de entrada

**Opción 2: Backend tradicional (Node.js)**
- ❌ Complejidad innecesaria
- ❌ Costo adicional de servidor
- ❌ Mantenimiento extra

**Opción 3: Edge Functions (Elegida)**
- ✅ API key protegida en servidor
- ✅ Rate limiting + validación en el edge
- ✅ Baja latencia (ejecuta cerca del usuario)
- ✅ Integración directa con Supabase
- ✅ Escala automática

**Razones de la Elección:**
- ✅ Seguridad: Credenciales nunca llegan a cliente
- ✅ Performance: Ejecuta en el edge (cerca del usuario)
- ✅ Integración: Acceso directo a datos de Supabase
- ✅ Simplicity: No necesita servidor adicional

### Alternativas Valoradas

#### **Para la UI**
- ❌ **Kotlin Compose**: Solo Android, no multiplataforma
- ❌ **React Native**: Performance inferior, comunidad menos estable
- ❌ **Xamarin**: Comunidad pequeña, menos soporte
- ✅ **Flutter**: Elegida por multiplataforma y performance

#### **Para la IA**
- ❌ **LLaMA local**: No es viable en mobile, requiere muchísimos recursos
- ❌ **Llamadas directas**: Expone API keys de seguridad
- ✅ **Edge Functions**: Mejor balance seguridad/rendimiento

#### **Para Bases de Datos**
- ❌ **MongoDB**: Overkill para datos relacionales simples
- ❌ **DynamoDB**: Coste variable impredecible
- ❌ **Firebase Firestore**: Menos flexible para relaciones
- ✅ **PostgreSQL (Supabase)**: Perfecto para este caso

#### **Para Autenticación**
- ❌ **Auth0**: Coste adicional innecesario
- ❌ **Custom Auth**: Inseguro y complejo
- ✅ **Supabase Auth**: Incluido, seguro, JWT

### Funcionalidades y/o Mejoras que se Añadirían

#### **Fase 2 - Mejoras de UX/Product** (1-2 meses)
- 📅 **Calendario Visual**: Vista mensual de eventos (especialmente para veterinarios)
- 📊 **Gráficos de Salud**: Tendencias de peso, historial de medicaciones, patrones
- 📸 **Galería Mejorada**: Organización visual de fotos por fecha
- 🔔 **Notificaciones Push**: Recordatorios en tiempo real (Android & iOS)
- 📤 **Exportar PDF**: Descargar historial para llevar al veterinario
- 🌙 **Modo Oscuro**: Tema dark para comodidad visual

#### **Fase 3 - Expansión Funcional** (2-3 meses)
- 👨‍👩‍👧‍👦 **Modo Familiar**: Múltiples usuarios (madre, padre, abuelos) gestionan misma mascota
- 📋 **Documentos Veterinarios**: Subir radiografías, análisis, reportes médicos
- 🏥 **Directorio de Veterinarios**: Búsqueda, reviews, ubicación en mapa
- 🌍 **Múltiples Especies**: Expandir desde perros/gatos a pájaros, reptiles, roedores, peces
- 💬 **Chat Veterinario**: Consultas directas con veterinarios licenciados
- 🔐 **Compartir Acceso**: Autorización controlada para que veterinarios vean historial

#### **Fase 4 - Características Avanzadas** (3-4 meses)
- 📱 **Panel para Veterinarios**: Dashboard especial con historial de pacientes (con consentimiento)
- 🤖 **Análisis Predictivo**: Machine learning para predecir problemas de salud
- 🌐 **Multi-dispositivo**: Sincronización en tiempo real entre teléfono, tablet, web
- 🎯 **Integración con Laboratorios**: Importar resultados de análisis directamente
- ⌚ **Wearables**: Integración con collares inteligentes y monitores de salud
- 🏥 **Seguros de Mascotas**: Integración para facilitar claims

#### **Fase 5 - Monetización y Escalabilidad** (6+ meses)
- 💳 **Premium Features**: Almacenamiento ilimitado, análisis avanzado, acceso veterinario
- 🏢 **SaaS para Veterinarios**: Gestión centralizada de clientes para clínicas
- 📊 **Analytics Anonimizado**: Investigación de tendencias de salud animal
- 🌐 **Internacionalización**: Soporte multiidioma y bases de datos localizadas
- 📱 **App Nativa**: Compilación a APK/IPA para app stores
- 🌍 **Expansión Geográfica**: Soporte de múltiples monedas y regulaciones

#### **¿Por qué estas mejoras?**
- ✅ **Fase 2**: Mejoran usabilidad inmediatamente
- ✅ **Fase 3**: Expanden mercado (múltiples usuarios)
- ✅ **Fase 4**: Crean ecosistema alrededor de veterinarios
- ✅ **Fase 5**: Permiten monetización y escalabilidad global

---

## 3️⃣ Documentación Adicional

### Exportaciones de Automatizaciones que se han Empleado

#### **Prompts Utilizados en GitHub Copilot**

1. **Estructura Inicial**
   ```
   "Crea una app Flutter con arquitectura MVC que incluya:
   - Controllers con Riverpod
   - Repositories para acceso a datos
   - Services para APIs externas
   - Models tipados con Dart
   - Views con Material Design 3"
   ```

2. **Servicios de API**
   ```
   "Implementa un servicio HTTP en Dart que:
   - Haga GET a una API REST
   - Tenga retry logic automático
   - Fallback a datos locales si falla
   - Manejo de errores robusto"
   ```

3. **State Management**
   ```
   "Crea providers de Riverpod para:
   - Autenticación de usuario
   - Lista de mascotas
   - Operaciones CRUD
   - Manejo de async loading"
   ```

4. **Testing**
   ```
   "Genera tests unitarios para:
   - Modelos (validación)
   - Servicios (mocking HTTP)
   - Controllers (Riverpod)"
   ```

#### **Técnicas de Prompt Engineering Aplicadas**

| Técnica | Ejemplo | Resultado |
|---------|---------|-----------|
| **Context Injection** | Proporcionar código existente | Continuidad en estilo |
| **Example-Driven** | Mostrar input/output esperado | Exactitud en formato |
| **Specification** | Describir requisitos en natural | Código que cumple specs |
| **Test-First** | Escribir pruebas primero | Código verificable |
| **Iteración** | Refinamiento con feedback | Mejora gradual |

### Archivos Utilizados como Base de Conocimiento

#### **Documentación Oficial Consultada**
- [Flutter Official Docs](https://flutter.dev/docs) - Guía completa del framework
- [Supabase Documentation](https://supabase.com/docs) - Referencia de backend
- [Dart Language Tour](https://dart.dev/guides/language/language-tour) - Sintaxis y características
- [Riverpod Guide](https://riverpod.dev) - State management
- [Material Design 3](https://m3.material.io/) - Diseño UI/UX

#### **Bases de Datos de Referencia**
- [Dog CEO API Dataset](https://dog.ceo/) - 340+ razas de perros
- [The Cat API Breeds](https://thecatapi.com/breeds) - 67+ razas de gatos
- [Open Pet Food Facts Database](https://world.openpetfoodfacts.org/) - Ingredientes y seguridad

#### **Ejemplos y Tutoriales**
- Flutter Cookbook (api.flutter.dev/cookbook)
- Supabase Examples (github.com/supabase/supabase/tree/master/examples)
- Riverpod Snippets (riverpod.dev/docs/essentials/first_request)

### Documentos de Contexto o Apoyo Utilizados

#### **Para el Desarrollo**
- **Especificación de Requisitos**: MVP con 7 funcionalidades principales
- **Wireframes**: Flujos de navegación entre pantallas
- **Diagrama ER**: Relaciones entre tablas de Supabase
- **Especificación de APIs**: Contratos de servicios externos

#### **Para el Asistente IA**
- **Prompt de Sistema**: Instrucciones precisas para resúmenes (con disclaimers médicos)
- **Ejemplos de Output**: Estructura JSON esperada del asistente
- **Restricciones de Seguridad**: NO diagnosticar, NO recetar, recomendar veterinario
- **Medical Disclaimers**: "No reemplaza al veterinario"

#### **Para Testing**
- **Test Coverage Goals**: Funcionalidades críticas testeadas
- **Mock Strategies**: Cómo mockear Supabase y HTTP
- **Golden Tests**: Validación de UI constante

### Documentación de las APIs

#### **APIs Externas Integradas**

**1. OpenAI API**
```
URL: https://api.openai.com/v1/chat/completions
Método: POST
Modelo: gpt-4-mini
Autenticación: Bearer Token (secreto en Edge Function)
Documentación: https://platform.openai.com/docs/api-reference

Caso de Uso:
- Input: Datos de mascota, eventos recientes, notas de salud
- Output: Resumen JSON con prioridades y preguntas para veterinario
- Seguridad: API key nunca llega a cliente
```

**2. Dog CEO API**
```
URL Base: https://dog.ceo/api/
Endpoints:
  - GET /breeds/list/all → Lista de razas
  - GET /breed/{name}/images/random → Imagen aleatoria
Autenticación: NINGUNA (pública)
Documentación: https://dog.ceo/dog-api/

Caso de Uso:
- Poblar dropdown de razas de perros
- Mostrar imágenes de mascotas
- Fallback: Lista local de razas comunes
```

**3. The Cat API**
```
URL Base: https://api.thecatapi.com/v1/
Endpoints:
  - GET /breeds → Lista de razas
  - GET /images/search?breed_id={id} → Imágenes de raza
Autenticación: Opcional (API key para más límites)
Documentación: https://thecatapi.com/

Caso de Uso:
- Razas y imágenes de gatos
- Similar a Dog CEO pero para felinos
```

**4. Open Pet Food Facts API**
```
URL Base: https://world.openpetfoodfacts.org/
Endpoint: /cgi/search.pl?search_terms={término}
Autenticación: NINGUNA (pública)
Documentación: https://world.openpetfoodfacts.org/api/

Caso de Uso:
- Búsqueda de ingredientes de alimentos
- Información de productos para mascotas
- Complementa base local de food safety
```

**5. Supabase REST API**
```
URL Base: https://[PROJECT_ID].supabase.co/rest/v1/
Autenticación: 
  - API Key + JWT Token
  - Row Level Security (RLS) por usuario
Documentación: https://supabase.com/docs/guides/api

Operaciones:
  - GET /tablas → Leer datos
  - POST /tablas → Crear registros
  - PATCH /tablas → Actualizar
  - DELETE /tablas → Eliminar
  
Seguridad:
  - Cada usuario solo ve sus datos
  - Validación en lado del servidor
  - Protección contra SQL injection
```

#### **APIs Creadas (si aplica)**
No se creó API propia. Se utiliza Supabase como BaaS completo.

---

## 📊 Resumen de Tecnologías

| Capa | Tecnología | Versión | Propósito |
|------|-----------|---------|-----------|
| **Frontend** | Flutter | 3.x | Multiplataforma UI |
| **Lenguaje** | Dart | 3.8+ | Programación del app |
| **State** | Riverpod | 2.6+ | Gestión de estado |
| **Backend** | Supabase | Cloud | BaaS con PostgreSQL |
| **Database** | PostgreSQL | 15+ | Base de datos relacional |
| **Auth** | Supabase Auth | JWT | Autenticación segura |
| **IA** | OpenAI | gpt-4-mini | Generación de resúmenes |
| **APIs** | 4+ públicas | - | Razas, imágenes, alimentos |
| **HTTP** | Dart:http | ^1.3.0 | Cliente HTTP |
| **Envs** | flutter_dotenv | 5.2+ | Variables de entorno |

---

**Estado Final**: ✅ DOCUMENTACIÓN COMPLETAMENTE ACTUALIZADA

**Fecha**: Mayo 2026
**Responsable**: Alvaro Ferrer
**Proyecto**: PetCare AI Companion - Módulo Vibe Coding
