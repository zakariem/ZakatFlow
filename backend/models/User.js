import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import validator from "validator";

const UserSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: [true, "Full name is required"],
      trim: true,
      minlength: [3, "Full name must be at least 3 characters"],
      maxlength: [50, "Full name must not exceed 50 characters"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      validate: {
        validator: validator.isEmail,
        message: "Please provide a valid email address",
      },
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [6, "Password must be at least 6 characters"],
      select: false,
    },
    role: {
      type: String,
      enum: ["admin", "client", "agent"],
      default: "client",
    },

    // Agent-specific fields
    address: {
      type: String,
      required: [
        function () {
          return this.role === "agent";
        },
        "Address is required for agents",
      ],
      trim: true,
    },
    phoneNumber: {
      type: String,
      required: [
        function () {
          return this.role === "agent";
        },
        "Phone number is required for agents",
      ],
      trim: true,
    },
    totalDonation: {
      type: Number,
      required: [
        function () {
          return this.role === "agent";
        },
        "Total donation is required for agents",
      ],
    },

    profileImageUrl: {
      type: String,
      default:
        "https://media.istockphoto.com/id/2151669184/vector/vector-flat-illustration-in-grayscale-avatar-user-profile-person-icon-gender-neutral.jpg?s=612x612&w=0&k=20&c=UEa7oHoOL30ynvmJzSCIPrwwopJdfqzBs0q69ezQoM8=",
    },
    cloudinaryPublicId: {
      type: String,
      default: null,
    },
    
    // Session tracking fields
    isLoggedIn: {
      type: Boolean,
      default: false,
    },
    currentSessionToken: {
      type: String,
      default: null,
    },
    lastLoginAt: {
      type: Date,
      default: null,
    },
    loginDeviceInfo: {
      type: String,
      default: null,
    },
  },
  { timestamps: true }
);

// Hash password before saving
UserSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  try {
    this.password = await bcrypt.hash(this.password, 10);
    next();
  } catch (error) {
    next(error);
  }
});

// Password comparison method
UserSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Session management methods
UserSchema.methods.setLoggedIn = function (token, deviceInfo = null) {
  this.isLoggedIn = true;
  this.currentSessionToken = token;
  this.lastLoginAt = new Date();
  this.loginDeviceInfo = deviceInfo;
};

UserSchema.methods.setLoggedOut = function () {
  this.isLoggedIn = false;
  this.currentSessionToken = null;
  this.loginDeviceInfo = null;
};

const User = mongoose.model("User", UserSchema);
export default User;
