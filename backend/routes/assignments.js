const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const db = admin.firestore();
const auth = require('../middleware/auth');
const requireAdminRole = require('../middleware/requireAdminRole');

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
    
    // For admin users, get all assignments. For regular users, get only assigned ones
    let query = db.collection('assignments');
    
    if (req.user.role !== 'super_admin' && req.user.role !== 'admin') {
      query = query.where('assignedTo', 'array-contains', userId);
    }
    
    const assignmentsSnapshot = await query.get();

    console.log(`📋 Found ${assignmentsSnapshot.docs.length} total assignments`);

    const assignments = [];
    
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      
      // Filter upcoming assignments in JavaScript
      const dueDate = data.dueDate ? (data.dueDate.toDate ? data.dueDate.toDate() : new Date(data.dueDate)) : new Date();
      
      if (dueDate >= today) {
        const assignmentData = {
          id: doc.id,
          title: data.title || '',
          description: data.description || '',
          dueDate: dueDate,
          priority: data.priority || 'medium',
          status: data.status || 'pending',
          assignedTo: data.assignedTo || [],
          assignedBy: data.assignedBy || '',
          createdBy: data.createdBy || '',
          createdAt: data.createdAt ? (data.createdAt.toDate ? data.createdAt.toDate() : new Date(data.createdAt)) : new Date(),
          updatedAt: data.updatedAt ? (data.updatedAt.toDate ? data.updatedAt.toDate() : new Date(data.updatedAt)) : null,
          startDate: data.startDate ? (data.startDate.toDate ? data.startDate.toDate() : new Date(data.startDate)) : null,
          tags: data.tags || [],
          category: data.category || '',
          attachments: data.attachments || [],
          // ALWAYS include completion data (null if not completed)
          completionTime: data.completionTime || null,
          completionDate: data.completionDate || null,
          completedAt: data.completedAt ? (data.completedAt.toDate ? data.completedAt.toDate() : new Date(data.completedAt)) : null,
          completedBy: data.completedBy || null,
        };
        
        assignments.push(assignmentData);
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
    const userId = req.user.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const status = req.query.status; // 'pending', 'completed', 'overdue'
    
    console.log('📋 All assignments request for user:', userId);
    
    let query = db.collection('assignments');
    
    // If not admin, filter by assignedTo
    if (req.user.role !== 'super_admin' && req.user.role !== 'admin') {
      query = query.where('assignedTo', 'array-contains', userId);
    }
    
    if (status && status !== 'all') {
      query = query.where('status', '==', status);
    }
    
    const assignmentsSnapshot = await query.get();

    console.log(`📋 Found ${assignmentsSnapshot.docs.length} total assignments`);

    const assignments = [];
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      assignments.push({
        id: doc.id,
        title: data.title || '',
        description: data.description || '',
        dueDate: data.dueDate ? (data.dueDate.toDate ? data.dueDate.toDate() : new Date(data.dueDate)) : new Date(),
        priority: data.priority || 'medium',
        status: data.status || 'pending',
        assignedTo: data.assignedTo || [],
        assignedBy: data.assignedBy || '',
        createdBy: data.createdBy || '',
        createdAt: data.createdAt ? (data.createdAt.toDate ? data.createdAt.toDate() : new Date(data.createdAt)) : new Date(),
        updatedAt: data.updatedAt ? (data.updatedAt.toDate ? data.updatedAt.toDate() : new Date(data.updatedAt)) : null
      });
    });

    // Sort by due date
    assignments.sort((a, b) => new Date(a.dueDate) - new Date(b.dueDate));

    res.json({
      success: true,
      message: 'Assignments retrieved successfully',
      data: {
        assignments: assignments,
        count: assignments.length,
        page: page,
        limit: limit
      }
    });

  } catch (error) {
    console.error('❌ Error fetching assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching assignments',
      error: error.message
    });
  }
});

// Create comprehensive dummy assignments (for testing)
router.post('/seed', auth, async (req, res) => {
  try {
    const userId = req.user.userId;
    const today = new Date();
    
    const sampleAssignments = [
      // Today's assignments
      {
        title: 'Morning Stand-up Meeting',
        description: 'Daily team synchronization meeting to discuss progress, blockers, and daily goals',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 1 * 60 * 60 * 1000)), // 1 hour from now
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Code Review - Payment Module',
        description: 'Review and approve pull requests for the new payment gateway integration',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 4 * 60 * 60 * 1000)), // 4 hours from now
        assignedTo: [userId],
        priority: 'high',
        status: 'in-progress',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Client Presentation Preparation',
        description: 'Prepare slides and demo for tomorrow\'s client presentation on Q4 features',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 6 * 60 * 60 * 1000)), // 6 hours from now
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },

      // Tomorrow's assignments
      {
        title: 'Monthly Financial Report',
        description: 'Compile and submit comprehensive financial report for October 2025',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 24 * 60 * 60 * 1000)), // tomorrow
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Security Audit Review',
        description: 'Review and validate security audit findings and create action plan',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 26 * 60 * 60 * 1000)), // tomorrow afternoon
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },

      // This week assignments
      {
        title: 'Database Optimization',
        description: 'Optimize database queries and implement indexing for better performance',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 3 * 24 * 60 * 60 * 1000)), // 3 days from now
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Employee Training Session',
        description: 'Conduct training session on new system features for HR department',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 4 * 24 * 60 * 60 * 1000)), // 4 days from now
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'API Documentation Update',
        description: 'Update API documentation with latest endpoints and authentication methods',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 5 * 24 * 60 * 60 * 1000)), // 5 days from now
        assignedTo: [userId],
        priority: 'low',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },

      // Next week assignments
      {
        title: 'System Backup & Recovery Test',
        description: 'Perform comprehensive system backup and test recovery procedures',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)), // 1 week from now
        assignedTo: [userId],
        priority: 'high',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        title: 'Quarterly Review Meeting',
        description: 'Attend quarterly business review meeting with stakeholders and management',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() + 10 * 24 * 60 * 60 * 1000)), // 10 days from now
        assignedTo: [userId],
        priority: 'medium',
        status: 'pending',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },

      // Overdue assignments (for testing)
      {
        title: 'System Performance Analysis',
        description: 'Analyze system performance metrics and create optimization recommendations',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() - 2 * 24 * 60 * 60 * 1000)), // 2 days ago (overdue)
        assignedTo: [userId],
        priority: 'medium',
        status: 'overdue',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.fromDate(new Date(today.getTime() - 5 * 24 * 60 * 60 * 1000)),
        updatedAt: admin.firestore.Timestamp.now()
      },

      // Completed assignments
      {
        title: 'Weekly Team Retrospective',
        description: 'Facilitate weekly retrospective meeting to discuss improvements and feedback',
        dueDate: admin.firestore.Timestamp.fromDate(new Date(today.getTime() - 1 * 24 * 60 * 60 * 1000)), // yesterday
        assignedTo: [userId],
        priority: 'low',
        status: 'completed',
        createdBy: req.user.userId,
        assignedBy: req.user.userId,
        createdAt: admin.firestore.Timestamp.fromDate(new Date(today.getTime() - 3 * 24 * 60 * 60 * 1000)),
        updatedAt: admin.firestore.Timestamp.now()
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
      message: 'Comprehensive dummy assignments created successfully',
      data: {
        count: sampleAssignments.length,
        summary: {
          today: sampleAssignments.filter(a => {
            const assignmentDate = a.dueDate.toDate();
            return assignmentDate.toDateString() === today.toDateString();
          }).length,
          thisWeek: sampleAssignments.filter(a => {
            const assignmentDate = a.dueDate.toDate();
            const weekFromNow = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);
            return assignmentDate >= today && assignmentDate <= weekFromNow;
          }).length,
          overdue: sampleAssignments.filter(a => a.status === 'overdue').length,
          completed: sampleAssignments.filter(a => a.status === 'completed').length
        },
        assignments: sampleAssignments.map(a => ({
          title: a.title,
          dueDate: a.dueDate.toDate(),
          priority: a.priority,
          status: a.status
        }))
      }
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

// ==================== NEW ENHANCED ASSIGNMENTS FEATURES FOR ADMIN DASHBOARD ====================

// Create new assignment (Admin/Manager only)
router.post('/', auth, async (req, res) => {
  try {
    // Check if user has permission to create assignments
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin' || req.user.role === 'account_officer';
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin or manager privileges required.'
      });
    }

    const {
      title,
      description,
      assignedTo, // Array of user IDs
      dueDate,
      priority = 'medium',
      category,
      tags = [],
      attachments = []
    } = req.body;

    // Validate required fields
    if (!title || !description || !assignedTo || !dueDate) {
      return res.status(400).json({
        success: false,
        message: 'Title, description, assignedTo, and dueDate are required'
      });
    }

    if (!Array.isArray(assignedTo) || assignedTo.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'assignedTo must be a non-empty array of user IDs'
      });
    }

    // Validate due date
    if (new Date(dueDate) <= new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Due date must be in the future'
      });
    }

    // Verify assigned users exist
    const userPromises = assignedTo.map(userId => db.collection('users').doc(userId).get());
    const userDocs = await Promise.all(userPromises);
    
    const validUsers = [];
    for (let i = 0; i < userDocs.length; i++) {
      if (userDocs[i].exists) {
        validUsers.push({
          id: assignedTo[i],
          name: userDocs[i].data().full_name,
          email: userDocs[i].data().email
        });
      }
    }

    if (validUsers.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid users found in assignedTo array'
      });
    }

    const assignmentData = {
      title,
      description,
      assignedTo, // Array of user IDs
      assignedToNames: validUsers.map(u => u.name), // Array of user names for display
      assignedBy: req.user.userId,
      createdBy: req.user.userId,
      dueDate: admin.firestore.Timestamp.fromDate(new Date(dueDate)),
      priority,
      category: category || 'general',
      tags,
      attachments,
      status: 'pending',
      progress: 0,
      comments: [],
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    };

    const docRef = await db.collection('assignments').add(assignmentData);

    // Create notifications for assigned users
    const notificationPromises = validUsers.map(user => 
      db.collection('notifications').add({
        user_id: user.id,
        title: 'New Assignment',
        message: `You have been assigned a new task: ${title}`,
        type: 'assignment',
        reference_id: docRef.id,
        reference_type: 'assignment',
        is_read: false,
        priority: priority,
        created_at: admin.firestore.Timestamp.now()
      })
    );

    await Promise.all(notificationPromises);

    res.status(201).json({
      success: true,
      message: 'Assignment created successfully',
      data: {
        id: docRef.id,
        ...assignmentData,
        assigned_users: validUsers
      }
    });

  } catch (error) {
    console.error('Create assignment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create assignment'
    });
  }
});

// Update assignment (Admin/Assignee)
router.put('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const assignmentRef = db.collection('assignments').doc(id);
    const assignmentDoc = await assignmentRef.get();

    if (!assignmentDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Assignment not found'
      });
    }

    const assignmentData = assignmentDoc.data();
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin' || req.user.role === 'account_officer';
    const isAssignee = assignmentData.assignedTo && assignmentData.assignedTo.includes(req.user.userId);
    const isCreator = assignmentData.createdBy === req.user.userId;

    if (!isAdmin && !isAssignee && !isCreator) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only update assignments you created or are assigned to.'
      });
    }

    const {
      title,
      description,
      dueDate,
      priority,
      status,
      progress,
      category,
      tags,
      attachments
    } = req.body;

    const updateData = {
      updatedAt: admin.firestore.Timestamp.now(),
      updatedBy: req.user.userId
    };

    // Only admin/creator can update these fields
    if (isAdmin || isCreator) {
      if (title !== undefined) updateData.title = title;
      if (description !== undefined) updateData.description = description;
      if (dueDate !== undefined) updateData.dueDate = admin.firestore.Timestamp.fromDate(new Date(dueDate));
      if (priority !== undefined) updateData.priority = priority;
      if (category !== undefined) updateData.category = category;
      if (tags !== undefined) updateData.tags = tags;
      if (attachments !== undefined) updateData.attachments = attachments;
    }

    // Assignees can update status and progress
    if (status !== undefined && ['pending', 'in-progress', 'completed', 'on-hold'].includes(status)) {
      updateData.status = status;
      
      if (status === 'completed') {
        updateData.completedAt = admin.firestore.Timestamp.now();
        updateData.completedBy = req.user.userId;
        
        // Store completion date and time from request if provided
        if (req.body.completionDate) {
          updateData.completionDate = req.body.completionDate;
        }
        if (req.body.completionTime) {
          updateData.completionTime = req.body.completionTime;
        }
      }
    }

    if (progress !== undefined && progress >= 0 && progress <= 100) {
      updateData.progress = progress;
    }

    await assignmentRef.update(updateData);

    // Create notification if status changed to completed
    if (status === 'completed' && assignmentData.createdBy !== req.user.userId) {
      try {
        await db.collection('notifications').add({
          user_id: assignmentData.createdBy,
          title: 'Assignment Completed',
          message: `${assignmentData.title} has been marked as completed`,
          type: 'assignment_update',
          reference_id: id,
          reference_type: 'assignment',
          is_read: false,
          priority: 'normal',
          created_at: admin.firestore.Timestamp.now()
        });
      } catch (notifError) {
        console.error('Failed to create completion notification:', notifError);
      }
    }

    res.json({
      success: true,
      message: 'Assignment updated successfully'
    });

  } catch (error) {
    console.error('Update assignment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update assignment'
    });
  }
});

// Delete assignment (Admin/Creator only)
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const assignmentRef = db.collection('assignments').doc(id);
    const assignmentDoc = await assignmentRef.get();

    if (!assignmentDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Assignment not found'
      });
    }

    const assignmentData = assignmentDoc.data();
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';
    const isCreator = assignmentData.createdBy === req.user.userId;

    if (!isAdmin && !isCreator) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Only admins or assignment creators can delete assignments.'
      });
    }

    await assignmentRef.delete();

    res.json({
      success: true,
      message: 'Assignment deleted successfully'
    });

  } catch (error) {
    console.error('Delete assignment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete assignment'
    });
  }
});

// Add comment to assignment
router.post('/:id/comments', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { comment } = req.body;

    if (!comment || comment.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Comment is required'
      });
    }

    const assignmentRef = db.collection('assignments').doc(id);
    const assignmentDoc = await assignmentRef.get();

    if (!assignmentDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Assignment not found'
      });
    }

    const assignmentData = assignmentDoc.data();
    const isAssignee = assignmentData.assignedTo && assignmentData.assignedTo.includes(req.user.userId);
    const isCreator = assignmentData.createdBy === req.user.userId;
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';

    if (!isAssignee && !isCreator && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only comment on assignments you are involved with.'
      });
    }

    // Get user details
    const userDoc = await db.collection('users').doc(req.user.userId).get();
    const userData = userDoc.exists ? userDoc.data() : {};

    const newComment = {
      id: `comment_${Date.now()}`,
      user_id: req.user.userId,
      user_name: userData.full_name || 'Unknown User',
      comment: comment.trim(),
      created_at: admin.firestore.Timestamp.now()
    };

    const currentComments = assignmentData.comments || [];
    currentComments.push(newComment);

    await assignmentRef.update({
      comments: currentComments,
      updatedAt: admin.firestore.Timestamp.now()
    });

    // Create notification for other participants
    const notificationRecipients = new Set();
    if (assignmentData.createdBy !== req.user.userId) {
      notificationRecipients.add(assignmentData.createdBy);
    }
    if (assignmentData.assignedTo) {
      assignmentData.assignedTo.forEach(userId => {
        if (userId !== req.user.userId) {
          notificationRecipients.add(userId);
        }
      });
    }

    const notificationPromises = Array.from(notificationRecipients).map(userId =>
      db.collection('notifications').add({
        user_id: userId,
        title: 'New Comment on Assignment',
        message: `${userData.full_name} commented on "${assignmentData.title}"`,
        type: 'assignment_comment',
        reference_id: id,
        reference_type: 'assignment',
        is_read: false,
        priority: 'normal',
        created_at: admin.firestore.Timestamp.now()
      })
    );

    await Promise.all(notificationPromises);

    res.json({
      success: true,
      message: 'Comment added successfully',
      data: { comment: newComment }
    });

  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add comment'
    });
  }
});

// Get assignment details
router.get('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const assignmentDoc = await db.collection('assignments').doc(id).get();

    if (!assignmentDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Assignment not found'
      });
    }

    const assignmentData = { id, ...assignmentDoc.data() };
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';
    const isAssignee = assignmentData.assignedTo && assignmentData.assignedTo.includes(req.user.userId);
    const isCreator = assignmentData.createdBy === req.user.userId;

    if (!isAdmin && !isAssignee && !isCreator) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only view assignments you are involved with.'
      });
    }

    // Get creator details
    if (assignmentData.createdBy) {
      try {
        const creatorDoc = await db.collection('users').doc(assignmentData.createdBy).get();
        if (creatorDoc.exists) {
          const creatorData = creatorDoc.data();
          assignmentData.creator = {
            id: assignmentData.createdBy,
            name: creatorData.full_name,
            email: creatorData.email
          };
        }
      } catch (error) {
        console.error('Error fetching creator details:', error);
      }
    }

    // Get assigned users details
    if (assignmentData.assignedTo && assignmentData.assignedTo.length > 0) {
      try {
        const userPromises = assignmentData.assignedTo.map(userId => 
          db.collection('users').doc(userId).get()
        );
        const userDocs = await Promise.all(userPromises);
        
        assignmentData.assigned_users = userDocs
          .filter(doc => doc.exists)
          .map(doc => ({
            id: doc.id,
            name: doc.data().full_name,
            email: doc.data().email,
            employee_id: doc.data().employee_id,
            department: doc.data().department
          }));
      } catch (error) {
        console.error('Error fetching assigned users details:', error);
      }
    }

    // Convert timestamps
    ['createdAt', 'updatedAt', 'dueDate', 'completedAt'].forEach(field => {
      if (assignmentData[field] && typeof assignmentData[field].toDate === 'function') {
        assignmentData[field] = assignmentData[field].toDate();
      }
    });

    // Convert comment timestamps
    if (assignmentData.comments) {
      assignmentData.comments.forEach(comment => {
        if (comment.created_at && typeof comment.created_at.toDate === 'function') {
          comment.created_at = comment.created_at.toDate();
        }
      });
    }

    res.json({
      success: true,
      data: { assignment: assignmentData }
    });

  } catch (error) {
    console.error('Get assignment details error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get assignment details'
    });
  }
});

// Get assignments analytics for admin dashboard
router.get('/admin/analytics', auth, async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin' || req.user.role === 'account_officer';
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const { period = 'month' } = req.query;
    const assignmentsSnapshot = await db.collection('assignments').get();

    const analytics = {
      total_assignments: 0,
      by_status: {
        pending: 0,
        'in-progress': 0,
        completed: 0,
        overdue: 0,
        'on-hold': 0
      },
      by_priority: {
        low: 0,
        medium: 0,
        high: 0,
        urgent: 0
      },
      by_category: {},
      completion_rate: 0,
      overdue_rate: 0,
      average_completion_time: 0,
      user_performance: {}
    };

    const now = new Date();
    const completedAssignments = [];
    const overdueAssignments = [];

    assignmentsSnapshot.forEach(doc => {
      const assignment = doc.data();
      analytics.total_assignments++;

      // Status breakdown
      let status = assignment.status || 'pending';
      
      // Check if overdue
      const dueDate = assignment.dueDate?.toDate();
      if (dueDate && dueDate < now && status !== 'completed') {
        status = 'overdue';
        overdueAssignments.push(assignment);
      }

      if (analytics.by_status[status] !== undefined) {
        analytics.by_status[status]++;
      }

      // Priority breakdown
      const priority = assignment.priority || 'medium';
      analytics.by_priority[priority]++;

      // Category breakdown
      const category = assignment.category || 'general';
      analytics.by_category[category] = (analytics.by_category[category] || 0) + 1;

      // Completion analysis
      if (assignment.status === 'completed') {
        completedAssignments.push(assignment);
        
        // Calculate completion time
        if (assignment.createdAt && assignment.completedAt) {
          const createdDate = assignment.createdAt.toDate();
          const completedDate = assignment.completedAt.toDate();
          const completionTime = (completedDate - createdDate) / (1000 * 60 * 60 * 24); // days
          completedAssignments[completedAssignments.length - 1].completion_time = completionTime;
        }
      }

      // User performance tracking
      if (assignment.assignedTo) {
        assignment.assignedTo.forEach(userId => {
          if (!analytics.user_performance[userId]) {
            analytics.user_performance[userId] = {
              total_assigned: 0,
              completed: 0,
              overdue: 0,
              completion_rate: 0
            };
          }
          
          analytics.user_performance[userId].total_assigned++;
          
          if (assignment.status === 'completed') {
            analytics.user_performance[userId].completed++;
          }
          
          if (status === 'overdue') {
            analytics.user_performance[userId].overdue++;
          }
          
          analytics.user_performance[userId].completion_rate = 
            (analytics.user_performance[userId].completed / analytics.user_performance[userId].total_assigned * 100).toFixed(2);
        });
      }
    });

    // Calculate rates
    if (analytics.total_assignments > 0) {
      analytics.completion_rate = (analytics.by_status.completed / analytics.total_assignments * 100).toFixed(2);
      analytics.overdue_rate = (analytics.by_status.overdue / analytics.total_assignments * 100).toFixed(2);
    }

    // Calculate average completion time
    if (completedAssignments.length > 0) {
      const totalTime = completedAssignments
        .filter(a => a.completion_time)
        .reduce((sum, a) => sum + a.completion_time, 0);
      
      analytics.average_completion_time = (totalTime / completedAssignments.length).toFixed(2);
    }

    res.json({
      success: true,
      data: { analytics }
    });

  } catch (error) {
    console.error('Get assignments analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get assignments analytics'
    });
  }
});

// Get assignments dashboard summary (Admin only)
router.get('/admin/dashboard-summary', auth, async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin' || req.user.role === 'account_officer';
    if (!isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required.'
      });
    }

    const assignmentsSnapshot = await db.collection('assignments').get();
    const now = new Date();
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const summary = {
      total_assignments: 0,
      active_assignments: 0,
      completed_today: 0,
      due_today: 0,
      overdue: 0,
      high_priority: 0,
      recent_activities: []
    };

    const recentActivities = [];

    assignmentsSnapshot.forEach(doc => {
      const assignment = { id: doc.id, ...doc.data() };
      summary.total_assignments++;

      const dueDate = assignment.dueDate?.toDate();
      const createdDate = assignment.createdAt?.toDate();
      const completedDate = assignment.completedAt?.toDate();

      // Count active (not completed)
      if (assignment.status !== 'completed') {
        summary.active_assignments++;
      }

      // Count completed today
      if (completedDate && completedDate >= today && completedDate < tomorrow) {
        summary.completed_today++;
      }

      // Count due today
      if (dueDate && dueDate >= today && dueDate < tomorrow && assignment.status !== 'completed') {
        summary.due_today++;
      }

      // Count overdue
      if (dueDate && dueDate < now && assignment.status !== 'completed') {
        summary.overdue++;
      }

      // Count high priority
      if (assignment.priority === 'high' || assignment.priority === 'urgent') {
        summary.high_priority++;
      }

      // Recent activities
      recentActivities.push({
        id: assignment.id,
        title: assignment.title,
        status: assignment.status,
        priority: assignment.priority,
        due_date: dueDate,
        created_at: createdDate,
        updated_at: assignment.updatedAt?.toDate()
      });
    });

    // Sort and limit recent activities
    summary.recent_activities = recentActivities
      .sort((a, b) => (b.updated_at || b.created_at || new Date(0)) - (a.updated_at || a.created_at || new Date(0)))
      .slice(0, 10);

    res.json({
      success: true,
      data: { summary }
    });

  } catch (error) {
    console.error('Get assignments dashboard summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get assignments dashboard summary'
    });
  }
});

// ==================== ADMIN DASHBOARD ENDPOINTS ====================

// Admin dashboard summary for assignments
router.get('/admin/dashboard/summary', auth, requireAdminRole, async (req, res) => {
  try {
    const assignmentsSnapshot = await db.collection('assignments').get();
    const assignments = [];
    
    assignmentsSnapshot.forEach(doc => {
      const data = doc.data();
      try {
        assignments.push({
          id: doc.id,
          title: data.title || 'No Title',
          status: data.status || 'pending',
          priority: data.priority || 'medium',
          assignedTo: data.assignedTo || null,
          dueDate: data.dueDate ? (data.dueDate.toDate ? data.dueDate.toDate() : new Date(data.dueDate)) : null,
          created_at: data.created_at ? (data.created_at.toDate ? data.created_at.toDate() : new Date(data.created_at)) : null
        });
      } catch (itemError) {
        console.error('Error processing assignment:', doc.id, itemError);
        // Add basic data without timestamp processing
        assignments.push({
          id: doc.id,
          title: data.title || 'No Title',
          status: data.status || 'pending',
          priority: data.priority || 'medium',
          assignedTo: data.assignedTo || null,
          dueDate: null,
          created_at: null
        });
      }
    });

    const now = new Date();
    
    const summary = {
      total_assignments: assignments.length,
      pending: assignments.filter(a => a.status === 'pending').length,
      in_progress: assignments.filter(a => a.status === 'in-progress' || a.status === 'in_progress').length,
      completed: assignments.filter(a => a.status === 'completed').length,
      overdue: assignments.filter(a => {
        if (!a.dueDate || a.status === 'completed') return false;
        return a.dueDate < now;
      }).length,
      completion_rate: 0
    };

    if (summary.total_assignments > 0) {
      summary.completion_rate = Math.round((summary.completed / summary.total_assignments) * 100);
    }

    // Count by priority
    const by_priority = {};
    assignments.forEach(assignment => {
      const priority = assignment.priority || 'medium';
      by_priority[priority] = (by_priority[priority] || 0) + 1;
    });

    // Recent assignments - filter out null created_at first
    const recent_assignments = assignments
      .filter(a => a.created_at !== null)
      .sort((a, b) => {
        const aTime = a.created_at || new Date(0);
        const bTime = b.created_at || new Date(0);
        return bTime - aTime;
      })
      .slice(0, 10)
      .map(assignment => ({
        id: assignment.id,
        title: assignment.title,
        assignedTo: assignment.assignedTo,
        status: assignment.status,
        priority: assignment.priority,
        dueDate: assignment.dueDate,
        created_at: assignment.created_at
      }));

    res.json({
      success: true,
      message: 'Assignments dashboard summary retrieved successfully',
      data: {
        summary,
        by_priority,
        recent_assignments
      }
    });

  } catch (error) {
    console.error('Error fetching assignments dashboard summary:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching assignments dashboard summary',
      error: error.message
    });
  }
});

// Get all assignments for admin
router.get('/admin/all', auth, requireAdminRole, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      priority,
      assigned_to,
      search,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;

    let query = db.collection('assignments');

    // Apply filters
    if (status && status !== 'all') {
      query = query.where('status', '==', status);
    }
    if (priority && priority !== 'all') {
      query = query.where('priority', '==', priority);
    }

    const snapshot = await query.get();
    let assignments = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      try {
        assignments.push({
          id: doc.id,
          title: data.title || 'No Title',
          description: data.description || '',
          status: data.status || 'pending',
          priority: data.priority || 'medium',
          assignedTo: data.assignedTo || null,
          dueDate: data.dueDate ? (data.dueDate.toDate ? data.dueDate.toDate() : new Date(data.dueDate)) : null,
          created_at: data.created_at ? (data.created_at.toDate ? data.created_at.toDate() : new Date(data.created_at)) : null,
          updated_at: data.updated_at ? (data.updated_at.toDate ? data.updated_at.toDate() : new Date(data.updated_at)) : null
        });
      } catch (itemError) {
        console.error('Error processing assignment:', doc.id, itemError);
        // Add basic data without timestamp processing
        assignments.push({
          id: doc.id,
          title: data.title || 'No Title',
          description: data.description || '',
          status: data.status || 'pending',
          priority: data.priority || 'medium',
          assignedTo: data.assignedTo || null,
          dueDate: null,
          created_at: null,
          updated_at: null
        });
      }
    });

    // Apply search filter
    if (search) {
      const searchLower = search.toLowerCase();
      assignments = assignments.filter(assignment =>
        assignment.title?.toLowerCase().includes(searchLower) ||
        assignment.description?.toLowerCase().includes(searchLower)
      );
    }

    // Apply assigned_to filter
    if (assigned_to && assigned_to !== 'all') {
      assignments = assignments.filter(assignment => {
        if (Array.isArray(assignment.assignedTo)) {
          return assignment.assignedTo.includes(assigned_to);
        }
        return assignment.assignedTo === assigned_to;
      });
    }

    // Apply sorting
    assignments.sort((a, b) => {
      let aValue = a[sort_by];
      let bValue = b[sort_by];
      
      if (aValue instanceof Date && bValue instanceof Date) {
        return sort_order === 'desc' ? bValue - aValue : aValue - bValue;
      }
      
      if (typeof aValue === 'string' && typeof bValue === 'string') {
        const comparison = aValue.localeCompare(bValue);
        return sort_order === 'desc' ? -comparison : comparison;
      }
      
      return 0;
    });

    // Apply pagination
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedAssignments = assignments.slice(startIndex, endIndex);

    // Get user details for assigned users
    const userIds = new Set();
    paginatedAssignments.forEach(assignment => {
      if (Array.isArray(assignment.assignedTo)) {
        assignment.assignedTo.forEach(id => userIds.add(id));
      } else if (assignment.assignedTo) {
        userIds.add(assignment.assignedTo);
      }
    });

    const userDetails = {};
    if (userIds.size > 0) {
      try {
        // Filter out any null, undefined, or empty string values
        const validUserIds = Array.from(userIds).filter(id => id && typeof id === 'string' && id.trim() !== '');
        
        if (validUserIds.length > 0) {
          // Batch query in chunks if too many IDs (Firestore limit is 10)
          const chunks = [];
          for (let i = 0; i < validUserIds.length; i += 10) {
            chunks.push(validUserIds.slice(i, i + 10));
          }
          
          for (const chunk of chunks) {
            const usersSnapshot = await db.collection('users').where(admin.firestore.FieldPath.documentId(), 'in', chunk).get();
            usersSnapshot.forEach(doc => {
              const userData = doc.data();
              userDetails[doc.id] = {
                full_name: userData.full_name || userData.name || 'Unknown',
                employee_id: userData.employee_id || 'N/A'
              };
            });
          }
        }
      } catch (userError) {
        console.error('Error fetching user details:', userError);
        // Continue without user details
      }
    }

    // Add user details to assignments
    paginatedAssignments.forEach(assignment => {
      if (Array.isArray(assignment.assignedTo)) {
        assignment.assigned_users = assignment.assignedTo.map(id => ({
          id,
          ...userDetails[id]
        }));
      } else if (assignment.assignedTo && userDetails[assignment.assignedTo]) {
        assignment.assigned_users = [{
          id: assignment.assignedTo,
          ...userDetails[assignment.assignedTo]
        }];
      }
    });

    res.json({
      success: true,
      message: 'All assignments retrieved successfully',
      data: {
        assignments: paginatedAssignments,
        pagination: {
          current_page: parseInt(page),
          per_page: parseInt(limit),
          total_items: assignments.length,
          total_pages: Math.ceil(assignments.length / limit),
          has_next: endIndex < assignments.length,
          has_prev: page > 1
        },
        filters_applied: { status, priority, assigned_to, search }
      }
    });

  } catch (error) {
    console.error('Error fetching all assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching all assignments',
      error: error.message
    });
  }
});

// Create new assignment (Admin)
router.post('/admin/create', auth, requireAdminRole, async (req, res) => {
  try {
    const {
      title,
      description,
      assignedTo, // Array of user IDs
      dueDate,
      priority = 'medium',
      category
    } = req.body;

    if (!title || !description || !assignedTo || !dueDate) {
      return res.status(400).json({
        success: false,
        message: 'Title, description, assignedTo, and dueDate are required'
      });
    }

    const assignmentData = {
      title,
      description,
      assignedTo: Array.isArray(assignedTo) ? assignedTo : [assignedTo],
      dueDate: admin.firestore.Timestamp.fromDate(new Date(dueDate)),
      priority,
      category: category || null,
      status: 'pending',
      progress: 0,
      created_by: req.user.userId,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };

    const docRef = await db.collection('assignments').add(assignmentData);

    res.status(201).json({
      success: true,
      message: 'Assignment created successfully',
      data: {
        id: docRef.id,
        ...assignmentData
      }
    });

  } catch (error) {
    console.error('Error creating assignment:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating assignment',
      error: error.message
    });
  }
});

module.exports = router;