import asyncHandler from "express-async-handler";
import User from "../models/User.js";
import generateToken from "../utils/generateToken.js"; // Helper function for JWT

// @desc    Register a new user
// @route   POST /api/users/register
// @access  Public
export const registerUser = asyncHandler(async (req, res) => {
    const { fullName, email, password } = req.body;

    // Validate input
    if (!fullName || !email || !password) {
        res.status(400).json({ message: "Please fill in all fields" });
    }

    // Check if user already exists
    const userExists = await User.findOne({ email });

    if (userExists) {
        res.status(400).json({ message: "User already exists" });
    }

    // Create new user
    const user = await User.create({
        fullName,
        email,
        password, // Password gets hashed in the User model
    });

    if (user) {
        res.status(201).json({
            "success": true,
            "message": "User created successfully",
            "data": {
                _id: user._id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                token: generateToken(user._id),
            },
        });
    } else {
        res.status(400).json({ message: "Invalid user data" });
    }
});

export const loginUser = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
        res.status(400).json({ message: "Please fill in all fields" });
    }

    // Check if user exists
    const user = await User.findOne({ email });

    if (user && (await user.matchPassword(password))) {
        res.json({
            "success": true,
            "message": "User logged in successfully",
            "data": {
                _id: user._id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                token: generateToken(user._id),
            },
        });
    } else {
        res.status(401).json({ message: "Invalid email or password" });
    }
});