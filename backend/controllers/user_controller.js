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
  const user = await User.findById(req.body._id);
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
  const user = await User.findById(req.user._id);
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
  console.log("Received request to upload profile image");

  if (!req.file) {
    console.log("No file uploaded");
    return res.status(400).json({ message: "No file uploaded" });
  }

  console.log("Checking user existence with ID:", req.headers.userid);
  const user = await User.findById(req.headers.userid);

  if (!user) {
    console.log("User not found");
    return res.status(404).json({ message: "User not found" });
  }

  try {
    // Delete old image if it exists
    if (user.cloudinaryPublicId) {
      console.log("Deleting old image with Public ID:", user.cloudinaryPublicId);
      await cloudinary.uploader.destroy(user.cloudinaryPublicId);
      console.log("Old image deleted successfully");
    }

    console.log("Uploading new image to Cloudinary...");

    // Use a Promise to handle async upload properly
    const uploadResult = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: "profile_images" },
        (error, result) => {
          if (error) {
            console.error("Upload error:", error.message);
            return reject(error);
          }
          resolve(result);
        }
      );
      stream.end(req.file.buffer);
    });

    console.log("Image uploaded successfully:", uploadResult.secure_url);

    // Update user details
    user.profileImageUrl = uploadResult.secure_url;
    user.cloudinaryPublicId = uploadResult.public_id;
    await user.save();

    console.log("User profile updated with new image");

    res.status(200).json({
      success: true,
      message: "Image uploaded successfully",
      data: {
        profileImageUrl: user.profileImageUrl,
        token: generateToken(user._id),
      },
    });
  } catch (error) {
    console.error("Internal server error:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});
