import express from "express";
import {
  createPayment,
  getPayments,
  getAgentPayments,
  getUserPayments
} from "../controllers/payment_controller.js";
import authMiddleware from "../middlewares/auth-middleware.js";
import authorizeRole from "../middlewares/role_middleware.js";

const router = express.Router();

router.post("/", authMiddleware, createPayment, authorizeRole("client"));
router.get("/", authMiddleware, getPayments, authorizeRole("admin"));
router.get("/agent", authMiddleware, getAgentPayments, authorizeRole("agent"));
router.get("/user", authMiddleware, getUserPayments, authorizeRole("client"));

export default router;