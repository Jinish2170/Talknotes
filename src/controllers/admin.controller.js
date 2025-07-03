import { sendMsgResponse } from "../utils/ApiError.js";
import { sendObjectResponse } from "../utils/ApiResponse.js";
import { StringError } from "../errors/string.error.js";
import httpStatusCodes from "http-status-codes";
import adminService from "../services/admin.service.js";
import noteStyleService from "../services/noteStyle.service.js";

const adminLogin = async (req, res) => {
    try {
        // Extract credentials from query parameters (for GET) or body (for POST)
        const { email, password } = req.method === 'GET' ? req.query : req.body;
        const admin = await adminService.adminLogin(email, password);
        return sendObjectResponse({
            res,
            result: admin,
            message: "Admin logged in successfully",
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
};

const userDeactivate = async (req, res) => {
    try {
        const { userId } = req.params;
        const result = await adminService.userDeactivate(userId);
        return sendObjectResponse({
            res,
            result,
            message: "User deactivated successfully",
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
};

export {
    adminLogin,
    userDeactivate
};