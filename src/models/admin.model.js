import mongoose from "mongoose";

const adminSchema = new mongoose.Schema({
    email: {
        type: String,
        require: true,
        unique: true
    },
    password: {
        type: String,
        require: true
    },
    name: {
        type: String,
        require: true
    },
},{timestamps});

export const Admin = mongoose.model("admin", adminSchema);