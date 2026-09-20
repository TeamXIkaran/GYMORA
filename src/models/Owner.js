import mongoose from "mongoose";

const ownerSchema = new mongoose.Schema(
  {
    gymName: {
      type: String,
      required: true,
      trim: true,
    },

    gymId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    ownerName: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    phone: {
      type: String,
      required: true,
      trim: true,
    },

    plan: {
      type: String,
      enum: ["STARTER", "PRO", "ELITE"],
      required: true,
    },

    paymentStatus: {
      type: String,
      enum: ["PENDING", "APPROVED", "REJECTED"],
      default: "PENDING",
    },

    membershipStatus: {
      type: String,
      enum: ["PENDING", "ACTIVE", "EXPIRED"],
      default: "PENDING",
    },

    membershipStartDate: {
      type: Date,
    },

    membershipEndDate: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

const Owner = mongoose.model("Owner", ownerSchema);

export default Owner;