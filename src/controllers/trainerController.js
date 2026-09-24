import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

import Trainer from "../models/Trainer.js";

const addTrainer = async (req, res) => {
  try {
    // Only owners can add trainers
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can add trainers",
      });
    }

    const {
      trainerId,
      fullName,
      phone,
      email,
      password,
      specialization,
      experience,
    } = req.body;

    // Required fields
    if (
      !fullName ||
      !phone ||
      !email ||
      !password ||
      !specialization ||
      experience === undefined ||
      experience === null ||
      experience === ""
    ) {
      return res.status(400).json({
        success: false,
        message: "All required fields must be provided",
      });
    }

    // Validate password
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters",
      });
    }

    // Validate experience
    const trainerExperience = Number(experience);

    if (
      Number.isNaN(trainerExperience) ||
      trainerExperience < 0
    ) {
      return res.status(400).json({
        success: false,
        message: "Experience must be a valid non-negative number",
      });
    }

    // Check duplicate trainer email inside this gym
    const existingTrainer = await Trainer.findOne({
      gymId: req.user.gymId,
      email: email.toLowerCase().trim(),
    });

    if (existingTrainer) {
      return res.status(409).json({
        success: false,
        message: "A trainer with this email already exists",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create trainer
    const trainer = await Trainer.create({
      trainerId: trainerId.trim(),
      fullName: fullName.trim(),
      phone: phone.trim(),
      email: email.toLowerCase().trim(),
      gymId: req.user.gymId,
      password: hashedPassword,
      specialization: specialization.trim(),
      experience: trainerExperience,
    });

    return res.status(201).json({
      success: true,
      message: "Trainer added successfully",
      data: {
        trainer: {
          id: trainer._id,
          fullName: trainer.fullName,
          phone: trainer.phone,
          email: trainer.email,
          gymId: trainer.gymId,
          specialization: trainer.specialization,
          experience: trainer.experience,
          status: trainer.status,
        },
      },
    });
  } catch (error) {
    console.error("Add trainer error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const getTrainers = async (req, res) => {
  try {
    // Only owners can view trainers
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can view trainers",
      });
    }

    // Get only trainers belonging to the logged-in owner's gym
    const trainers = await Trainer.find({
      gymId: req.user.gymId,
    })
      .select("-password")
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      message: "Trainers fetched successfully",
      data: {
        trainers,
      },
    });
  } catch (error) {
    console.error("Get trainers error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const loginTrainer = async (req, res) => {
  try {
    const { trainerId, password } = req.body;

    // Required fields
    if (!trainerId || !password) {
      return res.status(400).json({
        success: false,
        message: "Trainer ID and password are required",
      });
    }

    // Find trainer using Trainer ID
    const trainer = await Trainer.findOne({
      trainerId: trainerId.trim(),
    });

    if (!trainer) {
      return res.status(401).json({
        success: false,
        message: "Invalid Trainer ID or password",
      });
    }

    // Check trainer account status
    if (trainer.status !== "ACTIVE") {
      return res.status(403).json({
        success: false,
        message: "Trainer account is inactive",
      });
    }

    // Check password
    const isPasswordValid = await bcrypt.compare(
      password,
      trainer.password
    );

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid Trainer ID or password",
      });
    }

    // Generate JWT
    const token = jwt.sign(
      {
        trainerId: trainer.trainerId,
        gymId: trainer.gymId,
        role: "TRAINER",
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "1d",
      }
    );

    return res.status(200).json({
      success: true,
      message: "Trainer login successful",
      data: {
        token,
        trainer: {
          id: trainer._id,
          trainerId: trainer.trainerId,
          fullName: trainer.fullName,
          phone: trainer.phone,
          email: trainer.email,
          gymId: trainer.gymId,
          specialization: trainer.specialization,
          experience: trainer.experience,
          status: trainer.status,
        },
      },
    });
  } catch (error) {
    console.error("Trainer login error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

export { addTrainer, getTrainers, loginTrainer };
