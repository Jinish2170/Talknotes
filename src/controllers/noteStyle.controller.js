import noteStyleService from "../services/noteStyle.service.js";
import { sendMsgResponse } from "../utils/ApiError.js";
import { sendObjectResponse } from "../utils/ApiResponse.js";
import { StringError } from "../errors/string.error.js";
import httpStatusCodes from "http-status-codes";

const createNoteStyle = async (req, res) => {
    try {
        const { style_name, style_description } = req.body;
        const noteStyle = await noteStyleService.createNoteStyle({ style_name, style_description });
        return sendObjectResponse({
        res,
        result: noteStyle,
        message: "Note style created successfully",
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


const deleteNoteStyle = async (req, res) => {
    try {
        const { id } = req.params;
        const noteStyle = await noteStyleService.deleteNoteStyle(id);
        return sendObjectResponse({
            res,
            result: noteStyle,
            message: "Note style deleted successfully",
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

const updateNoteStyle = async (req, res) => {
    try {
        const { id } = req.params;
        const updateData = req.body;
        const noteStyle = await noteStyleService.updateNoteStyle(id, updateData);
        return sendObjectResponse({
            res,
            result: noteStyle,
            message: "Note style updated successfully",
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

const getNoteStyles = async (req, res) => {
    try {
        const noteStyles = await noteStyleService.getNoteStyles();
        return sendObjectResponse({
            res,
            result: noteStyles,
            message: "Note styles fetched successfully",
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
};

export {    createNoteStyle, deleteNoteStyle, updateNoteStyle, getNoteStyles };