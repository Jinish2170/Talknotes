import { GoogleGenAI } from "@google/genai";
import { configDotenv } from "dotenv";
configDotenv();
const ai = new GoogleGenAI({gemeniApiKey: process.env.GEMINI_API_KEY});

async function main() {
    const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: "Explain how AI works with neural networks",
        config: {
        thinkingConfig: {
            thinkingBudget: 10, // Allows minimal thinking
        },
        }
    });
    console.log(response.text);
}

await main();