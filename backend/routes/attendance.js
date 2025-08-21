const express = require('express');
const moment = require('moment');
const { getFirestore, getServerTimestamp, formatDate } = require('../config/database');
const auth = require('../middleware/auth');
const { validateAttendance } = require('../middleware/validation');

const router = express.Router();
const db = getFirestore();

// Check in
router.post('/checkin', auth, validateAttendance, async (req, res) => {
  try {
    const { qr_code, location, notes } = req.body;
    const today = formatDate();
    const currentTime = moment().format('HH:mm:ss');

    // Verify QR code
    const qrCodesSnapshot = await db.collection('qr_codes')
      .where('code', '==', qr_code)
      .where('is_active', '==', true)
      .get();

    if (qrCodesSnapshot.empty) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or inactive QR code'
      });
    }

    // Check if already checked in today
    const existingAttendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '==', today)
      .get();

    if (!existingAttendanceSnapshot.empty) {
      const existingAttendance = existingAttendanceSnapshot.docs[0].data();
      if (existingAttendance.check_in_time) {
        return res.status(400).json({
          success: false,
          message: 'Already checked in today'
        });
      }
    }

    // Determine status based on time (assuming work starts at 08:00)
    const workStartTime = '08:00:00';
    const status = currentTime > workStartTime ? 'late' : 'present';

    const attendanceData = {
      user_id: req.user.userId,
      date: today,
      check_in_time: currentTime,
      check_in_location: location,
      status: status,
      qr_code_used: qr_code,
      notes: notes || '',
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    if (!existingAttendanceSnapshot.empty) {
      // Update existing record
      const attendanceRef = existingAttendanceSnapshot.docs[0].ref;
      await attendanceRef.update({
        check_in_time: currentTime,
        check_in_location: location,
        status: status,
        qr_code_used: qr_code,
        notes: notes || '',
        updated_at: getServerTimestamp()
      });
    } else {
      // Create new record
      await db.collection('attendance').add(attendanceData);
    }

    res.json({
      success: true,
      message: 'Check-in successful',
      data: {
        date: today,
        check_in_time: currentTime,
        status,
        location
      }
    });

  } catch (error) {
    console.error('Check-in error:', error);
    res.status(500).json({
      success: false,
      message: 'Check-in failed'
    });
  }
});

// Check out
router.post('/checkout', auth, async (req, res) => {
  try {
    const { location, notes } = req.body;
    const today = formatDate();
    const currentTime = moment().format('HH:mm:ss');

    // Check if checked in today
    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '==', today)
      .get();

    if (attendanceSnapshot.empty) {
      return res.status(400).json({
        success: false,
        message: 'No check-in record found for today'
      });
    }

    const attendanceDoc = attendanceSnapshot.docs[0];
    const attendanceData = attendanceDoc.data();

    if (!attendanceData.check_in_time) {
      return res.status(400).json({
        success: false,
        message: 'Please check in first'
      });
    }

    if (attendanceData.check_out_time) {
      return res.status(400).json({
        success: false,
        message: 'Already checked out today'
      });
    }

    // Update with check-out time
    await attendanceDoc.ref.update({
      check_out_time: currentTime,
      check_out_location: location,
      notes: attendanceData.notes + (notes ? `\nCheckout: ${notes}` : ''),
      updated_at: getServerTimestamp()
    });

    res.json({
      success: true,
      message: 'Check-out successful',
      data: {
        date: today,
        check_out_time: currentTime,
        location
      }
    });

  } catch (error) {
    console.error('Check-out error:', error);
    res.status(500).json({
      success: false,
      message: 'Check-out failed'
    });
  }
});

// Get today's attendance status
router.get('/today', auth, async (req, res) => {
  try {
    const today = formatDate();

    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '==', today)
      .get();

    const attendanceData = attendanceSnapshot.empty 
      ? null 
      : { id: attendanceSnapshot.docs[0].id, ...attendanceSnapshot.docs[0].data() };

    res.json({
      success: true,
      data: {
        date: today,
        attendance: attendanceData,
        has_checked_in: attendanceData?.check_in_time ? true : false,
        has_checked_out: attendanceData?.check_out_time ? true : false
      }
    });

  } catch (error) {
    console.error('Get today attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get today\'s attendance'
    });
  }
});

// Submit leave request
router.post('/leave-request', auth, async (req, res) => {
  try {
    const { leave_type, start_date, end_date, reason } = req.body;

    // Validate required fields
    if (!leave_type || !start_date || !end_date || !reason) {
      return res.status(400).json({
        success: false,
        message: 'Leave type, start date, end date, and reason are required'
      });
    }

    // Validate leave types
    const validLeaveTypes = ['sick', 'annual', 'personal', 'emergency'];
    if (!validLeaveTypes.includes(leave_type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid leave type'
      });
    }

    // Validate dates
    if (moment(start_date).isAfter(moment(end_date))) {
      return res.status(400).json({
        success: false,
        message: 'Start date cannot be after end date'
      });
    }

    // Check if start date is in the past (except for sick leave)
    if (leave_type !== 'sick' && moment(start_date).isBefore(moment().startOf('day'))) {
      return res.status(400).json({
        success: false,
        message: 'Start date cannot be in the past'
      });
    }

    // Create leave request document
    const leaveRequestData = {
      user_id: req.user.userId,
      leave_type,
      start_date,
      end_date,
      reason,
      status: 'pending',
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    const leaveRequestRef = await db.collection('leave_requests').add(leaveRequestData);

    res.status(201).json({
      success: true,
      message: 'Leave request submitted successfully',
      data: {
        id: leaveRequestRef.id,
        leave_type,
        start_date,
        end_date,
        reason,
        status: 'pending'
      }
    });

  } catch (error) {
    console.error('Leave request error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit leave request'
    });
  }
});

// Get user's leave requests
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

// Cancel leave request (only if pending)
router.delete('/leave-requests/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const leaveRequestRef = db.collection('leave_requests').doc(id);
    const leaveRequestDoc = await leaveRequestRef.get();

    if (!leaveRequestDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Leave request not found'
      });
    }

    const leaveRequestData = leaveRequestDoc.data();

    // Check if the leave request belongs to the current user
    if (leaveRequestData.user_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized to cancel this leave request'
      });
    }

    // Check if the leave request is still pending
    if (leaveRequestData.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Can only cancel pending leave requests'
      });
    }

    await leaveRequestRef.delete();

    res.json({
      success: true,
      message: 'Leave request cancelled successfully'
    });

  } catch (error) {
    console.error('Cancel leave request error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel leave request'
    });
  }
});

// Get attendance summary for current month
router.get('/summary', auth, async (req, res) => {
  try {
    const { month, year } = req.query;
    const currentDate = new Date();
    const targetMonth = month || (currentDate.getMonth() + 1);
    const targetYear = year || currentDate.getFullYear();

    const startDate = `${targetYear}-${targetMonth.toString().padStart(2, '0')}-01`;
    const endDate = `${targetYear}-${targetMonth.toString().padStart(2, '0')}-31`;

    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '>=', startDate)
      .where('date', '<=', endDate)
      .orderBy('date', 'desc')
      .get();

    const attendance = [];
    let stats = {
      total_days: 0,
      present_days: 0,
      late_days: 0,
      absent_days: 0,
      sick_days: 0,
      leave_days: 0
    };

    attendanceSnapshot.forEach(doc => {
      const data = { id: doc.id, ...doc.data() };
      attendance.push(data);
      
      stats.total_days++;
      switch (data.status) {
        case 'present':
          stats.present_days++;
          break;
        case 'late':
          stats.late_days++;
          break;
        case 'absent':
          stats.absent_days++;
          break;
        case 'sick':
          stats.sick_days++;
          break;
        case 'leave':
          stats.leave_days++;
          break;
      }
    });

    res.json({
      success: true,
      data: {
        month: targetMonth,
        year: targetYear,
        attendance,
        stats
      }
    });

  } catch (error) {
    console.error('Get attendance summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance summary'
    });
  }
});

module.exports = router;
