import jwt from "jsonwebtoken";
import User from "../models/User.js";

export default async function authMiddleware(req, res, next) {
  let token;

  let authHeader = req.headers.authorization || req.headers.Authorization;
  if (authHeader && authHeader.startsWith("Bearer")) {
    token = authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        message: "Unauthorized",
      });
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Check if user exists and is still logged in with this token
      const user = await User.findById(decoded._id);
      if (!user || !user.isLoggedIn || user.currentSessionToken !== token) {
        return res.status(401).json({
          message: "Session expired or invalid. Please login again.",
          error: "INVALID_SESSION"
        });
      }
      
      req.user = decoded;
      next();
    } catch (err) {
      return res.status(401).json({
        message: "Unauthorized",
      });
    }
  } else {
    return res.status(401).json({
      message: "Unauthorized",
    });
  }
}
