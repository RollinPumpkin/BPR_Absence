const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const auth = require('../middleware/auth');

// Comprehensive database seeder endpoint
router.post('/seed-database', auth, async (req, res) => {
  try {
    console.log('🌱 Starting comprehensive database seeding...');
    const userId = req.user.userId;
    const db = admin.firestore();
    
    let results = {
      letters: 0,
      assignments: 0,
      attendance: 0,
      users: 0,
      errors: []
    };

    // 1. Seed Letters
    console.log('📝 Seeding letters...');
    const sampleLetters = [
      {
        subject: 'Sick Leave Request - Ahmad Suryono',
        content: 'I am requesting sick leave due to illness. Medical certificate will be provided.',
        letterType: 'sick_leave',
        priority: 'medium',
        senderId: userId,
        recipientId: 'admin',
        senderName: 'Ahmad Suryono',
        senderPosition: 'Account Officer',
        senderEmployeeId: 'EMP001',
        status: 'pending',
        requiresResponse: true,
        responseDeadline: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 3 * 24 * 60 * 60 * 1000)),
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        subject: 'Annual Leave Request - Budi Santoso',
        content: 'I would like to request annual leave for vacation next month.',
        letterType: 'annual_leave',
        priority: 'low',
        senderId: userId,
        recipientId: 'admin',
        senderName: 'Budi Santoso',
        senderPosition: 'Finance Staff',
        senderEmployeeId: 'EMP002',
        status: 'pending',
        requiresResponse: true,
        responseDeadline: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 3 * 24 * 60 * 60 * 1000)),
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        subject: 'Permission Letter - Sari Dewi',
        content: 'I need permission to leave early today for family matters.',
        letterType: 'permission_letter',
        priority: 'high',
        senderId: userId,
        recipientId: 'admin',
        senderName: 'Sari Dewi',
        senderPosition: 'Customer Service',
        senderEmployeeId: 'EMP003',
        status: 'pending',
        requiresResponse: true,
        responseDeadline: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 1 * 24 * 60 * 60 * 1000)),
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        subject: 'Work Certificate Request - Andi Putra',
        content: 'I need a work certificate for bank loan application.',
        letterType: 'work_certificate',
        priority: 'medium',
        senderId: userId,
        recipientId: 'admin',
        senderName: 'Andi Putra',
        senderPosition: 'Credit Analyst',
        senderEmployeeId: 'EMP004',
        status: 'pending',
        requiresResponse: true,
        responseDeadline: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 5 * 24 * 60 * 60 * 1000)),
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        subject: 'Emergency Leave - Maya Sari',
        content: 'Emergency family leave needed due to family member hospitalization.',
        letterType: 'emergency_leave',
        priority: 'high',
        senderId: userId,
        recipientId: 'admin',
        senderName: 'Maya Sari',
        senderPosition: 'Teller',
        senderEmployeeId: 'EMP005',
        status: 'approved',
        requiresResponse: false,
        responseMessage: 'Approved. Please take care of your family.',
        responseDate: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 1 * 24 * 60 * 60 * 1000)),
        updatedAt: admin.firestore.Timestamp.now()
      }
    ];

    for (const letter of sampleLetters) {
      try {
        await db.collection('letters').add(letter);
        results.letters++;
      } catch (error) {
        results.errors.push(`Letter seeding error: ${error.message}`);
      }
    }

    // 2. Seed Assignments
    console.log('🎯 Seeding assignments...');
    const today = new Date();
    const sampleAssignments = [
      {
        title: 'Monthly Report Submission',
        description: 'Submit monthly performance report to management',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)),
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        category: 'reporting',
        createdBy: userId,
        assignedBy: userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Customer Visit Schedule',
        description: 'Schedule visits to top 10 customers this month',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 14 * 24 * 60 * 60 * 1000)),
        assignedTo: [userId],
        priority: 'medium',
        status: 'in-progress',
        category: 'customer_relations',
        createdBy: userId,
        assignedBy: userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Training Module Completion',
        description: 'Complete mandatory compliance training modules',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000)),
        assignedTo: [userId],
        priority: 'low',
        status: 'pending',
        category: 'training',
        createdBy: userId,
        assignedBy: userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'System Backup Verification',
        description: 'Verify all system backups are working correctly',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000)),
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        category: 'maintenance',
        createdBy: userId,
        assignedBy: userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Branch Audit Preparation',
        description: 'Prepare documentation for upcoming branch audit',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 21 * 24 * 60 * 60 * 1000)),
        assignedTo: [userId],
        priority: 'medium',
        status: 'completed',
        category: 'audit',
        createdBy: userId,
        assignedBy: userId,
        completedAt: admin.firestore.Timestamp.now(),
        createdAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() - 2 * 24 * 60 * 60 * 1000)),
        updatedAt: admin.firestore.Timestamp.now()
      }
    ];

    for (const assignment of sampleAssignments) {
      try {
        await db.collection('assignments').add(assignment);
        results.assignments++;
      } catch (error) {
        results.errors.push(`Assignment seeding error: ${error.message}`);
      }
    }

    // 3. Seed Attendance Records
    console.log('⏰ Seeding attendance records...');
    const sampleAttendance = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() - i);
      
      // Skip weekends for more realistic data
      if (date.getDay() === 0 || date.getDay() === 6) continue;
      
      const dateStr = date.toISOString().split('T')[0];
      const checkInTime = i === 0 ? '09:15:00' : i === 1 ? '08:45:00' : '09:00:00';
      const checkOutTime = i === 0 ? '17:30:00' : i === 1 ? '17:45:00' : '17:00:00';
      const status = i === 0 ? 'late' : i === 2 ? 'sick_leave' : 'present';
      
      sampleAttendance.push({
        userId: userId,
        employeeId: 'EMP001',
        userName: 'Ahmad Suryono',
        department: 'Lending',
        date: dateStr,
        checkInTime: status === 'sick_leave' ? null : checkInTime,
        checkOutTime: status === 'sick_leave' ? null : checkOutTime,
        status: status,
        notes: status === 'late' ? 'Traffic jam' : status === 'sick_leave' ? 'Medical leave with certificate' : 'Regular work day',
        hoursWorked: status === 'sick_leave' ? 0 : 8,
        overtimeHours: i === 1 ? 0.75 : 0,
        createdAt: admin.firestore.Timestamp.fromDate(date),
        updatedAt: admin.firestore.Timestamp.now()
      });
    }

    for (const attendance of sampleAttendance) {
      try {
        await db.collection('attendance').add(attendance);
        results.attendance++;
      } catch (error) {
        results.errors.push(`Attendance seeding error: ${error.message}`);
      }
    }

    // 4. Seed Additional Users (for more realistic data)
    console.log('👥 Seeding additional employee data...');
    const sampleEmployees = [
      {
        employeeId: 'EMP002',
        fullName: 'Budi Santoso',
        email: 'budi.santoso@bpr.com',
        department: 'Finance',
        position: 'Finance Staff',
        role: 'employee',
        isActive: true,
        joinDate: '2024-01-15',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        employeeId: 'EMP003',
        fullName: 'Sari Dewi',
        email: 'sari.dewi@bpr.com',
        department: 'Customer Service',
        position: 'Customer Service Representative',
        role: 'employee',
        isActive: true,
        joinDate: '2024-03-01',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        employeeId: 'EMP004',
        fullName: 'Andi Putra',
        email: 'andi.putra@bpr.com',
        department: 'Credit Analysis',
        position: 'Credit Analyst',
        role: 'employee',
        isActive: true,
        joinDate: '2023-11-10',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        employeeId: 'EMP005',
        fullName: 'Maya Sari',
        email: 'maya.sari@bpr.com',
        department: 'Operations',
        position: 'Teller',
        role: 'employee',
        isActive: true,
        joinDate: '2024-02-20',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    ];

    for (const employee of sampleEmployees) {
      try {
        // Check if employee already exists
        const existingEmployee = await db.collection('users')
          .where('employeeId', '==', employee.employeeId)
          .get();
          
        if (existingEmployee.empty) {
          await db.collection('users').add(employee);
          results.users++;
        }
      } catch (error) {
        results.errors.push(`User seeding error: ${error.message}`);
      }
    }

    console.log('✅ Database seeding completed!');
    console.log('📊 Results:', results);

    res.json({
      success: true,
      message: 'Database seeded successfully',
      data: results
    });

  } catch (error) {
    console.error('❌ Database seeding failed:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to seed database',
      error: error.message
    });
  }
});

// Clear seeded data (for testing)
router.post('/clear-seeded-data', auth, async (req, res) => {
  try {
    console.log('🧹 Clearing seeded data...');
    const db = admin.firestore();
    
    let results = {
      letters: 0,
      assignments: 0,
      attendance: 0,
      errors: []
    };

    // Clear letters with seeded employee IDs
    const lettersQuery = await db.collection('letters')
      .where('senderEmployeeId', 'in', ['EMP001', 'EMP002', 'EMP003', 'EMP004', 'EMP005'])
      .get();
    
    for (const doc of lettersQuery.docs) {
      await doc.ref.delete();
      results.letters++;
    }

    // Clear assignments created in the last hour (likely seeded)
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const assignmentsQuery = await db.collection('assignments')
      .where('createdAt', '>', admin.firestore.Timestamp.fromDate(oneHourAgo))
      .get();
    
    for (const doc of assignmentsQuery.docs) {
      await doc.ref.delete();
      results.assignments++;
    }

    // Clear attendance records for test employee
    const attendanceQuery = await db.collection('attendance')
      .where('employeeId', '==', 'EMP001')
      .get();
    
    for (const doc of attendanceQuery.docs) {
      await doc.ref.delete();
      results.attendance++;
    }

    console.log('✅ Seeded data cleared!');
    console.log('📊 Cleared:', results);

    res.json({
      success: true,
      message: 'Seeded data cleared successfully',
      data: results
    });

  } catch (error) {
    console.error('❌ Failed to clear seeded data:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to clear seeded data',
      error: error.message
    });
  }
});

module.exports = router;