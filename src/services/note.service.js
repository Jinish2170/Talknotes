import { Note } from "../models/note.model.js";
import { StringError } from "../errors/string.error.js";
const createNote = async (noteData) => {
    try {
        const note = await Note.create(noteData);
        return note;
    } catch (error) {
        console.error("Error creating note:", error);
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

export default { createNote, getNotes, updateNote, deleteNote };