import mongoose from "mongoose";
import validator from "validator";

// Payment model for Zakat app integrating WaafiPay
const PaymentSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Payer (user) reference is required"]
    },
    userFullName: {
      type: String,
      required: [true, "Payer's full name is required"],
      trim: true,
      minlength: [3, "Full name must be at least 3 characters"],
      maxlength: [100, "Full name must not exceed 100 characters"]
    },
    userAccountNo: {
      type: String,
      required: [true, "Payer's mobile wallet number is required"],
      validate: {
        validator: function (v) {
          // Validate international phone number format
          return validator.isMobilePhone(v, 'any', { strictMode: false });
        },
        message: props => `${props.value} is not a valid phone number!`
      }
    },
    agentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Selected agent reference is required"]
    },
    agentName: {
      type: String,
      required: [true, "Selected agent's full name is required"],
      trim: true,
      minlength: [3, "Agent name must be at least 3 characters"],
      maxlength: [100, "Agent name must not exceed 100 characters"]
    },
    amount: {
      type: Number,
      required: [true, "Payment amount is required"],
      validate: {
        validator: function (v) {
          return v > 0;
        },
        message: props => `Amount must be greater than zero, got ${props.value}`
      }
    },
    currency: {
      type: String,
      default: "USD",
      uppercase: true,
      validate: {
        validator: function (v) {
          // ISO 4217 currency code validation: 3 uppercase letters
          return validator.isCurrency(`1 ${v}`) || /^[A-Z]{3}$/.test(v);
        },
        message: props => `${props.value} is not a valid currency code` 
      }
    },
    paymentMethod: {
      type: String,
      default: "mwallet_account",
      enum: ["mwallet_account", "CREDIT_CARD", "BANK_TRANSFER"],
      description: "Payment method used"
    },
    waafiResponse: {
      referenceId: { type: String, description: "Reference ID returned by WaafiPay" },
      transactionId: { type: String, description: "Transaction ID returned by WaafiPay" },
      issuerTransactionId: { type: String, description: "Issuer transaction ID from WaafiPay" },
      state: { type: String, description: "Transaction state (e.g., APPROVED)" },
      responseCode: { type: String, description: "Response code returned by WaafiPay" },
      responseMsg: { type: String, description: "Response message from WaafiPay" },
      merchantCharges: { type: Number, description: "Fees charged by the merchant gateway" },
      txAmount: { type: Number, description: "Actual amount processed by WaafiPay" }
    },
    paidAt: {
      type: Date,
      default: Date.now,
      description: "Timestamp when the payment was made"
    }
  },
  { timestamps: true }
);

const Payment = mongoose.model("Payment", PaymentSchema);
export default Payment;
