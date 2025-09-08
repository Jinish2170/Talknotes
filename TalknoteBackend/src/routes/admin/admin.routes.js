import express from "express";
import { createNoteStyle, deleteNoteStyle, updateNoteStyle, getNoteStyles } from "../../controllers/noteStyle.controller.js";
import { adminLogin, userDeactivate } from "../../controllers/admin.controller.js";
const router = express.Router();


router.post("/noteStyles", createNoteStyle);
router.put("/noteStyles/:id", updateNoteStyle);
router.delete("/noteStyles/:id", deleteNoteStyle);
router.get("/noteStyles", getNoteStyles);
router.get("/noteStyles/:id", getNoteStyles);
router.post("/adminLogin", adminLogin);
router.post("/userDeactivate/:userId", userDeactivate);

export default router;
