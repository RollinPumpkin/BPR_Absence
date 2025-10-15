// Admin role check middleware
const requireAdminRole = (req, res, next) => {
  const { role: userRole } = req.user;
  
  if (userRole !== 'admin' && userRole !== 'super_admin') {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Admin or Super Admin role required.'
    });
  }
  
  next();
};

module.exports = requireAdminRole;