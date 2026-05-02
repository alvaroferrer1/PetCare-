import OpenAI from "npm:openai@4.104.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return Response.json(
        { error: "OPENAI_API_KEY is not configured" },
        { status: 500, headers: corsHeaders },
      );
    }

    const payload = await req.json();
    const openai = new OpenAI({ apiKey });

    const response = await openai.responses.create({
      model: "gpt-4.1-mini",
      input: [
        {
          role: "system",
          content:
            "Eres un asistente de organizacion de cuidados de mascotas. No diagnostiques, no recomiendes medicamentos ni dosis, y recomienda veterinario ante sintomas preocupantes. Responde solo JSON valido en espanol.",
        },
        {
          role: "user",
          content: JSON.stringify(payload),
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: "care_summary",
          schema: {
            type: "object",
            additionalProperties: false,
            properties: {
              summary: { type: "string" },
              priorities: { type: "array", items: { type: "string" } },
              vet_questions: { type: "array", items: { type: "string" } },
              general_recommendations: {
                type: "array",
                items: { type: "string" },
              },
              safety_notice: { type: "string" },
            },
            required: [
              "summary",
              "priorities",
              "vet_questions",
              "general_recommendations",
              "safety_notice",
            ],
          },
        },
      },
    });

    const text = response.output_text;
    return new Response(text, {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (_error) {
    return Response.json(
      {
        summary:
          "No se pudo generar el resumen con IA en este momento. Revisa los cuidados pendientes manualmente.",
        priorities: ["Comprobar recordatorios pendientes."],
        vet_questions: ["¿Hay sintomas que requieren una revision veterinaria?"],
        general_recommendations: [
          "Mantener el historial de la mascota actualizado.",
        ],
        safety_notice:
          "La IA no diagnostica, no recomienda medicamentos ni sustituye a un profesional veterinario.",
      },
      { status: 200, headers: corsHeaders },
    );
  }
});
