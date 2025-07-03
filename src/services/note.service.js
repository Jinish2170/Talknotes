import { Note } from "../models/note.model.js";
import { NoteStyle } from "../models/noteStyle.model.js";
import { StringError } from "../errors/string.error.js";

const lookupNoteStyleByName = async (styleName) => {
    try {
        const noteStyle = await NoteStyle.findOne({ style_name: styleName });
        if (!noteStyle) {
            throw new StringError(`Note style with name '${styleName}' not found`);
        }
        return noteStyle._id;
    } catch (error) {
        if (error instanceof StringError) {
            throw error;
        }
        console.error("Error looking up note style:", error);
        throw new StringError("Failed to lookup note style");
    }
}

const createNote = async (noteData) => {
    try {
        let finalNoteData = { ...noteData };
        
        // If note_style is a string (name) instead of ObjectId, look up the ID
        if (typeof noteData.note_style === 'string' && !noteData.note_style.match(/^[0-9a-fA-F]{24}$/)) {
            finalNoteData.note_style = await lookupNoteStyleByName(noteData.note_style);
        }

        const note = await Note.create(finalNoteData);
        return note;
    } catch (error) {
        console.error("Error creating note:", error);
        if (error instanceof StringError) {
            throw error;
        }
        throw new StringError("Failed to create note");
    }
}

const getNotes = async () => {
    try {
        const notes = await Note.find();
        return notes;
    } catch (error) {
        console.error("Error fetching notes:", error);
        throw new Error("Failed to fetch notes");
    }
}

const updateNote = async (noteId, updatedData) => {
    try {
        const note = await Note.findByIdAndUpdate(noteId, updatedData, { new: true });
        return note;
    } catch (error) {
        console.error("Error updating note:", error);
        throw new Error("Failed to update note");
    }
}

const deleteNote = async (noteId) => {
    try {
        await Note.findByIdAndDelete(noteId);
    } catch (error) {
        console.error("Error deleting note:", error);
        throw new Error("Failed to delete note");
    }
}

const saveAudioNote = async (req, res) => {
    try {
        const { audio_note } = req.body;
        if (!audio_note) {
            throw new StringError("Audio note is required");
        }
        const noteData = { audio_note };
        const note = await createNote(noteData);
        return res.status(201).json({ status: 1, message: "Audio note saved successfully", data: note });
    } catch (error) {
        console.error("Error saving audio note:", error);
        return res.status(400).json({ status: 0, message: error.message });
    }
}

export default { createNote, getNotes, updateNote, deleteNote, saveAudioNote };