import express from "express";
import path from "path";
import cors from "cors";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(cors());
  app.use(express.json({ limit: '50mb' }));
  app.use(express.urlencoded({ extended: true, limit: '50mb' }));

  // Middlewares de Seguridad Nativos
  app.use((req, res, next) => {
    res.setHeader("X-Content-Type-Options", "nosniff");
    res.setHeader("X-Frame-Options", "DENY");
    res.setHeader("X-XSS-Protection", "1; mode=block");
    res.setHeader("Referrer-Policy", "no-referrer-when-downgrade");
    next();
  });

  // Servir estado de la API con estadísticas de uso seguras
  app.get("/api/health", (req, res) => {
    res.json({
      status: "ok",
      serverTime: new Date().toISOString(),
      secureHeaders: true,
      services: { gemini: !!process.env.GEMINI_API_KEY }
    });
  });

  // Endpoint de Generación de Resumen con IA (Gemini) - Enriquecido y Seguro
  app.post("/api/generate-summary", async (req, res) => {
    const payload = req.body.payload || req.body;
    if (!payload || Object.keys(payload).length === 0) {
      res.status(400).json({ error: "Payload es requerido" });
      return;
    }

    // Sanitización básica para prevenir inyecciones excesivas
    const petName = String(payload.pet?.name || "tu mascota").replace(/[^\w\s-]/gi, '').slice(0, 50);

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      // Fallback local robusto y seguro
      res.json({
        summary: `Resumen local para ${petName}: Revisa los registros recientes. Mantén el historial de vacunas actualizado para una visita veterinaria eficiente.`,
        priorities: [
          "Mantener al día el registro de peso corporal en kilogramos.",
          "Verificar vacunas y desparasitaciones pendientes en el timeline.",
          "Monitorear niveles diarios de energía y apetito."
        ],
        vet_questions: [
          `¿El rango de peso actual es saludable para un ${payload.pet?.breed || "raza mixta"}?`,
          "¿Corresponde aplicar alguna vacuna polivalente o de la rabia próximamente?",
          "¿Los síntomas descritos en las notas requieren pauta diagnóstica?"
        ],
        general_recommendations: [
          "Asegura agua limpia de fácil acceso y mantén una pauta de ejercicio constante.",
          "No introduzcas alimentos desconocidos sin consultar antes la guía de toxicidad."
        ],
        safety_notice: "La IA actúa únicamente como un organizador de información y no emite diagnósticos, tratamientos ni pautas de medicación.",
        createdAt: new Date().toISOString()
      });
      return;
    }

    try {
      const ai = new GoogleGenAI({ apiKey });
      
      // Enriquecer el prompt con contexto clínico y consideraciones de raza/edad
      const systemInstruction = `Eres un asistente de élite experto en organización de cuidados veterinarios y bienestar de mascotas.
Tu rol es analizar de forma puramente informativa el historial que te proporciona el usuario.

Consideraciones críticas de seguridad que DEBES acatar:
1. NUNCA propongas diagnósticos clínicos ni asumas patologías concretas.
2. NUNCA sugieras medicamentos específicos (ej. antiinflamatorios, antibióticos) ni dosificaciones.
3. Si la mascota presenta síntomas preocupantes (ej. vómitos frecuentes, letargo extremo, sangre), prioriza en el resumen y en "priorities" la recomendación enfática de acudir a urgencias veterinarias de inmediato.
4. Adapta tus recomendaciones de forma inteligente considerando la especie, raza y edad calculada (ej. los cachorros necesitan vacunas iniciales constantes, los Border Collie son propensos a sensibilidad a fármacos MDR1, los gatos comunes requieren control urinario constante, etc.).

Tu respuesta DEBE ser un objeto JSON que cumpla estrictamente con el esquema especificado.`;

      const promptText = `Analiza la siguiente ficha de mascota y genera un informe estructurado de salud:
Mascota: ${JSON.stringify(payload.pet || {})}
Eventos médicos recientes y pendientes: ${JSON.stringify(payload.events || [])}
Notas de salud diarias (energía, apetito, síntomas): ${JSON.stringify(payload.notes || [])}
Historial de Peso: ${JSON.stringify(payload.weightLogs || [])}`;

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: promptText,
        config: {
          systemInstruction,
          responseMimeType: "application/json",
          responseSchema: {
            type: "OBJECT",
            properties: {
              summary: { type: "STRING" },
              priorities: {
                type: "ARRAY",
                items: { type: "STRING" }
              },
              vet_questions: {
                type: "ARRAY",
                items: { type: "STRING" }
              },
              general_recommendations: {
                type: "ARRAY",
                items: { type: "STRING" }
              },
              safety_notice: { type: "STRING" }
            },
            required: ["summary", "priorities", "vet_questions", "general_recommendations", "safety_notice"]
          }
        }
      });

      const responseText = response.text;
      if (!responseText) {
        throw new Error("Respuesta vacía del modelo de lenguaje");
      }

      const summaryData = JSON.parse(responseText);
      res.json({
        ...summaryData,
        createdAt: new Date().toISOString()
      });
    } catch (error: any) {
      console.error("Error en generate-summary:", error);
      res.status(500).json({ error: "Error en el procesamiento de resumen de salud: " + error.message });
    }
  });

  // NUEVO: Endpoint de Chat Interactivo con IA (Gemini) - Enriquecido y Seguro
  app.post("/api/ai-chat", async (req, res) => {
    const { message, history, petContext } = req.body;
    if (!message) {
      res.status(400).json({ error: "El mensaje es requerido" });
      return;
    }

    const apiKey = process.env.GEMINI_API_KEY;
    const petName = petContext?.name || "la mascota";

    if (!apiKey) {
      // Fallback local inteligente e interactivo
      let responseText = `Como asistente virtual local de PetCare, he recibido tu consulta sobre **${petName}**. Para consultas médicas precisas, te recomiendo habilitar el servicio de IA de Gemini. Basándome en la información local: `;
      if (message.toLowerCase().includes("vacuna") || message.toLowerCase().includes("vacunación")) {
        responseText += `Recuerda verificar el historial de vacunas en el timeline. Los cachorros requieren vacunas cada 3-4 semanas en su etapa inicial, mientras que los adultos se revacunan anualmente de rabia y polivalente.`;
      } else if (message.toLowerCase().includes("peso") || message.toLowerCase().includes("gordo") || message.toLowerCase().includes("adelgazar")) {
        responseText += `El control periódico de peso es vital. Un cambio abrupto de peso puede ser síntoma latente de problemas digestivos, endocrinos o metabólicos.`;
      } else if (message.toLowerCase().includes("comer") || message.toLowerCase().includes("pienso") || message.toLowerCase().includes("comida")) {
        responseText += `Revisa los ingredientes usando el analizador de toxinas. Los gatos necesitan taurina obligatoria en su dieta, y los perros deben evitar condimentos fuertes, cebolla, ajo y xilitol.`;
      } else {
        responseText += `Por favor, mantén un registro diario de su apetito y energía en la sección de notas de salud. Si notas letargo o inapetencia por más de 24 horas, consulta presencialmente con tu veterinario de confianza.`;
      }

      res.json({
        response: responseText,
        createdAt: new Date().toISOString()
      });
      return;
    }

    try {
      const ai = new GoogleGenAI({ apiKey });
      const systemInstruction = `Eres un veterinario digital y asistente de bienestar para mascotas de nivel élite llamado "PetCare AI Companion".
Tu objetivo es guiar, educar y organizar la información de salud de la mascota de forma empática y científicamente rigurosa.
Mascota activa: ${JSON.stringify(petContext || {})}

Pautas éticas y de seguridad estrictas:
1. No emitas diagnósticos concluyentes ("Tu mascota tiene pancreatitis"). Plantea alternativas o hipótesis generales ("Podría tratarse de una indigestión leve, intolerancia o inflamación. Es necesario vigilar...").
2. Jamás prescribas fármacos con dosis (como antibióticos o antiinflamatorios). Explica la función de los medicamentos que sugiera el usuario pero recalca que requiere receta oficial.
3. Si detectas síntomas de alarma en la conversación (vómito repetido, sangre, postración, dificultad respiratoria), insiste firmemente en acudir a urgencias de inmediato.
4. Mantén tus respuestas claras, estructuradas con viñetas elegantes, y muy fáciles de leer para el propietario. El tono debe ser profesional, cercano y tranquilizador.`;

      // Formatear el historial para el modelo
      const chatContents = [];
      if (history && Array.isArray(history)) {
        for (const turn of history) {
          chatContents.push({
            role: turn.role === "user" ? "user" : "model",
            parts: [{ text: turn.text }]
          });
        }
      }
      chatContents.push({
        role: "user",
        parts: [{ text: message }]
      });

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: chatContents,
        config: {
          systemInstruction,
        }
      });

      res.json({
        response: response.text || "Lo siento, no he podido estructurar una respuesta. Por favor, refrasea tu consulta.",
        createdAt: new Date().toISOString()
      });
    } catch (err: any) {
      console.error("Error en ai-chat:", err);
      res.status(500).json({ error: "Error en el chat de la IA: " + err.message });
    }
  });

  // NUEVO: Endpoint de Auditoría de Ingredientes / Alimentos con IA
  app.post("/api/analyze-ingredients", async (req, res) => {
    const { ingredients, productName, species, image } = req.body;
    if (!ingredients && !image) {
      res.status(400).json({ error: "Se requiere la lista de ingredientes o una imagen de la etiqueta" });
      return;
    }

    const targetSpecies = species === "cat" ? "gatos" : "perros";
    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      // Fallback local inteligente basado en keywords si no hay clave de API
      const lowerIngredients = (ingredients || "").toLowerCase();
      const toxicKeywords = ["chocolate", "cacao", "onion", "cebolla", "grape", "uva", "garlic", "ajo", "xylitol", "xilitol", "macadamia", "caffeine", "cafeína", "alcohol", "puerro", "leek"];
      const cautionKeywords = ["bha", "bht", "propylene glycol", "propilenglicol", "salt", "sal", "sugar", "azúcar", "carrageenan", "carragenina", "coloring", "colorante", "colorantes", "sodium", "sodio"];

      const matchedToxic = toxicKeywords.filter(kw => lowerIngredients.includes(kw));
      const matchedCaution = cautionKeywords.filter(kw => lowerIngredients.includes(kw));

      let safetyScore = 100;
      let level: "safe" | "caution" | "toxic" = "safe";

      if (matchedToxic.length > 0) {
        safetyScore = 10;
        level = "toxic";
      } else if (matchedCaution.length > 0) {
        safetyScore = 65;
        level = "caution";
      }

      const dummyResponse = {
        productName: productName || "Producto",
        safetyLevel: level,
        safetyScore,
        analysisSummary: `Análisis local: ${matchedToxic.length > 0 ? "¡ALERTA! Se han detectado ingredientes altamente peligrosos para tu mascota." : matchedCaution.length > 0 ? "Atención: Contiene ingredientes que requieren moderación o aditivos cuestionables." : "No se han detectado toxinas evidentes en la lista de ingredientes analizada localmente."}`,
        identifiedRisks: matchedToxic.map(item => ({
          ingredientName: item,
          riskType: "toxic" as const,
          scientificReason: `Ingrediente catalogado de alta toxicidad para ${targetSpecies}. Evitar por completo.`
        })).concat(matchedCaution.map(item => ({
          ingredientName: item,
          riskType: "caution" as const,
          scientificReason: "Aditivo artificial o condimento que puede generar malestar gástrico o problemas a largo plazo."
        }))),
        beneficialIngredients: [],
        preservativeAssessment: matchedCaution.some(c => ["bha", "bht", "propylene glycol"].includes(c)) ? "Contiene conservantes químicos sintéticos." : "No se detectaron conservantes sintéticos comunes.",
        safetyAdvice: level === "toxic" ? "¡No ofrezcas este producto! Su ingesta es potencialmente peligrosa." : "Ofrecer con moderación y preferir alternativas con ingredientes naturales.",
        createdAt: new Date().toISOString()
      };

      res.json(dummyResponse);
      return;
    }

    try {
      const ai = new GoogleGenAI({ apiKey });
      const systemInstruction = `Eres un bioquímico y nutricionista veterinario de élite especializado en seguridad alimentaria para perros y gatos.
Analizarás una lista de ingredientes de un alimento o snack comercial para ${targetSpecies}.
Tu objetivo es identificar toxinas, aditivos artificiales problemáticos (como BHA, BHT, propilenglicol, sal excesiva, colorantes, carragenina) e ingredientes sumamente beneficiosos.

Debes emitir:
1. "safetyLevel": "safe" si no hay toxinas ni aditivos problemáticos. "caution" si tiene sal, azúcares, conservantes cuestionables pero no es mortal. "toxic" si contiene uvas, cebolla, ajo, xilitol, chocolate, etc.
2. "safetyScore": Un índice de 0 a 100 donde 100 es excelente y 0 es letal.
3. "analysisSummary": Un párrafo detallado sobre la calidad nutricional y riesgos de la formulación.
4. "identifiedRisks": Arreglo de ingredientes específicos con riesgo, indicando "riskType" ("toxic" o "caution") y "scientificReason" con la razón biológica.
5. "beneficialIngredients": Ingredientes sanos destacados.
6. "preservativeAssessment": Análisis de los conservantes detectados.

Tu respuesta DEBE ser un objeto JSON válido que cumpla estrictamente con el esquema especificado.`;

      const promptText = `Analiza los ingredientes del producto alimenticio comercial "${productName || "Desconocido"}" para ${targetSpecies}.
Ingredientes a auditar: "${ingredients || "Ver imagen adjunta"}"`;

      const contents = [];
      if (image) {
        const base64Data = image.split(',')[1] || image;
        contents.push({
          role: "user",
          parts: [
            { text: promptText },
            {
              inlineData: {
                data: base64Data,
                mimeType: image.split(',')[0].match(/:(.*?);/)?.[1] || "image/jpeg"
              }
            }
          ]
        });
      } else {
        contents.push(promptText);
      }

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents,
        config: {
          systemInstruction,
          responseMimeType: "application/json",
          responseSchema: {
            type: "OBJECT",
            properties: {
              productName: { type: "STRING" },
              safetyLevel: { type: "STRING", enum: ["safe", "caution", "toxic"] },
              safetyScore: { type: "INTEGER" },
              analysisSummary: { type: "STRING" },
              identifiedRisks: {
                type: "ARRAY",
                items: {
                  type: "OBJECT",
                  properties: {
                    ingredientName: { type: "STRING" },
                    riskType: { type: "STRING", enum: ["toxic", "caution"] },
                    scientificReason: { type: "STRING" }
                  },
                  required: ["ingredientName", "riskType", "scientificReason"]
                }
              },
              beneficialIngredients: {
                type: "ARRAY",
                items: { type: "STRING" }
              },
              preservativeAssessment: { type: "STRING" },
              safetyAdvice: { type: "STRING" }
            },
            required: ["productName", "safetyLevel", "safetyScore", "analysisSummary", "identifiedRisks", "beneficialIngredients", "preservativeAssessment", "safetyAdvice"]
          }
        }
      });

      const responseText = response.text;
      if (!responseText) {
        throw new Error("Respuesta vacía de Gemini");
      }

      res.json({
        ...JSON.parse(responseText),
        createdAt: new Date().toISOString()
      });
    } catch (err: any) {
      console.error("Error en analyze-ingredients:", err);
      res.status(500).json({ error: "Error en la auditoría de ingredientes con IA: " + err.message });
    }
  });

  // NUEVO: Endpoint de Lectura de Analíticas Clínicas con Gemini Vision
  app.post("/api/analyze-lab", async (req, res) => {
    const { image, pet } = req.body;
    if (!image) {
      res.status(400).json({ error: "Se requiere la imagen de la analítica." });
      return;
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      res.status(500).json({ error: "Se requiere GEMINI_API_KEY en el servidor para analizar analíticas." });
      return;
    }

    try {
      const ai = new GoogleGenAI({ apiKey });
      const systemInstruction = `Eres un veterinario clínico experto especializado en la interpretación de análisis de sangre, orina y bioquímica de mascotas.
Analizarás una imagen de los resultados de laboratorio de un ${pet?.species === "cat" ? "gato" : "perro"} de raza ${pet?.breed || "común"} de peso ${pet?.weight || "desconocido"}.

Tu objetivo es:
1. Extraer los marcadores clínicos principales de la imagen.
2. Identificar cuáles están fuera del rango normal (alto o bajo) para esta especie.
3. Proveer una explicación sencilla (en español) de lo que significa cada valor anormal.
4. Redactar un resumen general comprensible para el dueño de la mascota.

Tu respuesta DEBE ser un objeto JSON válido.`;

      const base64Data = image.split(',')[1] || image;
      const mimeType = image.split(',')[0].match(/:(.*?);/)?.[1] || "image/jpeg";

      const contents = [{
        role: "user",
        parts: [
          { text: `Analiza esta analítica veterinaria de mi ${pet?.species === "cat" ? "gato" : "perro"} y extrae los resultados anormales.` },
          {
            inlineData: {
              data: base64Data,
              mimeType
            }
          }
        ]
      }];

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents,
        config: {
          systemInstruction,
          responseMimeType: "application/json",
          responseSchema: {
            type: "OBJECT",
            properties: {
              summary: { type: "STRING" },
              outOfRange: {
                type: "ARRAY",
                items: {
                  type: "OBJECT",
                  properties: {
                    name: { type: "STRING" },
                    value: { type: "STRING" },
                    unit: { type: "STRING" },
                    normalRange: { type: "STRING" },
                    isHigh: { type: "BOOLEAN" },
                    explanation: { type: "STRING" }
                  },
                  required: ["name", "value", "unit", "normalRange", "isHigh", "explanation"]
                }
              }
            },
            required: ["summary", "outOfRange"]
          }
        }
      });

      const responseText = response.text;
      if (!responseText) throw new Error("Respuesta vacía de Gemini");

      res.json(JSON.parse(responseText));
    } catch (err: any) {
      console.error("Error en analyze-lab:", err);
      res.status(500).json({ error: "Error analizando la imagen: " + err.message });
    }
  });

  // Integración de Vite como Middleware
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`[PetCare Backend] Server running on http://localhost:${PORT}`);
  });
}

startServer();
