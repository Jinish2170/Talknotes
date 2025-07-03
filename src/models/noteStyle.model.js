import mongoose from "mongoose";

const noteStyleSchema = new mongoose.Schema({
    style_name: {
        type: String,
        required: true,
        unique: true
    },
    style_description: {
        type: String,
        required: true
    },
},{timestamps :true});

export const NoteStyle = mongoose.model("noteStyle", noteStyleSchema);