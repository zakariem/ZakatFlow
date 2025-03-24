import express from "express";
import {
  registerUser,
  loginUser,
  getUsers,
  getUserProfile,
  updateUserProfile,
  deleteUser,
  uploadProfileImage,
} from "../controllers/user_controller.js";
import authMiddleware from "../middlewares/auth-middleware.js";
import AuthorizeRole from "../middlewares/role_middleware.js";
import multer from "multer";

const router = express.Router();
const upload = multer();

router.post("/register", registerUser);
router.post("/login", loginUser);

router.get("/", authMiddleware, AuthorizeRole("admin"), getUsers);
router
  .route("/profile")
  .get(authMiddleware, getUserProfile)
  .put(authMiddleware, updateUserProfile)
  .delete(authMiddleware, deleteUser);

router.post(
  "/upload",
  authMiddleware,
  upload.single("image"),
  uploadProfileImage
);

export default router;
