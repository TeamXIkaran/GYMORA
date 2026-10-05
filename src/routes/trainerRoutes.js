import express from "express";

import {
    addTrainer,
    assignMemberToTrainer,
    deleteTrainer,
    getTrainerDetails,
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

router.get("/:id", authMiddleware, getTrainerDetails);
router.put(
  "/:trainerId/members/:clientId",
  authMiddleware,
  assignMemberToTrainer,
);
router.delete("/:id", authMiddleware, deleteTrainer);

export default router;
