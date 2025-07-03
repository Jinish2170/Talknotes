import noteService from '../services/note.service.js';
import { ApiResponse } from '../utils/ApiResponse.js';

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
export { createNote, getNotes, updateNote, deleteNote };
