// Example: How to use the new audio processing workflow

import { processCompleteAudioNote, processAudioTranscriptionOnly, processTranscriptionWithStyle } from '../utils/audio-processor.js';
import { Note } from '../models/note.model.js';
import { NoteStyle } from '../models/noteStyle.model.js';

/**
 * Example 1: Process complete audio note from database
 * This will:
 * 1. Download audio from audio_note URL (Cloudinary)
 * 2. Transcribe to text using Google Speech-to-Text
 * 3. Store transcription in audio_transcription field
 * 4. Process with selected style using Gemini
 * 5. Generate summary and action items
 * 6. Save everything back to database
 */
export const exampleCompleteProcessing = async (noteId) => {
  try {
    const result = await processCompleteAudioNote(noteId);
    
    console.log('Processing completed:', {
      noteId: result.noteId,
      title: result.title,
      transcriptionLength: result.transcription.length,
      confidence: result.confidence,
      wordCount: result.wordCount
    });

    return result;
  } catch (error) {
    console.error('Complete processing failed:', error.message);
    throw error;
  }
};

/**
 * Example 2: Only transcribe audio (no AI processing)
 * Useful when you just want the transcription
 */
export const exampleTranscriptionOnly = async (audioUrl) => {
  try {
    const result = await processAudioTranscriptionOnly(audioUrl);
    
    console.log('Transcription completed:', {
      transcript: result.transcript.substring(0, 100) + '...',
      confidence: result.confidence,
      wordCount: result.wordCount
    });

    return result.transcript;
  } catch (error) {
    console.error('Transcription failed:', error.message);
    throw error;
  }
};

/**
 * Example 3: Process existing transcription with different style
 * Useful when you want to reprocess with a different style
 */
export const exampleStyleProcessing = async (transcription, styleId) => {
  try {
    const result = await processTranscriptionWithStyle(transcription, styleId);
    
    console.log('Style processing completed:', {
      styleName: result.styleName,
      styledContentLength: result.styledContent.length
    });

    return result;
  } catch (error) {
    console.error('Style processing failed:', error.message);
    throw error;
  }
};

/**
 * Example controller function for API endpoint
 */
export const processAudioNoteController = async (req, res) => {
  try {
    const { noteId } = req.params;
    
    // Process the complete audio note
    const result = await processCompleteAudioNote(noteId);
    
    res.status(200).json({
      success: true,
      message: 'Audio note processed successfully',
      data: {
        noteId: result.noteId,
        title: result.title,
        transcription: result.transcription,
        styledContent: result.styledContent,
        summary: result.summary,
        actionItems: result.actionItems,
        confidence: result.confidence,
        wordCount: result.wordCount
      }
    });

  } catch (error) {
    console.error('Controller error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process audio note',
      error: error.message
    });
  }
};

/**
 * Example: Create and process a new audio note
 */
export const createAndProcessAudioNote = async (audioUrl, styleId, userId) => {
  try {
    // Create new note
    const newNote = new Note({
      audio_note: audioUrl,
      note_style: styleId,
      user: userId, // if you have user association
      audio_transcription: '', // Will be filled during processing
      text_note: '', // Will be filled during processing
      ai_note: '', // Will be filled during processing
      note_title: '' // Will be filled during processing
    });

    await newNote.save();
    console.log('New note created:', newNote._id);

    // Process the note
    const result = await processCompleteAudioNote(newNote._id);
    
    return {
      noteId: newNote._id,
      ...result
    };

  } catch (error) {
    console.error('Create and process failed:', error.message);
    throw error;
  }
};
