// Admin service for managing user roles and permissions
import { User } from "../models/user.model.js";

// control for is active user and add new style and delete style and get all styles and admin login with is_admin- done


// admin login and style management 
const adminLogin = async (email, password) => {
    try {
        // Logic for admin login
        if (!email) {
            throw new Error('Email is required');
        }
        if (!password) {
            throw new Error('Password is required');
        }
    
        // add admincredential in environment variables or a secure config file
        const adminUser = {
            email: process.env.ADMIN_EMAIL,
            password: process.env.ADMIN_PASSWORD,
            is_admin: true
        };
    
        if (email === adminUser.email && password === adminUser.password) {
            return {
                success: true,
                message: "admin registered successfully",
            };
        } else {
            throw new Error('Invalid admin credentials');
        }
        
    } catch (error) {
        console.error("Error during admin login:", error);
        throw new Error("Admin login failed");
        
    }
};

const userDeactivate = async (userId) => {
    try {
        // Logic to deactivate a user
        if (!userId) {
            throw new Error('User ID is required');
        }
        
        // Assuming User is a model that interacts with the database
        const user = await User.findById(userId);
        if (!user) {
            throw new Error('User not found');
        }
        
        user.is_active = false;
        await user.save();
        
        return {
            success: true,
            message: "User deactivated successfully",
        };
    } catch (error) {
        console.error("Error deactivating user:", error);
        throw new Error("Failed to deactivate user");
    }
};

export default {
    adminLogin,
    userDeactivate
};