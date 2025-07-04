import { SpeechClient } from '@google-cloud/speech';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import https from 'https';
import http from 'http';

// Get current directory for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config();

// Service account credentials from environment variables
const serviceAccountKey = {
  type: "service_account",
  project_id: process.env.GOOGLE_CLOUD_PROJECT_ID || "astute-window-464106-p2",
  private_key_id: process.env.GOOGLE_CLOUD_PRIVATE_KEY_ID,
  private_key: process.env.GOOGLE_CLOUD_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  client_email: process.env.GOOGLE_CLOUD_CLIENT_EMAIL,
  client_id: process.env.GOOGLE_CLOUD_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.GOOGLE_CLOUD_CLIENT_X509_CERT_URL,
  universe_domain: "googleapis.com"
};

// Validate required environment variables
const requiredEnvVars = [
  'GOOGLE_CLOUD_PRIVATE_KEY',
  'GOOGLE_CLOUD_CLIENT_EMAIL',
  'GOOGLE_CLOUD_PRIVATE_KEY_ID',
  'GOOGLE_CLOUD_CLIENT_ID'
];

const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
if (missingVars.length > 0) {
  throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
}

// Initialize Speech Client with credentials
const speechClient = new SpeechClient({
  credentials: serviceAccountKey,
  projectId: serviceAccountKey.project_id,
});

/**
 * Download audio file from URL (Cloudinary) stored in database in field ai_note
 */
const downloadAudioFromUrl = async (audioUrl) => {
  return new Promise((resolve, reject) => {
    const protocol = audioUrl.startsWith('https:') ? https : http;
    
    protocol.get(audioUrl, (response) => {
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to download audio: ${response.statusCode}`));
        return;
      }

      const chunks = [];
      response.on('data', (chunk) => chunks.push(chunk));
      response.on('end', () => {
        const audioBuffer = Buffer.concat(chunks);
        resolve(audioBuffer);
      });
    }).on('error', (error) => {
      reject(new Error(`Download error: ${error.message}`));
    });
  });
};

/**
 * Process audio note from database - Download from Cloudinary URL and transcribe
 */
export const processAudioNoteFromDB = async (audioNoteUrl, options = {}) => {
  try {
    // Download audio from Cloudinary URL
    console.log('Downloading audio from:', audioNoteUrl);
    const audioBuffer = await downloadAudioFromUrl(audioNoteUrl);

    // Default configuration for speech recognition
    const defaultConfig = {
      encoding: 'LINEAR16',
      languageCode: 'en-US',
      enableAutomaticPunctuation: true,
      enableWordTimeOffsets: true,
      model: 'latest_long', // Better for longer audio
    };

    const config = { ...defaultConfig, ...options };

    // Prepare audio for Google Speech API
    const audio = {
      content: audioBuffer.toString('base64'),
    };

    const request = {
      config: config,
      audio: audio,
    };

    console.log('Starting speech recognition...');
    
    // Perform speech recognition
    const [response] = await speechClient.recognize(request);
    
    if (!response.results || response.results.length === 0) {
      return {
        transcript: '',
        confidence: 0,
        success: false,
        error: 'No speech detected in audio'
      };
    }

    const transcription = response.results
      .map(result => result.alternatives[0].transcript)
      .join('\n');

    const confidence = response.results.length > 0 
      ? response.results[0].alternatives[0].confidence 
      : 0;

    console.log('Transcription completed successfully');

    return {
      transcript: transcription,
      confidence: confidence,
      success: true,
      wordCount: transcription.split(' ').length
    };

  } catch (error) {
    console.error('Audio processing error:', error);
    return {
      transcript: '',
      confidence: 0,
      success: false,
      error: error.message
    };
  }
};

/**
 * Transcribe audio buffer (for real-time processing)
 */
export const transcribeAudioBuffer = async (audioBuffer, options = {}) => {
  try {
    const defaultConfig = {
      encoding: 'LINEAR16',
      languageCode: 'en-US',
      enableAutomaticPunctuation: true,
      // Don't set sampleRateHertz by default - let it auto-detect
    };

    const config = { ...defaultConfig, ...options };

    const audio = {
      content: audioBuffer.toString('base64'),
    };

    const request = {
      config: config,
      audio: audio,
    };

    const [response] = await speechClient.recognize(request);
    
    if (!response.results || response.results.length === 0) {
      return {
        transcript: '',
        confidence: 0,
        error: 'No speech detected'
      };
    }

    const transcription = response.results
      .map(result => result.alternatives[0].transcript)
      .join('\n');

    const confidence = response.results[0].alternatives[0].confidence;

    return {
      transcript: transcription,
      confidence: confidence,
      success: true
    };

  } catch (error) {
    console.error('Speech-to-text buffer error:', error);
    return {
      transcript: '',
      confidence: 0,
      error: error.message,
      success: false
    };
  }
};

/**
 * Get supported languages for speech recognition
 */
export const getSupportedLanguages = () => {
  return [
    { code: 'en-US', name: 'English (US)' },
    { code: 'en-GB', name: 'English (UK)' },
    { code: 'es-ES', name: 'Spanish (Spain)' },
    { code: 'es-US', name: 'Spanish (US)' },
    { code: 'fr-FR', name: 'French' },
    { code: 'de-DE', name: 'German' },
    { code: 'it-IT', name: 'Italian' },
    { code: 'pt-BR', name: 'Portuguese (Brazil)' },
    { code: 'ja-JP', name: 'Japanese' },
    { code: 'ko-KR', name: 'Korean' },
    { code: 'zh-CN', name: 'Chinese (Simplified)' },
    { code: 'hi-IN', name: 'Hindi' },
  ];
};

/**
 * Stream audio transcription (for real-time use)
 */
export const createTranscriptionStream = (options = {}) => {
  const defaultConfig = {
    encoding: 'WEBM_OPUS',
    sampleRateHertz: 48000,
    languageCode: 'en-US',
    enableAutomaticPunctuation: true,
    interimResults: true,
  };

  const config = { ...defaultConfig, ...options };

  const request = {
    config: config,
    interimResults: true,
  };

  return speechClient.streamingRecognize(request);
};

export default speechClient;