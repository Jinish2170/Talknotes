import mongoose, { Schema } from "mongoose";

const noteSchema = new mongoose.Schema({
    audio_note: {
        type: String,
        require: true
    },
    text_note: {
        type: String,
        require: true
    },
    note_style: {
        type:  mongoose.Schema.Types.ObjectId,
        ref: "noteStyle",
        require: true
    },
    audio_transcription: {
        type: String,
        require: true
    },
    ai_note: {
        type: String,
        require: true
    },
    note_title: {
        type: String,
        require: true
    }
},{timestamps :true});

export const Note = mongoose.model("note", noteSchema);