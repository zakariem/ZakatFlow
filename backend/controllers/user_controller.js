import asyncHandler from "express-async-handler";
import User from "../models/User.js";
import generateToken from "../utils/generateToken.js";
import cloudinary from "../config/cloud.js";

// --------------------- AUTH ---------------------

// Register user
export const registerUser = asyncHandler(async (req, res) => {
  const { fullName, email, password } = req.body;
  if (!fullName || !email || !password) {
    return res.status(400).json({ message: "Fadlan buuxi dhammaan meelaha bannaan" });
  }

  const userExists = await User.findOne({ email });
  if (userExists) {
    return res.status(400).json({ message: "Isticmaale hore ayuu u jiray" });
  }

  const isFirstUser = (await User.countDocuments()) === 0;
  const user = new User({ fullName, email, password, role: isFirstUser ? "admin" : "client" });

  await user.save();
  const { password: _, ...userData } = user.toObject();

  res.status(201).json({
    success: true,
    message: "Isticmaale si guul leh ayaa loo diiwaan geliyay",
    data: { ...userData, token: generateToken(user._id) },
  });
});

// Login user
export const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "Fadlan buuxi dhammaan meelaha bannaan" });
  }

  const user = await User.findOne({ email }).select("+password");
  if (user && (await user.matchPassword(password))) {
    const { password: _, ...userData } = user.toObject();
    res.json({
      success: true,
      message: "Si guul leh ayaad u gashay",
      data: { ...userData, token: generateToken(user._id) },
    });
  } else {
    res.status(401).json({ message: "Email ama Password ayaa khaldan" });
  }
});

// --------------------- USER PROFILE ---------------------

// Get current user profile
export const getUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).select("-password");
  if (!user) return res.status(404).json({ message: "Isticmaale lama helin" });
  res.json({ success: true, data: user });
});

// Update user profile
export const updateUserProfile = asyncHandler(async (req, res) => {
  const { fullName, email, password, _id } = req.body;
  const user = await User.findById(_id);
  if (!user) return res.status(404).json({ message: "Isticmaale lama helin" });

  if (email && email !== user.email) {
    const emailExists = await User.findOne({ email });
    if (emailExists) return res.status(400).json({ message: "Email hore ayaa loo isticmaalay" });
    user.email = email;
  }

  if (fullName) user.fullName = fullName;
  if (password) user.password = password;

  const updatedUser = await user.save();
  const { password: _, ...userData } = updatedUser.toObject();

  res.json({
    success: true,
    message: "Xogta isticmaalaha waa la cusboonaysiiyay",
    data: { ...userData, token: generateToken(updatedUser._id) },
  });
});

// Delete user
export const deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.body._id);


  if (!user) {
    console.log("User not found for ID:", req.body._id);
    return res.status(404).json({ message: "Isticmaale lama helin" });
  }

  // Delete profile image if it exists
  if (user.cloudinaryPublicId) {
    await cloudinary.uploader.destroy(user.cloudinaryPublicId);
  }

  await user.deleteOne();
  res.json({ success: true, message: "Akaawnka isticmaalaha waa la tirtiray" });
});

// --------------------- IMAGE UPLOAD ---------------------

// Upload user profile image
export const uploadProfileImage = asyncHandler(async (req, res) => {
  if (!req.file) return res.status(400).json({ message: "Fayl lama helin" });

  const user = await User.findById(req.headers.userid);
  if (!user) return res.status(404).json({ message: "Isticmaale lama helin" });

  if (user.cloudinaryPublicId) await cloudinary.uploader.destroy(user.cloudinaryPublicId);

  const result = await new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream({ folder: "profile_images" }, (error, result) => {
      if (error) reject(error);
      else resolve(result);
    }).end(req.file.buffer);
  });

  user.profileImageUrl = result.secure_url;
  user.cloudinaryPublicId = result.public_id;
  const updatedUser = await user.save();

  const { password: _, ...userData } = updatedUser.toObject();
  res.status(200).json({
    success: true,
    message: "Sawirka si guul leh ayaa loo geliyay",
    data: { ...userData, token: generateToken(user._id) },
  });
});

// --------------------- AGENT CRUD (admin only) ---------------------

// Create agent
export const createAgent = asyncHandler(async (req, res) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({ message: "Kaliya admin ayaa abuurikaro agent" });
  }

  const { fullName, email, password, phoneNumber, address } = req.body;
  if (!fullName || !email || !password || phoneNumber || address || !req.file) {
    return res.status(400).json({ message: "Fadlan buuxi dhammaan xogta oo ay ku jirto sawir" });
  }

  const exists = await User.findOne({ email });
  if (exists) return res.status(400).json({ message: "Email hore ayaa loo isticmaalay" });

  const uploadResult = await new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream({ folder: "agents" }, (error, result) => {
      if (error) reject(error);
      else resolve(result);
    }).end(req.file.buffer);
  });

  const agent = new User({
    fullName,
    email,
    phoneNumber,
    address,
    password,
    role: "agent",
    profileImageUrl: uploadResult.secure_url,
    cloudinaryPublicId: uploadResult.public_id,
    totalDonation: 0,
  });

  await agent.save();
  const { password: _, ...agentData } = agent.toObject();

  res.status(201).json({
    success: true,
    message: "Agent si guul leh ayaa loo abuuray",
    data: agentData,
  });
});

// Get all agents
export const getAgents = asyncHandler(async (req, res) => {
  const agents = await User.find({ role: "agent" }).select("-password");
  res.json({ success: true, data: agents });
});

// Get single agent
export const getAgentById = asyncHandler(async (req, res) => {
  const agent = await User.findOne({ _id: req.params.id, role: "agent" }).select("-password");
  if (!agent) return res.status(404).json({ message: "Agent lama helin" });
  res.json({ success: true, data: agent });
});

// Update agent
export const updateAgent = asyncHandler(async (req, res) => {
  const agent = await User.findOne({ _id: req.params.id, role: "agent" });
  if (!agent) return res.status(404).json({ message: "Agent lama helin" });

  const { fullName, email, password, phoneNumber, address } = req.body;

  if (email && email !== agent.email) {
    const emailExists = await User.findOne({ email });
    if (emailExists) return res.status(400).json({ message: "Email hore ayaa loo isticmaalay" });
    agent.email = email;
  }

  if (fullName) agent.fullName = fullName;
  if (password) agent.password = password;
  if (phoneNumber) agent.phoneNumber = phoneNumber;
  if (address) agent.address = address;

  if (req.file) {
    if (agent.cloudinaryPublicId) await cloudinary.uploader.destroy(agent.cloudinaryPublicId);
    const uploadResult = await new Promise((resolve, reject) => {
      cloudinary.uploader.upload_stream({ folder: "agents" }, (error, result) => {
        if (error) reject(error);
        else resolve(result);
      }).end(req.file.buffer);
    });
    agent.profileImageUrl = uploadResult.secure_url;
    agent.cloudinaryPublicId = uploadResult.public_id;
  }

  const updatedAgent = await agent.save();
  const { password: _, ...agentData } = updatedAgent.toObject();

  res.json({
    success: true,
    message: "Xogta agent-ka waa la cusboonaysiiyay",
    data: agentData,
  });
});

// Delete agent
export const deleteAgent = asyncHandler(async (req, res) => {
  const agent = await User.findOne({ _id: req.params.id, role: "agent" });
  if (!agent) return res.status(404).json({ message: "Agent lama helin" });

  if (agent.cloudinaryPublicId) {
    await cloudinary.uploader.destroy(agent.cloudinaryPublicId);
  }

  await agent.deleteOne();
  res.json({ success: true, message: "Agent si guul leh ayaa loo tirtiray" });
});
