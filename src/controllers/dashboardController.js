import Owner from "../models/Owner.js";
import Member from "../models/Member.js";
import Trainer from "../models/Trainer.js";

const MEMBER_PLAN_PRICES = {
  BASIC: 5000,
  STANDARD: 10000,
  PREMIUM: 15000,
};

const getOwnerDashboard = async (req, res) => {
  try {
    // Only owners can access dashboard
    if (req.user.role !== "OWNER") {
      return res.status(403).json({
        success: false,
        message: "Only gym owners can access the dashboard",
      });
    }

    const gymId = req.user.gymId;

    // Get owner
    const owner = await Owner.findOne({ gymId }).select(
      "ownerName gymName gymId"
    );

    if (!owner) {
      return res.status(404).json({
        success: false,
        message: "Owner not found",
      });
    }

    // Get members and trainers of this gym
    const members = await Member.find({ gymId })
      .select("-password")
      .sort({ createdAt: -1 });

    const trainers = await Trainer.find({ gymId })
      .select("-password")
      .sort({ createdAt: -1 });

    // Total members
    const totalMembers = members.length;

    // Total trainers
    const totalTrainers = trainers.length;

    // Calculate total revenue
    const totalRevenue = members.reduce((total, member) => {
      const price = MEMBER_PLAN_PRICES[member.membershipPlan] || 0;

      return total + price;
    }, 0);

    // Current month and previous month
    const now = new Date();

    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();

    const previousMonthDate = new Date(
      currentYear,
      currentMonth - 1,
      1
    );

    const previousYear = previousMonthDate.getFullYear();
    const previousMonth = previousMonthDate.getMonth();

    // Calculate current month revenue
    const currentMonthRevenue = members.reduce((total, member) => {
      const memberDate = new Date(member.startDate);

      if (
        memberDate.getFullYear() === currentYear &&
        memberDate.getMonth() === currentMonth
      ) {
        return (
          total +
          (MEMBER_PLAN_PRICES[member.membershipPlan] || 0)
        );
      }

      return total;
    }, 0);

    // Calculate previous month revenue
    const previousMonthRevenue = members.reduce((total, member) => {
      const memberDate = new Date(member.startDate);

      if (
        memberDate.getFullYear() === previousYear &&
        memberDate.getMonth() === previousMonth
      ) {
        return (
          total +
          (MEMBER_PLAN_PRICES[member.membershipPlan] || 0)
        );
      }

      return total;
    }, 0);

    // Calculate percentage change
    let percentageChange = 0;

    if (previousMonthRevenue > 0) {
      percentageChange =
        ((currentMonthRevenue - previousMonthRevenue) /
          previousMonthRevenue) *
        100;

      percentageChange = Number(percentageChange.toFixed(2));
    } else if (currentMonthRevenue > 0) {
      percentageChange = 100;
    }

    // Recent 5 members
    const recentMembers = members.slice(0, 5).map((member) => ({
      id: member._id,
      fullName: member.fullName,
      membershipPlan: member.membershipPlan,
      status: member.status,
      startDate: member.startDate,
      endDate: member.endDate,
    }));

    // Trainer overview
    const trainerOverview = trainers.slice(0, 5).map((trainer) => ({
      id: trainer._id,
      fullName: trainer.fullName,
      specialization: trainer.specialization,
      experience: trainer.experience,
      status: trainer.status,
    }));

    return res.status(200).json({
      success: true,
      message: "Dashboard data fetched successfully",
      data: {
        owner: {
          name: owner.ownerName,
          gymName: owner.gymName,
          gymId: owner.gymId,
        },

        summary: {
          totalMembers,
          totalTrainers,
          totalRevenue,
        },

        revenueOverview: {
          revenue: totalRevenue,
          currentMonthRevenue,
          previousMonthRevenue,
          percentageChange,
        },

        quickActions: {
          members: totalMembers,
          trainers: totalTrainers,
        },

        recentMembers,

        trainerOverview,
      },
    });
  } catch (error) {
    console.error("Get owner dashboard error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

export { getOwnerDashboard };