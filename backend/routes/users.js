const express = require('express');
const { getFirestore, getServerTimestamp } = require('../config/database');
const auth = require('../middleware/auth');
const requireAdminRole = require('../middleware/requireAdminRole');
const upload = require('../middleware/upload');

const router = express.Router();
const db = getFirestore();

// ==================== ADMIN DASHBOARD SUMMARY API ====================

// Main admin dashboard data - fetch all key metrics
router.get('/admin/dashboard/summary', auth, requireAdminRole, async (req, res) => {
  try {
    // Get all users
    const usersSnapshot = await db.collection('users').get();
    const users = [];
    usersSnapshot.forEach(doc => {
      users.push({ id: doc.id, ...doc.data() });
    });

    // Calculate user statistics
    const userStats = {
      total_employees: users.length,
      active: users.filter(u => u.status === 'active').length,
      inactive: users.filter(u => u.status === 'inactive').length,
      terminated: users.filter(u => u.status === 'terminated').length,
      resigned: users.filter(u => u.status === 'resigned').length
    };

    // Department breakdown
    const departmentCounts = {};
    users.forEach(user => {
      if (user.department) {
        departmentCounts[user.department] = (departmentCounts[user.department] || 0) + 1;
      }
    });

    // Role breakdown  
    const roleCounts = {};
    users.forEach(user => {
      const role = user.role || 'employee';
      roleCounts[role] = (roleCounts[role] || 0) + 1;
    });

    // Recent hires (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const recentHires = users.filter(user => {
      if (!user.hire_date) return false;
      const hireDate = user.hire_date.toDate ? user.hire_date.toDate() : new Date(user.hire_date);
      return hireDate >= thirtyDaysAgo;
    });

    // Get attendance data for today
    const today = new Date().toISOString().split('T')[0];
    const attendanceSnapshot = await db.collection('attendance')
      .where('date', '==', today)
      .get();
    
    const todayAttendance = {
      total_marked: attendanceSnapshot.size,
      present: 0,
      absent: 0,
      late: 0,
      sick: 0
    };

    attendanceSnapshot.forEach(doc => {
      const data = doc.data();
      const status = data.status || 'absent';
      if (todayAttendance.hasOwnProperty(status)) {
        todayAttendance[status]++;
      }
    });

    // Get letters data
    const lettersSnapshot = await db.collection('letters').get();
    const letters = [];
    lettersSnapshot.forEach(doc => {
      letters.push({ id: doc.id, ...doc.data() });
    });

    const letterStats = {
      total_letters: letters.length,
      pending_approval: letters.filter(l => l.approval_status === 'pending').length,
      approved: letters.filter(l => l.approval_status === 'approved').length,
      rejected: letters.filter(l => l.approval_status === 'rejected').length,
      draft: letters.filter(l => l.status === 'draft').length
    };

    // Get assignments data
    const assignmentsSnapshot = await db.collection('assignments').get();
    const assignments = [];
    assignmentsSnapshot.forEach(doc => {
      assignments.push({ id: doc.id, ...doc.data() });
    });

    const assignmentStats = {
      total_assignments: assignments.length,
      pending: assignments.filter(a => a.status === 'pending').length,
      in_progress: assignments.filter(a => a.status === 'in-progress').length,
      completed: assignments.filter(a => a.status === 'completed').length,
      overdue: assignments.filter(a => {
        if (!a.dueDate || a.status === 'completed') return false;
        const dueDate = a.dueDate.toDate ? a.dueDate.toDate() : new Date(a.dueDate);
        return dueDate < new Date();
      }).length
    };

    const dashboardData = {
      users: userStats,
      departments: Object.entries(departmentCounts).map(([name, count]) => ({
        name,
        count
      })),
      roles: Object.entries(roleCounts).map(([name, count]) => ({
        name,
        count  
      })),
      recent_hires: recentHires.length,
      recent_hires_list: recentHires.slice(0, 5).map(user => ({
        id: user.id,
        full_name: user.full_name,
        department: user.department,
        hire_date: user.hire_date
      })),
      attendance_today: todayAttendance,
      letters: letterStats,
      assignments: assignmentStats,
      last_updated: new Date().toISOString()
    };

    res.json({
      success: true,
      message: 'Admin dashboard data retrieved successfully',
      data: dashboardData
    });

  } catch (error) {
    console.error('Error fetching admin dashboard data:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching dashboard data',
      error: error.message
    });
  }
});

// Get employees data for admin dashboard
router.get('/admin/employees', auth, requireAdminRole, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      department,
      status,
      role,
      sort_by = 'full_name',
      sort_order = 'asc'
    } = req.query;

    let query = db.collection('users');

    // Apply filters
    if (department) {
      query = query.where('department', '==', department);
    }
    if (status) {
      query = query.where('status', '==', status);
    } else {
      // Default: exclude terminated employees unless explicitly requested
      query = query.where('status', '!=', 'terminated');
    }
    if (role) {
      query = query.where('role', '==', role);
    }

    const snapshot = await query.get();
    let employees = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      // Double-check: skip terminated employees even if query didn't filter properly
      if (data.status === 'terminated') {
        return; // Skip this employee
      }
      employees.push({
        id: doc.id,
        employee_id: data.employee_id,
        full_name: data.full_name,
        email: data.email,
        department: data.department,
        position: data.position,
        role: data.role,
        status: data.status || 'active',
        hire_date: data.hire_date,
        phone: data.phone,
        created_at: data.created_at,
        updated_at: data.updated_at
      });
    });

    // Apply search filter
    if (search) {
      const searchLower = search.toLowerCase();
      employees = employees.filter(emp => 
        emp.full_name?.toLowerCase().includes(searchLower) ||
        emp.employee_id?.toLowerCase().includes(searchLower) ||
        emp.email?.toLowerCase().includes(searchLower) ||
        emp.department?.toLowerCase().includes(searchLower)
      );
    }

    // Apply sorting
    employees.sort((a, b) => {
      let aVal = a[sort_by] || '';
      let bVal = b[sort_by] || '';
      
      if (typeof aVal === 'string') aVal = aVal.toLowerCase();
      if (typeof bVal === 'string') bVal = bVal.toLowerCase();
      
      if (sort_order === 'desc') {
        return aVal < bVal ? 1 : -1;
      } else {
        return aVal > bVal ? 1 : -1;
      }
    });

    // Apply pagination
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedEmployees = employees.slice(startIndex, endIndex);

    // Get unique values for filters
    const allEmployees = [];
    const allSnapshot = await db.collection('users').get();
    allSnapshot.forEach(doc => {
      allEmployees.push(doc.data());
    });

    const departments = [...new Set(allEmployees.map(emp => emp.department).filter(Boolean))];
    const roles = [...new Set(allEmployees.map(emp => emp.role).filter(Boolean))];
    const statuses = ['active', 'inactive', 'terminated', 'resigned'];

    res.json({
      success: true,
      message: 'Employees retrieved successfully',
      data: {
        employees: paginatedEmployees,
        pagination: {
          current_page: parseInt(page),
          per_page: parseInt(limit),
          total_items: employees.length,
          total_pages: Math.ceil(employees.length / limit),
          has_next: endIndex < employees.length,
          has_prev: page > 1
        },
        filters: {
          departments,
          roles,
          statuses
        },
        summary: {
          total: employees.length,
          active: employees.filter(emp => emp.status === 'active').length,
          inactive: employees.filter(emp => emp.status === 'inactive').length
        }
      }
    });

  } catch (error) {
    console.error('Error fetching employees:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching employees',
      error: error.message
    });
  }
});

// Get all users (Admin only) - Legacy endpoint
router.get('/', auth, requireAdminRole, async (req, res) => {
  try {

    const {
      page = 1,
      limit = 20,
      search,
      department,
      status = 'active',
      role
    } = req.query;

    let usersRef = db.collection('users');

    // Apply basic query
    usersRef = usersRef.orderBy('created_at', 'desc');

    const snapshot = await usersRef.get();
    let users = [];

    snapshot.forEach(doc => {
      const userData = doc.data();
      const { password, ...userProfile } = userData;
      
      // Convert timestamps
      if (userProfile.created_at && typeof userProfile.created_at.toDate === 'function') {
        userProfile.created_at = userProfile.created_at.toDate();
      }
      if (userProfile.updated_at && typeof userProfile.updated_at.toDate === 'function') {
        userProfile.updated_at = userProfile.updated_at.toDate();
      }

      users.push({
        id: doc.id,
        ...userProfile
      });
    });

    // Apply filters in memory
    let filteredUsers = users;

    if (status && status !== 'all') {
      filteredUsers = filteredUsers.filter(user => user.status === status);
    }

    if (department) {
      filteredUsers = filteredUsers.filter(user => user.department === department);
    }

    if (role) {
      filteredUsers = filteredUsers.filter(user => user.role === role);
    }

    if (search) {
      const searchTerm = search.toLowerCase();
      filteredUsers = filteredUsers.filter(user => 
        user.full_name?.toLowerCase().includes(searchTerm) ||
        user.email?.toLowerCase().includes(searchTerm) ||
        user.employee_id?.toLowerCase().includes(searchTerm) ||
        user.department?.toLowerCase().includes(searchTerm)
      );
    }

    // Apply pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: {
        users: paginatedUsers,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(filteredUsers.length / parseInt(limit)),
          total_records: filteredUsers.length,
          limit: parseInt(limit),
          has_next_page: endIndex < filteredUsers.length,
          has_prev_page: parseInt(page) > 1
        },
        filters: {
          search,
          department,
          status,
          role
        }
      }
    });

  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get users'
    });
  }
});

// Get user by ID (Admin only)
router.get('/:userId', auth, async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin' && req.user.role !== 'account_officer') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { userId } = req.params;
    
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    const { password, ...userProfile } = userData;

    // Convert timestamps
    if (userProfile.created_at && typeof userProfile.created_at.toDate === 'function') {
      userProfile.created_at = userProfile.created_at.toDate();
    }
    if (userProfile.updated_at && typeof userProfile.updated_at.toDate === 'function') {
      userProfile.updated_at = userProfile.updated_at.toDate();
    }

    res.json({
      success: true,
      data: {
        user: {
          id: userId,
          ...userProfile
        }
      }
    });

  } catch (error) {
    console.error('Get user by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user'
    });
  }
});

// Get user profile
router.get('/profile', auth, async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    delete userData.password; // Remove password from response

    res.json({
      success: true,
      data: { 
        user: {
          id: userDoc.id,
          ...userData
        }
      }
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get profile'
    });
  }
});

// Update user profile
router.put('/profile', auth, async (req, res) => {
  try {
    const { full_name, phone, department, position } = req.body;

    // Build update object with only defined fields
    const updateData = {
      updated_at: getServerTimestamp()
    };

    if (full_name !== undefined) updateData.full_name = full_name;
    if (phone !== undefined) updateData.phone = phone;
    if (department !== undefined) updateData.department = department;
    if (position !== undefined) updateData.position = position;

    const userRef = db.collection('users').doc(req.user.userId);
    await userRef.update(updateData);

    res.json({
      success: true,
      message: 'Profile updated successfully'
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile'
    });
  }
});

// Upload profile picture
router.post('/profile/picture', auth, upload.single('profile_image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const profileImagePath = `/uploads/${req.file.filename}`;

    const userRef = db.collection('users').doc(req.user.userId);
    await userRef.update({
      profile_image: profileImagePath,
      updated_at: getServerTimestamp()
    });

    res.json({
      success: true,
      message: 'Profile picture updated successfully',
      data: { profile_image: profileImagePath }
    });

  } catch (error) {
    console.error('Upload profile picture error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload profile picture'
    });
  }
});

// Get user attendance history
router.get('/attendance', auth, async (req, res) => {
  try {
    const { page = 1, limit = 10, month, year } = req.query;
    const offset = (page - 1) * limit;

    let attendanceRef = db.collection('attendance')
      .where('user_id', '==', req.user.userId);

    // Apply date filters
    if (month && year) {
      // Filter by month and year
      const startDate = `${year}-${month.padStart(2, '0')}-01`;
      const endDate = `${year}-${month.padStart(2, '0')}-31`;
      attendanceRef = attendanceRef
        .where('date', '>=', startDate)
        .where('date', '<=', endDate);
    }

    // Get attendance records with pagination
    const snapshot = await attendanceRef
      .orderBy('date', 'desc')
      .limit(parseInt(limit))
      .offset(offset)
      .get();

    const attendance = [];
    snapshot.forEach(doc => {
      attendance.push({ id: doc.id, ...doc.data() });
    });

    // Get total count for pagination
    const totalSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .get();
    
    let total = totalSnapshot.size;
    
    // If month/year filter applied, count filtered results
    if (month && year) {
      const startDate = `${year}-${month.padStart(2, '0')}-01`;
      const endDate = `${year}-${month.padStart(2, '0')}-31`;
      const filteredSnapshot = await db.collection('attendance')
        .where('user_id', '==', req.user.userId)
        .where('date', '>=', startDate)
        .where('date', '<=', endDate)
        .get();
      total = filteredSnapshot.size;
    }

    res.json({
      success: true,
      data: {
        attendance,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(total / limit),
          total_records: total,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance history'
    });
  }
});

// Get user leave requests
router.get('/leave-requests', auth, async (req, res) => {
  try {
    const { status } = req.query;

    let leaveRequestsRef = db.collection('leave_requests')
      .where('user_id', '==', req.user.userId);

    if (status) {
      leaveRequestsRef = leaveRequestsRef.where('status', '==', status);
    }

    const snapshot = await leaveRequestsRef
      .orderBy('created_at', 'desc')
      .get();

    const leaveRequests = [];
    snapshot.forEach(doc => {
      leaveRequests.push({ id: doc.id, ...doc.data() });
    });

    res.json({
      success: true,
      data: { leave_requests: leaveRequests }
    });

  } catch (error) {
    console.error('Get leave requests error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get leave requests'
    });
  }
});

// Get user dashboard data
router.get('/dashboard', auth, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const currentMonth = new Date().getMonth() + 1;
    const currentYear = new Date().getFullYear();

    // Get today's attendance
    const todayAttendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '==', today)
      .get();

    const todayAttendance = todayAttendanceSnapshot.empty 
      ? null 
      : { id: todayAttendanceSnapshot.docs[0].id, ...todayAttendanceSnapshot.docs[0].data() };

    // Get this month's attendance count
    const startDate = `${currentYear}-${currentMonth.toString().padStart(2, '0')}-01`;
    const endDate = `${currentYear}-${currentMonth.toString().padStart(2, '0')}-31`;
    
    const monthlyAttendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '>=', startDate)
      .where('date', '<=', endDate)
      .get();

    // Count attendance by status
    let presentDays = 0;
    let lateDays = 0;
    let absentDays = 0;

    monthlyAttendanceSnapshot.forEach(doc => {
      const attendance = doc.data();
      if (attendance.status === 'present') {
        presentDays++;
      } else if (attendance.status === 'late') {
        lateDays++;
      } else if (attendance.status === 'absent') {
        absentDays++;
      }
    });

    // Get pending leave requests
    const pendingLeavesSnapshot = await db.collection('leave_requests')
      .where('user_id', '==', req.user.userId)
      .where('status', '==', 'pending')
      .get();

    res.json({
      success: true,
      data: {
        today_attendance: todayAttendance,
        monthly_stats: {
          present_days: presentDays,
          late_days: lateDays,
          absent_days: absentDays,
          total_days: monthlyAttendanceSnapshot.size
        },
        pending_leave_requests: pendingLeavesSnapshot.size,
        has_checked_in: todayAttendance?.check_in_time ? true : false,
        has_checked_out: todayAttendance?.check_out_time ? true : false
      }
    });

  } catch (error) {
    console.error('Get dashboard data error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard data'
    });
  }
});

// Get next employee ID for a specific role prefix
router.get('/next-employee-id/:prefix', auth, async (req, res) => {
  try {
    // Check if user has admin privileges
    const { role: userRole, employee_id: userEmployeeId } = req.user;
    const isAdmin = userRole === 'admin' || userRole === 'super_admin' || 
                    userEmployeeId?.startsWith('ADM') || userEmployeeId?.startsWith('SUP');
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { prefix } = req.params;
    
    // Validate prefix
    const validPrefixes = ['SUP', 'ADM', 'EMP', 'AO', 'OB', 'SCR'];
    if (!validPrefixes.includes(prefix)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid employee ID prefix'
      });
    }

    // Get all users with this prefix to find the next number
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();
    
    let maxNumber = 0;
    
    snapshot.forEach(doc => {
      const userData = doc.data();
      const employeeId = userData.employee_id;
      
      if (employeeId && employeeId.startsWith(prefix)) {
        // Extract number part (e.g., "ADM003" -> "003" -> 3)
        const numberPart = employeeId.substring(prefix.length);
        const number = parseInt(numberPart, 10);
        
        if (!isNaN(number) && number > maxNumber) {
          maxNumber = number;
        }
      }
    });
    
    // Generate next employee ID
    const nextNumber = maxNumber + 1;
    const nextEmployeeId = `${prefix}${String(nextNumber).padStart(3, '0')}`;
    
    res.json({
      success: true,
      data: {
        employee_id: nextEmployeeId,
        prefix: prefix,
        next_number: nextNumber
      }
    });

  } catch (error) {
    console.error('Generate employee ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate employee ID'
    });
  }
});

// Simple test endpoint without auth
router.get('/test-stats', async (req, res) => {
  try {
    console.log('🧪 Test stats endpoint called');
    res.json({
      success: true,
      message: 'Test endpoint working',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Test endpoint error:', error);
    res.status(500).json({
      success: false,
      message: 'Test endpoint failed'
    });
  }
});

// Test JWT token decode without auth
router.get('/test-token', (req, res) => {
  try {
    const jwt = require('jsonwebtoken');
    console.log('🧪 Test token endpoint called');
    
    const authHeader = req.header('Authorization');
    if (!authHeader) {
      return res.json({
        success: false,
        message: 'No auth header provided',
        debug: 'Please provide Authorization header'
      });
    }
    
    const token = authHeader.replace('Bearer ', '');
    if (!token) {
      return res.json({
        success: false,
        message: 'No token in header',
        authHeader: authHeader
      });
    }
    
    // Try to decode without verification first
    const decodedUnsafe = jwt.decode(token);
    console.log('🔍 Decoded token (unsafe):', decodedUnsafe);
    
    // Try to verify with secret
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      console.log('✅ Token verified successfully:', decoded);
      
      res.json({
        success: true,
        message: 'Token verification successful',
        decoded: decoded,
        hasRole: !!decoded.role,
        hasEmployeeId: !!decoded.employeeId,
        isAdmin: decoded.role === 'super_admin' || decoded.role === 'admin',
        isAdminEmployeeId: decoded.employeeId?.startsWith('SUP') || decoded.employeeId?.startsWith('ADM')
      });
    } catch (jwtError) {
      console.error('❌ JWT verification failed:', jwtError.message);
      res.json({
        success: false,
        message: 'JWT verification failed',
        error: jwtError.message,
        decodedUnsafe: decodedUnsafe
      });
    }
    
  } catch (error) {
    console.error('Test token endpoint error:', error);
    res.status(500).json({
      success: false,
      message: 'Test token endpoint failed',
      error: error.message
    });
  }
});

// Get employee statistics for dashboard
router.get('/stats', auth, async (req, res) => {
  try {
    console.log('📊 Getting employee statistics...');
    console.log('🔍 req.user contents:', JSON.stringify(req.user, null, 2));
    
    // Check if user has admin privileges
    const { role: userRole, employee_id: userEmployeeId, employeeId } = req.user;
    console.log('🔑 userRole:', userRole);
    console.log('🔑 userEmployeeId:', userEmployeeId);
    console.log('🔑 employeeId:', employeeId);
    
    const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
    const hasAdminEmployeeId = userEmployeeId?.startsWith('SUP') || userEmployeeId?.startsWith('ADM') || employeeId?.startsWith('SUP') || employeeId?.startsWith('ADM');
    const isAdmin = hasAdminRole || hasAdminEmployeeId;
    
    console.log('🔍 hasAdminRole:', hasAdminRole);
    console.log('🔍 hasAdminEmployeeId:', hasAdminEmployeeId);
    console.log('🔍 isAdmin:', isAdmin);
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();
    
    let stats = {
      total: 0,
      active: 0,
      new: 0,
      resign: 0
    };
    
    const currentDate = new Date();
    const threeMonthsAgo = new Date();
    threeMonthsAgo.setMonth(currentDate.getMonth() - 3);
    
    console.log('📅 Current date:', currentDate.toISOString());
    console.log('📅 Three months ago:', threeMonthsAgo.toISOString());
    
    snapshot.forEach(doc => {
      const userData = doc.data();
      console.log(`👤 Processing user ${userData.full_name || userData.email}:`, {
        status: userData.status,
        is_active: userData.is_active,
        created_at: userData.created_at
      });
      
      // Count total
      stats.total++;
      
      // Count active (status = 'active' and is_active = true)
      const isActive = userData.status === 'active' && userData.is_active === true;
      if (isActive) {
        stats.active++;
        console.log(`  ✅ Active user: ${userData.full_name || userData.email}`);
      }
      
      // Count resigned (non-active: status != 'active' OR is_active = false)
      const isResigned = userData.status !== 'active' || userData.is_active === false;
      if (isResigned) {
        stats.resign++;
        console.log(`  ❌ Resigned user: ${userData.full_name || userData.email} (status: ${userData.status}, is_active: ${userData.is_active})`);
      }
      
      // Count new employees (created in last 1-3 months)
      if (userData.created_at) {
        let createdDate;
        
        // Handle Firestore timestamp
        if (typeof userData.created_at.toDate === 'function') {
          createdDate = userData.created_at.toDate();
        } else if (userData.created_at instanceof Date) {
          createdDate = userData.created_at;
        } else if (typeof userData.created_at === 'string') {
          createdDate = new Date(userData.created_at);
        }
        
        if (createdDate && createdDate >= threeMonthsAgo && createdDate <= currentDate) {
          stats.new++;
          console.log(`  🆕 New user (last 3 months): ${userData.full_name || userData.email} - created: ${createdDate.toISOString()}`);
        }
      }
    });
    
    console.log('✅ Employee statistics calculated:', stats);
    
    res.json({
      success: true,
      message: 'Employee statistics retrieved successfully',
      data: stats
    });
    
  } catch (error) {
    console.error('❌ Get employee statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get employee statistics',
      data: {
        total: 0,
        active: 0,
        new: 0,
        resign: 0
      }
    });
  }
});

// ==================== NEW ENHANCED USERS/EMPLOYEE FEATURES FOR ADMIN DASHBOARD ====================

// Create new employee (Admin only)
router.post('/admin/create-employee', auth, requireAdminRole, async (req, res) => {
  try {

    const {
      full_name,
      email,
      employee_id,
      role,
      department,
      position,
      phone,
      hire_date,
      salary,
      manager_id,
      emergency_contact
    } = req.body;

    // Validate required fields
    if (!full_name || !email || !employee_id || !role || !department || !position) {
      return res.status(400).json({
        success: false,
        message: 'Full name, email, employee ID, role, department, and position are required'
      });
    }

    // Check if email already exists (excluding terminated users)
    const emailQuery = await db.collection('users')
      .where('email', '==', email)
      .where('status', '!=', 'terminated')
      .get();
    if (!emailQuery.empty) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists'
      });
    }

    // Check if employee ID already exists (excluding terminated users)
    const employeeIdQuery = await db.collection('users')
      .where('employee_id', '==', employee_id)
      .where('status', '!=', 'terminated')
      .get();
    if (!employeeIdQuery.empty) {
      return res.status(400).json({
        success: false,
        message: 'Employee ID already exists'
      });
    }

    // Create user document
    const userData = {
      full_name,
      email,
      employee_id,
      role,
      department,
      position,
      phone: phone || '',
      hire_date: hire_date || new Date().toISOString().split('T')[0],
      salary: salary || null,
      manager_id: manager_id || null,
      emergency_contact: emergency_contact || {},
      status: 'active',
      is_active: true,
      profile_completed: true,
      password_reset_required: true,
      created_by: req.user.userId,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    const userRef = await db.collection('users').add(userData);

    // Create default password (employee can change later)
    const defaultPassword = `${employee_id}@2025`;
    const bcrypt = require('bcrypt');
    const hashedPassword = await bcrypt.hash(defaultPassword, 10);
    
    await userRef.update({
      password: hashedPassword
    });

    // Create welcome notification
    try {
      await db.collection('notifications').add({
        user_id: userRef.id,
        title: 'Welcome to BPR Absence System',
        message: `Welcome ${full_name}! Your account has been created. Please change your default password.`,
        type: 'welcome',
        reference_id: userRef.id,
        reference_type: 'user',
        is_read: false,
        priority: 'high',
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create welcome notification:', notifError);
    }

    res.status(201).json({
      success: true,
      message: 'Employee created successfully',
      data: {
        user_id: userRef.id,
        employee_id,
        full_name,
        email,
        default_password: defaultPassword,
        department,
        position,
        role
      }
    });

  } catch (error) {
    console.error('Create employee error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create employee'
    });
  }
});

// Update employee (Admin only)
router.put('/admin/employees/:userId', auth, requireAdminRole, async (req, res) => {
  try {

    const { userId } = req.params;
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Employee not found'
      });
    }

    const {
      full_name,
      email,
      role,
      department,
      position,
      phone,
      salary,
      manager_id,
      status,
      emergency_contact
    } = req.body;

    const updateData = {
      updated_at: getServerTimestamp(),
      updated_by: req.user.userId
    };

    // Check email uniqueness if changed
    if (email && email !== userDoc.data().email) {
      const emailQuery = await db.collection('users').where('email', '==', email).get();
      if (!emailQuery.empty) {
        return res.status(400).json({
          success: false,
          message: 'Email already exists'
        });
      }
      updateData.email = email;
    }

    // Update allowed fields
    if (full_name !== undefined) updateData.full_name = full_name;
    if (role !== undefined) updateData.role = role;
    if (department !== undefined) updateData.department = department;
    if (position !== undefined) updateData.position = position;
    if (phone !== undefined) updateData.phone = phone;
    if (salary !== undefined) updateData.salary = salary;
    if (manager_id !== undefined) updateData.manager_id = manager_id;
    if (status !== undefined) {
      updateData.status = status;
      updateData.is_active = status === 'active';
    }
    if (emergency_contact !== undefined) updateData.emergency_contact = emergency_contact;

    await userRef.update(updateData);

    res.json({
      success: true,
      message: 'Employee updated successfully'
    });

  } catch (error) {
    console.error('Update employee error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update employee'
    });
  }
});

// Delete employee (Admin only)
router.delete('/admin/employees/:userId', auth, requireAdminRole, async (req, res) => {
  try {
    // Check admin privileges
    const { role: userRole, employee_id: userEmployeeId } = req.user;
    const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
    const hasAdminEmployeeId = userEmployeeId?.startsWith('SUP') || userEmployeeId?.startsWith('ADM');
    const isAdmin = hasAdminRole || hasAdminEmployeeId;
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { userId } = req.params;
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Employee not found'
      });
    }

    const userData = userDoc.data();

    // Prevent deletion of admin users
    if (userData.role === 'admin' || userData.role === 'super_admin' || 
        userData.employee_id?.startsWith('ADM') || userData.employee_id?.startsWith('SUP')) {
      return res.status(403).json({
        success: false,
        message: 'Cannot delete admin users'
      });
    }

    // Soft delete - update status to terminated instead of actual deletion
    await userRef.update({
      status: 'terminated',
      is_active: false,
      deleted_at: getServerTimestamp(),
      deleted_by: req.user.userId,
      deletion_reason: 'Deleted by admin'
    });

    // Create notification for audit trail
    try {
      await db.collection('notifications').add({
        user_id: userId,
        title: 'Account Terminated',
        message: `Your account has been terminated by admin`,
        type: 'account_termination',
        reference_id: userId,
        reference_type: 'user',
        is_read: false,
        priority: 'high',
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create termination notification:', notifError);
    }

    res.json({
      success: true,
      message: 'Employee deleted successfully',
      data: {
        user_id: userId,
        employee_id: userData.employee_id,
        full_name: userData.full_name
      }
    });

  } catch (error) {
    console.error('Delete employee error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete employee'
    });
  }
});

// Deactivate/Reactivate employee (Admin only)
router.patch('/admin/employees/:userId/status', auth, requireAdminRole, async (req, res) => {
  try {

    const { userId } = req.params;
    const { status, reason } = req.body;

    if (!['active', 'inactive', 'terminated', 'resigned'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be: active, inactive, terminated, or resigned'
      });
    }

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Employee not found'
      });
    }

    const updateData = {
      status,
      is_active: status === 'active',
      updated_at: getServerTimestamp(),
      updated_by: req.user.userId,
      status_change_reason: reason || 'Status changed by admin'
    };

    if (status === 'terminated' || status === 'resigned') {
      updateData.termination_date = getServerTimestamp();
      updateData.termination_reason = reason;
    }

    await userRef.update(updateData);

    // Create notification
    try {
      const statusMessages = {
        active: 'Your account has been activated',
        inactive: 'Your account has been deactivated',
        terminated: 'Your employment has been terminated',
        resigned: 'Your resignation has been processed'
      };

      await db.collection('notifications').add({
        user_id: userId,
        title: 'Account Status Changed',
        message: statusMessages[status] + (reason ? `. Reason: ${reason}` : ''),
        type: 'account_status',
        reference_id: userId,
        reference_type: 'user',
        is_read: false,
        priority: status === 'terminated' ? 'urgent' : 'high',
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create status change notification:', notifError);
    }

    res.json({
      success: true,
      message: `Employee status updated to ${status}`,
      data: {
        user_id: userId,
        status,
        reason
      }
    });

  } catch (error) {
    console.error('Update employee status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update employee status'
    });
  }
});

// Get employee analytics for admin dashboard
router.get('/admin/analytics', auth, requireAdminRole, async (req, res) => {
  try {
    // Check admin privileges
    const { role: userRole, employee_id: userEmployeeId } = req.user;
    const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
    const hasAdminEmployeeId = userEmployeeId?.startsWith('SUP') || userEmployeeId?.startsWith('ADM');
    const isAdmin = hasAdminRole || hasAdminEmployeeId;
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const usersSnapshot = await db.collection('users').get();
    
    const analytics = {
      total_employees: 0,
      by_status: {
        active: 0,
        inactive: 0,
        terminated: 0,
        resigned: 0
      },
      by_department: {},
      by_role: {},
      by_hire_period: {
        this_year: 0,
        last_year: 0,
        older: 0
      },
      recent_hires: [],
      upcoming_reviews: [],
      salary_ranges: {
        under_5m: 0,
        '5m_10m': 0,
        '10m_15m': 0,
        over_15m: 0
      },
      gender_distribution: {
        male: 0,
        female: 0,
        not_specified: 0
      }
    };

    const currentYear = new Date().getFullYear();
    const lastYear = currentYear - 1;
    const recentHires = [];

    usersSnapshot.forEach(doc => {
      const user = { id: doc.id, ...doc.data() };
      analytics.total_employees++;

      // Status breakdown
      const status = user.status || 'active';
      if (analytics.by_status[status] !== undefined) {
        analytics.by_status[status]++;
      }

      // Department breakdown
      const department = user.department || 'Not Assigned';
      analytics.by_department[department] = (analytics.by_department[department] || 0) + 1;

      // Role breakdown
      const role = user.role || 'employee';
      analytics.by_role[role] = (analytics.by_role[role] || 0) + 1;

      // Hire date analysis
      if (user.hire_date) {
        const hireYear = new Date(user.hire_date).getFullYear();
        if (hireYear === currentYear) {
          analytics.by_hire_period.this_year++;
          recentHires.push({
            id: user.id,
            name: user.full_name,
            department: user.department,
            position: user.position,
            hire_date: user.hire_date
          });
        } else if (hireYear === lastYear) {
          analytics.by_hire_period.last_year++;
        } else {
          analytics.by_hire_period.older++;
        }
      }

      // Salary analysis
      if (user.salary) {
        const salary = user.salary;
        if (salary < 5000000) {
          analytics.salary_ranges.under_5m++;
        } else if (salary < 10000000) {
          analytics.salary_ranges['5m_10m']++;
        } else if (salary < 15000000) {
          analytics.salary_ranges['10m_15m']++;
        } else {
          analytics.salary_ranges.over_15m++;
        }
      }

      // Gender analysis (if available)
      const gender = user.gender || 'not_specified';
      if (analytics.gender_distribution[gender] !== undefined) {
        analytics.gender_distribution[gender]++;
      } else {
        analytics.gender_distribution.not_specified++;
      }
    });

    // Sort recent hires by hire date
    analytics.recent_hires = recentHires
      .sort((a, b) => new Date(b.hire_date) - new Date(a.hire_date))
      .slice(0, 10);

    res.json({
      success: true,
      data: { analytics }
    });

  } catch (error) {
    console.error('Get employee analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get employee analytics'
    });
  }
});

// Get departments list (Admin only)
router.get('/admin/departments', auth, requireAdminRole, async (req, res) => {
  try {
    // Check admin privileges
    const { role: userRole, employee_id: userEmployeeId } = req.user;
    const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
    const hasAdminEmployeeId = userEmployeeId?.startsWith('SUP') || userEmployeeId?.startsWith('ADM');
    const isAdmin = hasAdminRole || hasAdminEmployeeId;
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const usersSnapshot = await db.collection('users').get();
    const departments = {};

    usersSnapshot.forEach(doc => {
      const user = doc.data();
      const dept = user.department || 'Not Assigned';
      
      if (!departments[dept]) {
        departments[dept] = {
          name: dept,
          total_employees: 0,
          active_employees: 0,
          positions: new Set(),
          employees: []
        };
      }

      departments[dept].total_employees++;
      if (user.status === 'active') {
        departments[dept].active_employees++;
      }
      
      if (user.position) {
        departments[dept].positions.add(user.position);
      }

      departments[dept].employees.push({
        id: doc.id,
        name: user.full_name,
        employee_id: user.employee_id,
        position: user.position,
        status: user.status
      });
    });

    // Convert Sets to arrays and format response
    const departmentsList = Object.values(departments).map(dept => ({
      ...dept,
      positions: Array.from(dept.positions),
      employee_count: dept.total_employees,
      active_count: dept.active_employees
    }));

    res.json({
      success: true,
      data: {
        departments: departmentsList,
        total_departments: departmentsList.length
      }
    });

  } catch (error) {
    console.error('Get departments error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get departments list'
    });
  }
});

// Bulk import employees (Admin only)
router.post('/admin/bulk-import', auth, requireAdminRole, async (req, res) => {
  try {
    // Check admin privileges
    const { role: userRole, employee_id: userEmployeeId } = req.user;
    const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
    const hasAdminEmployeeId = userEmployeeId?.startsWith('SUP') || userEmployeeId?.startsWith('ADM');
    const isAdmin = hasAdminRole || hasAdminEmployeeId;
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { employees } = req.body;

    if (!employees || !Array.isArray(employees) || employees.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Employees array is required and cannot be empty'
      });
    }

    const batch = db.batch();
    const results = [];
    const bcrypt = require('bcrypt');

    for (const employee of employees) {
      const {
        full_name,
        email,
        employee_id,
        role,
        department,
        position,
        phone,
        hire_date,
        salary
      } = employee;

      // Validate required fields
      if (!full_name || !email || !employee_id || !department || !position) {
        results.push({
          employee_id,
          email,
          success: false,
          error: 'Missing required fields: full_name, email, employee_id, department, position'
        });
        continue;
      }

      try {
        // Check for duplicates
        const emailQuery = await db.collection('users').where('email', '==', email).get();
        const employeeIdQuery = await db.collection('users').where('employee_id', '==', employee_id).get();

        if (!emailQuery.empty) {
          results.push({
            employee_id,
            email,
            success: false,
            error: 'Email already exists'
          });
          continue;
        }

        if (!employeeIdQuery.empty) {
          results.push({
            employee_id,
            email,
            success: false,
            error: 'Employee ID already exists'
          });
          continue;
        }

        // Create user document
        const defaultPassword = `${employee_id}@2025`;
        const hashedPassword = await bcrypt.hash(defaultPassword, 10);

        const userRef = db.collection('users').doc();
        const userData = {
          full_name,
          email,
          employee_id,
          role: role || 'employee',
          department,
          position,
          phone: phone || '',
          hire_date: hire_date || new Date().toISOString().split('T')[0],
          salary: salary || null,
          status: 'active',
          is_active: true,
          profile_completed: false,
          password_reset_required: true,
          password: hashedPassword,
          created_by: req.user.userId,
          created_at: getServerTimestamp(),
          updated_at: getServerTimestamp()
        };

        batch.set(userRef, userData);

        results.push({
          employee_id,
          email,
          full_name,
          success: true,
          user_id: userRef.id,
          default_password: defaultPassword
        });

      } catch (error) {
        results.push({
          employee_id,
          email,
          success: false,
          error: error.message
        });
      }
    }

    await batch.commit();

    const successCount = results.filter(r => r.success).length;
    const failureCount = results.filter(r => !r.success).length;

    res.json({
      success: true,
      message: `Bulk import completed. ${successCount} successful, ${failureCount} failed.`,
      data: {
        total_employees: employees.length,
        successful: successCount,
        failed: failureCount,
        results
      }
    });

  } catch (error) {
    console.error('Bulk import employees error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to import employees'
    });
  }
});

// Reset employee password (Admin only)
router.post('/admin/employees/:userId/reset-password', auth, requireAdminRole, async (req, res) => {
  try {
    // Check admin privileges
    const { role: userRole, employee_id: userEmployeeId } = req.user;
    const hasAdminRole = userRole === 'admin' || userRole === 'super_admin';
    const hasAdminEmployeeId = userEmployeeId?.startsWith('SUP') || userEmployeeId?.startsWith('ADM');
    const isAdmin = hasAdminRole || hasAdminEmployeeId;
    
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { userId } = req.params;
    const { new_password } = req.body;

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Employee not found'
      });
    }

    const userData = userDoc.data();
    
    // Generate new password if not provided
    const password = new_password || `${userData.employee_id}@${new Date().getFullYear()}`;
    
    const bcrypt = require('bcrypt');
    const hashedPassword = await bcrypt.hash(password, 10);

    await userRef.update({
      password: hashedPassword,
      password_reset_required: true,
      password_reset_at: getServerTimestamp(),
      password_reset_by: req.user.userId,
      updated_at: getServerTimestamp()
    });

    // Create notification
    try {
      await db.collection('notifications').add({
        user_id: userId,
        title: 'Password Reset',
        message: 'Your password has been reset by an administrator. Please change it upon next login.',
        type: 'password_reset',
        reference_id: userId,
        reference_type: 'user',
        is_read: false,
        priority: 'high',
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create password reset notification:', notifError);
    }

    res.json({
      success: true,
      message: 'Password reset successfully',
      data: {
        user_id: userId,
        employee_id: userData.employee_id,
        new_password: password
      }
    });

  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reset password'
    });
  }
});

module.exports = router;
