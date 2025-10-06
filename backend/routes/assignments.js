const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const auth = require('../middleware/auth');

// Simple test endpoint without auth
router.get('/test', async (req, res) => {
  try {
    res.json({
      success: true,
      message: 'Assignments endpoint is working',
      data: {
        timestamp: new Date().toISOString(),
        endpoint: '/api/assignments/test'
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Test endpoint error',
      error: error.message
    });
  }
});

// Debug endpoint to check auth middleware
router.get('/auth-test', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      message: 'Auth test successful',
      data: {
        userId: req.user.userId,
        role: req.user.role,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Auth test error',
      error: error.message
    });
  }
});

// Get upcoming assignments for a user
router.get('/upcoming', auth, async (req, res) => {
  try {
    console.log('📅 Upcoming assignments request received');
    console.log('👤 User ID from token:', req.user.userId);
    
    const userId = req.user.userId;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID not found in token'
      });
    }
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    console.log('📅 Looking for assignments after:', today);
    
    // Simplified query without complex filtering - get all assignments for user
    const assignmentsSnapshot = await db.collection('assignments')
      .where('assignedTo', 'array-contains', userId)
      .get();

    console.log(`📋 Found ${assignmentsSnapshot.docs.length} total assignments for user`);

    const assignments = [];
    const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
    
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      
      // Filter upcoming assignments in JavaScript
      if (data.dueDate && data.dueDate >= todayTimestamp) {
        assignments.push({
          id: doc.id,
          title: data.title,
          description: data.description || '',
          dueDate: data.dueDate.toDate(),
          priority: data.priority || 'medium',
          status: data.status || 'pending',
          createdBy: data.createdBy,
          createdAt: data.createdAt ? data.createdAt.toDate() : null
        });
      }
    });

    // Sort by due date and limit to 10
    assignments.sort((a, b) => a.dueDate - b.dueDate);
    const limitedAssignments = assignments.slice(0, 10);

    console.log(`✅ Returning ${limitedAssignments.length} upcoming assignments`);

    res.json({
      success: true,
      message: 'Upcoming assignments retrieved successfully',
      data: {
        assignments: limitedAssignments,
        count: limitedAssignments.length
      }
    });

  } catch (error) {
    console.error('❌ Error fetching upcoming assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching upcoming assignments',
      error: error.message
    });
  }
});

// Get all assignments for a user (with pagination)
router.get('/', auth, async (req, res) => {
  try {
    const userId = req.user.uid;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const status = req.query.status; // 'pending', 'completed', 'overdue'
    
    let query = db.collection('assignments')
      .where('assignedTo', 'array-contains', userId);
    
    if (status) {
      query = query.where('status', '==', status);
    }
    
    const assignmentsSnapshot = await query
      .orderBy('dueDate', 'desc')
      .limit(limit)
      .get();

    const assignments = [];
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      assignments.push({
        id: doc.id,
        title: data.title,
        description: data.description,
        dueDate: data.dueDate.toDate(),
        priority: data.priority || 'medium',
        status: data.status || 'pending',
        createdBy: data.createdBy,
        createdAt: data.createdAt ? data.createdAt.toDate() : null
      });
    });

    res.json({
      success: true,
      data: assignments,
      pagination: {
        page,
        limit,
        total: assignments.length
      }
    });

  } catch (error) {
    console.error('Error fetching assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching assignments',
      error: error.message
    });
  }
});

// Create sample assignments (for testing)
router.post('/seed', auth, async (req, res) => {
  try {
    const userId = req.user.uid;
    const today = new Date();
    
    const sampleAssignments = [
      {
        title: 'Team Meeting',
        description: 'Weekly team sync meeting',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 2 * 60 * 60 * 1000)), // 2 hours from now
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Project Report',
        description: 'Submit monthly project report',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 24 * 60 * 60 * 1000)), // tomorrow
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Code Review',
        description: 'Review pull requests from team members',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000)), // 3 days from now
        assignedTo: [userId],
        priority: 'low',
        status: 'pending',
        createdBy: 'admin',
        createdAt: admin.firestore.Timestamp.now()
      }
    ];

    const batch = db.batch();
    sampleAssignments.forEach(assignment => {
      const docRef = db.collection('assignments').doc();
      batch.set(docRef, assignment);
    });

    await batch.commit();

    res.json({
      success: true,
      message: 'Sample assignments created successfully',
      count: sampleAssignments.length
    });

  } catch (error) {
    console.error('Error creating sample assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating sample assignments',
      error: error.message
    });
  }
});

module.exports = router;