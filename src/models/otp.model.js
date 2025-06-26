import mongoose from "mongoose";

const otpSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true
    },
    otp: {
        type: String,
        required: true
    },
otp_expiry: {
        type: Date,
        required: true
    }
},{timestamps});

export const Otp = mongoose.model("otp", otpSchema);