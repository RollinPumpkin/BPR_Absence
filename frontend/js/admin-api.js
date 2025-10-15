// Admin API Service for Frontend Integration
// This file contains all API calls for admin dashboard

// Base URL for API
const API_BASE_URL = '/api';

// Check if user has admin access
function checkAdminAccess() {
  const userRole = localStorage.getItem('userRole') || sessionStorage.getItem('userRole');
  const employeeId = localStorage.getItem('employeeId') || sessionStorage.getItem('employeeId');
  
  // Check role-based access
  const hasRoleAccess = userRole === 'admin' || userRole === 'super_admin';
  
  // Check employee ID-based access
  const hasEmployeeIdAccess = employeeId?.startsWith('SUP') || employeeId?.startsWith('ADM');
  
  const hasAccess = hasRoleAccess || hasEmployeeIdAccess;
  
  return {
    hasAccess,
    userRole,
    employeeId,
    hasRoleAccess,
    hasEmployeeIdAccess
  };
}

// Helper function to make API calls with authentication
async function apiCall(endpoint, options = {}) {
  // Check admin access before making API calls
  const accessCheck = checkAdminAccess();
  if (!accessCheck.hasAccess) {
    // Redirect to unauthorized page or login
    window.location.href = '/login.html?error=unauthorized';
    throw new Error('Unauthorized access. Admin atau super_admin role diperlukan.');
  }
  
  const token = localStorage.getItem('token') || sessionStorage.getItem('token');
  
  if (!token) {
    window.location.href = '/login.html?error=token_missing';
    throw new Error('Authentication token not found');
  }
  
  const defaultOptions = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  };

  const config = {
    ...defaultOptions,
    ...options,
    headers: {
      ...defaultOptions.headers,
      ...options.headers
    }
  };

  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, config);
    const data = await response.json();
    
    if (!response.ok) {
      // Handle 401/403 errors - redirect to login
      if (response.status === 401 || response.status === 403) {
        localStorage.removeItem('token');
        localStorage.removeItem('userRole');
        localStorage.removeItem('employeeId');
        sessionStorage.removeItem('token');
        sessionStorage.removeItem('userRole');
        sessionStorage.removeItem('employeeId');
        window.location.href = '/login.html?error=session_expired';
        throw new Error('Session expired or unauthorized');
      }
      
      throw new Error(data.message || 'API call failed');
    }
    
    return data;
  } catch (error) {
    console.error('API call error:', error);
    throw error;
  }
}

// ==================== DASHBOARD APIS ====================

// Get main dashboard summary
async function getDashboardSummary() {
  return apiCall('/users/admin/dashboard/summary');
}

// ==================== EMPLOYEES APIS ====================

// Get employees with filters and pagination
async function getEmployees(params = {}) {
  const queryParams = new URLSearchParams(params).toString();
  return apiCall(`/users/admin/employees?${queryParams}`);
}

// Create new employee
async function createEmployee(employeeData) {
  return apiCall('/users/admin/create-employee', {
    method: 'POST',
    body: JSON.stringify(employeeData)
  });
}

// Update employee
async function updateEmployee(employeeId, updateData) {
  return apiCall(`/users/admin/employees/${employeeId}`, {
    method: 'PUT',
    body: JSON.stringify(updateData)
  });
}

// Update employee status
async function updateEmployeeStatus(employeeId, statusData) {
  return apiCall(`/users/admin/employees/${employeeId}/status`, {
    method: 'PATCH',
    body: JSON.stringify(statusData)
  });
}

// Reset employee password
async function resetEmployeePassword(employeeId, passwordData = {}) {
  return apiCall(`/users/admin/employees/${employeeId}/reset-password`, {
    method: 'POST',
    body: JSON.stringify(passwordData)
  });
}

// Bulk import employees
async function bulkImportEmployees(employeesData) {
  return apiCall('/users/admin/bulk-import', {
    method: 'POST',
    body: JSON.stringify(employeesData)
  });
}

// Get analytics data
async function getEmployeeAnalytics() {
  return apiCall('/users/admin/analytics');
}

// Get departments data
async function getDepartments() {
  return apiCall('/users/admin/departments');
}

// ==================== ATTENDANCE APIS ====================

// Get attendance dashboard summary
async function getAttendanceSummary() {
  return apiCall('/attendance/admin/dashboard');
}

// Get all attendance with advanced filtering
async function getAttendanceReports(params = {}) {
  const queryParams = new URLSearchParams(params).toString();
  return apiCall(`/attendance/admin/all?${queryParams}`);
}

// Bulk update attendance status
async function bulkUpdateAttendance(attendanceIds, newStatus, adminNotes = '') {
  return apiCall('/attendance/admin/bulk-update', {
    method: 'POST',
    body: JSON.stringify({ 
      attendance_ids: attendanceIds,
      new_status: newStatus,
      admin_notes: adminNotes
    })
  });
}

// Generate attendance report
async function generateAttendanceReport(params = {}) {
  const queryParams = new URLSearchParams(params).toString();
  return apiCall(`/attendance/admin/report?${queryParams}`);
}

// Get today's attendance (legacy - redirects to dashboard)
async function getTodayAttendance() {
  const dashboard = await getAttendanceSummary();
  return dashboard?.summary?.today || {};
}

// Export attendance data (legacy - uses report endpoint)
async function exportAttendanceData(params = {}) {
  return generateAttendanceReport({ ...params, format: 'json' });
}

// ==================== LETTERS APIS ====================

// Get letters dashboard summary
async function getLettersSummary() {
  return apiCall('/letters/dashboard/summary');
}

// Get letters with filters
async function getLetters(params = {}) {
  const queryParams = new URLSearchParams(params).toString();
  return apiCall(`/letters?${queryParams}`);
}

// Bulk action on letters (approve/reject/delete)
async function bulkLetterAction(actionData) {
  return apiCall('/letters/bulk-action', {
    method: 'POST',
    body: JSON.stringify(actionData)
  });
}

// Get letter templates
async function getLetterTemplates() {
  return apiCall('/letters/templates');
}

// Create letter template
async function createLetterTemplate(templateData) {
  return apiCall('/letters/templates', {
    method: 'POST',
    body: JSON.stringify(templateData)
  });
}

// Get letters analytics
async function getLettersAnalytics() {
  return apiCall('/letters/analytics');
}

// ==================== ASSIGNMENTS APIS ====================

// Get assignments dashboard summary
async function getAssignmentsSummary() {
  return apiCall('/assignments/dashboard/summary');
}

// Get assignments with filters
async function getAssignments(params = {}) {
  const queryParams = new URLSearchParams(params).toString();
  return apiCall(`/assignments?${queryParams}`);
}

// Create new assignment
async function createAssignment(assignmentData) {
  return apiCall('/assignments', {
    method: 'POST',
    body: JSON.stringify(assignmentData)
  });
}

// Update assignment
async function updateAssignment(assignmentId, updateData) {
  return apiCall(`/assignments/${assignmentId}`, {
    method: 'PUT',
    body: JSON.stringify(updateData)
  });
}

// Delete assignment
async function deleteAssignment(assignmentId) {
  return apiCall(`/assignments/${assignmentId}`, {
    method: 'DELETE'
  });
}

// Add comment to assignment
async function addAssignmentComment(assignmentId, comment) {
  return apiCall(`/assignments/${assignmentId}/comments`, {
    method: 'POST',
    body: JSON.stringify({ comment })
  });
}

// Get user performance data
async function getUserPerformance() {
  return apiCall('/assignments/user-performance');
}

// ==================== UTILITY FUNCTIONS ====================

// Format date for display
function formatDate(dateString) {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleDateString('id-ID', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

// Format currency (Indonesian Rupiah)
function formatCurrency(amount) {
  if (!amount) return '-';
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR'
  }).format(amount);
}

// Get status badge class
function getStatusBadgeClass(status) {
  const statusClasses = {
    'active': 'badge-success',
    'inactive': 'badge-warning', 
    'terminated': 'badge-danger',
    'resigned': 'badge-secondary',
    'pending': 'badge-warning',
    'approved': 'badge-success',
    'rejected': 'badge-danger',
    'completed': 'badge-success',
    'in-progress': 'badge-primary',
    'overdue': 'badge-danger'
  };
  return statusClasses[status] || 'badge-secondary';
}

// Show loading state
function showLoading(elementId) {
  const element = document.getElementById(elementId);
  if (element) {
    element.innerHTML = '<div class="text-center"><i class="fa fa-spinner fa-spin"></i> Loading...</div>';
  }
}

// Hide loading state
function hideLoading(elementId) {
  const element = document.getElementById(elementId);
  if (element) {
    element.innerHTML = '';
  }
}

// Show error message
function showError(message, elementId = null) {
  const errorHtml = `<div class="alert alert-danger alert-dismissible">
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    <i class="fa fa-exclamation-triangle"></i> ${message}
  </div>`;
  
  if (elementId) {
    const element = document.getElementById(elementId);
    if (element) {
      element.innerHTML = errorHtml;
    }
  } else {
    // Show in a general error container or toast
    console.error('Error:', message);
  }
}

// Show success message
function showSuccess(message, elementId = null) {
  const successHtml = `<div class="alert alert-success alert-dismissible">
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    <i class="fa fa-check"></i> ${message}
  </div>`;
  
  if (elementId) {
    const element = document.getElementById(elementId);
    if (element) {
      element.innerHTML = successHtml;
    }
  } else {
    // Show in a general success container or toast
    console.log('Success:', message);
  }
}

// Initialize admin page - call this on page load
function initializeAdminPage() {
  // Check admin access
  if (!checkAdminAccess()) {
    return false;
  }
  
  // Update UI with user info
  updateAdminUI();
  
  return true;
}

// Update admin UI with user info
function updateAdminUI() {
  const userName = localStorage.getItem('userName') || sessionStorage.getItem('userName') || 'Admin';
  const userRole = localStorage.getItem('userRole') || sessionStorage.getItem('userRole') || 'admin';
  
  // Update user name in navigation
  const userNameElements = document.querySelectorAll('.admin-user-name');
  userNameElements.forEach(element => {
    element.textContent = userName;
  });
  
  // Update user role badge
  const userRoleElements = document.querySelectorAll('.admin-user-role');
  userRoleElements.forEach(element => {
    element.textContent = userRole === 'super_admin' ? 'Super Admin' : 'Admin';
    element.className = `badge ${userRole === 'super_admin' ? 'bg-danger' : 'bg-primary'}`;
  });
  
  // Show/hide super admin only features
  const superAdminElements = document.querySelectorAll('.super-admin-only');
  superAdminElements.forEach(element => {
    element.style.display = userRole === 'super_admin' ? 'block' : 'none';
  });
}

// Logout function
function logoutAdmin() {
  if (confirm('Yakin ingin logout?')) {
    // Clear all stored data
    localStorage.removeItem('token');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userName');
    localStorage.removeItem('userId');
    sessionStorage.clear();
    
    // Redirect to login
    window.location.href = '/login.html?message=logout_success';
  }
}

// Export all functions for use in HTML pages
window.AdminAPI = {
  // Authentication & Access
  checkAdminAccess,
  initializeAdminPage,
  updateAdminUI,
  logoutAdmin,
  
  // Dashboard
  getDashboardSummary,
  
  // Employees
  getEmployees,
  createEmployee,
  updateEmployee,
  updateEmployeeStatus,
  resetEmployeePassword,
  bulkImportEmployees,
  getEmployeeAnalytics,
  getDepartments,
  
  // Attendance
  getAttendanceSummary,
  getTodayAttendance,
  getAttendanceReports,
  bulkUpdateAttendance,
  exportAttendanceData,
  
  // Letters
  getLettersSummary,
  getLetters,
  bulkLetterAction,
  getLetterTemplates,
  createLetterTemplate,
  getLettersAnalytics,
  
  // Assignments
  getAssignmentsSummary,
  getAssignments,
  createAssignment,
  updateAssignment,
  deleteAssignment,
  addAssignmentComment,
  getUserPerformance,
  
  // Utilities
  formatDate,
  formatCurrency,
  getStatusBadgeClass,
  showLoading,
  hideLoading,
  showError,
  showSuccess
};