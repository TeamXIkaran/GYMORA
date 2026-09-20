import express from "express";

import {
    submitPayment,
    approvePayment,
    rejectPayment,
} from "../controllers/paymentController.js";

const router = express.Router();

router.post("/submit", submitPayment);

router.post("/approve", approvePayment);

router.post("/reject", rejectPayment);

export default router;