import asyncHandler from "express-async-handler";
import User from "../models/User.js";
import generateToken from "../utils/generateToken.js";
import cloudinary from "../config/cloud.js";

// @desc    Register a new user
// @route   POST /api/users/register
// @access  Public
export const registerUser = asyncHandler(async (req, res) => {
  const { fullName, email, password } = req.body;
  if (!fullName || !email || !password) {
    return res.status(400).json({ message: "Please fill in all fields" });
  }

  const userExists = await User.findOne({ email });
  if (userExists) {
    return res.status(400).json({ message: "User already exists" });
  }

  const user = new User({ fullName, email, password });
  await user.save(); // Ensure password is hashed before saving

  if (user) {
    const { password, ...userData } = user.toObject();
    res.status(201).json({
      success: true,
      message: "User created successfully",
      data: { ...userData, token: generateToken(user._id) },
    });
  } else {
    res.status(400).json({ message: "Invalid user data" });
  }
});

// @desc    Login user
// @route   POST /api/users/login
// @access  Public
export const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "Please fill in all fields" });
  }

  const user = await User.findOne({ email }).select("+password"); // Explicitly select password
  if (user && (await user.matchPassword(password))) {
    const { password, ...userData } = user.toObject();
    res.json({
      success: true,
      message: "User logged in successfully",
      data: { ...userData, token: generateToken(user._id) },
    });
  } else {
    res.status(401).json({ message: "Invalid email or password" });
  }
});

// @desc    Get all users
// @route   GET /api/users
// @access  Private/Admin
export const getUsers = asyncHandler(async (req, res) => {
  const users = await User.find().select("-password");
  res.json({ success: true, data: users });
});

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
export const getUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).select("-password");
  if (user) {
    res.json({ success: true, data: user });
  } else {
    res.status(404).json({ message: "User not found" });
  }
});

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
export const updateUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  if (user) {
    user.fullName = req.body.fullName || user.fullName;
    user.email = req.body.email || user.email;
    if (req.body.password) {
      user.password = req.body.password;
    }
    const updatedUser = await user.save();
    const { password, ...userData } = updatedUser.toObject();
    res.json({
      success: true,
      message: "User updated successfully",
      data: { ...userData, token: generateToken(updatedUser._id) },
    });
  } else {
    res.status(404).json({ message: "User not found" });
  }
});

// @desc    Delete user
// @route   DELETE /api/users/:id
// @access  Private/Admin/Client
export const deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  if (
    req.user._id.toString() !== user._id.toString() &&
    req.user.role !== "admin"
  ) {
    return res
      .status(403)
      .json({ message: "Not authorized to delete this account" });
  }
  await user.deleteOne();
  res.json({ success: true, message: "User account deleted successfully" });
});

// @desc    Upload profile image
// @route   POST /api/users/upload
// @access  Private
export const uploadProfileImage = asyncHandler(async (req, res) => {
  const { userId } = req.body;

  if (!req.file || !userId) {
    return res.status(400).json({ message: "Missing file or userId" });
  }

  const user = await User.findById(userId);
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  try {
    // Delete old image if exists
    if (user.cloudinaryPublicId) {
      await cloudinary.uploader.destroy(user.cloudinaryPublicId);
    }

    // Upload new image
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: "profile_images" },
      async (error, result) => {
        if (error) {
          return res.status(500).json({ message: "Upload error", error: error.message });
        }

        // Update user details
        user.profileImageUrl = result.secure_url;
        user.cloudinaryPublicId = result.public_id;
        await user.save();

        res.status(200).json({
          success: true,
          message: "Image uploaded successfully",
          data: user,
          token: generateToken(user._id),
        });
      }
    );

    uploadStream.end(req.file.buffer);
  } catch (error) {
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});
