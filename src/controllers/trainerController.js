import bcrypt from "bcryptjs";
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
      fullName: fullName.trim(),
      phone: phone.trim(),
      email: email.toLowerCase().trim(),

      // Gym comes from authenticated owner's token
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

export { addTrainer };