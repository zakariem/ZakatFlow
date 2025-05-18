const AuthorizeRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user?.role) {
      return res.status(403).json({
        message: 'User role not found',
      });
    }
    if (!allowedRoles.includes(req.user.role)) {
      console.log(req.user.role);
      return res.status(403).json({
        message: `Role ${req.user.role} is not allowed to access this resource`,
      });
    }
    next();
  };
};

export default AuthorizeRole;