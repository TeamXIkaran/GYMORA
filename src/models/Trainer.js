import mongoose from "mongoose";

const trainerSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
    },

    phone: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      lowercase: true,
      trim: true,
    },

    gymId: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },

    password: {
      type: String,
      required: true,
    },

    specialization: {
      type: String,
      enum: [
        "Weight Training",
        "Cardio & HIIT",
        "CrossFit",
        "Yoga & Flexibility",
        "Strength & Conditioning",
        "Personal Training",
      ],
      required: true,
    },

    experience: {
      type: Number,
      required: true,
      min: 0,
    },

    status: {
      type: String,
      enum: ["ACTIVE", "INACTIVE"],
      default: "ACTIVE",
    },
  },
  {
    timestamps: true,
  }
);

const Trainer = mongoose.model("Trainer", trainerSchema);

export default Trainer;