import express from "express";
import { addTrainer } from "../controllers/trainerController.js";
import authMiddleware from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", authMiddleware, addTrainer);

export default router;