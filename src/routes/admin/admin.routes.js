import express from "express";

const router = express.Router();


router.post("/noteStyles", createNoteStyle);
router.put("/noteStyles/:id", updateNoteStyle);
router.delete("/noteStyles/:id", deleteNoteStyle);

export default router