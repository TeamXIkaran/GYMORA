const MEMBER_PLANS = {
  BASIC: {
    name: "Basic Plan",
    planCode: "BASIC",
    price: 5000,
    durationMonths: 1,
  },

  STANDARD: {
    name: "Standard Plan",
    planCode: "STANDARD",
    price: 10000,
    durationMonths: 3,
  },

  PREMIUM: {
    name: "Premium Plan",
    planCode: "PREMIUM",
    price: 15000,
    durationMonths: 6,
  },
};

const getPlans = (req, res) => {
  try {
    const plans = Object.values(MEMBER_PLANS);

    return res.status(200).json({
      success: true,
      message: "Plans fetched successfully",
      data: {
        plans,
      },
    });
  } catch (error) {
    console.error("Get plans error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

export { getPlans };