import { processAudioNoteFromDB } from '../configs/speesh-to-text.config.js';
import { generateContentFromStyleSelected, generateSmartSummary, generateActionList } from '../configs/gemini.config.js';
import { Note } from '../models/note.model.js';
import { NoteStyle } from '../models/noteStyle.model.js';
import fs from 'fs';

/**
 * Process complete audio note workflow from database
 * 1. Download audio from Cloudinary URL
 * 2. Transcribe audio to text
 * 3. Process transcription with selected style using Gemini
 * 4. Generate additional AI content (summary, actions)
 */
export const processCompleteAudioNote = async (noteId) => {
  try {
    // Find the note in database
    const note = await Note.findById(noteId).populate('note_style');
    if (!note) {
      throw new Error(`Note with ID ${noteId} not found`);
    }

    console.log('Processing audio note:', noteId);
    console.log('Audio URL:', note.audio_note);
    console.log('Selected Style:', note.note_style.style_name);

    // Step 1: Process audio from Cloudinary URL and get transcription
    const transcriptionResult = await processAudioNoteFromDB(note.audio_note);
    
    if (!transcriptionResult.success) {
      throw new Error(`Transcription failed: ${transcriptionResult.error}`);
    }
-
    console.log('Transcription completed:', transcriptionResult.transcript.substring(0, 100) + '...');

    // Step 2: Update note with transcription
    note.audio_transcription = transcriptionResult.transcript;
    
    // Step 3: Process transcription with selected style using Gemini
    const styledContent = await generateContentFromStyleSelected(
      transcriptionResult.transcript, 
      note.note_style._id
    );

    // Step 4: Generate additional AI content
    const summary = await generateSmartSummary(transcriptionResult.transcript);
    const actionItems = await generateActionList(transcriptionResult.transcript);

    // Step 5: Update note with all AI-generated content
    note.ai_note = styledContent;
    note.text_note = `${styledContent}\n\n--- SUMMARY ---\n${summary}\n\n--- ACTION ITEMS ---\n${actionItems}`;
    
    // Generate title from first few words of styled content
    const titleWords = styledContent.split(' ').slice(0, 8).join(' ');
    note.note_title = titleWords.length > 50 ? titleWords.substring(0, 47) + '...' : titleWords;

    // Save updated note
    await note.save();

    console.log('Audio note processing completed successfully');

    return {
      success: true,
      noteId: note._id,
      transcription: transcriptionResult.transcript,
      styledContent: styledContent,
      summary: summary,
      actionItems: actionItems,
      title: note.note_title,
      confidence: transcriptionResult.confidence,
      wordCount: transcriptionResult.wordCount
    };

  } catch (error) {
    console.error('Complete audio note processing error:', error);
    throw new Error(`Failed to process audio note: ${error.message}`);
  }
};

/**
 * Process only transcription part (for existing notes)
 */
export const processAudioTranscriptionOnly = async (audioUrl, options = {}) => {
  try {
    const transcriptionResult = await processAudioNoteFromDB(audioUrl, options);
    
    if (!transcriptionResult.success) {
      throw new Error(`Transcription failed: ${transcriptionResult.error}`);
    }

    return {
      success: true,
      transcript: transcriptionResult.transcript,
      confidence: transcriptionResult.confidence,
      wordCount: transcriptionResult.wordCount
    };

  } catch (error) {
    console.error('Audio transcription error:', error);
    throw new Error(`Failed to transcribe audio: ${error.message}`);
  }
};

/**
 * Process transcription with style (for existing transcriptions)
 */
export const processTranscriptionWithStyle = async (transcription, styleId) => {
  try {
    // Validate style exists
    const style = await NoteStyle.findById(styleId);
    if (!style) {
      throw new Error(`Style with ID ${styleId} not found`);
    }

    const styledContent = await generateContentFromStyleSelected(transcription, styleId);
    const summary = await generateSmartSummary(transcription);
    const actionItems = await generateActionList(transcription);

    return {
      success: true,
      styledContent: styledContent,
      summary: summary,
      actionItems: actionItems,
      styleName: style.style_name
    };

  } catch (error) {
    console.error('Transcription styling error:', error);
    throw new Error(`Failed to process transcription with style: ${error.message}`);
  }
};

export default {
  processCompleteAudioNote,
  processAudioTranscriptionOnly,
  processTranscriptionWithStyle
};
