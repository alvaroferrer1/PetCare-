# PetCare AI Companion (React & Node.js Version)

<div align="center">

**Aplicación full-stack para organizar el cuidado de mascotas con React, Express, Tailwind CSS e IA (Gemini).**

Proyecto final del módulo **Desarrollo Vibe Coding** (migrado de Flutter a React/Node.js).

![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-8E75C2?style=for-the-badge&logo=google-gemini&logoColor=white)

</div>

---

## Descripción

**PetCare AI Companion** es una aplicación full-stack diseñada para ayudar a dueños de perros y gatos a centralizar toda la información de cuidado, salud y bienestar de sus peludos de forma visual, organizada y offline-first.

La aplicación permite registrar múltiples mascotas, gestionar un historial cronológico de vacunas, desparasitaciones, visitas al veterinario, control de peso, cargar cartillas de vacunación, y consultar la seguridad alimentaria de alimentos cotidianos y productos comerciales.

También incluye una avanzada integración de IA con **Google Gemini (gemini-2.5-flash)** para sintetizar de manera segura estados de salud diarios, organizar prioridades de cuidado y formular preguntas clínicas estructuradas para preparar la próxima visita al veterinario.

> ⚠️ **Aviso Importante:** La IA es una herramienta organizadora. No diagnostica, no recomienda medicamentos ni sustituye de ningún modo a un profesional veterinario cualificado.

---

## Stack Técnico (React / Node.js)

| Área | Tecnología |
| --- | --- |
| **Frontend** | React 19 + TypeScript |
| **Estilos** | Tailwind CSS v4 + Lucide Icons |
| **Gráficos** | Recharts (Evolución de peso y energía diaria) |
| **Backend** | Express + Node.js (con empaquetado en CommonJS usando esbuild) |
| **IA** | SDK oficial `@google/genai` (Modelo: `gemini-2.5-flash`) |
| **APIs Externas** | Dog CEO API, The Cat API, Open Pet Food Facts (world.openpetfoodfacts.org) |
| **Persistencia** | Sincronización robusta en `localStorage` (Offline-first / Cero fugas de datos) |

---

## Funcionalidades Principales

1. **Gestión Multimascota**: Creación, actualización y visualización detallada de perros y gatos, con sus fichas médicas individuales.
2. **Historial y Timeline**: Registro categorizado por tipo de evento (Vacunas, Medicación, Visitas, Higiene, etc.) con estados pendiente/completado.
3. **Control de Peso y Energía**: Registro histórico de peso en kilogramos y niveles diarios de energía representados en gráficas interactivas con Recharts.
4. **Seguridad Alimentaria (Food Safety)**: Buscador local de ingredientes (chocolate, uvas, etc.) con avisos detallados y niveles de toxicidad, con fallback a búsquedas reales de piensos en Open Pet Food Facts.
5. **Asistente de IA (Gemini)**: Generador de informes clínicos, prioridades de cuidado y plantillas de preguntas veterinarias basadas en el historial diario de la mascota.
6. **Modo Demo Instantáneo**: Permite explorar toda la potencia del MVP con un solo clic pre-poblando datos completos de Luna (Border Collie) y Michi (gato doméstico europeo).

---

## Instalación y Ejecución Local

### Prerrequisitos
- Node.js (v22 o superior)
- npm

### Pasos

1. Instalar las dependencias del proyecto:
   ```bash
   npm install
   ```

2. Definir tu clave de Gemini en un archivo `.env`:
   ```env
   GEMINI_API_KEY=tu_clave_api_aqui
   ```

3. Arrancar el servidor de desarrollo (con proxy Vite para API y Hot Reloading):
   ```bash
   npm run dev
   ```

4. Compilar para producción:
   ```bash
   npm run build
   ```

5. Iniciar en producción:
   ```bash
   npm run start
   ```
