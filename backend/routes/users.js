const express = require('express');
const { getFirestore, getServerTimestamp } = require('../config/database');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();
const db = getFirestore();

// Get all users (Admin only)
router.get('/', auth, async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin' && req.user.role !== 'account_officer') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

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

module.exports = router;
