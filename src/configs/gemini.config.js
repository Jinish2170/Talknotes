import { GoogleGenerativeAI } from "@google/generative-ai";
const genai = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);


/**
 * Generate smart summary for voice notes
 */
const generateSmartSummary = async (text, maxTokens = 1250) => {
  try {
    const model = await genai.getGenerativeModel({ 
      model: "gemini-2.0-flash-exp",
      systemInstruction: `You are a smart note summarization AI. Create concise, actionable summaries of voice notes.

GUIDELINES:
- Extract key points and main topics
- Preserve important details and context
- Use clear, professional language
- Focus on actionable items when present
- Keep summaries between 50-100 words`
    });

    const generationConfig = {
      maxOutputTokens: maxTokens,
      temperature: 0.3,
      topP: 0.8,
    };

    const result = await model.generateContent({
      contents: [{ 
        role: "user", 
        parts: [{ text: `Summarize this voice note clearly and concisely:\n\n${text}` }] 
      }],
      generationConfig,
    });

    return result.response.text();
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(`Failed to generate summary: ${error.message}`);
  }
};

/**
 * Extract action items from voice notes
 */
const generateActionList = async (text, maxTokens = 200) => {
  try {
    const model = genai.getGenerativeModel({ 
      model: "gemini-2.0-flash-exp",
      systemInstruction: `You are a task extraction AI. Identify and format actionable items from voice notes.

GUIDELINES:
- Extract specific tasks, deadlines, and action items
- Format as clear bullet points
- Include context when necessary
- Prioritize urgent or time-sensitive items
- If no actions found, return "No specific action items identified"`
    });

    const generationConfig = {
      maxOutputTokens: maxTokens,
      temperature: 0.2,
      topP: 0.7,
    };

    const result = await model.generateContent({
      contents: [{ 
        role: "user", 
        parts: [{ text: `Extract key tasks and action items from this voice note:\n\n${text}` }] 
      }],
      generationConfig,
    });

    return result.response.text();
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(`Failed to generate action list: ${error.message}`);
  }
};


/**
 * Generate content from transcription using selected style from database
 */
const generateContentFromStyleSelected = async (audioTranscription, styleId) => {
  try {
    // Import database model
    const { NoteStyle } = await import('../models/noteStyle.js');
    
    // Fetch style from database
    const styleRecord = await NoteStyle.findById(styleId);
    if (!styleRecord) {
      throw new Error(`Style with ID ${styleId} not found`);
    }
    
    const model = genai.getGenerativeModel({
      model: "gemini-2.0-flash-exp",
      systemInstruction: `You are an AI note processor that transforms audio transcriptions into well-formatted notes based on specific style requirements.

TASK:
Transform the provided audio transcription according to the given style description.

GUIDELINES:
- Process the raw transcription into coherent, well-structured content
- Apply the specified style requirements precisely
- Maintain all important information from the transcription
- Improve readability and organization
- Correct any transcription errors naturally
- Create a meaningful title and organized content`
    });

    const generationConfig = {
      maxOutputTokens: 1500,
      temperature: 0.4,
      topP: 0.8,
    };

    const prompt = `Please process this audio transcription according to the following style:

STYLE: ${styleRecord.style_name}
STYLE DESCRIPTION: ${styleRecord.style_description}

AUDIO TRANSCRIPTION:
${audioTranscription}

Please transform this transcription into a well-formatted note following the style requirements above.`;

    const result = await model.generateContent({
      contents: [{
        role: "user",
        parts: [{ text: prompt }]
      }],
      generationConfig,
    });

    return result.response.text();
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(`Failed to generate styled content: ${error.message}`);
  }
};

export default {genai, generateSmartSummary, generateActionList, generateContentFromStyleSelected};