import express from "express";

import {
  addTrainer,
  getTrainers,
} from "../controllers/trainerController.js";

import authMiddleware from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/", authMiddleware, getTrainers);

router.post("/", authMiddleware, addTrainer);

export default router;