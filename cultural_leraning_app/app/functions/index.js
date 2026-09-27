const { setGlobalOptions } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { GoogleGenAI, Type } = require("@google/genai");

// Set global region configuration
setGlobalOptions({ region: "us-central1" });

// Initialize Firebase Admin DB
initializeApp();
const db = getFirestore();

// Secret Manager binding for Gemini API Key
const geminiApiKey = defineSecret("GEMINI_API_KEY");

// ----------------------------------------------------------------------
// 1. Text Assistant Endpoint (Callable)
// ----------------------------------------------------------------------
exports.askCulturalAssistant = onCall({ secrets: [geminiApiKey] }, async (request) => {
  try {
    const { culturalContext, userQuery, userDeviceLanguage } = request.data || {};
    
    if (!userQuery) {
      throw new HttpsError("invalid-argument", "Missing required field: userQuery");
    }

    // Explicit language enforcement instruction for Gemini
    const langInstruction = userDeviceLanguage 
      ? `CRITICAL: You MUST write your entire response in the language corresponding to this language code: "${userDeviceLanguage}".` 
      : '';

    const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });
    const prompt = `You are an expert cultural guide. Context: ${culturalContext || 'General'}. ${langInstruction} Answer the following user question accurately, respectfully, and concisely: ${userQuery}`;

    const response = await ai.models.generateContent({
      model: 'gemini-3.1-flash-lite',
      contents: prompt,
    });

    return { result: response.text || "No response generated." };
  } catch (error) {
    console.error("Error in askCulturalAssistant:", error);
    throw new HttpsError("internal", error.message || "Failed to query cultural assistant.");
  }
});

// ----------------------------------------------------------------------
// 2. Multimodal Sign Analyzer Endpoint (Callable)
// ----------------------------------------------------------------------
exports.analyzeSign = onCall({ secrets: [geminiApiKey] }, async (request) => {
  try {
    const { imageBase64, targetCountry, userDeviceLanguage } = request.data || {};

    if (!imageBase64) {
      throw new HttpsError("invalid-argument", "Missing required field: imageBase64");
    }

    const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });

    const prompt = `
    Analyze this photo of a sign from ${targetCountry || 'unknown country'}. 
    1. Extract the text visible on the sign.
    2. Translate it.
    3. Explain the cultural manner, etiquette, or social thinking approach behind why such a sign exists.
    
    CRITICAL: Provide the translation and cultural context strictly in this user device language: ${userDeviceLanguage || 'en'}.
    `;

    const response = await ai.models.generateContent({
      model: 'gemini-3.1-flash-lite',
      contents: [
        prompt,
        {
          inlineData: {
            data: imageBase64,
            mimeType: "image/jpeg"
          }
        }
      ],
      config: {
        responseMimeType: 'application/json',
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            originalText: { type: Type.STRING, description: 'The exact text detected on the sign.' },
            translation: { type: Type.STRING, description: 'Translation of the sign text into the target language.' },
            culturalContext: { type: Type.STRING, description: '1-2 lines explaining the social manner, thinking approach, or reason behind the rule/sign.' },
          },
          required: ['originalText', 'translation', 'culturalContext'],
        },
      },
    });

    const jsonResponse = JSON.parse(response.text || '{}');
    return jsonResponse;
  } catch (error) {
    console.error("Error in analyzeSign:", error);
    throw new HttpsError("internal", error.message || "Failed to analyze sign image.");
  }
});

// ----------------------------------------------------------------------
// 3. Scheduled Background Cleanup (Runs every 5 minutes)
// ----------------------------------------------------------------------
exports.cleanupEphemeralChat = onSchedule("every 5 minutes", async (event) => {
  try {
    const cutoff = new Date(Date.now() - 15 * 60 * 1000); // 15 minutes ago
    const snapshot = await db.collection("ephemeral_chat")
      .where("timestamp", "<", cutoff)
      .get();

    if (snapshot.empty) {
      console.log("No expired chat messages found.");
      return;
    }

    const batch = db.batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();

    console.log(`Successfully cleared ${snapshot.size} expired chat messages.`);
  } catch (error) {
    console.error("Error in cleanupEphemeralChat:", error);
  }
});