import express from "express";
import multer from "../config/multer.js";
import {
  registerUser,
  loginUser,
  getUserProfile,
  updateUserProfile,
  deleteUser,
  uploadProfileImage,
  createAgent,
  getAgents,
  getAgentById,
  updateAgent,
  deleteAgent,
} from "../controllers/user_controller.js";
import authMiddleware from "../middlewares/auth-middleware.js";
import AuthorizeRole from "../middlewares/role_middleware.js";

const router = express.Router();

// User Auth
router.post("/register", registerUser);
router.post("/login", loginUser);


router
  .route("/profile")
  .get(authMiddleware, getUserProfile)
  .put(authMiddleware, updateUserProfile)
  .delete(authMiddleware, deleteUser);

// Image Upload (User)
router.post(
  "/upload",
  authMiddleware,
  multer.single("image"),
  uploadProfileImage
);

// Agent Routes (Admin Only)
router.post(
  "/agents",
  authMiddleware,
  AuthorizeRole("admin"),
  multer.single("image"),
  createAgent
);

router.get("/agents", authMiddleware, getAgents);
router.get("/agents/:id", authMiddleware, AuthorizeRole("admin"), getAgentById);
router.put(
  "/agents/:id",
  authMiddleware,
  AuthorizeRole("admin"),
  multer.single("image"),
  updateAgent
);
router.delete("/agents/:id", authMiddleware, AuthorizeRole("admin"), deleteAgent);

export default router;