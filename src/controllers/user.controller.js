import { sendMsgResponse } from "../utils/ApiError.js";
import { sendObjectResponse } from "../utils/ApiResponse.js";
import { StringError } from "../errors/string.error.js";
import httpStatusCodes from "http-status-codes";
import userService from "../services/user.service.js";

const registerUser = async (req, res) => {
    try {
        const user = await userService.registerUser(req);
        return sendObjectResponse({
            res,
            result: user,
            message: "User registered successfully",
            status: 1,
            statusCode: httpStatusCodes.CREATED,
        });
    } catch (e) {
        console.log({ e });
        if (e instanceof StringError) {
            return sendMsgResponse({
                res,
                message: e.message,
                status: 0,
                statusCode: httpStatusCodes.BAD_REQUEST,
            });
        }
        return sendMsgResponse({
            res,
            message: "Something went wrong!",
            status: 0,
            statusCode: httpStatusCodes.BAD_REQUEST,
        });
    }
};

const loginUser = async (req, res) => {
    try {
        const user = await userService.loginUser(req);
        return sendObjectResponse({
        res,
        result: user,
        message: "User logged in successfully",
        status: 1,
        statusCode: httpStatusCodes.OK,
    });
    } catch (e) {
        console.log({ e });
        if (e instanceof StringError) {
        return sendMsgResponse({
        res,
        message: e.message,
        status: 0,
        statusCode: httpStatusCodes.BAD_REQUEST,
        });
        }
        return sendMsgResponse({
        res,
        message: "Something went wrong!",
        status: 0,
        statusCode: httpStatusCodes.BAD_REQUEST,
        });
    }
}

const updateUser = async (req, res) => {
    try {
        // Implement user update logic here
        return sendMsgResponse({
            res,
            message: "User updated successfully",
            status: 1,
            statusCode: httpStatusCodes.OK,
        });
    } catch (e) {
        console.log({ e });
        return sendMsgResponse({
            res,
            message: "Something went wrong!",
            status: 0,
            statusCode: httpStatusCodes.BAD_REQUEST,
        });
    }
}

export { registerUser, loginUser, updateUser };