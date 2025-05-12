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
    return res
      .status(400)
      .json({ message: "Fadlan buuxi dhammaan meelaha bannaan" });
  }

  const userExists = await User.findOne({ email });
  if (userExists) {
    return res.status(400).json({ message: "Isticmaale hore ayuu u jiray" });
  }

  const user = new User({ fullName, email, password });
  await user.save();

  if (user) {
    const { password, ...userData } = user.toObject();
    res.status(201).json({
      success: true,
      message: "Isticmaale si guul leh ayaa loo diiwaan geliyay",
      data: { ...userData, token: generateToken(user._id) },
    });
  } else {
    res.status(400).json({ message: "Xog isticmaalayaal aan sax ahayn" });
  }
});

// @desc    Login user
// @route   POST /api/users/login
// @access  Public
export const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res
      .status(400)
      .json({ message: "Fadlan buuxi dhammaan meelaha bannaan" });
  }

  const user = await User.findOne({ email }).select("+password");
  if (user && (await user.matchPassword(password))) {
    const { password, ...userData } = user.toObject();
    res.json({
      success: true,
      message: "Si guul leh ayaad u gashay",
      data: { ...userData, token: generateToken(user._id) },
    });
  } else {
    res.status(401).json({ message: "Email ama Password ayaa khaldan" });
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
    res.status(404).json({ message: "Isticmaale lama helin" });
  }
});

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
export const updateUserProfile = asyncHandler(async (req, res) => {
  const { fullName, email, password, _id } = req.body;

  const user = await User.findById(_id);

  if (!user) {
    return res.status(404).json({ message: "Isticmaale lama helin" });
  }

  // Check if email is changing and not already used
  if (email && email !== user.email) {
    const emailExists = await User.findOne({ email });
    if (emailExists) {
      return res
        .status(400)
        .json({ message: "Email-ka hore ayaa loo isticmaalay" });
    }
    user.email = email;
  }

  // Update other fields if provided
  if (fullName) user.fullName = fullName;
  if (password) user.password = password;

  const updatedUser = await user.save();

  // Remove password before sending response
  const { password: removed, ...userData } = updatedUser.toObject();

  res.json({
    success: true,
    message: "Xogta isticmaalaha si guul leh ayaa loo cusboonaysiiyay",
    data: { ...userData, token: generateToken(updatedUser._id) },
  });
});

// @desc    Delete user
// @route   DELETE /api/users/:id
// @access  Private/Admin/Client
export const deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.body._id);
  console.log("Tirtirista isticmaalaha ID-ga:", req.body._id);
  if (!user) {
    return res.status(404).json({ message: "Isticmaale lama helin" });
  }

  if (
    req.body._id.toString() !== user._id.toString() &&
    req.body.role !== "admin"
  ) {
    return res
      .status(403)
      .json({ message: "Ma haysid oggolaansho inaad tirtirto akoonkan" });
  }

  try {
    if (user.cloudinaryPublicId) {
      console.log(
        "Tirtirista sawirka isticmaalaha Cloudinary:",
        user.cloudinaryPublicId
      );
      await cloudinary.uploader.destroy(user.cloudinaryPublicId);
      console.log("Sawirka waa la tirtiray");
    }

    await user.deleteOne();
    res.json({
      success: true,
      message: "Akaawnka isticmaalaha waa la tirtiray",
    });
  } catch (error) {
    console.error("Khalad tirtirid:", error.message);
    res.status(500).json({ message: "Khalad gudaha ah", error: error.message });
  }
});

// @desc    Upload profile image
// @route   POST /api/users/upload
// @access  Private
export const uploadProfileImage = asyncHandler(async (req, res) => {
  console.log("Codsi la helay si loo geliyo sawirka profile-ka");

  if (!req.file) {
    console.log("Fayl lama soo gelin");
    return res.status(400).json({ message: "Fayl lama helin" });
  }

  console.log("Hubinta isticmaalaha ID-ga:", req.headers.userid);
  const user = await User.findById(req.headers.userid);

  if (!user) {
    console.log("Isticmaale lama helin");
    return res.status(404).json({ message: "Isticmaale lama helin" });
  }

  try {
    if (user.cloudinaryPublicId) {
      console.log("Tirtirida sawirkii hore:", user.cloudinaryPublicId);
      await cloudinary.uploader.destroy(user.cloudinaryPublicId);
      console.log("Sawirkii hore waa la tirtiray");
    }

    console.log("Gelinta sawirka cusub Cloudinary...");

    const uploadResult = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: "profile_images" },
        (error, result) => {
          if (error) {
            console.error("Khalad gelin:", error.message);
            return reject(error);
          }
          resolve(result);
        }
      );
      stream.end(req.file.buffer);
    });

    console.log("Sawir si guul leh ayaa loo geliyay:", uploadResult.secure_url);

    user.profileImageUrl = uploadResult.secure_url;
    user.cloudinaryPublicId = uploadResult.public_id;
    await user.save();

    console.log("Profile-ka isticmaalaha waa la cusboonaysiiyay");

    res.status(200).json({
      success: true,
      message: "Sawirka si guul leh ayaa loo geliyay",
      data: {
        profileImageUrl: user.profileImageUrl,
        token: generateToken(user._id),
      },
    });
  } catch (error) {
    console.error("Khalad gudaha ah:", error.message);
    res.status(500).json({ message: "Khalad gudaha ah", error: error.message });
  }
});
