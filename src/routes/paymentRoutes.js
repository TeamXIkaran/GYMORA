import express from "express";

import {
    submitPayment,
    approvePayment,
    rejectPayment,
    getPaymentStatus,
} from "../controllers/paymentController.js";

const router = express.Router();

router.post("/submit", submitPayment);
router.post("/approve", approvePayment);
router.post("/reject", rejectPayment);

router.get("/status/:paymentId", getPaymentStatus);

export default router;