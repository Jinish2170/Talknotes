import express from "express";
import { createNoteStyle, deleteNoteStyle, updateNoteStyle, getNoteStyles } from "../../controllers/noteStyle.controller.js";
const router = express.Router();


router.post("/noteStyles", createNoteStyle);
router.put("/noteStyles/:id", updateNoteStyle);
router.delete("/noteStyles/:id", deleteNoteStyle);
router.get("/noteStyles", getNoteStyles);

export default router
