import express from "express";
import {
  createPayment,
  getPayments,
  getAgentPayments,
  getUserPayments
} from "../controllers/payment_controller.js";
import authMiddleware from "../middlewares/auth-middleware.js";

const router = express.Router();

router.post("/", authMiddleware, createPayment);
router.get("/", authMiddleware, getPayments);
router.get("/agent", authMiddleware, getAgentPayments);
router.get("/user", authMiddleware, getUserPayments);

export default router;