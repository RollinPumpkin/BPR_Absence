const adminAuth = (req, res, next) => {
  try {
    // Check if user has admin role (admin or super_admin)
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';
    const hasAdminEmployeeId = req.user.employeeId?.startsWith('SUP') || req.user.employeeId?.startsWith('ADM');
    
    if (!isAdmin && !hasAdminEmployeeId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Authorization check failed'
    });
  }
};

module.exports = adminAuth;
