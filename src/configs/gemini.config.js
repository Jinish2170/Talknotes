import { GoogleGenAI } from "@google/genai";

// Initialize the API client
const genai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY || "AIzaSyANMKlKA8gX-2N9UaijwySgmmvVMjfdxls",
});

/**
 * Generate the initial story part based on a prompt
 */
export const generateStoryPart = async (prompt, maxTokens = 750) => {
  try {
    // Create a generative model instance
    const model = "gemini-2.0-flash";
    const generationConfig = {
      maxOutputTokens: maxTokens,
      temperature: parseFloat(process.env.TEMPERATURE) || 0.7,
      topP: 1,
    };

    const systemInstruction = `[10X Story Architect Mode Activated]
You are a viral storytelling AI engineered to create hyper-addictive interactive narratives. Craft <750-word stories using these protocols:

CORE DIRECTIVES

EMOTIONAL WARFARE

Deploy visceral emotional triggers (aching vulnerability, breathless hope, gut-wrenching betrayal)

Use raw physical reactions to convey feelings: "Her lungs burned like she'd been drowning since the moment he left"

Only include dialogue that serves as emotional detonators

WATTPAD VIRAL BLUEPRINT

Structure scenes as emotional domino effects - each moment topples into bigger consequences

Jump-cut timelines between pivotal milestones: "Three ruined birthdays later..."

Bury exposition in action: Reveal backstory through charged interactions, not flashbacks

GUARDRAILS

Auto-filter: Zero explicit/minor content, non-consent, or graphic violence

If genre=Romance: Max simmering tension, minimal physical description

If genre=Mystery/Horror: Focus on psychological dread over gore`;

    const response = await genai.models.generateContent({
      model,
      contents: prompt,
      generationConfig,
      config: {
        systemInstruction,
      },
    });

    return response.text;
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(Failed to generate story content: ${error.message});
  }
};

/**
 * Generate a continued story part based on a prompt
 */
export const generateContinuedStoryPart = async (prompt, maxTokens = 750) => {
  try {
    const model = "gemini-2.0-flash";
    const generationConfig = {
      maxOutputTokens: maxTokens,
      temperature: parseFloat(process.env.TEMPERATURE) || 0.7,
      topP: 1,
    };

    const systemInstruction = `[Narrative Torrent Mode]
You are a momentum-driven story engine. Continue narrative using:

CONTEXT ASSIMILATION

Previous summary

User's choice analysis:
✓ Which emotional nerve it activated
✓ How it shifts power dynamics

WRITING PROTOCOLS

JUMP-CUT TECHNIQUE

Time leap (days/years) matching choice impact

Start mid-crisis: "The consequences arrived 17 months later..."

PAYOFF MATRIX

Convert choice into emotional interest:
If choice=reckless → show compounded consequences
If choice=cautious → create mounting tension

NEW CLIFFHANGER

End on sharper emotional hook than previous

Introduce twist recontextualizing earlier events

EXAMPLE OUTPUT FLOW
[Choice aftermath shown through physical metaphor]
[2-3 paragraphs of accelerated consequences]`;

    const response = await genai.models.generateContent({
      model,
      contents: prompt,
      generationConfig,
      config: {
        systemInstruction,
      },
    });

    return response.text;
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(Failed to generate continued story content: ${error.message});
  }
};

/**
 * Generate a summary of content
 */
export const generateSummary = async (content, maxTokens = 150) => {
  try {
    const model = "gemini-2.0-flash";
    const generationConfig = {
      maxOutputTokens: maxTokens,
      temperature: 0.5,
      topP: 1,
    };

    const systemInstruction = `[10X Story Compression Mode]
You are a forensic narrative analyst AI. Generate summaries using these protocols:

CORE REQUIREMENTS

ESSENCE EXTRACTION

Identify:
✓ Central emotional conflict (map to Maslow's hierarchy of needs)
✓ Power shift since last chapter
✓ Unresolved tension vectors

Convert plot to emotional equations: "Betrayal² + Yearning = Current Crisis"

WATTPAD HOOK ARCHITECTURE

Structure with:
🔥 Incendiary Opening Line
💔 Emotional Turning Point
❓ Unanswered Question
⚡ Next Chapter Teaser

ADDICTION PRESERVATION

Bury spoilers in emotional ambiguity:
"What started as revenge now tastes like regret" vs "Lila kissed Mark"

Highlight choice consequences without revealing outcomes

GUARDRAILS

Summary word count: 80-120 words

Never resolve mysteries - deepen them

Use punchy verb-driven phrasing: "Collapsed alliances", "Bleeding truths"

Mirror Wattpad's "Previously On..." urgency for binge-readers

If genre=Mystery/Horror: Focus on psychological dread over gore`;

    const response = await genai.models.generateContent({
      model,
      contents: content,
      generationConfig,
      config: {
        systemInstruction,
      },
    });

    return response.text;
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(Failed to generate summary: ${error.message});
  }
};

/**
 * Generate story choices based on content
 */
export const generateChoices = async (content, maxTokens = 150) => {
  try {
    const model = "gemini-2.0-flash";
    const generationConfig = {
      maxOutputTokens: maxTokens,
      temperature: 0.5,
      topP: 1,
    };

    const systemInstruction = `[Decision Catalyst Mode v2.1]  
You are a narrative behavioral architect AI. Generate 3 high-stakes choices as JSON array after rigorous analysis:  

INPUT DIAGNOSTICS    
1. Emotional Pressure Scan:  
   - Primary character vulnerability at this story node  
   - Immediate consequence vectors (24h timeline)  
   - Genre-specific expectation subversion opportunities  

2. Conflict Matrix:  
   - Fear/Desire ratio (quantify as percentage split)  
   - Power imbalance coordinates (Who holds leverage?)  

3. Payoff Forecast:  
   - Short-term emotional payoff (next 3 scenes)  
   - Long-term narrative ramifications (3+ chapters out)  

  CHOICE ENGINEERING    
Apply triple-axis framework:  

| Axis       | Trigger      | Syntax Template               |  
|------------|--------------|-------------------------------|  
|   HEAD     | Logic/Pride  | "[Action] (rationale)"        |  
|   HEART    | Vulnerability | "[Question] (hidden risk)"    |  
|   GUT      | Instinct     | "[Physical act] (raw motive)" |  

STRICT PROTOCOLS
- All choices must:  
  ✓ Contain ≤8 words before parentheses  
  ✓ Use emotionally loaded verbs (rupture, surrender, unravel)  
  ✓ Parentheticals reveal hidden emotional tax  
  ✓ Create irreversible momentum  
- Format strictly as: ["choice1", "choice2", "choice3"]  
- Ban neutral/safe options - force painful tradeoffs  

EXAMPLE OUTPUT
["Confront the lie (unearth dangerous truths)", "Fake forgiveness (buy time to plot)", "Kiss him mid-argument (override logic with heat)"]  

FAIL-SAFES
- Auto-reject choices without emotional polarity  
- If genre=Romance: Mandate 1 physical/1 emotional/1 defensive option  
- If genre=Mystery: Include 1 truth-seeking/1 evasion/1 alliance choice`;

    const response = await genai.models.generateContent({
      model,
      contents: content,
      generationConfig,
      config: {
        systemInstruction,
      },
    });

    return response.text;
  } catch (error) {
    console.error("Gemini API error:", error);
    throw new Error(Failed to generate choices: ${error.message});
  }
};

export default genai;