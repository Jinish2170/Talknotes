import { uploadOnCloudinary } from './cloudinary.js';
import { processAudioNoteFromDB } from '../configs/speesh-to-text.config.js';
import { generateContentFromStyleSelected, generateSmartSummary } from '../configs/gemini.config.js';

/**
 * Complete audio processing pipeline
 * Handles: Upload to Cloudinary -> Speech-to-Text -> Gemini Processing
 */
export const processCompleteAudioNote = async (audioFile, styleName) => {
  try {
    console.log('Starting complete audio processing pipeline...');

    // Step 1: Upload audio to Cloudinary
    console.log('Uploading audio to Cloudinary...');
    const cloudinaryResponse = await uploadOnCloudinary(audioFile.tempFilePath);
    
    if (!cloudinaryResponse?.secure_url) {
      throw new Error('Failed to upload audio to Cloudinary');
    }

    const audioUrl = cloudinaryResponse.secure_url;
    console.log('Audio uploaded successfully:', audioUrl);

    // Step 2: Convert audio to text using Google Speech-to-Text
    console.log('Starting speech-to-text conversion...');
    const transcriptionResult = await processAudioNoteFromDB(audioUrl);
    
    if (!transcriptionResult.success || !transcriptionResult.transcript) {
      throw new Error(transcriptionResult.error || 'Speech-to-text conversion failed');
    }

    const transcript = transcriptionResult.transcript;
    console.log('Speech-to-text completed. Transcript length:', transcript.length);

    // Step 3: Process with Gemini AI (parallel processing for efficiency)
    console.log('Processing with Gemini AI...');
    const [aiNote, summary] = await Promise.all([
      generateContentFromStyleSelected(transcript, styleName),
      generateSmartSummary(transcript)
    ]);

    console.log('Gemini processing completed successfully');

    // Return complete processed data
    return {
      audio_note: audioUrl,
      audio_transcription: transcript,
      ai_note: aiNote,
      summary: summary,
      style_name: styleName,
      success: true
    };

  } catch (error) {
    console.error('Audio processing pipeline error:', error);
    throw new Error(`Audio processing failed: ${error.message}`);
  }
};

/**
 * Process audio from existing Cloudinary URL
 * Used when audio is already uploaded
 */
export const processExistingAudioNote = async (audioUrl, styleName) => {
  try {
    console.log('Processing existing audio from URL:', audioUrl);

    // Step 1: Convert audio to text
    const transcriptionResult = await processAudioNoteFromDB(audioUrl);
    
    if (!transcriptionResult.success || !transcriptionResult.transcript) {
      throw new Error(transcriptionResult.error || 'Speech-to-text conversion failed');
    }

    const transcript = transcriptionResult.transcript;

    // Step 2: Process with Gemini AI
    const [aiNote, summary] = await Promise.all([
      generateContentFromStyleSelected(transcript, styleName),
      generateSmartSummary(transcript)
    ]);

    return {
      audio_note: audioUrl,
      audio_transcription: transcript,
      ai_note: aiNote,
      summary: summary,
      style_name: styleName,
      success: true
    };

  } catch (error) {
    console.error('Existing audio processing error:', error);
    throw new Error(`Audio processing failed: ${error.message}`);
  }
};

