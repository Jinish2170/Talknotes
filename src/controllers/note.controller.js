import noteService from '../services/note.service.js';
import { ApiResponse } from '../utils/ApiResponse.js';
import { uploadOnCloudinary } from '../utils/cloudinary.js';
import { StringError } from '../errors/string.error.js';
import httpStatusCodes from "http-status-codes";
import { processCompleteAudioNote } from '../utils/audio-processor.js';
import { sendObjectResponse } from '../utils/ApiResponse.js';

// save audio file in cloudinary and save note in database
const saveAudioNote = async (req, res) => {
    try {
        // Check if files were uploaded
        if (!req.files) {
            return res.status(400).json(new ApiResponse(400, null, "Audio file is required"));
        }

        // Accept either 'audio' or 'audioFile' as the field name
        const audioFile = req.files.audio || req.files.audioFile;
        if (!audioFile) {
            return res.status(400).json(new ApiResponse(400, null, "Audio file is required. Please upload a file with field name 'audio' or 'audioFile'"));
        }
        
        // Validate required fields from body
        const { note_title, note_style, text_note = "", audio_transcription = "", ai_note = "" } = req.body;
        
        if (!note_title) {
            return res.status(400).json(new ApiResponse(400, null, "Note title is required"));
        }
        
        if (!note_style) {
            return res.status(400).json(new ApiResponse(400, null, "Note style is required. You can provide either the style name or style ID"));
        }

        // Upload audio file to Cloudinary
        let cloudinaryResponse;
        try {
            cloudinaryResponse = await uploadOnCloudinary(audioFile.tempFilePath);
            if (!cloudinaryResponse) {
                return res.status(500).json(new ApiResponse(500, null, "Failed to upload audio file"));
            }
        } catch (cloudinaryError) {
            return res.status(500).json(new ApiResponse(500, null, `Failed to upload to Cloudinary: ${cloudinaryError.message}`));
        }

        // Prepare note data with all required fields
        const noteData = {
            note_title,
            note_style,
            text_note,
            audio_transcription,
            ai_note,
            audio_url: cloudinaryResponse.url,
            audio_public_id: cloudinaryResponse.public_id
        };

        // Create note
        try {
            const savedNote = await noteService.createNote(noteData);
            return res.status(201).json(
                new ApiResponse(201, savedNote, "Note created successfully")
            );
        } catch (error) {
            // If there was an error with note creation, try to delete the uploaded file
            if (cloudinaryResponse && cloudinaryResponse.public_id) {
                try {
                    await cloudinary.uploader.destroy(cloudinaryResponse.public_id);
                } catch (deleteError) {
                    console.error("Error deleting file from Cloudinary after failed note creation:", deleteError);
                }
            }

            console.error("Error creating note:", error);
            const statusCode = error instanceof StringError ? 400 : 500;
            const message = error instanceof StringError ? error.message : "Failed to create note";
            return res.status(statusCode).json(new ApiResponse(statusCode, null, message));
        }
    } catch (error) {
        console.error("Unexpected error in saveAudioNote:", error);
        return res.status(500).json(new ApiResponse(500, null, "An unexpected error occurred"));
    }
};


const createNote = async (req, res) => {
    try {
        const noteData = req.body;
        const note = await noteService.createNote(noteData);
        return res.status(201).json(new ApiResponse(201, note, "Note created successfully"));
    } catch (error) {
        console.error("Error creating note:", error);
        return res
        .status(400)
        .json(new ApiResponse(400, null, "Failed to create note"));
    }
}
const getNotes = async (req, res) => {
    try {
        const notes = await noteService.getNotes();
        return res.status(200).json(new ApiResponse(200, notes, "Notes fetched successfully"));
    } catch (error) {
        console.error("Error fetching notes:", error);
        return res.status(400).json(new ApiResponse(400, null, "Failed to fetch notes"));
    }
}

const updateNote = async (req, res) => {
    try {
        const { noteId } = req.params;
        const updatedData = req.body;
        const note = await noteService.updateNote(noteId, updatedData);
        return res.status(200).json(new ApiResponse(200, note, "Note updated successfully"));
    } catch (error) {
        console.error("Error updating note:", error);
        return res.status(400).json(new ApiResponse(400, null, "Failed to update note"));
    }
}

const deleteNote = async (req, res) => {
    try {
        const { noteId } = req.params;
        await noteService.deleteNote(noteId);
        return res.status(200).json(new ApiResponse(200, null, "Note deleted successfully"));
    } catch (error) {
        console.error("Error deleting note:", error);
        return res.status(400).json(new ApiResponse(400, null, "Failed to delete note"));
    }
}

// Process audio file with style and return AI-generated content
const processAudioNote = async (req, res) => {
    try {
        // Validate required inputs - with express-fileupload, files are in req.files
        if (!req.files?.audioFile) {
            return sendObjectResponse({
                res,
                result: null,
                message: "Audio file is required. Please upload a file with field name 'audioFile'",
                status: 0,
                statusCode: httpStatusCodes.BAD_REQUEST
            });
        }

        const { styleName } = req.body;
        if (!styleName) {
            return sendObjectResponse({
                res,
                result: null,
                message: "Style name is required",
                status: 0,
                statusCode: httpStatusCodes.BAD_REQUEST
            });
        }

        const audioFile = req.files.audioFile;

        // Log file details for debugging
        console.log('Received file:', {
            name: audioFile.name,
            mimetype: audioFile.mimetype,
            size: audioFile.size
        });

        // Validate audio file type - WAV files can have different MIME types
        const allowedMimeTypes = [
            'audio/wav', 
            'audio/wave',
            'audio/x-wav',
            'audio/mpeg', 
            'audio/mp3', 
            'audio/mp4', 
            'audio/m4a',
            'audio/webm',
            'audio/ogg'
        ];
        
        const isValidAudio = allowedMimeTypes.includes(audioFile.mimetype) || 
                           audioFile.name.toLowerCase().endsWith('.wav') ||
                           audioFile.name.toLowerCase().endsWith('.mp3') ||
                           audioFile.name.toLowerCase().endsWith('.mp4') ||
                           audioFile.name.toLowerCase().endsWith('.m4a') ||
                           audioFile.name.toLowerCase().endsWith('.webm');
        
        if (!isValidAudio) {
            return sendObjectResponse({
                res,
                result: null,
                message: `Invalid audio file format. Received MIME type: ${audioFile.mimetype}. Supported formats: WAV, MP3, MP4, WebM`,
                status: 0,
                statusCode: httpStatusCodes.BAD_REQUEST
            });
        }

        // Process the complete audio note pipeline
        const processedData = await processCompleteAudioNote(audioFile, styleName);

        return sendObjectResponse({
            res,
            result: processedData,
            message: "Audio note processed successfully",
            status: 1,
            statusCode: httpStatusCodes.OK
        });

    } catch (error) {
        console.error('Process audio note error:', error);
        return sendObjectResponse({
            res,
            result: null,
            message: error.message || "Failed to process audio note",
            status: 0,
            statusCode: httpStatusCodes.INTERNAL_SERVER_ERROR
        });
    }
};

export { createNote, getNotes, updateNote, deleteNote, saveAudioNote, processAudioNote };
