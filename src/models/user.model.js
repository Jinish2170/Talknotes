import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        require: true,
        unique: true
    },
    auth_type: {
        type: String,
        enum: [
            "apple",
            "google",
            "email"
        ]
    },
    password: {
        type: String,
        require: true
    },
    is_admin: {
        type: Boolean,
        default: false
    },
    is_active: {
        type: Boolean,
        default: true
    },
    name:{
        type: String,
        require: true
    }
},{timestamps :true});

export const User = mongoose.model("user", userSchema);