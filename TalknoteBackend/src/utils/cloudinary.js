import {v2 as cloudinary} from "cloudinary"
import fs from "fs"


// Configure Cloudinary silently
if (!process.env.CLOUDINARY_CLOUD_NAME || !process.env.CLOUDINARY_API_KEY || !process.env.CLOUDINARY_API_SECRET) {
    console.error("Missing Cloudinary environment variables. Please check your .env file.");
    throw new Error("Cloudinary configuration is incomplete");
}

cloudinary.config({ 
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME, 
    api_key: process.env.CLOUDINARY_API_KEY, 
    api_secret: process.env.CLOUDINARY_API_SECRET 
});

const uploadOnCloudinary = async (localFilePath) => {
    try {
        if (!localFilePath) {
            throw new Error("No file path provided");
        }

        // Check if file exists
        if (!fs.existsSync(localFilePath)) {
            throw new Error(`File not found at path: ${localFilePath}`);
        }

        // Upload started

        // Upload the file to cloudinary
        const response = await cloudinary.uploader.upload(localFilePath, {
            resource_type: "auto",
            folder: "talknotes",
            unique_filename: true
        });

        console.log("Cloudinary upload successful:", response.url);
        
        // Clean up the temp file
        try {
            fs.unlinkSync(localFilePath);
        } catch (unlinkError) {
            console.warn("Failed to delete temp file:", unlinkError);
        }
        
        return response;
    } catch (error) {
        console.error("Cloudinary upload error:", error);
        
        // Try to clean up the temp file
        try {
            if (fs.existsSync(localFilePath)) {
                fs.unlinkSync(localFilePath);
            }
        } catch (unlinkError) {
            console.warn("Failed to delete temp file:", unlinkError);
        }
        
        throw error; // Re-throw the error for handling in the controller
    }
}



export {uploadOnCloudinary}