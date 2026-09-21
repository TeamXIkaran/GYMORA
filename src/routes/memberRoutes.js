import express from "express";
import { addMember } from "../controllers/memberController.js";
import authMiddleware from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", authMiddleware, addMember);

export default router;