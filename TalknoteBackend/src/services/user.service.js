import { StringError } from "../errors/string.error.js";
import { User } from "../models/user.model.js"; 

const registerUser = async (req) => {
    try {
        const { email, password, name } = req.body;

        // Validate input fields before any DB operation
        if (
            email === undefined ||
            email === null ||
            email === "" ||
            password === undefined ||
            password === null ||
            password === "" ||
            name === undefined ||
            name === null ||
            name === ""
        ) {
            throw new StringError("email, password and name are required");
        }

        // Strong password validation
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        if (!passwordRegex.test(password)) {
            throw new StringError("Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character");
        }

        const user = await User.findOne({ email: email });
        if (user) {
            throw new StringError("User already registered with this email");
        }
        // Create a new user instance
        const newUser = await User.create({
            email: email,
            password: password,
            name: name
        });
        await newUser.save();
        // Optionally, you can return the created user or any other relevant information
        console.log(newUser);
        return {
            success: true,
            message: "User registered successfully",
        }
        } catch (error) {
        console.error(error);
        if (error instanceof StringError) {
            throw new StringError(error.message);
        }
        throw error; // Rethrow the error for the caller to handle
    }
};


const loginUser = async (req) => {
    try {
        const { email, password } = req.body;

        if (
            email === undefined ||
            email === null ||
            email === "" 
        ) {
            throw new StringError("email is required");
        }

        if (
            password === undefined ||
            password === null ||
            password === ""
        ) {
            throw new StringError("password is required");
        }
    
        const user = await User.findOne({ email: email });
    
        if (!user) {
            throw new StringError("User not found! Please register first.");
        }
    
        if (!user.is_active) {
            throw new StringError("User is not active");
        }
    
        console.log(user);
        return {
            sucess: true,
            message: "User logged in successfully",
        }
    } catch (error) {
        console.error(error);
        if (error instanceof StringError) {
            throw new StringError(error.message);
        }
        throw error; // Rethrow the error for the caller to handle
        }
    };

const updateUser = async (req, res) => {
    try {
        const { name, email, password } = req.body;
        const userId = req.params.userId;
        if (!userId) {
            throw new StringError("User ID is required");
        }   
        if (
            email === undefined ||
            email === null ||
            email === "" ||
            password === undefined ||
            password === null ||
            password === "" ||
            name === undefined ||
            name === null ||
            name === ""
        ) {
            throw new StringError("email, password and name are required");
        }
        const user = await User.findById(userId);
        if (!user) {
            throw new StringError("User not found");
        }
        user.email = email;
        user.password = password;
        user.name = name;
        await user.save();
        return {
            success: true,
            message: "User updated successfully",
        };
    } catch (error) {
        console.error(error);
        if (error instanceof StringError) {
            throw new StringError(error.message);
        }
        throw error; // Rethrow the error for the caller to handle
        
    }
}
export default {
    registerUser,
    loginUser,
    updateUser
};

