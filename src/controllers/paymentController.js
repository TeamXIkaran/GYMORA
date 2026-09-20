import Payment from "../models/Payment.js";
import Owner from "../models/Owner.js";
import bcrypt from "bcryptjs";
import {
    sendPaymentNotification,
    sendOwnerCredentialsEmail,
} from "../services/emailService.js";

const PLAN_DETAILS = {
    STARTER: {
        amount: 5,
    },
    PRO: {
        amount: 10,
    },
    ELITE: {
        amount: 15,
    },
};

const submitPayment = async (req, res) => {
    try {
        const { ownerId } = req.body;

        if (!ownerId) {
            return res.status(400).json({
                success: false,
                message: "Owner ID is required",
            });
        }

        const owner = await Owner.findById(ownerId);

        if (!owner) {
            return res.status(404).json({
                success: false,
                message: "Owner not found",
            });
        }

        if (owner.paymentStatus === "APPROVED") {
            return res.status(400).json({
                success: false,
                message: "Payment has already been approved",
            });
        }

        const planDetails = PLAN_DETAILS[owner.plan];

        if (!planDetails) {
            return res.status(400).json({
                success: false,
                message: "Invalid membership plan",
            });
        }

        const existingPayment = await Payment.findOne({
            owner: owner._id,
            paymentStatus: "PENDING",
        });

        if (existingPayment) {
            return res.status(400).json({
                success: false,
                message: "Payment is already pending for verification",
                data: {
                    paymentId: existingPayment._id,
                },
            });
        }

        const payment = await Payment.create({
            owner: owner._id,
            gymName: owner.gymName,
            gymId: owner.gymId,
            ownerName: owner.ownerName,
            plan: owner.plan,
            amount: planDetails.amount,
            paymentStatus: "PENDING",
        });

        sendPaymentNotification({
            gymName: payment.gymName,
            gymId: payment.gymId,
            ownerName: payment.ownerName,
            plan: payment.plan,
            amount: payment.amount,
            paymentId: payment._id,
            paymentStatus: payment.paymentStatus,
        }).catch((error) => {
            console.error(
                "Payment notification email failed:",
                error.message
            );
        });

        return res.status(201).json({
            success: true,
            message: "Payment submitted for verification",
            data: {
                paymentId: payment._id,
                gymName: payment.gymName,
                gymId: payment.gymId,
                plan: payment.plan,
                amount: payment.amount,
                paymentStatus: payment.paymentStatus,
            },
        });
    } catch (error) {
        console.error("Submit payment error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

const approvePayment = async (req, res) => {
    try {
        const { paymentId } = req.body;

        if (!paymentId) {
            return res.status(400).json({
                success: false,
                message: "Payment ID is required",
            });
        }

        const payment = await Payment.findById(paymentId);

        if (!payment) {
            return res.status(404).json({
                success: false,
                message: "Payment not found",
            });
        }

        if (payment.paymentStatus === "APPROVED") {
            return res.status(400).json({
                success: false,
                message: "Payment is already approved",
            });
        }

        if (payment.paymentStatus === "REJECTED") {
            return res.status(400).json({
                success: false,
                message: "Payment has already been rejected",
            });
        }

        const owner = await Owner.findById(payment.owner);

        if (!owner) {
            return res.status(404).json({
                success: false,
                message: "Owner not found",
            });
        }

        const membershipStartDate = new Date();
        const membershipEndDate = new Date(membershipStartDate);

        if (payment.plan === "STARTER") {
            membershipEndDate.setMonth(
                membershipEndDate.getMonth() + 1
            );
        } else if (payment.plan === "PRO") {
            membershipEndDate.setMonth(
                membershipEndDate.getMonth() + 3
            );
        } else if (payment.plan === "ELITE") {
            membershipEndDate.setMonth(
                membershipEndDate.getMonth() + 6
            );
        }

        const temporaryPassword = `Gym@${Math.random()
            .toString(36)
            .slice(-8)}`;

        const hashedTemporaryPassword = await bcrypt.hash(
            temporaryPassword,
            10
        );

        owner.password = hashedTemporaryPassword;

        payment.paymentStatus = "APPROVED";
        payment.verifiedAt = new Date();

        owner.paymentStatus = "APPROVED";
        owner.membershipStatus = "ACTIVE";
        owner.membershipStartDate = membershipStartDate;
        owner.membershipEndDate = membershipEndDate;

        await payment.save();
        await owner.save();

        sendOwnerCredentialsEmail({
            gymName: owner.gymName,
            gymId: owner.gymId,
            ownerName: owner.ownerName,
            password: temporaryPassword,
            plan: owner.plan,
            membershipStartDate: owner.membershipStartDate,
            membershipEndDate: owner.membershipEndDate,
            email: owner.email,
        }).catch((error) => {
            console.error(
                "Owner credentials email failed:",
                error.message
            );
        });

        return res.status(200).json({
            success: true,
            message: "Payment approved and membership activated",
            data: {
                paymentId: payment._id,
                paymentStatus: payment.paymentStatus,
                membershipStatus: owner.membershipStatus,
                membershipStartDate: owner.membershipStartDate,
                membershipEndDate: owner.membershipEndDate,
            },
        });
    } catch (error) {
        console.error("Approve payment error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

const rejectPayment = async (req, res) => {
    try {
        const { paymentId } = req.body;

        if (!paymentId) {
            return res.status(400).json({
                success: false,
                message: "Payment ID is required",
            });
        }

        const payment = await Payment.findById(paymentId);

        if (!payment) {
            return res.status(404).json({
                success: false,
                message: "Payment not found",
            });
        }

        if (payment.paymentStatus === "APPROVED") {
            return res.status(400).json({
                success: false,
                message: "Payment is already approved",
            });
        }

        if (payment.paymentStatus === "REJECTED") {
            return res.status(400).json({
                success: false,
                message: "Payment is already rejected",
            });
        }

        const owner = await Owner.findById(payment.owner);

        if (!owner) {
            return res.status(404).json({
                success: false,
                message: "Owner not found",
            });
        }

        payment.paymentStatus = "REJECTED";
        payment.verifiedAt = new Date();

        owner.paymentStatus = "REJECTED";
        owner.membershipStatus = "PENDING";

        await payment.save();
        await owner.save();

        return res.status(200).json({
            success: true,
            message: "Payment rejected successfully",
            data: {
                paymentId: payment._id,
                paymentStatus: payment.paymentStatus,
                membershipStatus: owner.membershipStatus,
            },
        });
    } catch (error) {
        console.error("Reject payment error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error",
        });
    }
};

export {
    submitPayment,
    approvePayment,
    rejectPayment,
};

