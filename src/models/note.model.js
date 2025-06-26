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
        type: Schema.Types.ObjectId,
        ref: "note",
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
},{timestamps});

export const Note = mongoose.model("note", noteSchema);