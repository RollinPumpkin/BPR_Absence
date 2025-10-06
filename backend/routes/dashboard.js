const express = require('express');
const moment = require('moment');
const { getFirestore, getServerTimestamp, formatDate } = require('../config/database');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();
const db = getFirestore();

// ==================== USER DASHBOARD ENDPOINTS ====================

// Get user dashboard data
router.get('/user', auth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = formatDate();
    const currentMonth = moment().format('YYYY-MM');
    const startOfMonth = `${currentMonth}-01`;
    const endOfMonth = moment().endOf('month').format('YYYY-MM-DD');

    // Get user info
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    const userData = userDoc.data();

    // Today's attendance
    const todayAttendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', userId)
      .where('date', '==', today)
      .get();

    const todayAttendance = todayAttendanceSnapshot.empty 
      ? null 
      : { id: todayAttendanceSnapshot.docs[0].id, ...todayAttendanceSnapshot.docs[0].data() };

    // This month's attendance summary
    const monthAttendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', userId)
      .where('date', '>=', startOfMonth)
      .where('date', '<=', endOfMonth)
      .get();

    let monthStats = {
      total_days: 0,
      present_days: 0,
      late_days: 0,
      absent_days: 0,
      total_hours: 0,
      overtime_hours: 0
    };

    monthAttendanceSnapshot.forEach(doc => {
      const attendance = doc.data();
      monthStats.total_days++;
      
      switch (attendance.status) {
        case 'present':
          monthStats.present_days++;
          break;
        case 'late':
          monthStats.late_days++;
          break;
        case 'absent':
          monthStats.absent_days++;
          break;
      }

      if (attendance.total_hours_worked) {
        monthStats.total_hours += parseFloat(attendance.total_hours_worked) || 0;
      }
      if (attendance.overtime_hours) {
        monthStats.overtime_hours += parseFloat(attendance.overtime_hours) || 0;
      }
    });

    // Upcoming tasks (assignments) - handle if collection doesn't exist
    let upcomingTasks = [];
    try {
      const upcomingAssignmentsSnapshot = await db.collection('assignments')
        .where('user_id', '==', userId)
        .limit(5)
        .get();

      upcomingAssignmentsSnapshot.forEach(doc => {
        const assignment = doc.data();
        // Only include if status is assigned or in_progress
        if (['assigned', 'in_progress'].includes(assignment.status)) {
          upcomingTasks.push({
            id: doc.id,
            title: assignment.title,
            description: assignment.description,
            status: assignment.status,
            due_date: assignment.due_date,
            priority: assignment.priority || 'medium',
            created_at: assignment.created_at
          });
        }
      });
    } catch (assignmentError) {
      console.warn('Assignments query failed, continuing without assignments:', assignmentError.message);
      upcomingTasks = [];
    }

    // Recent leave requests
    const recentLeaveRequestsSnapshot = await db.collection('leave_requests')
      .where('user_id', '==', userId)
      .orderBy('created_at', 'desc')
      .limit(3)
      .get();

    const recentLeaveRequests = [];
    recentLeaveRequestsSnapshot.forEach(doc => {
      const leave = doc.data();
      recentLeaveRequests.push({
        id: doc.id,
        leave_type: leave.leave_type,
        start_date: leave.start_date,
        end_date: leave.end_date,
        status: leave.status,
        reason: leave.reason,
        created_at: leave.created_at
      });
    });

    // Weekly attendance chart data (last 7 days)
    const weeklyAttendanceData = [];
    for (let i = 6; i >= 0; i--) {
      const date = moment().subtract(i, 'days').format('YYYY-MM-DD');
      const dayName = moment().subtract(i, 'days').format('dddd').substring(0, 1);
      
      const dayAttendanceSnapshot = await db.collection('attendance')
        .where('user_id', '==', userId)
        .where('date', '==', date)
        .get();

      let status = 'absent';
      let hours = 0;
      
      if (!dayAttendanceSnapshot.empty) {
        const dayAttendance = dayAttendanceSnapshot.docs[0].data();
        status = dayAttendance.status;
        hours = parseFloat(dayAttendance.total_hours_worked) || 0;
      }

      weeklyAttendanceData.push({
        date,
        day: dayName,
        status,
        hours: Math.round(hours)
      });
    }

    res.json({
      success: true,
      data: {
        user: {
          id: userId,
          full_name: userData.full_name,
          employee_id: userData.employee_id,
          department: userData.department,
          position: userData.position,
          email: userData.email
        },
        today_attendance: {
          date: today,
          attendance: todayAttendance,
          has_checked_in: todayAttendance?.check_in_time ? true : false,
          has_checked_out: todayAttendance?.check_out_time ? true : false,
          current_status: todayAttendance?.status || 'not_checked_in'
        },
        month_summary: {
          month: moment().format('MMMM YYYY'),
          ...monthStats,
          attendance_rate: monthStats.total_days > 0 
            ? Math.round(((monthStats.present_days + monthStats.late_days) / monthStats.total_days) * 100)
            : 0
        },
        upcoming_tasks: upcomingTasks,
        recent_leave_requests: recentLeaveRequests,
        weekly_attendance: weeklyAttendanceData,
        quick_stats: {
          pending_assignments: upcomingTasks.filter(task => task.status === 'assigned').length,
          in_progress_assignments: upcomingTasks.filter(task => task.status === 'in_progress').length,
          pending_leave_requests: recentLeaveRequests.filter(leave => leave.status === 'pending').length,
          total_overtime_hours: monthStats.overtime_hours
        }
      }
    });

  } catch (error) {
    console.error('Get user dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user dashboard data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get user activity summary with time-based filtering
router.get('/user/activity', auth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { period = 'week' } = req.query; // week, month, year
    
    let startDate, endDate, periodLabel;
    
    switch (period) {
      case 'week':
        startDate = moment().startOf('week').format('YYYY-MM-DD');
        endDate = moment().endOf('week').format('YYYY-MM-DD');
        periodLabel = 'This Week';
        break;
      case 'month':
        startDate = moment().startOf('month').format('YYYY-MM-DD');
        endDate = moment().endOf('month').format('YYYY-MM-DD');
        periodLabel = 'This Month';
        break;
      case 'year':
        startDate = moment().startOf('year').format('YYYY-MM-DD');
        endDate = moment().endOf('year').format('YYYY-MM-DD');
        periodLabel = 'This Year';
        break;
      default:
        startDate = moment().startOf('week').format('YYYY-MM-DD');
        endDate = moment().endOf('week').format('YYYY-MM-DD');
        periodLabel = 'This Week';
    }

    // Get attendance data for period
    const attendanceSnapshot = await db.collection('attendance')
      .where('user_id', '==', userId)
      .where('date', '>=', startDate)
      .where('date', '<=', endDate)
      .orderBy('date', 'asc')
      .get();

    const attendanceData = [];
    let totalHours = 0;
    let totalOvertimeHours = 0;
    let presentDays = 0;
    let lateDays = 0;

    attendanceSnapshot.forEach(doc => {
      const data = { id: doc.id, ...doc.data() };
      attendanceData.push(data);
      
      if (data.total_hours_worked) {
        totalHours += parseFloat(data.total_hours_worked) || 0;
      }
      if (data.overtime_hours) {
        totalOvertimeHours += parseFloat(data.overtime_hours) || 0;
      }
      if (data.status === 'present') {
        presentDays++;
      } else if (data.status === 'late') {
        lateDays++;
      }
    });

    // Get assignments for period - handle if collection doesn't exist
    let completedAssignments = 0;
    let pendingAssignments = 0;
    let inProgressAssignments = 0;
    let totalAssignments = 0;

    try {
      const assignmentsSnapshot = await db.collection('assignments')
        .where('user_id', '==', userId)
        .get();

      assignmentsSnapshot.forEach(doc => {
        const assignment = doc.data();
        totalAssignments++;
        switch (assignment.status) {
          case 'completed':
            completedAssignments++;
            break;
          case 'assigned':
            pendingAssignments++;
            break;
          case 'in_progress':
            inProgressAssignments++;
            break;
        }
      });
    } catch (assignmentError) {
      console.warn('Assignments query failed, continuing without assignments:', assignmentError.message);
    }

    res.json({
      success: true,
      data: {
        period: periodLabel,
        date_range: { start: startDate, end: endDate },
        attendance_summary: {
          total_days_worked: attendanceData.length,
          present_days: presentDays,
          late_days: lateDays,
          total_hours: totalHours.toFixed(2),
          overtime_hours: totalOvertimeHours.toFixed(2),
          average_hours_per_day: attendanceData.length > 0 
            ? (totalHours / attendanceData.length).toFixed(2) 
            : '0.00'
        },
        assignment_summary: {
          total_assignments: totalAssignments,
          completed: completedAssignments,
          in_progress: inProgressAssignments,
          pending: pendingAssignments,
          completion_rate: totalAssignments > 0 
            ? Math.round((completedAssignments / totalAssignments) * 100)
            : 0
        },
        daily_breakdown: attendanceData.map(att => ({
          date: att.date,
          day: moment(att.date).format('dddd'),
          status: att.status,
          check_in_time: att.check_in_time,
          check_out_time: att.check_out_time,
          hours_worked: att.total_hours_worked || '0.00',
          overtime_hours: att.overtime_hours || '0.00'
        }))
      }
    });

  } catch (error) {
    console.error('Get user activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user activity data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ==================== ADMIN DASHBOARD ENDPOINTS ====================

// Get admin dashboard overview
router.get('/admin', auth, adminAuth, async (req, res) => {
  try {
    const today = formatDate();
    const currentMonth = moment().format('YYYY-MM');
    const startOfMonth = `${currentMonth}-01`;
    const endOfMonth = moment().endOf('month').format('YYYY-MM-DD');

    // Total employees count
    const employeesSnapshot = await db.collection('users')
      .where('role', '==', 'employee')
      .where('is_active', '==', true)
      .get();
    const totalEmployees = employeesSnapshot.size;

    // Today's attendance overview
    const todayAttendanceSnapshot = await db.collection('attendance')
      .where('date', '==', today)
      .get();

    let todayStats = {
      total_checked_in: 0,
      present: 0,
      late: 0,
      absent: 0,
      not_checked_in: totalEmployees
    };

    const checkedInUsers = new Set();
    todayAttendanceSnapshot.forEach(doc => {
      const attendance = doc.data();
      if (attendance.check_in_time) {
        checkedInUsers.add(attendance.user_id);
        todayStats.total_checked_in++;
        
        switch (attendance.status) {
          case 'present':
            todayStats.present++;
            break;
          case 'late':
            todayStats.late++;
            break;
          case 'absent':
            todayStats.absent++;
            break;
        }
      }
    });

    todayStats.not_checked_in = totalEmployees - todayStats.total_checked_in;

    // This month's overall attendance
    const monthAttendanceSnapshot = await db.collection('attendance')
      .where('date', '>=', startOfMonth)
      .where('date', '<=', endOfMonth)
      .get();

    let monthStats = {
      total_attendance_records: monthAttendanceSnapshot.size,
      total_working_days: 0,
      average_attendance_rate: 0,
      total_hours_worked: 0,
      total_overtime_hours: 0
    };

    const dailyAttendance = {};
    monthAttendanceSnapshot.forEach(doc => {
      const attendance = doc.data();
      
      if (!dailyAttendance[attendance.date]) {
        dailyAttendance[attendance.date] = 0;
      }
      if (attendance.check_in_time) {
        dailyAttendance[attendance.date]++;
      }

      if (attendance.total_hours_worked) {
        monthStats.total_hours_worked += parseFloat(attendance.total_hours_worked) || 0;
      }
      if (attendance.overtime_hours) {
        monthStats.total_overtime_hours += parseFloat(attendance.overtime_hours) || 0;
      }
    });

    const workingDaysCount = Object.keys(dailyAttendance).length;
    monthStats.total_working_days = workingDaysCount;
    
    if (workingDaysCount > 0) {
      const totalPossibleAttendance = workingDaysCount * totalEmployees;
      const actualAttendance = Object.values(dailyAttendance).reduce((sum, count) => sum + count, 0);
      monthStats.average_attendance_rate = Math.round((actualAttendance / totalPossibleAttendance) * 100);
    }

    // Recent leave requests (pending approval)
    const pendingLeaveRequestsSnapshot = await db.collection('leave_requests')
      .where('status', '==', 'pending')
      .orderBy('created_at', 'desc')
      .limit(5)
      .get();

    const pendingLeaveRequests = [];
    for (const doc of pendingLeaveRequestsSnapshot.docs) {
      const leave = doc.data();
      
      // Get user details
      let userDetails = { full_name: 'Unknown User', employee_id: 'N/A' };
      try {
        const userDoc = await db.collection('users').doc(leave.user_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          userDetails = {
            full_name: userData.full_name,
            employee_id: userData.employee_id,
            department: userData.department
          };
        }
      } catch (userError) {
        console.warn('Could not fetch user details for leave request:', userError.message);
      }

      pendingLeaveRequests.push({
        id: doc.id,
        ...leave,
        user_details: userDetails
      });
    }

    // Recent assignments
    const recentAssignmentsSnapshot = await db.collection('assignments')
      .orderBy('created_at', 'desc')
      .limit(5)
      .get();

    const recentAssignments = [];
    for (const doc of recentAssignmentsSnapshot.docs) {
      const assignment = doc.data();
      
      // Get user details
      let userDetails = { full_name: 'Unknown User', employee_id: 'N/A' };
      try {
        const userDoc = await db.collection('users').doc(assignment.user_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          userDetails = {
            full_name: userData.full_name,
            employee_id: userData.employee_id
          };
        }
      } catch (userError) {
        console.warn('Could not fetch user details for assignment:', userError.message);
      }

      recentAssignments.push({
        id: doc.id,
        title: assignment.title,
        status: assignment.status,
        due_date: assignment.due_date,
        priority: assignment.priority || 'medium',
        created_at: assignment.created_at,
        user_details: userDetails
      });
    }

    // Weekly attendance chart data (last 7 days)
    const weeklyAttendanceChart = [];
    for (let i = 6; i >= 0; i--) {
      const date = moment().subtract(i, 'days').format('YYYY-MM-DD');
      const dayName = moment().subtract(i, 'days').format('dddd').substring(0, 1);
      
      const dayAttendanceSnapshot = await db.collection('attendance')
        .where('date', '==', date)
        .get();

      let presentCount = 0;
      let lateCount = 0;
      let totalCheckedIn = 0;

      dayAttendanceSnapshot.forEach(doc => {
        const attendance = doc.data();
        if (attendance.check_in_time) {
          totalCheckedIn++;
          if (attendance.status === 'present') {
            presentCount++;
          } else if (attendance.status === 'late') {
            lateCount++;
          }
        }
      });

      weeklyAttendanceChart.push({
        date,
        day: dayName,
        total_checked_in: totalCheckedIn,
        present: presentCount,
        late: lateCount,
        absent: Math.max(0, totalEmployees - totalCheckedIn)
      });
    }

    // Quick action items count
    const quickStats = {
      pending_leave_requests: pendingLeaveRequestsSnapshot.size,
      active_assignments: recentAssignments.filter(a => ['assigned', 'in_progress'].includes(a.status)).length,
      employees_not_checked_in_today: todayStats.not_checked_in,
      late_employees_today: todayStats.late
    };

    res.json({
      success: true,
      data: {
        overview: {
          total_employees: totalEmployees,
          date: today,
          month: moment().format('MMMM YYYY')
        },
        today_attendance: todayStats,
        month_summary: monthStats,
        pending_leave_requests: pendingLeaveRequests,
        recent_assignments: recentAssignments,
        weekly_attendance_chart: weeklyAttendanceChart,
        quick_stats: quickStats
      }
    });

  } catch (error) {
    console.error('Get admin dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get admin dashboard data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get admin department-wise statistics
router.get('/admin/departments', auth, adminAuth, async (req, res) => {
  try {
    const today = formatDate();
    const currentMonth = moment().format('YYYY-MM');
    const startOfMonth = `${currentMonth}-01`;
    const endOfMonth = moment().endOf('month').format('YYYY-MM-DD');

    // Get all employees grouped by department
    const usersSnapshot = await db.collection('users')
      .where('role', '==', 'employee')
      .where('is_active', '==', true)
      .get();

    const departmentStats = {};

    // Initialize department stats
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      const department = user.department || 'Unknown';
      
      if (!departmentStats[department]) {
        departmentStats[department] = {
          total_employees: 0,
          present_today: 0,
          late_today: 0,
          absent_today: 0,
          month_attendance_rate: 0,
          total_hours_worked: 0,
          employees: []
        };
      }
      
      departmentStats[department].total_employees++;
      departmentStats[department].employees.push({
        id: doc.id,
        full_name: user.full_name,
        employee_id: user.employee_id,
        position: user.position
      });
    });

    // Get today's attendance by department
    const todayAttendanceSnapshot = await db.collection('attendance')
      .where('date', '==', today)
      .get();

    for (const doc of todayAttendanceSnapshot.docs) {
      const attendance = doc.data();
      
      // Get user department
      try {
        const userDoc = await db.collection('users').doc(attendance.user_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          const department = userData.department || 'Unknown';
          
          if (departmentStats[department] && attendance.check_in_time) {
            if (attendance.status === 'present') {
              departmentStats[department].present_today++;
            } else if (attendance.status === 'late') {
              departmentStats[department].late_today++;
            }
          }
        }
      } catch (userError) {
        console.warn('Could not fetch user department:', userError.message);
      }
    }

    // Calculate absent count for each department
    Object.keys(departmentStats).forEach(department => {
      const dept = departmentStats[department];
      dept.absent_today = dept.total_employees - dept.present_today - dept.late_today;
      dept.attendance_rate_today = dept.total_employees > 0 
        ? Math.round(((dept.present_today + dept.late_today) / dept.total_employees) * 100)
        : 0;
    });

    // Get month attendance by department
    const monthAttendanceSnapshot = await db.collection('attendance')
      .where('date', '>=', startOfMonth)
      .where('date', '<=', endOfMonth)
      .get();

    const departmentMonthlyAttendance = {};

    for (const doc of monthAttendanceSnapshot.docs) {
      const attendance = doc.data();
      
      try {
        const userDoc = await db.collection('users').doc(attendance.user_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          const department = userData.department || 'Unknown';
          
          if (!departmentMonthlyAttendance[department]) {
            departmentMonthlyAttendance[department] = {
              total_attendance: 0,
              total_hours: 0,
              working_days: new Set()
            };
          }
          
          if (attendance.check_in_time) {
            departmentMonthlyAttendance[department].total_attendance++;
            departmentMonthlyAttendance[department].working_days.add(attendance.date);
          }
          
          if (attendance.total_hours_worked) {
            departmentMonthlyAttendance[department].total_hours += parseFloat(attendance.total_hours_worked) || 0;
          }
        }
      } catch (userError) {
        console.warn('Could not fetch user department for monthly stats:', userError.message);
      }
    }

    // Calculate monthly attendance rates
    Object.keys(departmentStats).forEach(department => {
      const dept = departmentStats[department];
      const monthlyData = departmentMonthlyAttendance[department];
      
      if (monthlyData) {
        const workingDays = monthlyData.working_days.size;
        const possibleAttendance = dept.total_employees * workingDays;
        
        dept.month_attendance_rate = possibleAttendance > 0 
          ? Math.round((monthlyData.total_attendance / possibleAttendance) * 100)
          : 0;
        dept.total_hours_worked = monthlyData.total_hours.toFixed(2);
      }
    });

    res.json({
      success: true,
      data: {
        departments: departmentStats,
        summary: {
          total_departments: Object.keys(departmentStats).length,
          date: today,
          month: moment().format('MMMM YYYY')
        }
      }
    });

  } catch (error) {
    console.error('Get department statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get department statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ==================== REAL-TIME DASHBOARD STATISTICS ====================

// Get real-time attendance status
router.get('/realtime/attendance', auth, adminAuth, async (req, res) => {
  try {
    const today = formatDate();
    const currentTime = moment().format('HH:mm:ss');

    // Get all active employees
    const employeesSnapshot = await db.collection('users')
      .where('role', '==', 'employee')
      .where('is_active', '==', true)
      .get();

    const employees = [];
    employeesSnapshot.forEach(doc => {
      const userData = doc.data();
      employees.push({
        id: doc.id,
        full_name: userData.full_name,
        employee_id: userData.employee_id,
        department: userData.department,
        position: userData.position
      });
    });

    // Get today's attendance for all employees
    const attendanceSnapshot = await db.collection('attendance')
      .where('date', '==', today)
      .get();

    const attendanceMap = {};
    attendanceSnapshot.forEach(doc => {
      const attendance = doc.data();
      attendanceMap[attendance.user_id] = attendance;
    });

    // Combine employee data with attendance status
    const realTimeStatus = employees.map(employee => {
      const attendance = attendanceMap[employee.id];
      
      return {
        ...employee,
        attendance_status: attendance ? {
          status: attendance.status,
          check_in_time: attendance.check_in_time,
          check_out_time: attendance.check_out_time,
          location: attendance.check_in_location,
          hours_worked: attendance.total_hours_worked || '0.00',
          is_overtime: attendance.is_overtime || false
        } : {
          status: 'not_checked_in',
          check_in_time: null,
          check_out_time: null,
          location: null,
          hours_worked: '0.00',
          is_overtime: false
        }
      };
    });

    // Calculate summary statistics
    const summary = {
      total_employees: employees.length,
      checked_in: realTimeStatus.filter(emp => emp.attendance_status.check_in_time).length,
      not_checked_in: realTimeStatus.filter(emp => !emp.attendance_status.check_in_time).length,
      present: realTimeStatus.filter(emp => emp.attendance_status.status === 'present').length,
      late: realTimeStatus.filter(emp => emp.attendance_status.status === 'late').length,
      checked_out: realTimeStatus.filter(emp => emp.attendance_status.check_out_time).length,
      still_working: realTimeStatus.filter(emp => emp.attendance_status.check_in_time && !emp.attendance_status.check_out_time).length,
      current_time: currentTime,
      last_updated: moment().toISOString()
    };

    res.json({
      success: true,
      data: {
        summary,
        employees: realTimeStatus,
        timestamp: moment().toISOString()
      }
    });

  } catch (error) {
    console.error('Get real-time attendance error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get real-time attendance data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// ==================== DASHBOARD WIDGETS ====================

// Get attendance chart widget data
router.get('/widgets/attendance-chart', auth, async (req, res) => {
  try {
    const { period = 'week', user_id } = req.query;
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';
    const targetUserId = user_id && isAdmin ? user_id : req.user.userId;

    let startDate, endDate, labels = [];
    
    switch (period) {
      case 'week':
        for (let i = 6; i >= 0; i--) {
          const date = moment().subtract(i, 'days');
          labels.push(date.format('ddd'));
          if (i === 6) startDate = date.format('YYYY-MM-DD');
          if (i === 0) endDate = date.format('YYYY-MM-DD');
        }
        break;
      case 'month':
        const weeksInMonth = Math.ceil(moment().daysInMonth() / 7);
        for (let i = 0; i < weeksInMonth; i++) {
          labels.push(`W${i + 1}`);
        }
        startDate = moment().startOf('month').format('YYYY-MM-DD');
        endDate = moment().endOf('month').format('YYYY-MM-DD');
        break;
      default:
        // Default to week
        for (let i = 6; i >= 0; i--) {
          const date = moment().subtract(i, 'days');
          labels.push(date.format('ddd'));
          if (i === 6) startDate = date.format('YYYY-MM-DD');
          if (i === 0) endDate = date.format('YYYY-MM-DD');
        }
    }

    let attendanceQuery = db.collection('attendance')
      .where('date', '>=', startDate)
      .where('date', '<=', endDate);

    if (targetUserId) {
      attendanceQuery = attendanceQuery.where('user_id', '==', targetUserId);
    }

    const attendanceSnapshot = await attendanceQuery.get();
    
    const chartData = {
      labels,
      datasets: {
        present: new Array(labels.length).fill(0),
        late: new Array(labels.length).fill(0),
        absent: new Array(labels.length).fill(0)
      }
    };

    if (period === 'week') {
      attendanceSnapshot.forEach(doc => {
        const attendance = doc.data();
        const dayIndex = moment(attendance.date).diff(moment(startDate), 'days');
        
        if (dayIndex >= 0 && dayIndex < labels.length) {
          if (attendance.status === 'present') {
            chartData.datasets.present[dayIndex]++;
          } else if (attendance.status === 'late') {
            chartData.datasets.late[dayIndex]++;
          }
        }
      });

      // Calculate absent (assuming 1 user if user_id specified, otherwise get total employees)
      if (targetUserId) {
        for (let i = 0; i < labels.length; i++) {
          if (chartData.datasets.present[i] === 0 && chartData.datasets.late[i] === 0) {
            chartData.datasets.absent[i] = 1;
          }
        }
      }
    }

    res.json({
      success: true,
      data: {
        chart_data: chartData,
        period,
        date_range: { start: startDate, end: endDate },
        user_id: targetUserId
      }
    });

  } catch (error) {
    console.error('Get attendance chart widget error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get attendance chart data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get quick stats widget
router.get('/widgets/quick-stats', auth, async (req, res) => {
  try {
    const today = formatDate();
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';
    const userId = req.user.userId;

    if (isAdmin) {
      // Admin quick stats
      const [
        totalEmployeesSnapshot,
        todayAttendanceSnapshot,
        pendingLeaveSnapshot,
        activeAssignmentsSnapshot
      ] = await Promise.all([
        db.collection('users').where('role', '==', 'employee').where('is_active', '==', true).get(),
        db.collection('attendance').where('date', '==', today).get(),
        db.collection('leave_requests').where('status', '==', 'pending').get(),
        db.collection('assignments').where('status', 'in', ['assigned', 'in_progress']).get()
      ]);

      const totalEmployees = totalEmployeesSnapshot.size;
      let presentToday = 0;
      let lateToday = 0;

      todayAttendanceSnapshot.forEach(doc => {
        const attendance = doc.data();
        if (attendance.check_in_time) {
          if (attendance.status === 'present') {
            presentToday++;
          } else if (attendance.status === 'late') {
            lateToday++;
          }
        }
      });

      res.json({
        success: true,
        data: {
          type: 'admin',
          stats: [
            {
              title: 'Total Employees',
              value: totalEmployees,
              icon: 'people',
              color: 'blue'
            },
            {
              title: 'Present Today',
              value: presentToday,
              icon: 'check_circle',
              color: 'green'
            },
            {
              title: 'Late Today',
              value: lateToday,
              icon: 'schedule',
              color: 'orange'
            },
            {
              title: 'Pending Leaves',
              value: pendingLeaveSnapshot.size,
              icon: 'pending',
              color: 'red'
            },
            {
              title: 'Active Assignments',
              value: activeAssignmentsSnapshot.size,
              icon: 'assignment',
              color: 'purple'
            }
          ]
        }
      });

    } else {
      // User quick stats
      const currentMonth = moment().format('YYYY-MM');
      const startOfMonth = `${currentMonth}-01`;
      const endOfMonth = moment().endOf('month').format('YYYY-MM-DD');

      const [
        todayAttendanceSnapshot,
        monthAttendanceSnapshot,
        pendingLeaveSnapshot,
        assignmentsSnapshot
      ] = await Promise.all([
        db.collection('attendance').where('user_id', '==', userId).where('date', '==', today).get(),
        db.collection('attendance').where('user_id', '==', userId).where('date', '>=', startOfMonth).where('date', '<=', endOfMonth).get(),
        db.collection('leave_requests').where('user_id', '==', userId).where('status', '==', 'pending').get(),
        db.collection('assignments').where('user_id', '==', userId).where('status', 'in', ['assigned', 'in_progress']).get()
      ]);

      const todayAttendance = todayAttendanceSnapshot.empty ? null : todayAttendanceSnapshot.docs[0].data();
      let monthHours = 0;
      let presentDays = 0;

      monthAttendanceSnapshot.forEach(doc => {
        const attendance = doc.data();
        if (attendance.total_hours_worked) {
          monthHours += parseFloat(attendance.total_hours_worked) || 0;
        }
        if (attendance.status === 'present' || attendance.status === 'late') {
          presentDays++;
        }
      });

      res.json({
        success: true,
        data: {
          type: 'user',
          stats: [
            {
              title: 'Hours Today',
              value: todayAttendance?.total_hours_worked || '0.00',
              icon: 'schedule',
              color: 'blue'
            },
            {
              title: 'Hours This Month',
              value: monthHours.toFixed(2),
              icon: 'access_time',
              color: 'green'
            },
            {
              title: 'Days Present',
              value: presentDays,
              icon: 'check_circle',
              color: 'green'
            },
            {
              title: 'Pending Tasks',
              value: assignmentsSnapshot.size,
              icon: 'assignment',
              color: 'orange'
            },
            {
              title: 'Leave Requests',
              value: pendingLeaveSnapshot.size,
              icon: 'pending',
              color: 'red'
            }
          ]
        }
      });
    }

  } catch (error) {
    console.error('Get quick stats widget error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get quick stats data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get recent activities widget
router.get('/widgets/recent-activities', auth, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';
    const userId = req.user.userId;

    const activities = [];

    if (isAdmin) {
      // Admin sees all recent activities
      try {
        const [
          recentAttendanceSnapshot,
          recentLeaveRequestsSnapshot
        ] = await Promise.all([
          db.collection('attendance').orderBy('created_at', 'desc').limit(Math.floor(parseInt(limit) / 2)).get(),
          db.collection('leave_requests').orderBy('created_at', 'desc').limit(Math.floor(parseInt(limit) / 2)).get()
        ]);

        // Process attendance activities
        for (const doc of recentAttendanceSnapshot.docs) {
          const attendance = doc.data();
          try {
            const userDoc = await db.collection('users').doc(attendance.user_id).get();
            const userData = userDoc.exists ? userDoc.data() : { full_name: 'Unknown User' };
            
            activities.push({
              id: doc.id,
              type: 'attendance',
              title: `${userData.full_name} checked in`,
              description: `Status: ${attendance.status} at ${attendance.check_in_time}`,
              timestamp: attendance.created_at,
              icon: 'login',
              color: attendance.status === 'late' ? 'orange' : 'green'
            });
          } catch (error) {
            console.warn('Could not fetch user for attendance activity:', error.message);
          }
        }

        // Process leave request activities
        for (const doc of recentLeaveRequestsSnapshot.docs) {
          const leave = doc.data();
          try {
            const userDoc = await db.collection('users').doc(leave.user_id).get();
            const userData = userDoc.exists ? userDoc.data() : { full_name: 'Unknown User' };
            
            activities.push({
              id: doc.id,
              type: 'leave_request',
              title: `${userData.full_name} requested leave`,
              description: `${leave.leave_type} from ${leave.start_date} to ${leave.end_date}`,
              timestamp: leave.created_at,
              icon: 'event_busy',
              color: leave.status === 'pending' ? 'orange' : 'blue'
            });
          } catch (error) {
            console.warn('Could not fetch user for leave activity:', error.message);
          }
        }
      } catch (error) {
        console.warn('Error fetching admin activities:', error.message);
      }

    } else {
      // User sees only their activities
      try {
        const [
          userAttendanceSnapshot,
          userLeaveRequestsSnapshot
        ] = await Promise.all([
          db.collection('attendance').where('user_id', '==', userId).orderBy('created_at', 'desc').limit(Math.floor(parseInt(limit) / 2)).get(),
          db.collection('leave_requests').where('user_id', '==', userId).orderBy('created_at', 'desc').limit(Math.floor(parseInt(limit) / 2)).get()
        ]);

        // Process user attendance
        userAttendanceSnapshot.forEach(doc => {
          const attendance = doc.data();
          activities.push({
            id: doc.id,
            type: 'attendance',
            title: 'You checked in',
            description: `Status: ${attendance.status} at ${attendance.check_in_time}`,
            timestamp: attendance.created_at,
            icon: 'login',
            color: attendance.status === 'late' ? 'orange' : 'green'
          });
        });

        // Process user leave requests
        userLeaveRequestsSnapshot.forEach(doc => {
          const leave = doc.data();
          activities.push({
            id: doc.id,
            type: 'leave_request',
            title: 'Leave request submitted',
            description: `${leave.leave_type} from ${leave.start_date} to ${leave.end_date}`,
            timestamp: leave.created_at,
            icon: 'event_busy',
            color: leave.status === 'pending' ? 'orange' : 'blue'
          });
        });
      } catch (error) {
        console.warn('Error fetching user activities:', error.message);
      }
    }

    // Sort activities by timestamp (most recent first)
    activities.sort((a, b) => {
      const timeA = a.timestamp?.toDate ? a.timestamp.toDate() : new Date(a.timestamp);
      const timeB = b.timestamp?.toDate ? b.timestamp.toDate() : new Date(b.timestamp);
      return timeB - timeA;
    });

    res.json({
      success: true,
      data: {
        activities: activities.slice(0, parseInt(limit)),
        total_count: activities.length,
        user_type: isAdmin ? 'admin' : 'user'
      }
    });

  } catch (error) {
    console.error('Get recent activities widget error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get recent activities data',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;