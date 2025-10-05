const express = require('express');
const moment = require('moment');
const { getFirestore, getServerTimestamp, formatDate } = require('../config/database');
const auth = require('../middleware/auth');
const { validateAttendance } = require('../middleware/validation');

const router = express.Router();
const db = getFirestore();

// Get attendance records with filtering and pagination
router.get('/', auth, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      start_date,
      end_date,
      status,
      sort_by = 'date',
      sort_order = 'desc'
    } = req.query;

    const userId = req.user.userId;
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';

    let attendanceRef = db.collection('attendance');

    // Filter by user if not admin
    if (!isAdmin) {
      attendanceRef = attendanceRef.where('user_id', '==', userId);
    }

    // Apply date filters if provided
    if (start_date) {
      attendanceRef = attendanceRef.where('date', '>=', start_date);
    }
    if (end_date) {
      attendanceRef = attendanceRef.where('date', '<=', end_date);
    }

    // Apply status filter if provided
    if (status) {
      attendanceRef = attendanceRef.where('status', '==', status);
    }

    // Apply sorting
    attendanceRef = attendanceRef.orderBy('date', sort_order);

    // Get attendance records
    const snapshot = await attendanceRef.get();
    const attendanceRecords = [];

    for (const doc of snapshot.docs) {
      const attendanceData = { id: doc.id, ...doc.data() };

      // Get user details if admin
      if (isAdmin && attendanceData.user_id) {
        try {
          const userDoc = await db.collection('users').doc(attendanceData.user_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            attendanceData.user_name = userData.full_name;
            attendanceData.employee_id = userData.employee_id;
            attendanceData.department = userData.department;
          }
        } catch (error) {
          console.error('Error fetching user details:', error);
        }
      }

      attendanceRecords.push(attendanceData);
    }

    // Apply pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedRecords = attendanceRecords.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: {
        attendance: paginatedRecords,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(attendanceRecords.length / parseInt(limit)),
          total_records: attendanceRecords.length,
          limit: parseInt(limit),
          has_next_page: endIndex < attendanceRecords.length,
          has_prev_page: parseInt(page) > 1
        },
        filters: {
          start_date,
          end_date,
          status,
          sort_by,
          sort_order
        }
      }
    });

  } catch (error) {
    console.error('Get attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance records'
    });
  }
});

// Check in
router.post('/checkin', auth, validateAttendance, async (req, res) => {
  try {
    const { qr_code, location, notes, latitude, longitude } = req.body;
    const today = formatDate();
    const currentTime = moment().format('HH:mm:ss');
    const currentDateTime = moment().toISOString();

    // Enhanced validation
    if (!qr_code) {
      return res.status(400).json({
        success: false,
        message: 'QR code is required for check-in'
      });
    }

    if (!location) {
      return res.status(400).json({
        success: false,
        message: 'Location is required for check-in'
      });
    }

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

    const qrCodeData = qrCodesSnapshot.docs[0].data();

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
          message: 'Already checked in today',
          data: {
            check_in_time: existingAttendance.check_in_time,
            status: existingAttendance.status
          }
        });
      }
    }

    // Get work schedule from settings (with fallback)
    let workStartTime = '08:00:00';
    let lateThresholdMinutes = 15;
    
    try {
      const settingsSnapshot = await db.collection('settings').doc('app_config').get();
      if (settingsSnapshot.exists) {
        const settings = settingsSnapshot.data();
        workStartTime = settings.work_start_time || workStartTime;
        lateThresholdMinutes = settings.late_threshold_minutes || lateThresholdMinutes;
      }
    } catch (settingsError) {
      console.warn('Could not fetch settings, using defaults:', settingsError.message);
    }

    // Determine status based on time with late threshold
    const workStart = moment(workStartTime, 'HH:mm:ss');
    const currentMoment = moment(currentTime, 'HH:mm:ss');
    const lateThreshold = workStart.clone().add(lateThresholdMinutes, 'minutes');
    
    let status = 'present';
    if (currentMoment.isAfter(lateThreshold)) {
      status = 'late';
    } else if (currentMoment.isAfter(workStart)) {
      status = 'present'; // Within grace period
    }

    const attendanceData = {
      user_id: req.user.userId,
      date: today,
      check_in_time: currentTime,
      check_in_datetime: currentDateTime,
      check_in_location: location,
      check_in_coordinates: {
        latitude: latitude || null,
        longitude: longitude || null
      },
      status: status,
      qr_code_used: qr_code,
      qr_location: qrCodeData.location,
      notes: notes || '',
      work_start_time: workStartTime,
      late_threshold_minutes: lateThresholdMinutes,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    let attendanceId;
    if (!existingAttendanceSnapshot.empty) {
      // Update existing record
      const attendanceRef = existingAttendanceSnapshot.docs[0].ref;
      await attendanceRef.update({
        check_in_time: currentTime,
        check_in_datetime: currentDateTime,
        check_in_location: location,
        check_in_coordinates: {
          latitude: latitude || null,
          longitude: longitude || null
        },
        status: status,
        qr_code_used: qr_code,
        qr_location: qrCodeData.location,
        notes: notes || '',
        work_start_time: workStartTime,
        late_threshold_minutes: lateThresholdMinutes,
        updated_at: getServerTimestamp()
      });
      attendanceId = existingAttendanceSnapshot.docs[0].id;
    } else {
      // Create new record
      const newAttendanceRef = await db.collection('attendance').add(attendanceData);
      attendanceId = newAttendanceRef.id;
    }

    res.json({
      success: true,
      message: `Check-in successful - Status: ${status}`,
      data: {
        id: attendanceId,
        date: today,
        check_in_time: currentTime,
        status,
        location,
        qr_location: qrCodeData.location,
        minutes_late: status === 'late' ? currentMoment.diff(workStart, 'minutes') : 0
      }
    });

  } catch (error) {
    console.error('Check-in error:', error);
    res.status(500).json({
      success: false,
      message: 'Check-in failed',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Check out
router.post('/checkout', auth, async (req, res) => {
  try {
    const { location, notes, latitude, longitude } = req.body;
    const today = formatDate();
    const currentTime = moment().format('HH:mm:ss');
    const currentDateTime = moment().toISOString();

    // Enhanced validation
    if (!location) {
      return res.status(400).json({
        success: false,
        message: 'Location is required for check-out'
      });
    }

    // Check if checked in today
    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '==', today)
      .get();

    if (attendanceSnapshot.empty) {
      return res.status(400).json({
        success: false,
        message: 'No check-in record found for today. Please check in first.'
      });
    }

    const attendanceDoc = attendanceSnapshot.docs[0];
    const attendanceData = attendanceDoc.data();

    if (!attendanceData.check_in_time) {
      return res.status(400).json({
        success: false,
        message: 'Please check in first before checking out'
      });
    }

    if (attendanceData.check_out_time) {
      return res.status(400).json({
        success: false,
        message: 'Already checked out today',
        data: {
          check_out_time: attendanceData.check_out_time,
          total_hours: attendanceData.total_hours_worked
        }
      });
    }

    // Calculate working hours
    const checkInTime = moment(attendanceData.check_in_time, 'HH:mm:ss');
    const checkOutTime = moment(currentTime, 'HH:mm:ss');
    const totalMinutesWorked = checkOutTime.diff(checkInTime, 'minutes');
    const totalHoursWorked = (totalMinutesWorked / 60).toFixed(2);

    // Get work schedule from settings for overtime calculation
    let workEndTime = '17:00:00';
    let standardWorkHours = 8;
    
    try {
      const settingsSnapshot = await db.collection('settings').doc('app_config').get();
      if (settingsSnapshot.exists) {
        const settings = settingsSnapshot.data();
        workEndTime = settings.work_end_time || workEndTime;
        standardWorkHours = settings.standard_work_hours || standardWorkHours;
      }
    } catch (settingsError) {
      console.warn('Could not fetch settings, using defaults:', settingsError.message);
    }

    // Calculate overtime
    const workEnd = moment(workEndTime, 'HH:mm:ss');
    const isOvertime = checkOutTime.isAfter(workEnd);
    const overtimeMinutes = isOvertime ? checkOutTime.diff(workEnd, 'minutes') : 0;
    const overtimeHours = (overtimeMinutes / 60).toFixed(2);

    // Determine early departure
    const isEarlyDeparture = checkOutTime.isBefore(workEnd);
    const earlyDepartureMinutes = isEarlyDeparture ? workEnd.diff(checkOutTime, 'minutes') : 0;

    // Update attendance record with check-out information
    const updateData = {
      check_out_time: currentTime,
      check_out_datetime: currentDateTime,
      check_out_location: location,
      check_out_coordinates: {
        latitude: latitude || null,
        longitude: longitude || null
      },
      total_minutes_worked: totalMinutesWorked,
      total_hours_worked: totalHoursWorked,
      overtime_minutes: overtimeMinutes,
      overtime_hours: overtimeHours,
      early_departure_minutes: earlyDepartureMinutes,
      is_overtime: isOvertime,
      is_early_departure: isEarlyDeparture,
      work_end_time: workEndTime,
      standard_work_hours: standardWorkHours,
      notes: attendanceData.notes + (notes ? `\nCheckout: ${notes}` : ''),
      updated_at: getServerTimestamp()
    };

    await attendanceDoc.ref.update(updateData);

    // Prepare response data
    const responseData = {
      id: attendanceDoc.id,
      date: today,
      check_in_time: attendanceData.check_in_time,
      check_out_time: currentTime,
      location,
      total_hours_worked: totalHoursWorked,
      total_minutes_worked: totalMinutesWorked,
      overtime_hours: overtimeHours,
      overtime_minutes: overtimeMinutes,
      early_departure_minutes: earlyDepartureMinutes,
      is_overtime: isOvertime,
      is_early_departure: isEarlyDeparture,
      status: attendanceData.status
    };

    let message = 'Check-out successful';
    if (isOvertime) {
      message += ` - Overtime: ${overtimeHours} hours`;
    } else if (isEarlyDeparture) {
      message += ` - Early departure: ${earlyDepartureMinutes} minutes early`;
    }

    res.json({
      success: true,
      message,
      data: responseData
    });

  } catch (error) {
    console.error('Check-out error:', error);
    res.status(500).json({
      success: false,
      message: 'Check-out failed',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
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
      leave_days: 0,
      total_hours_worked: 0,
      total_overtime_hours: 0,
      average_hours_per_day: 0
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

      // Calculate hours worked
      if (data.total_hours_worked) {
        stats.total_hours_worked += parseFloat(data.total_hours_worked) || 0;
      }
      if (data.overtime_hours) {
        stats.total_overtime_hours += parseFloat(data.overtime_hours) || 0;
      }
    });

    // Calculate average hours per day
    if (stats.total_days > 0) {
      stats.average_hours_per_day = (stats.total_hours_worked / stats.total_days).toFixed(2);
    }

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

// Get attendance history with advanced filtering
router.get('/history', auth, async (req, res) => {
  try {
    const { 
      start_date, 
      end_date, 
      status, 
      page = 1, 
      limit = 20,
      sort_by = 'date',
      sort_order = 'desc'
    } = req.query;

    let attendanceRef = db.collection('attendance')
      .where('user_id', '==', req.user.userId);

    // Date filtering
    if (start_date) {
      attendanceRef = attendanceRef.where('date', '>=', start_date);
    }
    if (end_date) {
      attendanceRef = attendanceRef.where('date', '<=', end_date);
    }

    // Status filtering
    if (status) {
      attendanceRef = attendanceRef.where('status', '==', status);
    }

    // Sorting
    const validSortFields = ['date', 'check_in_time', 'total_hours_worked'];
    const sortField = validSortFields.includes(sort_by) ? sort_by : 'date';
    const sortDirection = sort_order === 'asc' ? 'asc' : 'desc';
    
    attendanceRef = attendanceRef.orderBy(sortField, sortDirection);

    // Pagination - Firestore doesn't support offset, use limit for basic pagination
    attendanceRef = attendanceRef.limit(parseInt(limit));

    const snapshot = await attendanceRef.get();
    const attendance = [];
    
    snapshot.forEach(doc => {
      const data = { id: doc.id, ...doc.data() };
      attendance.push(data);
    });

    // Get total count for pagination (requires separate query)
    let totalQuery = db.collection('attendance')
      .where('user_id', '==', req.user.userId);
    
    if (start_date) {
      totalQuery = totalQuery.where('date', '>=', start_date);
    }
    if (end_date) {
      totalQuery = totalQuery.where('date', '<=', end_date);
    }
    if (status) {
      totalQuery = totalQuery.where('status', '==', status);
    }

    const totalSnapshot = await totalQuery.get();
    const totalRecords = totalSnapshot.size;

    res.json({
      success: true,
      data: {
        attendance,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(totalRecords / parseInt(limit)),
          total_records: totalRecords,
          limit: parseInt(limit),
          has_next_page: parseInt(page) < Math.ceil(totalRecords / parseInt(limit)),
          has_prev_page: parseInt(page) > 1
        },
        filters: {
          start_date: start_date || null,
          end_date: end_date || null,
          status: status || null,
          sort_by: sortField,
          sort_order: sortDirection
        }
      }
    });

  } catch (error) {
    console.error('Get attendance history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance history'
    });
  }
});

// Get detailed attendance statistics and analytics
router.get('/statistics', auth, async (req, res) => {
  try {
    const { period = 'month', year, month, start_date, end_date } = req.query;
    const currentDate = new Date();
    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth() + 1;

    let startDateStr, endDateStr, periodLabel;

    // Determine date range based on period
    switch (period) {
      case 'week':
        const startOfWeek = moment().startOf('week');
        const endOfWeek = moment().endOf('week');
        startDateStr = startOfWeek.format('YYYY-MM-DD');
        endDateStr = endOfWeek.format('YYYY-MM-DD');
        periodLabel = `Week of ${startOfWeek.format('MMM DD, YYYY')}`;
        break;
      
      case 'month':
        const targetYear = year || currentYear;
        const targetMonth = month || currentMonth;
        startDateStr = `${targetYear}-${targetMonth.toString().padStart(2, '0')}-01`;
        endDateStr = `${targetYear}-${targetMonth.toString().padStart(2, '0')}-31`;
        periodLabel = moment(`${targetYear}-${targetMonth}`, 'YYYY-MM').format('MMMM YYYY');
        break;
      
      case 'year':
        const targetYearOnly = year || currentYear;
        startDateStr = `${targetYearOnly}-01-01`;
        endDateStr = `${targetYearOnly}-12-31`;
        periodLabel = `Year ${targetYearOnly}`;
        break;
      
      case 'custom':
        if (!start_date || !end_date) {
          return res.status(400).json({
            success: false,
            message: 'start_date and end_date are required for custom period'
          });
        }
        startDateStr = start_date;
        endDateStr = end_date;
        periodLabel = `${moment(start_date).format('MMM DD, YYYY')} - ${moment(end_date).format('MMM DD, YYYY')}`;
        break;
      
      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid period. Use: week, month, year, or custom'
        });
    }

    // Get attendance data for the period
    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '>=', startDateStr)
      .where('date', '<=', endDateStr)
      .orderBy('date', 'asc')
      .get();

    const attendanceRecords = [];
    attendanceSnapshot.forEach(doc => {
      attendanceRecords.push({ id: doc.id, ...doc.data() });
    });

    // Calculate comprehensive statistics
    const stats = {
      period: periodLabel,
      total_days_recorded: attendanceRecords.length,
      attendance_breakdown: {
        present: 0,
        late: 0,
        absent: 0,
        sick: 0,
        leave: 0
      },
      working_hours: {
        total_hours: 0,
        average_hours_per_day: 0,
        shortest_day: null,
        longest_day: null,
        total_overtime_hours: 0,
        days_with_overtime: 0
      },
      punctuality: {
        on_time_days: 0,
        late_days: 0,
        average_late_minutes: 0,
        total_late_minutes: 0,
        punctuality_percentage: 0
      },
      trends: {
        daily_hours: [],
        weekly_summary: [],
        most_productive_day: null,
        least_productive_day: null
      }
    };

    let totalHours = 0;
    let totalOvertimeHours = 0;
    let totalLateMinutes = 0;
    let lateDays = 0;
    let shortestDay = null;
    let longestDay = null;

    // Process each attendance record
    attendanceRecords.forEach(record => {
      // Status breakdown
      stats.attendance_breakdown[record.status] = (stats.attendance_breakdown[record.status] || 0) + 1;

      // Working hours analysis
      if (record.total_hours_worked) {
        const hoursWorked = parseFloat(record.total_hours_worked);
        totalHours += hoursWorked;
        
        // Track shortest and longest days
        if (shortestDay === null || hoursWorked < shortestDay.hours) {
          shortestDay = { date: record.date, hours: hoursWorked };
        }
        if (longestDay === null || hoursWorked > longestDay.hours) {
          longestDay = { date: record.date, hours: hoursWorked };
        }

        // Daily hours for trends
        stats.trends.daily_hours.push({
          date: record.date,
          hours: hoursWorked,
          status: record.status
        });
      }

      // Overtime analysis
      if (record.overtime_hours && parseFloat(record.overtime_hours) > 0) {
        totalOvertimeHours += parseFloat(record.overtime_hours);
        stats.working_hours.days_with_overtime++;
      }

      // Punctuality analysis
      if (record.status === 'late') {
        lateDays++;
        if (record.minutes_late) {
          totalLateMinutes += record.minutes_late;
        }
      } else if (record.status === 'present') {
        stats.punctuality.on_time_days++;
      }
    });

    // Calculate averages and percentages
    stats.working_hours.total_hours = totalHours.toFixed(2);
    stats.working_hours.total_overtime_hours = totalOvertimeHours.toFixed(2);
    stats.working_hours.shortest_day = shortestDay;
    stats.working_hours.longest_day = longestDay;

    if (attendanceRecords.length > 0) {
      stats.working_hours.average_hours_per_day = (totalHours / attendanceRecords.length).toFixed(2);
    }

    stats.punctuality.late_days = lateDays;
    stats.punctuality.total_late_minutes = totalLateMinutes;
    
    if (lateDays > 0) {
      stats.punctuality.average_late_minutes = Math.round(totalLateMinutes / lateDays);
    }

    const totalWorkingDays = stats.punctuality.on_time_days + lateDays;
    if (totalWorkingDays > 0) {
      stats.punctuality.punctuality_percentage = Math.round((stats.punctuality.on_time_days / totalWorkingDays) * 100);
    }

    // Weekly summary for trends (if period allows)
    if (period === 'month' || period === 'year' || period === 'custom') {
      const weeklyData = {};
      stats.trends.daily_hours.forEach(day => {
        const week = moment(day.date).week();
        if (!weeklyData[week]) {
          weeklyData[week] = { total_hours: 0, days: 0, week_start: moment(day.date).startOf('week').format('YYYY-MM-DD') };
        }
        weeklyData[week].total_hours += day.hours;
        weeklyData[week].days++;
      });

      stats.trends.weekly_summary = Object.entries(weeklyData).map(([week, data]) => ({
        week: parseInt(week),
        week_start: data.week_start,
        total_hours: data.total_hours.toFixed(2),
        average_hours: (data.total_hours / data.days).toFixed(2),
        days_worked: data.days
      }));
    }

    // Find most and least productive days
    if (stats.trends.daily_hours.length > 0) {
      const sortedDays = [...stats.trends.daily_hours].sort((a, b) => b.hours - a.hours);
      stats.trends.most_productive_day = sortedDays[0];
      stats.trends.least_productive_day = sortedDays[sortedDays.length - 1];
    }

    res.json({
      success: true,
      data: {
        statistics: stats,
        raw_data: {
          attendance_records: attendanceRecords,
          date_range: {
            start: startDateStr,
            end: endDateStr,
            period: period
          }
        }
      }
    });

  } catch (error) {
    console.error('Get attendance statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get attendance patterns and insights
router.get('/insights', auth, async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const endDate = moment().format('YYYY-MM-DD');
    const startDate = moment().subtract(parseInt(days), 'days').format('YYYY-MM-DD');

    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', req.user.userId)
      .where('date', '>=', startDate)
      .where('date', '<=', endDate)
      .orderBy('date', 'asc')
      .get();

    const records = [];
    attendanceSnapshot.forEach(doc => {
      records.push({ id: doc.id, ...doc.data() });
    });

    const insights = {
      period_summary: `Last ${days} days`,
      patterns: {
        most_common_check_in_time: null,
        most_common_check_out_time: null,
        preferred_work_days: {},
        attendance_streak: 0,
        longest_streak: 0
      },
      performance_indicators: {
        consistency_score: 0, // Based on regular check-in/out times
        punctuality_score: 0, // Based on on-time arrivals
        productivity_score: 0 // Based on hours worked vs expected
      },
      recommendations: []
    };

    if (records.length === 0) {
      insights.recommendations.push('No attendance data found for the specified period. Start tracking your attendance to get insights.');
      return res.json({ success: true, data: { insights } });
    }

    // Analyze check-in patterns
    const checkInTimes = records.filter(r => r.check_in_time).map(r => r.check_in_time);
    const checkOutTimes = records.filter(r => r.check_out_time).map(r => r.check_out_time);

    // Find most common check-in time (rounded to 15-minute intervals)
    if (checkInTimes.length > 0) {
      const timeSlots = {};
      checkInTimes.forEach(time => {
        const hour = parseInt(time.split(':')[0]);
        const minute = parseInt(time.split(':')[1]);
        const roundedMinute = Math.round(minute / 15) * 15;
        const slot = `${hour.toString().padStart(2, '0')}:${roundedMinute.toString().padStart(2, '0')}`;
        timeSlots[slot] = (timeSlots[slot] || 0) + 1;
      });
      
      insights.patterns.most_common_check_in_time = Object.entries(timeSlots)
        .sort(([,a], [,b]) => b - a)[0]?.[0];
    }

    // Find most common check-out time
    if (checkOutTimes.length > 0) {
      const timeSlots = {};
      checkOutTimes.forEach(time => {
        const hour = parseInt(time.split(':')[0]);
        const minute = parseInt(time.split(':')[1]);
        const roundedMinute = Math.round(minute / 15) * 15;
        const slot = `${hour.toString().padStart(2, '0')}:${roundedMinute.toString().padStart(2, '0')}`;
        timeSlots[slot] = (timeSlots[slot] || 0) + 1;
      });
      
      insights.patterns.most_common_check_out_time = Object.entries(timeSlots)
        .sort(([,a], [,b]) => b - a)[0]?.[0];
    }

    // Analyze day-of-week patterns
    records.forEach(record => {
      const dayOfWeek = moment(record.date).format('dddd');
      insights.patterns.preferred_work_days[dayOfWeek] = (insights.patterns.preferred_work_days[dayOfWeek] || 0) + 1;
    });

    // Calculate attendance streaks
    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;

    const sortedRecords = records.sort((a, b) => moment(a.date).diff(moment(b.date)));
    let lastDate = null;

    sortedRecords.forEach(record => {
      if (['present', 'late'].includes(record.status)) {
        if (lastDate && moment(record.date).diff(moment(lastDate), 'days') === 1) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
        
        longestStreak = Math.max(longestStreak, tempStreak);
        
        // Current streak (only if recent)
        if (moment().diff(moment(record.date), 'days') <= 1) {
          currentStreak = tempStreak;
        }
        
        lastDate = record.date;
      } else {
        tempStreak = 0;
      }
    });

    insights.patterns.attendance_streak = currentStreak;
    insights.patterns.longest_streak = longestStreak;

    // Calculate performance scores
    const onTimeCount = records.filter(r => r.status === 'present').length;
    const lateCount = records.filter(r => r.status === 'late').length;
    const workingDays = onTimeCount + lateCount;

    if (workingDays > 0) {
      insights.performance_indicators.punctuality_score = Math.round((onTimeCount / workingDays) * 100);
    }

    // Consistency score based on regular patterns
    const hoursWorked = records.filter(r => r.total_hours_worked).map(r => parseFloat(r.total_hours_worked));
    if (hoursWorked.length > 0) {
      const avgHours = hoursWorked.reduce((a, b) => a + b, 0) / hoursWorked.length;
      const variance = hoursWorked.reduce((acc, hours) => acc + Math.pow(hours - avgHours, 2), 0) / hoursWorked.length;
      const stdDev = Math.sqrt(variance);
      insights.performance_indicators.consistency_score = Math.max(0, Math.round(100 - (stdDev * 10)));
    }

    // Productivity score (hours worked vs expected 8 hours)
    if (hoursWorked.length > 0) {
      const avgHours = hoursWorked.reduce((a, b) => a + b, 0) / hoursWorked.length;
      insights.performance_indicators.productivity_score = Math.min(100, Math.round((avgHours / 8) * 100));
    }

    // Generate recommendations
    if (insights.performance_indicators.punctuality_score < 80) {
      insights.recommendations.push('Try to arrive on time more consistently. Consider setting earlier alarms or planning your commute better.');
    }

    if (insights.performance_indicators.consistency_score < 70) {
      insights.recommendations.push('Your work hours vary significantly. Try to maintain more consistent working hours for better work-life balance.');
    }

    if (insights.patterns.attendance_streak < 5) {
      insights.recommendations.push('Build a consistent attendance habit. Regular attendance improves your professional reputation.');
    }

    if (insights.patterns.attendance_streak >= 10) {
      insights.recommendations.push('Excellent attendance streak! Keep up the great work.');
    }

    res.json({
      success: true,
      data: { insights }
    });

  } catch (error) {
    console.error('Get attendance insights error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance insights',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Admin: Get all attendance records
router.get('/admin/all', auth, async (req, res) => {
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
      limit = 50,
      start_date,
      end_date,
      user_id,
      department,
      status
    } = req.query;

    let attendanceRef = db.collection('attendance');

    // Apply filters
    if (start_date) {
      attendanceRef = attendanceRef.where('date', '>=', start_date);
    }
    if (end_date) {
      attendanceRef = attendanceRef.where('date', '<=', end_date);
    }
    if (user_id) {
      attendanceRef = attendanceRef.where('user_id', '==', user_id);
    }
    if (status) {
      attendanceRef = attendanceRef.where('status', '==', status);
    }

    attendanceRef = attendanceRef.orderBy('date', 'desc');

    const snapshot = await attendanceRef.get();
    const attendanceRecords = [];

    for (const doc of snapshot.docs) {
      const attendanceData = { id: doc.id, ...doc.data() };

      // Get user details
      if (attendanceData.user_id) {
        try {
          const userDoc = await db.collection('users').doc(attendanceData.user_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            attendanceData.user_name = userData.full_name;
            attendanceData.employee_id = userData.employee_id;
            attendanceData.department = userData.department;
            attendanceData.position = userData.position;
          }
        } catch (error) {
          console.error('Error fetching user details:', error);
        }
      }

      // Apply department filter if specified
      if (department && attendanceData.department !== department) {
        continue;
      }

      attendanceRecords.push(attendanceData);
    }

    // Apply pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedRecords = attendanceRecords.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: {
        attendance: paginatedRecords,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(attendanceRecords.length / parseInt(limit)),
          total_records: attendanceRecords.length,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Admin get all attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance records'
    });
  }
});

// Admin: Attendance statistics
router.get('/admin/statistics', auth, async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin' && req.user.role !== 'account_officer') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { start_date, end_date, department } = req.query;
    
    // Set default date range if not provided
    const startDate = start_date || moment().startOf('month').format('YYYY-MM-DD');
    const endDate = end_date || moment().endOf('month').format('YYYY-MM-DD');

    let attendanceRef = db.collection('attendance')
      .where('date', '>=', startDate)
      .where('date', '<=', endDate);

    const snapshot = await attendanceRef.get();
    
    const stats = {
      total_attendance_records: 0,
      total_employees: new Set(),
      present_count: 0,
      absent_count: 0,
      late_count: 0,
      early_leave_count: 0,
      by_department: {},
      by_date: {},
      summary: {
        total_working_days: 0,
        average_attendance_rate: 0,
        punctuality_rate: 0
      }
    };

    const userDepartments = new Map();
    
    // Process attendance records
    for (const doc of snapshot.docs) {
      const attendance = doc.data();
      stats.total_attendance_records++;
      stats.total_employees.add(attendance.user_id);

      // Get user department if not cached
      if (!userDepartments.has(attendance.user_id)) {
        try {
          const userDoc = await db.collection('users').doc(attendance.user_id).get();
          if (userDoc.exists) {
            userDepartments.set(attendance.user_id, userDoc.data().department || 'Unknown');
          }
        } catch (error) {
          userDepartments.set(attendance.user_id, 'Unknown');
        }
      }

      const userDept = userDepartments.get(attendance.user_id);
      
      // Skip if department filter is applied and doesn't match
      if (department && userDept !== department) {
        continue;
      }

      // Count by status
      if (attendance.status === 'present') {
        stats.present_count++;
      } else if (attendance.status === 'absent') {
        stats.absent_count++;
      }

      // Count late arrivals
      if (attendance.check_in_time && moment(attendance.check_in_time, 'HH:mm:ss').isAfter(moment('09:00:00', 'HH:mm:ss'))) {
        stats.late_count++;
      }

      // Count early leaves
      if (attendance.check_out_time && moment(attendance.check_out_time, 'HH:mm:ss').isBefore(moment('17:00:00', 'HH:mm:ss'))) {
        stats.early_leave_count++;
      }

      // Group by department
      if (!stats.by_department[userDept]) {
        stats.by_department[userDept] = {
          total_records: 0,
          present: 0,
          absent: 0,
          late: 0,
          early_leave: 0
        };
      }
      stats.by_department[userDept].total_records++;
      if (attendance.status === 'present') stats.by_department[userDept].present++;
      if (attendance.status === 'absent') stats.by_department[userDept].absent++;

      // Group by date
      const date = attendance.date;
      if (!stats.by_date[date]) {
        stats.by_date[date] = {
          total_records: 0,
          present: 0,
          absent: 0,
          late: 0
        };
      }
      stats.by_date[date].total_records++;
      if (attendance.status === 'present') stats.by_date[date].present++;
      if (attendance.status === 'absent') stats.by_date[date].absent++;
    }

    // Calculate summary statistics
    stats.total_employees = stats.total_employees.size;
    stats.summary.total_working_days = Object.keys(stats.by_date).length;
    stats.summary.average_attendance_rate = stats.total_attendance_records > 0 ? 
      ((stats.present_count / stats.total_attendance_records) * 100).toFixed(2) : 0;
    stats.summary.punctuality_rate = stats.present_count > 0 ? 
      (((stats.present_count - stats.late_count) / stats.present_count) * 100).toFixed(2) : 0;

    res.json({
      success: true,
      data: {
        statistics: stats,
        period: {
          start_date: startDate,
          end_date: endDate,
          department: department || 'All'
        }
      }
    });

  } catch (error) {
    console.error('Admin attendance statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance statistics'
    });
  }
});

module.exports = router;
