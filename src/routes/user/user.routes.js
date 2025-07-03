import express from "express";
import { getNoteStyles } from "../../controllers/noteStyle.controller.js";
import { createNote, getNotes, updateNote, deleteNote, saveAudioNote } from "../../controllers/note.controller.js";
import { registerUser, loginUser, updateUser } from "../../controllers/user.controller.js";
const router = express.Router();


router.get("/noteStyles", getNoteStyles);
router.post("/createNote", createNote);
router.get("/getNotes", getNotes);
router.put("/updateNote/:noteId", updateNote);
router.delete("/deleteNote/:noteId", deleteNote);
router.post("/registerUser", registerUser);
router.post("/loginUser", loginUser);
router.put("/updateUser/:userId", updateUser);
router.post("/saveAudioNote", saveAudioNote);

export default router;  