import { NoteStyle } from "../models/noteStyle.model.js"; 


const createNoteStyle = async (styleData) => {
    try {
        const { style_name, style_description } = styleData;
    
        if (!style_name || !style_description) {
            throw new Error("Style name and style description are required");
        }
    
        const noteStyle = new NoteStyle({
            style_name,
            style_description
        });
    
        await noteStyle.save();
        return noteStyle;
    
    } catch (error) {
        console.error("Error creating note style:", error);
        throw new Error("Failed to create note style");
    }
};

const deleteNoteStyle = async (id) => {
    try {
        const noteStyle = await NoteStyle.findByIdAndDelete(id);
        if (!noteStyle) {
            throw new Error("Note style not found");
        }
        return { message: "Note style deleted successfully" };
    } catch (error) {
        console.error("Error deleting note style:", error);
        return { message: "Failed to delete note style" };
    }
};

const updateNoteStyle = async (id, updateData) => {
    try {
        const noteStyle = await NoteStyle.findByIdAndUpdate(id, updateData, { new: true });
        if (!noteStyle) {
            throw new Error("Note style not found");
        }
        return { message: "Note style updated successfully", data: noteStyle };
    } catch (error) {
        console.error("Error updating note style:", error);
        return { message: "Failed to update note style" };
    }
};

const getNoteStyles = async () => {
    try {
        const noteStyles = await NoteStyle.find();
        return noteStyles;
    } catch (error) {
        console.error("Error fetching note styles:", error);
        return [];
    }
};
export default {    createNoteStyle, 
                    deleteNoteStyle,    
                    updateNoteStyle, 
                    getNoteStyles };