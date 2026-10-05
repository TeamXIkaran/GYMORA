import bcrypt from "bcryptjs";
import mongoose from "mongoose";
import Member from "../models/Member.js";
import Trainer from "../models/Trainer.js";

const MEMBER_PLANS = {
  BASIC: {
    price: 5000,
    durationMonths: 1,
  },

  STANDARD: {
    price: 10000,
    durationMonths: 3,
  },

  PREMIUM: {
    price: 15000,
    durationMonths: 6,
  },
};

const addMember = async (req, res) => {
  try {
    // Only owners can add members
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can add members",
      });
    }

    const {
      fullName,
      clientId,
      trainerId,
      planName,
      phone,
      email,
      password,
      membershipPlan,
      startDate,
    } = req.body;

    // Required fields
    if (
      !fullName ||
      !clientId ||
      !phone ||
      !email ||
      !password ||
      !membershipPlan ||
      !startDate
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

    // Validate membership plan
    const selectedPlan = MEMBER_PLANS[membershipPlan];

    if (!selectedPlan) {
      return res.status(400).json({
        success: false,
        message: "Invalid membership plan",
      });
    }

    // Validate start date
    const membershipStartDate = new Date(startDate);

    if (Number.isNaN(membershipStartDate.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid start date",
      });
    }

    // Automatically calculate end date
    const membershipEndDate = new Date(membershipStartDate);

    membershipEndDate.setMonth(
      membershipEndDate.getMonth() + selectedPlan.durationMonths,
    );

    const assignedTrainerId = trainerId?.trim() || "";
    if (assignedTrainerId) {
      const trainer = await Trainer.findOne({
        trainerId: assignedTrainerId,
        gymId: req.user.gymId,
      });
      if (!trainer) {
        return res.status(404).json({
          success: false,
          message: "Trainer not found in this gym",
        });
      }
    }

    // Check whether email already exists in this gym
    const existingMember = await Member.findOne({
      gymId: req.user.gymId,
      email: email.toLowerCase().trim(),
    });

    if (existingMember) {
      return res.status(409).json({
        success: false,
        message: "A member with this email already exists",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create member
    const member = await Member.create({
      clientId: clientId.trim(),
      fullName: fullName.trim(),
      planName: planName?.trim() || "",
      phone: phone.trim(),
      email: email.toLowerCase().trim(),

      // Gym ID comes from authenticated owner's JWT
      gymId: req.user.gymId,
      trainerId: assignedTrainerId,

      password: hashedPassword,
      membershipPlan: membershipPlan.trim(),

      startDate: membershipStartDate,
      endDate: membershipEndDate,

      status: "ACTIVE",
    });

    return res.status(201).json({
      success: true,
      message: "Member added successfully",
      data: {
        client: {
          id: member._id,
          clientId: member.clientId,
          fullName: member.fullName,
          planName: member.planName,
          phone: member.phone,
          email: member.email,
          gymId: member.gymId,
          trainerId: member.trainerId,
          membershipPlan: member.membershipPlan,

          price: selectedPlan.price,
          durationMonths: selectedPlan.durationMonths,

          startDate: member.startDate,
          endDate: member.endDate,
          status: member.status,
        },
      },
    });
  } catch (error) {
    console.error("Add member error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const getMembers = async (req, res) => {
  try {
    // Only owners can view members
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can view members",
      });
    }

    // Get only members belonging to the logged-in owner's gym
    const [members, trainers] = await Promise.all([
      Member.find({ gymId: req.user.gymId })
        .select("-password")
        .sort({ createdAt: -1 })
        .lean(),
      Trainer.find({ gymId: req.user.gymId })
        .select("trainerId fullName")
        .lean(),
    ]);
    const trainerNames = new Map(
      trainers.map((trainer) => [trainer.trainerId, trainer.fullName]),
    );
    const membersWithTrainerNames = members.map((member) => ({
      ...member,
      trainerName: trainerNames.get(member.trainerId) ?? "",
    }));

    return res.status(200).json({
      success: true,
      message: "Members fetched successfully",
      data: {
        members: membersWithTrainerNames,
      },
    });
  } catch (error) {
    console.error("Get members error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

const deleteMember = async (req, res) => {
  try {
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can delete members",
      });
    }

    const { id } = req.params;
    const memberSelector = mongoose.isValidObjectId(id)
      ? { $or: [{ _id: id }, { clientId: id }] }
      : { clientId: id };
    const member = await Member.findOneAndDelete({
      ...memberSelector,
      gymId: req.user.gymId,
    });

    if (!member) {
      return res.status(404).json({
        success: false,
        message: "Member not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Member deleted successfully",
      data: {
        member: {
          clientId: member.clientId,
          fullName: member.fullName,
        },
      },
    });
  } catch (error) {
    console.error("Delete member error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

export { addMember, deleteMember, getMembers };
