import bcrypt from "bcryptjs";
import Member from "../models/Member.js";

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
      planName,
      phone,
      email,
      password,
      membershipPlan,
      startDate,
      endDate,
    } = req.body;

    // Required fields
    if (
      !fullName ||
      !phone ||
      !email ||
      !password ||
      !membershipPlan ||
      !startDate ||
      !endDate
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

    // Validate dates
    const membershipStartDate = new Date(startDate);
    const membershipEndDate = new Date(endDate);

    if (
      Number.isNaN(membershipStartDate.getTime()) ||
      Number.isNaN(membershipEndDate.getTime())
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid membership dates",
      });
    }

    if (membershipEndDate <= membershipStartDate) {
      return res.status(400).json({
        success: false,
        message: "End date must be after start date",
      });
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
      fullName: fullName.trim(),
      planName: planName?.trim() || "",
      phone: phone.trim(),
      email: email.toLowerCase().trim(),

      // IMPORTANT:
      // gymId comes from the authenticated owner's JWT
      gymId: req.user.gymId,

      password: hashedPassword,
      membershipPlan: membershipPlan.trim(),
      startDate: membershipStartDate,
      endDate: membershipEndDate,
    });

    return res.status(201).json({
      success: true,
      message: "Member added successfully",
      data: {
        member: {
          id: member._id,
          fullName: member.fullName,
          planName: member.planName,
          phone: member.phone,
          email: member.email,
          gymId: member.gymId,
          membershipPlan: member.membershipPlan,
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

export { addMember };