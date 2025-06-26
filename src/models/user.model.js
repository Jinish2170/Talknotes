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
    is_active: {
        type: Boolean,
        default: true
    },
    name:{
        type: String,
        require: true
    },
    apple_id: {
        type: String,
        unique: true,
        required: function() {
            return this.auth_type === "apple";
        }
    }
},{timestamps});

export const User = mongoose.model("user", userSchema);