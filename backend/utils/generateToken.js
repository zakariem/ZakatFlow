import jwt from "jsonwebtoken";

const generateToken = (user) => {
  return jwt.sign(
    { _id: user._id, role: user.role }, // include role here!
    process.env.JWT_SECRET,
    { expiresIn: "30d" }
  );
};

export default generateToken;
