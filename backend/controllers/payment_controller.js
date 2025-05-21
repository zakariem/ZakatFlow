import asyncHandler from "express-async-handler";
import axios from "axios";
import Payment from "../models/Payment.js";
import User from "../models/User.js";
import validator from "validator";

// @desc    Create a new payment and process via WaafiPay
// @route   POST /api/payments
// @access  Private (client)
export const createPayment = asyncHandler(async (req, res) => {
  const {
    userFullName,
    userAccountNo,
    agentId,
    agentName,
    amount,
    currency = "USD"
  } = req.body;

  if (!userFullName || !userAccountNo || !agentId || !agentName || !amount) {
    return res.status(400).json({ message: "All payment fields are required" });
  }
  if (!validator.isMobilePhone(userAccountNo, 'any')) {
    return res.status(400).json({ message: "Invalid payer phone number" });
  }
  if (amount <= 0) {
    return res.status(400).json({ message: "Amount must be greater than zero" });
  }

  const agent = await User.findById(agentId);
  if (!agent || agent.role !== "agent") {
    return res.status(404).json({ message: "Agent not found" });
  }

  const waafiPayload = {
    schemaVersion: "1.0",
    requestId: Date.now().toString(), // Numeric string
    timestamp: new Date().toISOString(),
    channelName: "WEB",
    serviceName: "API_PURCHASE",
    serviceParams: {
      merchantUid: process.env.WAAFI_MERCHANT_UID,
      apiUserId: process.env.WAAFI_API_USER_ID,
      apiKey: process.env.WAAFI_API_KEY,
      paymentMethod: "mwallet_account",
      payerInfo: { accountNo: userAccountNo },
      transactionInfo: {
        referenceId: Date.now().toString(), // Numeric reference
        invoiceId: Date.now().toString().slice(0, 10), // Numeric invoice
        amount: amount.toFixed(2), // Ensure 2 decimal places
        currency: currency,
        description: `Zakat payment to ${agentName}`
      }
    }
  };

  const waafiRes = await axios.post(
    "https://api.waafipay.net/asm",
    waafiPayload,
    { headers: { "Content-Type": "application/json" } }
  );

  const { responseCode, responseMsg, params } = waafiRes.data;

  if (responseCode === "2001") {
    const payment = await Payment.create({
      userId: req.user._id,
      userFullName,
      userAccountNo,
      agentId,
      agentName,
      amount,
      currency,
      paymentMethod: "mwallet_account",
      waafiResponse: {
        referenceId: params.referenceId,
        transactionId: params.transactionId,
        issuerTransactionId: params.issuerTransactionId,
        state: params.state,
        responseCode,
        responseMsg,
        merchantCharges: parseFloat(params.merchantCharges),
        txAmount: parseFloat(params.txAmount)
      },
      paidAt: new Date()
    });

    agent.totalDonation = (agent.totalDonation || 0) + amount;
    await agent.save();

    return res.status(201).json({ success: true, data: payment });
  } else {
    return res.status(400).json({ success: false, message: responseMsg });
  }
});

// @desc    Get all payments (admin only)
// @route   GET /api/payments
// @access  Private (admin)
export const getPayments = asyncHandler(async (req, res) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }
  const payments = await Payment.find().sort({ createdAt: -1 });
  res.json({ success: true, data: payments });
});

// @desc    Get payments received by an agent
// @route   GET /api/payments/agent
// @access  Private (agent)
export const getAgentPayments = asyncHandler(async (req, res) => {
  if (req.user.role !== "agent") {
    return res.status(403).json({ message: "Agent access required" });
  }
  const payments = await Payment.find({ agentId: req.user._id }).sort({ paidAt: -1 });
  res.json({ success: true, data: payments });
});

// @desc    Get payments made by a user
// @route   GET /api/payments/user
// @access  Private (client)
export const getUserPayments = asyncHandler(async (req, res) => {
  const payments = await Payment.find({ userId: req.user._id }).sort({ paidAt: -1 });
  res.json({ success: true, data: payments });
});