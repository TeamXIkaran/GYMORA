import express from "express";

import {
  addTrainer,
  getTrainers,
  loginTrainer,
} from "../controllers/trainerController.js";

import authMiddleware from "../middleware/authMiddleware.js";

const router = express.Router();

// Trainer login
router.post("/login", loginTrainer);

// Owner-only trainer management
router.get("/", authMiddleware, getTrainers);

router.post("/", authMiddleware, addTrainer);

export default router;