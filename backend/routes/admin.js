const express = require('express');
const { getFirestore, getServerTimestamp, formatDate } = require('../config/database');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const QRCode = require('qrcode');
const moment = require('moment');

const router = express.Router();
const db = getFirestore();

// Get all users (admin only)
router.get('/users', auth, adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 10, search = '' } = req.query;
    const offset = (page - 1) * limit;

    let usersRef = db.collection('users');
    
    // Apply search filter if provided
    if (search) {
      // Firebase doesn't support complex OR queries like SQL, so we'll get all users and filter in memory
      // For better performance in production, consider using Algolia or implementing separate search indexes
      const snapshot = await usersRef.get();
      const allUsers = [];
      
      snapshot.forEach(doc => {
        const userData = doc.data();
        const user = { id: doc.id, ...userData };
        
        // Remove password from response
        delete user.password;
        
        // Check if user matches search criteria
        if (
          user.full_name?.toLowerCase().includes(search.toLowerCase()) ||
          user.email?.toLowerCase().includes(search.toLowerCase()) ||
          user.employee_id?.toLowerCase().includes(search.toLowerCase())
        ) {
          allUsers.push(user);
        }
      });
      
      // Sort by created_at (newest first)
      allUsers.sort((a, b) => {
        const dateA = a.created_at?.toDate() || new Date(0);
        const dateB = b.created_at?.toDate() || new Date(0);
        return dateB - dateA;
      });
      
      // Apply pagination
      const total = allUsers.length;
      const users = allUsers.slice(offset, offset + parseInt(limit));
      
      return res.json({
        success: true,
        data: {
          users,
          pagination: {
            current_page: parseInt(page),
            total_pages: Math.ceil(total / limit),
            total_records: total,
            limit: parseInt(limit)
          }
        }
      });
    } else {
      // No search, get paginated results
      const snapshot = await usersRef
        .orderBy('created_at', 'desc')
        .limit(parseInt(limit))
        .offset(offset)
        .get();
      
      const users = [];
      snapshot.forEach(doc => {
        const userData = doc.data();
        delete userData.password; // Remove password from response
        users.push({ id: doc.id, ...userData });
      });
      
      // Get total count for pagination
      const totalSnapshot = await usersRef.get();
      const total = totalSnapshot.size;
      
      res.json({
        success: true,
        data: {
          users,
          pagination: {
            current_page: parseInt(page),
            total_pages: Math.ceil(total / limit),
            total_records: total,
            limit: parseInt(limit)
          }
        }
      });
    }

  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get users'
    });
  }
});

// Get attendance reports
router.get('/attendance-reports', auth, adminAuth, async (req, res) => {
  try {
    const { date, month, year, user_id, status } = req.query;

    let attendanceRef = db.collection('attendance');
    
    // Apply filters
    if (user_id) {
      attendanceRef = attendanceRef.where('user_id', '==', user_id);
    }
    
    if (status) {
      attendanceRef = attendanceRef.where('status', '==', status);
    }
    
    if (date) {
      attendanceRef = attendanceRef.where('date', '==', date);
    } else if (month && year) {
      // For month/year filtering, we'll get all records and filter in memory
      // This is because Firestore doesn't support range queries on date strings easily
      const startDate = `${year}-${month.padStart(2, '0')}-01`;
      const endDate = `${year}-${month.padStart(2, '0')}-31`;
      attendanceRef = attendanceRef.where('date', '>=', startDate).where('date', '<=', endDate);
    } else if (year) {
      const startDate = `${year}-01-01`;
      const endDate = `${year}-12-31`;
      attendanceRef = attendanceRef.where('date', '>=', startDate).where('date', '<=', endDate);
    }
    
    const snapshot = await attendanceRef.orderBy('date', 'desc').get();
    const attendance = [];
    
    // Get user details for each attendance record
    for (const doc of snapshot.docs) {
      const attendanceData = { id: doc.id, ...doc.data() };
      
      // Get user details
      if (attendanceData.user_id) {
        try {
          const userDoc = await db.collection('users').doc(attendanceData.user_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            attendanceData.employee_id = userData.employee_id;
            attendanceData.full_name = userData.full_name;
            attendanceData.department = userData.department;
            attendanceData.position = userData.position;
          }
        } catch (userError) {
          console.error('Error fetching user details:', userError);
        }
      }
      
      attendance.push(attendanceData);
    }

    res.json({
      success: true,
      data: { attendance }
    });

  } catch (error) {
    console.error('Get attendance reports error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance reports'
    });
  }
});

// Get dashboard statistics
router.get('/dashboard-stats', auth, adminAuth, async (req, res) => {
  try {
    const today = formatDate();
    
    // Get total employees (non-admin users)
    const usersSnapshot = await db.collection('users').where('role', '==', 'employee').get();
    const totalEmployees = usersSnapshot.size;
    
    // Get today's attendance
    const todayAttendanceSnapshot = await db.collection('attendance').where('date', '==', today).get();
    const totalAttendanceToday = todayAttendanceSnapshot.size;
    
    // Count present today (present + late)
    let presentToday = 0;
    let absentToday = 0;
    
    todayAttendanceSnapshot.forEach(doc => {
      const attendance = doc.data();
      if (attendance.status === 'present' || attendance.status === 'late') {
        presentToday++;
      } else if (attendance.status === 'absent') {
        absentToday++;
      }
    });
    
    // Get pending leave requests
    const pendingLeavesSnapshot = await db.collection('leave_requests').where('status', '==', 'pending').get();
    const pendingLeaveRequests = pendingLeavesSnapshot.size;

    res.json({
      success: true,
      data: {
        total_employees: totalEmployees,
        total_attendance_today: totalAttendanceToday,
        present_today: presentToday,
        absent_today: absentToday,
        pending_leave_requests: pendingLeaveRequests
      }
    });

  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard statistics'
    });
  }
});

// Manage leave requests
router.get('/leave-requests', auth, adminAuth, async (req, res) => {
  try {
    const { status = 'pending' } = req.query;

    const leaveRequestsSnapshot = await db.collection('leave_requests')
      .where('status', '==', status)
      .orderBy('created_at', 'desc')
      .get();
    
    const leaveRequests = [];
    
    // Get user details for each leave request
    for (const doc of leaveRequestsSnapshot.docs) {
      const leaveData = { id: doc.id, ...doc.data() };
      
      // Get user details
      if (leaveData.user_id) {
        try {
          const userDoc = await db.collection('users').doc(leaveData.user_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            leaveData.employee_id = userData.employee_id;
            leaveData.full_name = userData.full_name;
            leaveData.department = userData.department;
          }
        } catch (userError) {
          console.error('Error fetching user details:', userError);
        }
      }
      
      leaveRequests.push(leaveData);
    }

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

// Approve/reject leave request
router.put('/leave-requests/:id', auth, adminAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // 'approved' or 'rejected'

    if (!['approved', 'rejected'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be "approved" or "rejected"'
      });
    }

    const leaveRequestRef = db.collection('leave_requests').doc(id);
    await leaveRequestRef.update({
      status,
      approved_by: req.user.userId,
      approved_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    });

    res.json({
      success: true,
      message: `Leave request ${status} successfully`
    });

  } catch (error) {
    console.error('Update leave request error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update leave request'
    });
  }
});

// Generate QR code for location
router.post('/generate-qr', auth, adminAuth, async (req, res) => {
  try {
    const { location } = req.body;

    if (!location) {
      return res.status(400).json({
        success: false,
        message: 'Location is required'
      });
    }

    // Generate unique QR code
    const qrCodeData = `BPR_${location.replace(/\s+/g, '_')}_${Date.now()}`;
    
    // Save to Firestore
    const qrCodeDoc = {
      code: qrCodeData,
      location,
      is_active: true,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };
    
    const qrCodeRef = await db.collection('qr_codes').add(qrCodeDoc);

    // Generate QR code image
    const qrCodeUrl = await QRCode.toDataURL(qrCodeData);

    res.json({
      success: true,
      message: 'QR code generated successfully',
      data: {
        id: qrCodeRef.id,
        qr_code: qrCodeData,
        qr_image: qrCodeUrl,
        location
      }
    });

  } catch (error) {
    console.error('Generate QR code error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate QR code'
    });
  }
});

// Get QR codes
router.get('/qr-codes', auth, adminAuth, async (req, res) => {
  try {
    const snapshot = await db.collection('qr_codes')
      .orderBy('created_at', 'desc')
      .get();
    
    const qrCodes = [];
    snapshot.forEach(doc => {
      qrCodes.push({ id: doc.id, ...doc.data() });
    });

    res.json({
      success: true,
      data: { qr_codes: qrCodes }
    });

  } catch (error) {
    console.error('Get QR codes error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get QR codes'
    });
  }
});

// Toggle QR code status
router.put('/qr-codes/:id/toggle', auth, adminAuth, async (req, res) => {
  try {
    const { id } = req.params;

    const qrCodeRef = db.collection('qr_codes').doc(id);
    const qrCodeDoc = await qrCodeRef.get();
    
    if (!qrCodeDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'QR code not found'
      });
    }
    
    const currentStatus = qrCodeDoc.data().is_active;
    
    await qrCodeRef.update({
      is_active: !currentStatus,
      updated_at: getServerTimestamp()
    });

    res.json({
      success: true,
      message: 'QR code status updated successfully'
    });

  } catch (error) {
    console.error('Toggle QR code error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle QR code status'
    });
  }
});

// Delete QR code
router.delete('/qr-codes/:id', auth, adminAuth, async (req, res) => {
  try {
    const { id } = req.params;

    await db.collection('qr_codes').doc(id).delete();

    res.json({
      success: true,
      message: 'QR code deleted successfully'
    });

  } catch (error) {
    console.error('Delete QR code error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete QR code'
    });
  }
});

// Update user status (activate/deactivate)
router.put('/users/:id/status', auth, adminAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const { is_active } = req.body;

    if (typeof is_active !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'is_active must be a boolean value'
      });
    }

    const userRef = db.collection('users').doc(id);
    await userRef.update({
      is_active,
      updated_at: getServerTimestamp()
    });

    res.json({
      success: true,
      message: `User ${is_active ? 'activated' : 'deactivated'} successfully`
    });

  } catch (error) {
    console.error('Update user status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user status'
    });
  }
});

module.exports = router;
