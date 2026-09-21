import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import connectDB from "./src/config/db.js";
import ownerRoutes from "./src/routes/ownerRoutes.js";
import paymentRoutes from "./src/routes/paymentRoutes.js";
import memberRoutes from "./src/routes/memberRoutes.js";
import trainerRoutes from "./src/routes/trainerRoutes.js";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/owner", ownerRoutes);
app.use("/api/payment", paymentRoutes);
app.use("/api/members", memberRoutes);
app.use("/api/trainers", trainerRoutes);


app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Karan Trainer Gym Backend is running",
  });
});

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
};

startServer();