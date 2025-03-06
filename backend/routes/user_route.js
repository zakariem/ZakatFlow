import express from "express";
import { registerUser, loginUser, getUsers, getUserProfile, updateUserProfile, deleteUser } from "../controllers/user_controller.js";
import authMiddleware from "../middlewares/auth-middleware.js";
import AuthorizeRole from "../middlewares/role-middleware.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);

router.route("/").get(authMiddleware, AuthorizeRole("admin"), getUsers);
router.route("/profile").get(authMiddleware, getUserProfile).put(authMiddleware, updateUserProfile).delete(authMiddleware, deleteUser);

export default router;