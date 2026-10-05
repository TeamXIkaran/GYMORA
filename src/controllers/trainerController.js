import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import mongoose from "mongoose";

import Trainer from "../models/Trainer.js";
import Member from "../models/Member.js";

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

    if (Number.isNaN(trainerExperience) || trainerExperience < 0) {
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

    const trainerIds = trainers.map((trainer) => trainer.trainerId);
    const assignmentCounts = await Member.aggregate([
      { $match: { gymId: req.user.gymId, trainerId: { $in: trainerIds } } },
      { $group: { _id: "$trainerId", count: { $sum: 1 } } },
    ]);
    const countByTrainerId = new Map(
      assignmentCounts.map((item) => [item._id, item.count]),
    );

    return res.status(200).json({
      success: true,
      message: "Trainers fetched successfully",
      data: {
        trainers: trainers.map((trainer) => ({
          ...trainer.toObject(),
          assignedMembersCount: countByTrainerId.get(trainer.trainerId) ?? 0,
        })),
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

const getTrainerDetails = async (req, res, next) => {
  try {
    // These are trainer-facing endpoints. Passing them to this generic
    // /:id handler caused valid trainer requests to be treated as owner-only
    // trainer-detail requests.
    const reservedPaths = new Set([
      "profile",
      "clients",
      "sessions",
      "dashboard",
      "progress",
      "workouts",
    ]);
    if (reservedPaths.has(req.params.id.toLowerCase())) return next();

    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can view trainer details",
      });
    }

    const trainer = await Trainer.findOne({
      trainerId: req.params.id,
      gymId: req.user.gymId,
    }).select("-password");
    if (!trainer) {
      return res.status(404).json({ success: false, message: "Trainer not found" });
    }

    const assignedMembers = await Member.find({
      trainerId: trainer.trainerId,
      gymId: req.user.gymId,
    }).select("-password").sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      message: "Trainer details fetched successfully",
      data: {
        trainer: {
          id: trainer._id,
          trainerId: trainer.trainerId,
          fullName: trainer.fullName,
          phone: trainer.phone,
          email: trainer.email,
          specialization: trainer.specialization,
          experience: trainer.experience,
          status: trainer.status,
          assignedMembersCount: assignedMembers.length,
        },
        assignedMembers,
      },
    });
  } catch (error) {
    console.error("Get trainer details error:", error);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const assignMemberToTrainer = async (req, res) => {
  try {
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can assign members",
      });
    }

    const { trainerId, clientId } = req.params;
    const trainer = await Trainer.findOne({ trainerId, gymId: req.user.gymId });
    if (!trainer) {
      return res.status(404).json({ success: false, message: "Trainer not found" });
    }
    const member = await Member.findOne({ clientId, gymId: req.user.gymId });
    if (!member) {
      return res.status(404).json({ success: false, message: "Member not found in this gym" });
    }
    if (member.trainerId === trainer.trainerId) {
      return res.status(200).json({
        success: true,
        message: "Member is already assigned to this trainer",
        data: { member: { clientId: member.clientId, fullName: member.fullName, trainerId: trainer.trainerId } },
      });
    }

    member.trainerId = trainer.trainerId;
    await member.save();
    return res.status(200).json({
      success: true,
      message: "Member assigned to trainer successfully",
      data: {
        member: { clientId: member.clientId, fullName: member.fullName, trainerId: trainer.trainerId },
        trainer: { trainerId: trainer.trainerId, fullName: trainer.fullName },
      },
    });
  } catch (error) {
    console.error("Assign member to trainer error:", error);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

const deleteTrainer = async (req, res) => {
  try {
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can delete trainers",
      });
    }

    const { id } = req.params;
    const trainer = await Trainer.findOne({
      gymId: req.user.gymId,
      $or: [{ trainerId: id }, ...(mongoose.isValidObjectId(id) ? [{ _id: id }] : [])],
    });

    if (!trainer) {
      return res.status(404).json({
        success: false,
        message: "Trainer not found",
      });
    }

    const assignedMembers = await Member.updateMany({
      gymId: req.user.gymId,
      trainerId: trainer.trainerId,
    }, { $set: { trainerId: "" } });

    await Trainer.deleteOne({ _id: trainer._id, gymId: req.user.gymId });

    return res.status(200).json({
      success: true,
      message: "Trainer deleted successfully",
      data: { id: trainer._id, unassignedMembers: assignedMembers.modifiedCount },
    });
  } catch (error) {
    console.error("Delete trainer error:", error);

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
    const isPasswordValid = await bcrypt.compare(password, trainer.password);

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
      },
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

export {
  addTrainer,
  assignMemberToTrainer,
  deleteTrainer,
  getTrainerDetails,
  getTrainers,
  loginTrainer,
};
