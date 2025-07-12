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
 * Detect audio encoding based on file extension and buffer
 */
const detectAudioEncoding = (audioUrl, audioBuffer) => {
  const url = audioUrl.toLowerCase();
  
  // Check file extension
  if (url.includes('.wav')) {
    return 'LINEAR16';
  } else if (url.includes('.mp3')) {
    return 'MP3';
  } else if (url.includes('.m4a') || url.includes('.mp4')) {
    return 'MP3'; // MP4/M4A audio is typically AAC, but MP3 encoding works
  } else if (url.includes('.ogg')) {
    return 'OGG_OPUS';
  } else if (url.includes('.webm')) {
    return 'WEBM_OPUS';
  }
  
  // Fallback: try to detect from buffer header
  const header = audioBuffer.slice(0, 12);
  const headerStr = header.toString('ascii', 0, 4);
  
  if (headerStr === 'RIFF') {
    return 'LINEAR16'; // WAV file
  } else if (header[0] === 0xFF && (header[1] & 0xE0) === 0xE0) {
    return 'MP3'; // MP3 file
  }
  
  // Default fallback
  return 'ENCODING_UNSPECIFIED';
};

/**
 * Get optimal config for audio file
 */
const getAudioConfig = (audioUrl, audioBuffer) => {
  const encoding = detectAudioEncoding(audioUrl, audioBuffer);
  
  const baseConfig = {
    languageCode: 'en-US',
    enableAutomaticPunctuation: true,
    model: 'latest_long',
  };
  
  // Configure based on detected encoding
  switch (encoding) {
    case 'LINEAR16': // WAV files
      return {
        ...baseConfig,
        encoding: 'LINEAR16',
        // Don't specify sample rate - let Google auto-detect
      };
    
    case 'MP3': // MP3 files
      return {
        ...baseConfig,
        encoding: 'MP3',
      };
    
    case 'OGG_OPUS': // OGG files
      return {
        ...baseConfig,
        encoding: 'OGG_OPUS',
      };
    
    case 'WEBM_OPUS': // WebM files
      return {
        ...baseConfig,
        encoding: 'WEBM_OPUS',
      };
    
    default: // Unknown - let Google figure it out
      return {
        ...baseConfig,
        encoding: 'ENCODING_UNSPECIFIED',
      };
  }
};
/**
 * Estimate audio duration based on file size and type
 * This is a rough estimation - actual duration may vary
 */
const estimateAudioDuration = (fileSizeMB, encoding) => {
  // Rough estimates based on common bitrates:
  // MP3: ~1MB per minute (128kbps)
  // WAV: ~10MB per minute (uncompressed 44.1kHz 16-bit stereo)
  // OGG/WebM: ~0.8MB per minute (variable compression)
  
  switch (encoding) {
    case 'LINEAR16': // WAV
      return fileSizeMB / 10; // ~10MB per minute
    case 'MP3':
      return fileSizeMB / 1; // ~1MB per minute
    case 'OGG_OPUS':
    case 'WEBM_OPUS':
      return fileSizeMB / 0.8; // ~0.8MB per minute
    default:
      return fileSizeMB / 1.5; // Conservative estimate
  }
};

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

    // Get optimal configuration based on audio file type
    const detectedConfig = getAudioConfig(audioNoteUrl, audioBuffer);
    const config = { ...detectedConfig, ...options };

    console.log('Detected audio config:', {
      encoding: config.encoding,
      url: audioNoteUrl,
      bufferSize: audioBuffer.length
    });

    // Check audio file size and duration estimate
    const fileSizeMB = audioBuffer.length / (1024 * 1024);
    console.log(`Audio file size: ${fileSizeMB.toFixed(2)} MB`);
    
    // Get more accurate duration estimate based on file type
    const encoding = detectAudioEncoding(audioNoteUrl, audioBuffer);
    const estimatedMinutes = estimateAudioDuration(fileSizeMB, encoding);
    console.log(`Estimated audio duration: ~${estimatedMinutes.toFixed(1)} minutes (${encoding} format)`);
    
    // Use longRunningRecognize for files > 1 minute or > 1MB
    const shouldUseLongRunning = fileSizeMB > 1 || estimatedMinutes > 1;
    
    if (shouldUseLongRunning) {
      console.log(`Using Long Running Recognition (file: ${fileSizeMB.toFixed(2)}MB, estimated: ${estimatedMinutes.toFixed(1)}min)...`);
      
      const audio = {
        content: audioBuffer.toString('base64'),
      };

      const request = {
        config: {
          ...config,
          enableWordTimeOffsets: false, // Disable for performance
          maxAlternatives: 1,           // Only get best result
        },
        audio: audio,
      };

      try {
        // Start long running recognition operation
        const [operation] = await speechClient.longRunningRecognize(request);
        console.log('Long running operation started:', {
          operationName: operation.name,
          metadata: operation.metadata
        });
        
        // Poll for operation status with timeout and progress updates
        const startTime = Date.now();
        const maxWaitTime = 30 * 60 * 1000; // 30 minutes max wait
        
        console.log('Waiting for long running operation to complete...');
        
        // Custom polling function with progress monitoring
        const pollWithProgress = async () => {
          const pollInterval = 10000; // Check every 10 seconds
          let lastProgressPercent = 0;
          
          while (true) {
            const elapsedTime = Date.now() - startTime;
            
            // Check timeout
            if (elapsedTime > maxWaitTime) {
              throw new Error('Operation timeout: Audio processing took longer than 30 minutes');
            }
            
            // Get current operation status
            const [currentOp] = await operation.get();
            
            // Check if completed
            if (currentOp.done) {
              if (currentOp.error) {
                throw new Error(`Operation failed: ${currentOp.error.message}`);
              }
              return currentOp.response;
            }
            
            // Log progress if available
            if (currentOp.metadata) {
              const metadata = currentOp.metadata;
              
              if (metadata.progressPercent !== undefined && metadata.progressPercent > lastProgressPercent) {
                console.log(`📊 Progress: ${metadata.progressPercent}% complete (${Math.round(elapsedTime / 1000)}s elapsed)`);
                lastProgressPercent = metadata.progressPercent;
              } else if (metadata.startTime) {
                console.log(`⏳ Processing... (${Math.round(elapsedTime / 1000)}s elapsed)`);
              }
            } else {
              console.log(`⏳ Processing... (${Math.round(elapsedTime / 1000)}s elapsed)`);
            }
            
            // Wait before next poll
            await new Promise(resolve => setTimeout(resolve, pollInterval));
          }
        };
        
        // Use custom polling with fallback to operation.promise()
        let response;
        try {
          response = await pollWithProgress();
        } catch (pollingError) {
          console.warn('Custom polling failed, falling back to operation.promise():', pollingError.message);
          
          // Fallback to original method with timeout
          const [fallbackResponse] = await Promise.race([
            operation.promise(),
            new Promise((_, reject) => 
              setTimeout(() => reject(new Error('Operation timeout after 30 minutes')), maxWaitTime)
            )
          ]);
          response = fallbackResponse;
        }
        
        const processingTime = (Date.now() - startTime) / 1000;
        console.log(`Long running operation completed in ${processingTime.toFixed(1)} seconds`);
        
        // Check if the operation completed successfully
        if (!response || !response.results || response.results.length === 0) {
          console.warn('No speech results found in completed operation');
          return {
            transcript: '',
            success: false,
            error: 'No speech detected in audio',
            processingTimeSeconds: processingTime
          };
        }

        const transcription = response.results
          .map(result => result.alternatives[0].transcript)
          .join('\n');

        console.log('Long running transcription completed successfully:', {
          transcriptLength: transcription.length,
          resultCount: response.results.length,
          processingTime: `${processingTime.toFixed(1)}s`
        });

        return {
          transcript: transcription,
          success: true,
          processingTimeSeconds: processingTime,
          resultCount: response.results.length
        };
        
      } catch (operationError) {
        console.error('Long running operation error:', operationError);
        throw new Error(`Long running recognition failed: ${operationError.message}`);
      }
      
    } else {
      console.log(`Using synchronous recognition (file: ${fileSizeMB.toFixed(2)}MB, estimated: ${estimatedMinutes.toFixed(1)}min)...`);
      
      // Use synchronous recognition for files <= 1 minute
      const audio = {
        content: audioBuffer.toString('base64'),
      };

      const request = {
        config: config,
        audio: audio,
      };

      console.log('Starting synchronous speech recognition...');
      
      const [response] = await speechClient.recognize(request);
      
      if (!response.results || response.results.length === 0) {
        return {
          transcript: '',
          success: false,
          error: 'No speech detected in audio'
        };
      }

      const transcription = response.results
        .map(result => result.alternatives[0].transcript)
        .join('\n');

      console.log('Synchronous transcription completed successfully');

      return {
        transcript: transcription,
        success: true
      };
    }

  } catch (error) {
    console.error('Audio processing error:', error);
    return {
      transcript: '',
      success: false,
      error: error.message
    };
  }
};

/**
 * Detect encoding from buffer only (when URL is not available)
 */
const detectEncodingFromBuffer = (audioBuffer) => {
  const header = audioBuffer.slice(0, 12);
  const headerStr = header.toString('ascii', 0, 4);
  
  if (headerStr === 'RIFF') {
    return 'LINEAR16'; // WAV file
  } else if (header[0] === 0xFF && (header[1] & 0xE0) === 0xE0) {
    return 'MP3'; // MP3 file
  } else if (headerStr === 'OggS') {
    return 'OGG_OPUS'; // OGG file
  }
  
  return 'ENCODING_UNSPECIFIED';
};

/**
 * Transcribe audio buffer (for real-time processing)
 */
export const transcribeAudioBuffer = async (audioBuffer, options = {}) => {
  try {
    // Detect encoding from buffer
    const encoding = detectEncodingFromBuffer(audioBuffer);
    
    const defaultConfig = {
      encoding: encoding,
      languageCode: 'en-US',
      enableAutomaticPunctuation: true,
    };

    const config = { ...defaultConfig, ...options };

    console.log('Buffer transcription config:', {
      encoding: config.encoding,
      bufferSize: audioBuffer.length
    });

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