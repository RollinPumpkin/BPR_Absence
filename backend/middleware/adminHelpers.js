/**
 * Helper functions for checking admin authorization consistently across routes
 */

const checkAdminAccess = (user) => {
  if (!user) return false;
  
  const hasAdminRole = user.role === 'admin' || user.role === 'super_admin';
  const hasAdminEmployeeId = user.employeeId?.startsWith('SUP') || 
                            user.employeeId?.startsWith('ADM') ||
                            user.employee_id?.startsWith('SUP') || 
                            user.employee_id?.startsWith('ADM');
  
  return hasAdminRole || hasAdminEmployeeId;
};

const checkSuperAdminAccess = (user) => {
  if (!user) return false;
  
  const hasRole = user.role === 'super_admin';
  const hasEmployeeId = user.employeeId?.startsWith('SUP') || 
                       user.employee_id?.startsWith('SUP');
  
  return hasRole || hasEmployeeId;
};

const requireAdmin = (req, res, next) => {
  if (!checkAdminAccess(req.user)) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Admin privileges required.',
      code: 'INSUFFICIENT_PRIVILEGES'
    });
  }
  next();
};

const requireSuperAdmin = (req, res, next) => {
  if (!checkSuperAdminAccess(req.user)) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Super Admin privileges required.',
      code: 'INSUFFICIENT_PRIVILEGES'
    });
  }
  next();
};

module.exports = {
  checkAdminAccess,
  checkSuperAdminAccess,
  requireAdmin,
  requireSuperAdmin
};