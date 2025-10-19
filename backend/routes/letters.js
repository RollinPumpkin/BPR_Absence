const express = require('express');
const moment = require('moment');
const { getFirestore, getServerTimestamp } = require('../config/database');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const requireAdminRole = require('../middleware/requireAdminRole');
const { validateLetter } = require('../middleware/validation');

const router = express.Router();
const db = getFirestore();

// ==================== LETTERS MANAGEMENT ENDPOINTS ====================

// Get letters with filtering and pagination
router.get('/', auth, async (req, res) => {
  try {
    const { 
      type, 
      status, 
      recipient_id,
      page = 1, 
      limit = 20,
      search,
      start_date,
      end_date,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;

    console.log('📋 Letters API called');
    console.log('👤 User info:', {
      userId: req.user.userId,
      role: req.user.role,
      employeeId: req.user.employeeId
    });

    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';
    let lettersRef = db.collection('letters');

    console.log('🔒 Is Admin:', isAdmin);

    // For admin users, get all letters
    // For regular users, filter by recipient_id
    if (!isAdmin) {
      console.log('👥 Filtering by recipient_id:', req.user.userId);
      lettersRef = lettersRef.where('recipient_id', '==', req.user.userId);
    } else {
      console.log('👑 Admin access - getting all letters');
    }

    // Simple ordering without complex where clauses for now
    lettersRef = lettersRef.orderBy('created_at', 'desc').limit(parseInt(limit));

    const snapshot = await lettersRef.get();
    const allLetters = [];
    
    // Get user details for each letter
    for (const doc of snapshot.docs) {
      const letterData = { id: doc.id, ...doc.data() };
      
      // Apply filters in memory for now (until indexes are ready)
      let includeRecord = true;
      
      if (type && letterData.letter_type !== type) includeRecord = false;
      if (status && letterData.status !== status) includeRecord = false;
      if (recipient_id && isAdmin && letterData.recipient_id !== recipient_id) includeRecord = false;
      if (start_date && letterData.created_at && letterData.created_at.toDate() < new Date(start_date)) includeRecord = false;
      if (end_date && letterData.created_at && letterData.created_at.toDate() > new Date(end_date)) includeRecord = false;
      
      if (!includeRecord) continue;
      
      // Get recipient details
      if (letterData.recipient_id) {
        try {
          const userDoc = await db.collection('users').doc(letterData.recipient_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            letterData.recipient_name = userData.full_name;
            letterData.recipient_employee_id = userData.employee_id;
            letterData.recipient_department = userData.department;
          }
        } catch (userError) {
          console.error('Error fetching recipient details:', userError);
        }
      }

      // Get sender details
      if (letterData.sender_id) {
        try {
          const senderDoc = await db.collection('users').doc(letterData.sender_id).get();
          if (senderDoc.exists) {
            const senderData = senderDoc.data();
            letterData.sender_name = senderData.full_name;
            letterData.sender_position = senderData.position;
          }
        } catch (senderError) {
          console.error('Error fetching sender details:', senderError);
        }
      }

      allLetters.push(letterData);
    }

    // Apply search filter if provided
    let filteredLetters = allLetters;
    if (search) {
      const searchTerm = search.toLowerCase();
      filteredLetters = allLetters.filter(letter => 
        letter.subject?.toLowerCase().includes(searchTerm) ||
        letter.letter_number?.toLowerCase().includes(searchTerm) ||
        letter.recipient_name?.toLowerCase().includes(searchTerm) ||
        letter.content?.toLowerCase().includes(searchTerm)
      );
    }

    // Get total count for pagination
    let totalQuery = db.collection('letters');
    if (!isAdmin) {
      totalQuery = totalQuery.where('recipient_id', '==', req.user.userId);
    }
    const totalSnapshot = await totalQuery.get();
    const totalRecords = totalSnapshot.size;

    res.json({
      success: true,
      data: {
        letters: filteredLetters,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(totalRecords / parseInt(limit)),
          total_records: totalRecords,
          limit: parseInt(limit),
          has_next_page: parseInt(page) < Math.ceil(totalRecords / parseInt(limit)),
          has_prev_page: parseInt(page) > 1
        },
        filters: {
          type,
          status,
          search,
          start_date,
          end_date,
          sort_by: 'created_at',
          sort_order: 'desc'
        }
      }
    });

  } catch (error) {
    console.error('Get letters error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letters'
    });
  }
});

// Get received letters (approved/rejected letters for current user)
router.get('/received', auth, async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 20,
      status,
      letter_type,
      priority,
      start_date,
      end_date,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;

    console.log('📨 Received Letters API called');
    console.log('👤 User info:', {
      userId: req.user.userId,
      role: req.user.role,
      employeeId: req.user.employeeId
    });

    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';
    let lettersRef = db.collection('letters');

    // For admin users, get all received letters
    // For regular users, filter by recipient_id
    if (!isAdmin) {
      console.log('👥 Filtering by recipient_id:', req.user.userId);
      lettersRef = lettersRef.where('recipient_id', '==', req.user.userId);
    } else {
      console.log('👑 Admin access - getting all received letters');
    }

    // Filter by status to only show received letters (approved/rejected/processed)
    // Use simple approach - get all and filter in memory for now
    
    // Apply additional filters first
    if (status) {
      lettersRef = lettersRef.where('status', '==', status);
    }
    
    if (letter_type) {
      lettersRef = lettersRef.where('type', '==', letter_type);
    }
    
    if (priority) {
      lettersRef = lettersRef.where('priority', '==', priority);
    }

    // Apply date filters
    if (start_date) {
      const startDate = new Date(start_date);
      lettersRef = lettersRef.where('created_at', '>=', startDate);
    }
    
    if (end_date) {
      const endDate = new Date(end_date);
      endDate.setHours(23, 59, 59, 999);
      lettersRef = lettersRef.where('created_at', '<=', endDate);
    }

    // Apply sorting
    lettersRef = lettersRef.orderBy(sort_by, sort_order);

    console.log('🔍 Executing received letters query...');
    const snapshot = await lettersRef.get();
    
    // Filter received letters in memory to avoid Firestore 'in' query limitations
    const receivedStatuses = ['approved', 'rejected', 'processed'];
    const allLetters = [];
    snapshot.forEach(doc => {
      const letterData = doc.data();
      if (receivedStatuses.includes(letterData.status)) {
        allLetters.push({
          id: doc.id,
          ...letterData
        });
      }
    });

    // Apply pagination to filtered results
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const letters = allLetters.slice(offset, offset + parseInt(limit));
    const total = allLetters.length;

    console.log(`📊 Found ${letters.length} received letters (total: ${total})`);

    res.json({
      success: true,
      data: {
        letters,
        pagination: {
          current_page: parseInt(page),
          per_page: parseInt(limit),
          total: total,
          last_page: Math.ceil(total / parseInt(limit))
        }
      }
    });
  } catch (error) {
    console.error('❌ Error getting received letters:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get received letters'
    });
  }
});

// Get letter statistics
router.get('/statistics', auth, async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';
    const { period = 'month' } = req.query;

    let startDate, endDate;
    
    switch (period) {
      case 'week':
        startDate = moment().startOf('week').toDate();
        endDate = moment().endOf('week').toDate();
        break;
      case 'year':
        startDate = moment().startOf('year').toDate();
        endDate = moment().endOf('year').toDate();
        break;
      default: // month
        startDate = moment().startOf('month').toDate();
        endDate = moment().endOf('month').toDate();
    }

    let lettersRef = db.collection('letters');

    // Simplified query to avoid index issues
    lettersRef = lettersRef.orderBy('created_at', 'desc');

    const lettersSnapshot = await lettersRef.get();

    const stats = {
      total_letters: 0,
      sent_letters: 0,
      read_letters: 0,
      pending_responses: 0,
      responded_letters: 0,
      overdue_responses: 0,
      by_type: {
        warning: 0,
        promotion: 0,
        transfer: 0,
        termination: 0,
        appreciation: 0,
        memo: 0,
        announcement: 0,
        other: 0
      },
      by_priority: {
        low: 0,
        normal: 0,
        high: 0,
        urgent: 0
      }
    };

    const now = new Date();

    lettersSnapshot.forEach(doc => {
      const letter = doc.data();
      
      // Apply filters in memory
      const letterDate = letter.created_at?.toDate();
      if (letterDate && (letterDate < startDate || letterDate > endDate)) {
        return; // Skip this letter
      }
      
      // Filter by user if not admin
      if (!isAdmin && letter.recipient_id !== req.user.userId) {
        return; // Skip this letter
      }
      
      stats.total_letters++;

      // Status counts
      if (letter.status === 'sent') {
        stats.sent_letters++;
      } else if (letter.status === 'read') {
        stats.read_letters++;
      }

      // Response tracking
      if (letter.requires_response) {
        if (letter.response_received) {
          stats.responded_letters++;
        } else {
          stats.pending_responses++;
          
          // Check if overdue
          if (letter.response_deadline) {
            const deadline = new Date(letter.response_deadline);
            if (now > deadline) {
              stats.overdue_responses++;
            }
          }
        }
      }

      // By type
      const type = letter.letter_type || 'other';
      if (stats.by_type[type] !== undefined) {
        stats.by_type[type]++;
      } else {
        stats.by_type.other++;
      }

      // By priority
      const priority = letter.priority || 'normal';
      if (stats.by_priority[priority] !== undefined) {
        stats.by_priority[priority]++;
      }
    });

    res.json({
      success: true,
      data: {
        statistics: stats,
        period: {
          type: period,
          start_date: startDate.toISOString(),
          end_date: endDate.toISOString()
        }
      }
    });

  } catch (error) {
    console.error('Get letter statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letter statistics'
    });
  }
});

// Get pending letter requests for admin approval
router.get('/pending', auth, async (req, res) => {
  try {
    console.log('🔍 Pending letters endpoint called');
    console.log('👤 User from auth middleware:', req.user);
    
    // Check if user has admin privileges (both admin and super_admin can access)
    const isAdmin = req.user.role === 'admin' || req.user.role === 'super_admin';
    const hasAdminEmployeeId = req.user.employeeId?.startsWith('SUP') || req.user.employeeId?.startsWith('ADM');
    
    console.log('🔐 Auth check:', {
      isAdmin,
      hasAdminEmployeeId,
      role: req.user.role,
      employeeId: req.user.employeeId
    });
    
    if (!isAdmin && !hasAdminEmployeeId) {
      console.log('❌ Access denied - insufficient privileges');
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required to view pending letters.'
      });
    }

    const { 
      page = 1, 
      limit = 20,
      letter_type,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;

    console.log('📋 Getting pending letter requests for user:', {
      role: req.user.role,
      employeeId: req.user.employeeId,
      userId: req.user.userId
    });

    // Temporary fix: Remove orderBy to avoid index requirement
    // TODO: Create Firestore composite index for (status, created_at) to enable ordering
    let lettersRef = db.collection('letters')
      .where('status', '==', 'pending')
      .limit(parseInt(limit));

    console.log('🔍 Executing query without orderBy (temporary fix)...');
    const snapshot = await lettersRef.get();
    console.log('📊 Query results:', snapshot.size, 'documents found');
    
    const pendingLetters = [];
    
    // Get user details for each letter
    for (const doc of snapshot.docs) {
      const letterData = { id: doc.id, ...doc.data() };
      
      // Filter by letter type if specified
      if (letter_type && letterData.letter_type !== letter_type) {
        continue;
      }

      // Get sender/requester details
      try {
        const userDoc = await db.collection('users').doc(letterData.sender_id || letterData.recipient_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          letterData.requester = {
            id: userDoc.id,
            full_name: userData.full_name,
            email: userData.email,
            employee_id: userData.employee_id,
            department: userData.department,
            position: userData.position
          };
          
          // Add senderName and recipientName for easier access in frontend
          letterData.senderName = userData.full_name;
          letterData.recipientName = userData.full_name;
          letterData.recipientEmployeeId = userData.employee_id;
        }
      } catch (userError) {
        console.error('Error fetching user details:', userError);
      }

      // Convert timestamps
      if (letterData.created_at && typeof letterData.created_at.toDate === 'function') {
        letterData.created_at = letterData.created_at.toDate();
      }
      if (letterData.updated_at && typeof letterData.updated_at.toDate === 'function') {
        letterData.updated_at = letterData.updated_at.toDate();
      }

      pendingLetters.push(letterData);
    }

    // Sort by created_at descending since we can't use orderBy in query
    pendingLetters.sort((a, b) => {
      const dateA = a.created_at ? new Date(a.created_at) : new Date(0);
      const dateB = b.created_at ? new Date(b.created_at) : new Date(0);
      return dateB - dateA; // Descending order
    });

    console.log('✅ Successfully processed and sorted pending letters:', pendingLetters.length);

    res.json({
      success: true,
      message: 'Pending letters retrieved successfully',
      data: {
        letters: pendingLetters,
        pagination: {
          current_page: parseInt(page),
          total_records: pendingLetters.length,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get pending letters error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pending letters'
    });
  }
});

// Get single letter by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const letterId = req.params.id;
    const letterDoc = await db.collection('letters').doc(letterId).get();

    if (!letterDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Letter not found'
      });
    }

    const letterData = { id: letterDoc.id, ...letterDoc.data() };
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';

    // Check access permissions
    if (!isAdmin && letterData.recipient_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only view your own letters.'
      });
    }

    // Get recipient details
    if (letterData.recipient_id) {
      try {
        const userDoc = await db.collection('users').doc(letterData.recipient_id).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          letterData.recipient = {
            id: letterData.recipient_id,
            full_name: userData.full_name,
            employee_id: userData.employee_id,
            department: userData.department,
            position: userData.position,
            email: userData.email
          };
        }
      } catch (userError) {
        console.error('Error fetching recipient details:', userError);
      }
    }

    // Get sender details
    if (letterData.sender_id) {
      try {
        const senderDoc = await db.collection('users').doc(letterData.sender_id).get();
        if (senderDoc.exists) {
          const senderData = senderDoc.data();
          letterData.sender = {
            id: letterData.sender_id,
            full_name: senderData.full_name,
            position: senderData.position,
            department: senderData.department,
            email: senderData.email
          };
        }
      } catch (senderError) {
        console.error('Error fetching sender details:', senderError);
      }
    }

    // Mark as read if recipient is viewing
    if (letterData.recipient_id === req.user.userId && letterData.status === 'sent') {
      await db.collection('letters').doc(letterId).update({
        status: 'read',
        read_at: getServerTimestamp(),
        updated_at: getServerTimestamp()
      });
      letterData.status = 'read';
      letterData.read_at = new Date();
    }

    res.json({
      success: true,
      data: { letter: letterData }
    });

  } catch (error) {
    console.error('Get letter error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letter'
    });
  }
});

// Create new letter (Admin only)
router.post('/', auth, adminAuth, validateLetter, async (req, res) => {
  try {
    const {
      recipient_id,
      subject,
      content,
      letter_type,
      letter_number,
      letter_date,
      priority,
      requires_response,
      response_deadline,
      attachments,
      cc_recipients,
      template_used,
      reference_number
    } = req.body;

    // Verify recipient exists
    const recipientDoc = await db.collection('users').doc(recipient_id).get();
    if (!recipientDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Recipient not found'
      });
    }

    // Generate letter number if not provided
    let finalLetterNumber = letter_number;
    if (!finalLetterNumber) {
      const currentDate = moment().format('YYYYMMDD');
      const letterCount = await db.collection('letters')
        .where('created_at', '>=', new Date(moment().startOf('day').toISOString()))
        .where('created_at', '<=', new Date(moment().endOf('day').toISOString()))
        .get();
      
      finalLetterNumber = `${letter_type.toUpperCase()}/${currentDate}/${String(letterCount.size + 1).padStart(3, '0')}`;
    }

    const letterData = {
      recipient_id,
      sender_id: req.user.userId,
      subject,
      content,
      letter_type,
      letter_number: finalLetterNumber,
      letter_date: letter_date || moment().format('YYYY-MM-DD'),
      priority: priority || 'normal',
      status: 'pending', // Letter requests start as pending for admin approval
      requires_response: requires_response || false,
      response_deadline: response_deadline || null,
      attachments: attachments || [],
      cc_recipients: cc_recipients || [],
      template_used: template_used || null,
      reference_number: reference_number || null,
      read_at: null,
      response_received: false,
      response_content: null,
      response_date: null,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    const docRef = await db.collection('letters').add(letterData);

    // Create notification for recipient
    try {
      await db.collection('notifications').add({
        user_id: recipient_id,
        title: 'New Letter Received',
        message: `You have received a new ${letter_type} letter: ${subject}`,
        type: 'letter',
        reference_id: docRef.id,
        reference_type: 'letter',
        is_read: false,
        priority: priority,
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create notification:', notifError);
    }

    res.status(201).json({
      success: true,
      message: 'Letter created successfully',
      data: {
        letter: {
          id: docRef.id,
          ...letterData
        }
      }
    });

  } catch (error) {
    console.error('Create letter error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create letter'
    });
  }
});

// Update letter (Admin only)
router.put('/:id', auth, adminAuth, async (req, res) => {
  try {
    const letterId = req.params.id;
    const letterDoc = await db.collection('letters').doc(letterId).get();

    if (!letterDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Letter not found'
      });
    }

    const currentData = letterDoc.data();
    
    // Prevent updating sent letters that have been read
    if (currentData.status === 'read') {
      return res.status(400).json({
        success: false,
        message: 'Cannot update letter that has been read by recipient'
      });
    }

    const allowedUpdates = [
      'subject', 'content', 'priority', 'requires_response', 
      'response_deadline', 'attachments', 'cc_recipients'
    ];

    const updates = {};
    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    updates.updated_at = getServerTimestamp();

    await db.collection('letters').doc(letterId).update(updates);

    res.json({
      success: true,
      message: 'Letter updated successfully'
    });

  } catch (error) {
    console.error('Update letter error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update letter'
    });
  }
});

// Delete letter (Admin only)
router.delete('/:id', auth, adminAuth, async (req, res) => {
  try {
    const letterId = req.params.id;
    const letterDoc = await db.collection('letters').doc(letterId).get();

    if (!letterDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Letter not found'
      });
    }

    const letterData = letterDoc.data();
    
    // Prevent deleting read letters
    if (letterData.status === 'read') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete letter that has been read by recipient'
      });
    }

    await db.collection('letters').doc(letterId).delete();

    res.json({
      success: true,
      message: 'Letter deleted successfully'
    });

  } catch (error) {
    console.error('Delete letter error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete letter'
    });
  }
});

// Submit response to letter (Recipient only)
router.post('/:id/response', auth, async (req, res) => {
  try {
    const letterId = req.params.id;
    const { response_content } = req.body;

    if (!response_content) {
      return res.status(400).json({
        success: false,
        message: 'Response content is required'
      });
    }

    const letterDoc = await db.collection('letters').doc(letterId).get();

    if (!letterDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Letter not found'
      });
    }

    const letterData = letterDoc.data();

    // Check if user is the recipient
    if (letterData.recipient_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'Only the letter recipient can submit a response'
      });
    }

    // Check if letter requires response
    if (!letterData.requires_response) {
      return res.status(400).json({
        success: false,
        message: 'This letter does not require a response'
      });
    }

    // Check if response already submitted
    if (letterData.response_received) {
      return res.status(400).json({
        success: false,
        message: 'Response has already been submitted for this letter'
      });
    }

    // Check deadline if exists
    if (letterData.response_deadline) {
      const deadline = new Date(letterData.response_deadline);
      const now = new Date();
      if (now > deadline) {
        return res.status(400).json({
          success: false,
          message: 'Response deadline has passed'
        });
      }
    }

    await db.collection('letters').doc(letterId).update({
      response_received: true,
      response_content,
      response_date: getServerTimestamp(),
      updated_at: getServerTimestamp()
    });

    // Create notification for sender
    try {
      await db.collection('notifications').add({
        user_id: letterData.sender_id,
        title: 'Letter Response Received',
        message: `Response received for letter: ${letterData.subject}`,
        type: 'letter_response',
        reference_id: letterId,
        reference_type: 'letter',
        is_read: false,
        priority: letterData.priority,
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create notification:', notifError);
    }

    res.json({
      success: true,
      message: 'Response submitted successfully'
    });

  } catch (error) {
    console.error('Submit response error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to submit response'
    });
  }
});

// Get letter templates (Admin only)
router.get('/templates/list', auth, adminAuth, async (req, res) => {
  try {
    const templatesSnapshot = await db.collection('letter_templates')
      .orderBy('name', 'asc')
      .get();

    const templates = [];
    templatesSnapshot.forEach(doc => {
      templates.push({ id: doc.id, ...doc.data() });
    });

    res.json({
      success: true,
      data: { templates }
    });

  } catch (error) {
    console.error('Get templates error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letter templates'
    });
  }
});

// Get letter statistics (detailed)
router.get('/stats/overview', auth, async (req, res) => {
  try {
    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';
    const { period = 'month' } = req.query;

    let startDate, endDate;
    
    switch (period) {
      case 'week':
        startDate = moment().startOf('week').toDate();
        endDate = moment().endOf('week').toDate();
        break;
      case 'month':
        startDate = moment().startOf('month').toDate();
        endDate = moment().endOf('month').toDate();
        break;
      case 'year':
        startDate = moment().startOf('year').toDate();
        endDate = moment().endOf('year').toDate();
        break;
      default:
        startDate = moment().startOf('month').toDate();
        endDate = moment().endOf('month').toDate();
    }

    let baseQuery = db.collection('letters');

    if (!isAdmin) {
      baseQuery = baseQuery.where('recipient_id', '==', req.user.userId);
    }

    // Simple query without date filters for now
    baseQuery = baseQuery.orderBy('created_at', 'desc').limit(100);

    const lettersSnapshot = await baseQuery.get();

    const stats = {
      total_letters: 0,
      sent_letters: 0,
      read_letters: 0,
      pending_responses: 0,
      responded_letters: 0,
      overdue_responses: 0,
      by_type: {},
      by_priority: {
        low: 0,
        normal: 0,
        high: 0,
        urgent: 0
      }
    };

    const now = new Date();

    lettersSnapshot.forEach(doc => {
      const letter = doc.data();
      
      // Apply date filter in memory for now
      const letterDate = letter.created_at?.toDate();
      if (letterDate && (letterDate < startDate || letterDate > endDate)) {
        return; // Skip this letter
      }
      
      stats.total_letters++;

      // Status counts
      if (letter.status === 'sent') {
        stats.sent_letters++;
      } else if (letter.status === 'read') {
        stats.read_letters++;
      }

      // Response tracking
      if (letter.requires_response) {
        if (letter.response_received) {
          stats.responded_letters++;
        } else {
          stats.pending_responses++;
          
          // Check if overdue
          if (letter.response_deadline) {
            const deadline = new Date(letter.response_deadline);
            if (now > deadline) {
              stats.overdue_responses++;
            }
          }
        }
      }

      // By type
      const type = letter.letter_type || 'other';
      stats.by_type[type] = (stats.by_type[type] || 0) + 1;

      // By priority
      const priority = letter.priority || 'normal';
      stats.by_priority[priority]++;
    });

    res.json({
      success: true,
      data: {
        period,
        date_range: {
          start: moment(startDate).format('YYYY-MM-DD'),
          end: moment(endDate).format('YYYY-MM-DD')
        },
        stats
      }
    });

  } catch (error) {
    console.error('Get letter stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letter statistics'
    });
  }
});

// ==================== LETTER APPROVAL ENDPOINTS (ADMIN ONLY) ====================

// Update letter status - Approve/Reject letter request (Admin only)
router.put('/:letterId/status', auth, adminAuth, async (req, res) => {
  try {
    const { letterId } = req.params;
    const { status, reason } = req.body;

    console.log('📋 Updating letter status:', { letterId, status, reason });

    // Validate status
    const validStatuses = ['pending', 'approved', 'rejected', 'sent', 'read'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`
      });
    }

    // Get letter document
    const letterDoc = await db.collection('letters').doc(letterId).get();
    
    if (!letterDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Letter not found'
      });
    }

    const letterData = letterDoc.data();

    // Prepare update data
    const updateData = {
      status: status,
      updated_at: getServerTimestamp()
    };

    // Add approval/rejection specific fields
    if (status === 'approved') {
      updateData.approved_at = getServerTimestamp();
      updateData.approved_by = req.user.userId;
      updateData.approval_reason = reason || 'Letter request approved';
    } else if (status === 'rejected') {
      updateData.rejected_at = getServerTimestamp();
      updateData.rejected_by = req.user.userId;
      updateData.rejection_reason = reason || 'Letter request rejected';
    }

    // Update letter
    await db.collection('letters').doc(letterId).update(updateData);

    // Create notification for the requester
    try {
      const notificationTitle = status === 'approved' ? 'Letter Request Approved' : 'Letter Request Rejected';
      const notificationMessage = status === 'approved' 
        ? `Your ${letterData.letter_type} request has been approved`
        : `Your ${letterData.letter_type} request has been rejected. Reason: ${reason || 'No reason provided'}`;

      await db.collection('notifications').add({
        user_id: letterData.sender_id || letterData.recipient_id,
        title: notificationTitle,
        message: notificationMessage,
        type: 'letter_status',
        reference_id: letterId,
        reference_type: 'letter',
        is_read: false,
        priority: 'normal',
        created_at: getServerTimestamp()
      });
    } catch (notifError) {
      console.error('Failed to create notification:', notifError);
    }

    res.json({
      success: true,
      message: `Letter ${status} successfully`,
      data: {
        letter_id: letterId,
        status: status,
        updated_at: new Date().toISOString(),
        reason: reason
      }
    });

  } catch (error) {
    console.error('Update letter status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update letter status'
    });
  }
});

// ==================== NEW ENHANCED LETTERS FEATURES FOR ADMIN DASHBOARD ====================

// Bulk approve/reject letters (Admin only)
router.post('/admin/bulk-action', auth, adminAuth, async (req, res) => {
  try {
    const { letter_ids, action, reason } = req.body;

    if (!letter_ids || !Array.isArray(letter_ids) || letter_ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Letter IDs array is required and cannot be empty'
      });
    }

    if (!['approve', 'reject', 'delete'].includes(action)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid action. Must be approve, reject, or delete'
      });
    }

    const batch = db.batch();
    const results = [];

    for (const letterId of letter_ids) {
      try {
        const letterRef = db.collection('letters').doc(letterId);
        const letterDoc = await letterRef.get();

        if (!letterDoc.exists) {
          results.push({
            letter_id: letterId,
            success: false,
            error: 'Letter not found'
          });
          continue;
        }

        const letterData = letterDoc.data();

        if (action === 'delete') {
          // Only allow deletion of pending or rejected letters
          if (letterData.status === 'sent' || letterData.status === 'read') {
            results.push({
              letter_id: letterId,
              success: false,
              error: 'Cannot delete sent or read letters'
            });
            continue;
          }
          batch.delete(letterRef);
        } else {
          const status = action === 'approve' ? 'approved' : 'rejected';
          const updateData = {
            status: status,
            updated_at: getServerTimestamp()
          };

          if (action === 'approve') {
            updateData.approved_at = getServerTimestamp();
            updateData.approved_by = req.user.userId;
            updateData.approval_reason = reason || 'Bulk approval';
          } else {
            updateData.rejected_at = getServerTimestamp();
            updateData.rejected_by = req.user.userId;
            updateData.rejection_reason = reason || 'Bulk rejection';
          }

          batch.update(letterRef, updateData);

          // Queue notification (will be created after batch commit)
          results.push({
            letter_id: letterId,
            success: true,
            action: action,
            recipient_id: letterData.sender_id || letterData.recipient_id,
            letter_type: letterData.letter_type,
            subject: letterData.subject
          });
        }

        if (action !== 'delete') {
          results.push({
            letter_id: letterId,
            success: true,
            action: action
          });
        }

      } catch (error) {
        results.push({
          letter_id: letterId,
          success: false,
          error: error.message
        });
      }
    }

    await batch.commit();

    // Create notifications for successful actions
    const notificationPromises = results
      .filter(r => r.success && r.recipient_id)
      .map(async (r) => {
        try {
          const title = r.action === 'approve' ? 'Letter Approved' : 'Letter Rejected';
          const message = r.action === 'approve' 
            ? `Your ${r.letter_type} letter "${r.subject}" has been approved`
            : `Your ${r.letter_type} letter "${r.subject}" has been rejected. ${reason ? `Reason: ${reason}` : ''}`;

          await db.collection('notifications').add({
            user_id: r.recipient_id,
            title: title,
            message: message,
            type: 'letter_status',
            reference_id: r.letter_id,
            reference_type: 'letter',
            is_read: false,
            priority: 'normal',
            created_at: getServerTimestamp()
          });
        } catch (notifError) {
          console.error('Failed to create notification for', r.letter_id, notifError);
        }
      });

    await Promise.all(notificationPromises);

    const successCount = results.filter(r => r.success).length;
    const failureCount = results.filter(r => !r.success).length;

    res.json({
      success: true,
      message: `Bulk ${action} completed. ${successCount} successful, ${failureCount} failed.`,
      data: {
        total_letters: letter_ids.length,
        successful: successCount,
        failed: failureCount,
        results
      }
    });

  } catch (error) {
    console.error('Bulk letter action error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to perform bulk action on letters'
    });
  }
});

// Get letter templates for admin dashboard
router.get('/admin/templates', auth, adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    const templatesSnapshot = await db.collection('letter_templates')
      .orderBy('name', 'asc')
      .get();

    const templates = [];
    templatesSnapshot.forEach(doc => {
      const templateData = { id: doc.id, ...doc.data() };
      
      // Convert timestamps
      if (templateData.created_at && typeof templateData.created_at.toDate === 'function') {
        templateData.created_at = templateData.created_at.toDate();
      }
      if (templateData.updated_at && typeof templateData.updated_at.toDate === 'function') {
        templateData.updated_at = templateData.updated_at.toDate();
      }

      templates.push(templateData);
    });

    // Apply pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedTemplates = templates.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: {
        templates: paginatedTemplates,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(templates.length / parseInt(limit)),
          total_records: templates.length,
          limit: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Get letter templates error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letter templates'
    });
  }
});

// Create/Update letter template (Admin only)
router.post('/admin/templates', auth, adminAuth, async (req, res) => {
  try {
    const { name, letter_type, subject_template, content_template, variables, is_active = true } = req.body;

    if (!name || !letter_type || !content_template) {
      return res.status(400).json({
        success: false,
        message: 'Name, letter type, and content template are required'
      });
    }

    const templateData = {
      name,
      letter_type,
      subject_template: subject_template || '',
      content_template,
      variables: variables || [],
      is_active,
      created_by: req.user.userId,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
    };

    const docRef = await db.collection('letter_templates').add(templateData);

    res.status(201).json({
      success: true,
      message: 'Letter template created successfully',
      data: {
        template_id: docRef.id,
        ...templateData
      }
    });

  } catch (error) {
    console.error('Create letter template error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create letter template'
    });
  }
});

// Update letter template (Admin only)
router.put('/admin/templates/:id', auth, adminAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, letter_type, subject_template, content_template, variables, is_active } = req.body;

    const templateRef = db.collection('letter_templates').doc(id);
    const templateDoc = await templateRef.get();

    if (!templateDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Letter template not found'
      });
    }

    const updateData = {
      updated_at: getServerTimestamp(),
      updated_by: req.user.userId
    };

    if (name !== undefined) updateData.name = name;
    if (letter_type !== undefined) updateData.letter_type = letter_type;
    if (subject_template !== undefined) updateData.subject_template = subject_template;
    if (content_template !== undefined) updateData.content_template = content_template;
    if (variables !== undefined) updateData.variables = variables;
    if (is_active !== undefined) updateData.is_active = is_active;

    await templateRef.update(updateData);

    res.json({
      success: true,
      message: 'Letter template updated successfully'
    });

  } catch (error) {
    console.error('Update letter template error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update letter template'
    });
  }
});

// Get letter analytics for admin dashboard
router.get('/admin/analytics', auth, adminAuth, async (req, res) => {
  try {
    const { period = 'month', start_date, end_date } = req.query;

    let startDate, endDate;
    if (period === 'custom' && start_date && end_date) {
      startDate = start_date;
      endDate = end_date;
    } else {
      switch (period) {
        case 'week':
          startDate = moment().startOf('week').format('YYYY-MM-DD');
          endDate = moment().endOf('week').format('YYYY-MM-DD');
          break;
        case 'year':
          startDate = moment().startOf('year').format('YYYY-MM-DD');
          endDate = moment().endOf('year').format('YYYY-MM-DD');
          break;
        default:
          startDate = moment().startOf('month').format('YYYY-MM-DD');
          endDate = moment().endOf('month').format('YYYY-MM-DD');
      }
    }

    // Get all letters for the period
    const lettersSnapshot = await db.collection('letters')
      .orderBy('created_at', 'desc')
      .get();

    const analytics = {
      period_info: {
        period,
        start_date: startDate,
        end_date: endDate
      },
      summary: {
        total_letters: 0,
        pending_letters: 0,
        approved_letters: 0,
        rejected_letters: 0,
        sent_letters: 0,
        read_letters: 0
      },
      by_type: {},
      by_department: {},
      by_priority: {
        low: 0,
        normal: 0,
        high: 0,
        urgent: 0
      },
      response_analytics: {
        total_requiring_response: 0,
        responded: 0,
        pending_response: 0,
        overdue_response: 0
      },
      trends: {
        daily_counts: {},
        weekly_counts: {},
        monthly_counts: {}
      }
    };

    const now = new Date();
    const startDateObj = new Date(startDate);
    const endDateObj = new Date(endDate);

    for (const doc of lettersSnapshot.docs) {
      const letter = doc.data();
      
      // Filter by date range
      const letterDate = letter.created_at?.toDate();
      if (!letterDate || letterDate < startDateObj || letterDate > endDateObj) {
        continue;
      }

      analytics.summary.total_letters++;

      // Status breakdown
      if (letter.status === 'pending') analytics.summary.pending_letters++;
      else if (letter.status === 'approved') analytics.summary.approved_letters++;
      else if (letter.status === 'rejected') analytics.summary.rejected_letters++;
      else if (letter.status === 'sent') analytics.summary.sent_letters++;
      else if (letter.status === 'read') analytics.summary.read_letters++;

      // By type
      const type = letter.letter_type || 'other';
      analytics.by_type[type] = (analytics.by_type[type] || 0) + 1;

      // By priority
      const priority = letter.priority || 'normal';
      analytics.by_priority[priority]++;

      // Get user department for analytics
      try {
        const userDoc = await db.collection('users').doc(letter.recipient_id || letter.sender_id).get();
        if (userDoc.exists) {
          const dept = userDoc.data().department || 'Unknown';
          analytics.by_department[dept] = (analytics.by_department[dept] || 0) + 1;
        }
      } catch (error) {
        analytics.by_department['Unknown'] = (analytics.by_department['Unknown'] || 0) + 1;
      }

      // Response analytics
      if (letter.requires_response) {
        analytics.response_analytics.total_requiring_response++;
        
        if (letter.response_received) {
          analytics.response_analytics.responded++;
        } else {
          analytics.response_analytics.pending_response++;
          
          // Check if overdue
          if (letter.response_deadline && new Date(letter.response_deadline) < now) {
            analytics.response_analytics.overdue_response++;
          }
        }
      }

      // Trends
      const dateKey = moment(letterDate).format('YYYY-MM-DD');
      const weekKey = moment(letterDate).format('YYYY-[W]WW');
      const monthKey = moment(letterDate).format('YYYY-MM');

      analytics.trends.daily_counts[dateKey] = (analytics.trends.daily_counts[dateKey] || 0) + 1;
      analytics.trends.weekly_counts[weekKey] = (analytics.trends.weekly_counts[weekKey] || 0) + 1;
      analytics.trends.monthly_counts[monthKey] = (analytics.trends.monthly_counts[monthKey] || 0) + 1;
    }

    // Calculate response rates
    if (analytics.response_analytics.total_requiring_response > 0) {
      analytics.response_analytics.response_rate = 
        ((analytics.response_analytics.responded / analytics.response_analytics.total_requiring_response) * 100).toFixed(2);
      analytics.response_analytics.overdue_rate = 
        ((analytics.response_analytics.overdue_response / analytics.response_analytics.total_requiring_response) * 100).toFixed(2);
    }

    res.json({
      success: true,
      data: { analytics }
    });

  } catch (error) {
    console.error('Get letter analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letter analytics'
    });
  }
});

// Export letters data (Admin only)
router.get('/admin/export', auth, adminAuth, async (req, res) => {
  try {
    const { format = 'json', start_date, end_date, status, letter_type } = req.query;

    let lettersRef = db.collection('letters').orderBy('created_at', 'desc');

    const snapshot = await lettersRef.get();
    const lettersData = [];

    for (const doc of snapshot.docs) {
      const letter = { id: doc.id, ...doc.data() };
      
      // Apply filters
      if (start_date && letter.created_at?.toDate() < new Date(start_date)) continue;
      if (end_date && letter.created_at?.toDate() > new Date(end_date)) continue;
      if (status && letter.status !== status) continue;
      if (letter_type && letter.letter_type !== letter_type) continue;

      // Get user details
      try {
        if (letter.recipient_id) {
          const userDoc = await db.collection('users').doc(letter.recipient_id).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            letter.recipient_name = userData.full_name;
            letter.recipient_employee_id = userData.employee_id;
            letter.recipient_department = userData.department;
          }
        }
      } catch (error) {
        console.error('Error fetching user details for export:', error);
      }

      // Convert timestamps for export
      if (letter.created_at && typeof letter.created_at.toDate === 'function') {
        letter.created_at = letter.created_at.toDate().toISOString();
      }
      if (letter.updated_at && typeof letter.updated_at.toDate === 'function') {
        letter.updated_at = letter.updated_at.toDate().toISOString();
      }

      lettersData.push(letter);
    }

    if (format === 'csv') {
      const csvHeaders = [
        'Letter Number', 'Type', 'Subject', 'Status', 'Priority',
        'Recipient Name', 'Employee ID', 'Department',
        'Created Date', 'Requires Response', 'Response Received'
      ];

      const csvRows = lettersData.map(letter => [
        letter.letter_number || '',
        letter.letter_type || '',
        (letter.subject || '').replace(/,/g, ';'),
        letter.status || '',
        letter.priority || '',
        letter.recipient_name || '',
        letter.recipient_employee_id || '',
        letter.recipient_department || '',
        letter.created_at || '',
        letter.requires_response ? 'Yes' : 'No',
        letter.response_received ? 'Yes' : 'No'
      ]);

      const csvContent = [csvHeaders.join(','), ...csvRows.map(row => row.join(','))].join('\n');

      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=letters_export_${new Date().toISOString().split('T')[0]}.csv`);
      res.send(csvContent);
    } else {
      res.json({
        success: true,
        data: {
          letters: lettersData,
          export_info: {
            format,
            total_records: lettersData.length,
            exported_at: new Date().toISOString(),
            filters: { start_date, end_date, status, letter_type }
          }
        }
      });
    }

  } catch (error) {
    console.error('Export letters error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to export letters data'
    });
  }
});

// Get letters dashboard summary (Admin only)
router.get('/admin/dashboard-summary', auth, adminAuth, async (req, res) => {
  try {
    const today = moment().format('YYYY-MM-DD');
    const thisWeek = {
      start: moment().startOf('week').format('YYYY-MM-DD'),
      end: moment().endOf('week').format('YYYY-MM-DD')
    };
    const thisMonth = {
      start: moment().startOf('month').format('YYYY-MM-DD'),
      end: moment().endOf('month').format('YYYY-MM-DD')
    };

    // Get all letters
    const lettersSnapshot = await db.collection('letters').get();
    
    const summary = {
      total_letters: 0,
      pending_approval: 0,
      today_letters: 0,
      week_letters: 0,
      month_letters: 0,
      urgent_letters: 0,
      overdue_responses: 0,
      recent_activities: [],
      status_breakdown: {
        pending: 0,
        approved: 0,
        rejected: 0,
        sent: 0,
        read: 0
      },
      type_breakdown: {}
    };

    const now = new Date();
    const recentActivities = [];

    lettersSnapshot.forEach(doc => {
      const letter = { id: doc.id, ...doc.data() };
      summary.total_letters++;

      const letterDate = letter.created_at?.toDate();
      const letterDateStr = letterDate ? moment(letterDate).format('YYYY-MM-DD') : null;

      // Count by status
      if (letter.status === 'pending') {
        summary.pending_approval++;
        summary.status_breakdown.pending++;
      } else if (letter.status === 'approved') {
        summary.status_breakdown.approved++;
      } else if (letter.status === 'rejected') {
        summary.status_breakdown.rejected++;
      } else if (letter.status === 'sent') {
        summary.status_breakdown.sent++;
      } else if (letter.status === 'read') {
        summary.status_breakdown.read++;
      }

      // Count by time periods
      if (letterDateStr === today) summary.today_letters++;
      if (letterDateStr >= thisWeek.start && letterDateStr <= thisWeek.end) summary.week_letters++;
      if (letterDateStr >= thisMonth.start && letterDateStr <= thisMonth.end) summary.month_letters++;

      // Count urgent letters
      if (letter.priority === 'urgent' || letter.priority === 'high') {
        summary.urgent_letters++;
      }

      // Count overdue responses
      if (letter.requires_response && !letter.response_received && letter.response_deadline) {
        if (new Date(letter.response_deadline) < now) {
          summary.overdue_responses++;
        }
      }

      // Type breakdown
      const type = letter.letter_type || 'other';
      summary.type_breakdown[type] = (summary.type_breakdown[type] || 0) + 1;

      // Recent activities (last 10 letters)
      if (recentActivities.length < 10) {
        recentActivities.push({
          id: letter.id,
          type: 'letter',
          action: `Letter ${letter.status}`,
          subject: letter.subject,
          letter_type: letter.letter_type,
          status: letter.status,
          priority: letter.priority,
          created_at: letterDate
        });
      }
    });

    // Sort recent activities by date
    summary.recent_activities = recentActivities
      .sort((a, b) => (b.created_at || new Date(0)) - (a.created_at || new Date(0)))
      .slice(0, 10);

    res.json({
      success: true,
      data: { summary }
    });

  } catch (error) {
    console.error('Get letters dashboard summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get letters dashboard summary'
    });
  }
});

// ==================== ADMIN DASHBOARD ENDPOINTS ====================

// Admin dashboard summary for letters
router.get('/admin/dashboard/summary', auth, requireAdminRole, async (req, res) => {
  try {
    const lettersSnapshot = await db.collection('letters').get();
    const letters = [];
    
    lettersSnapshot.forEach(doc => {
      letters.push({ id: doc.id, ...doc.data() });
    });

    const summary = {
      total_letters: letters.length,
      pending_approval: letters.filter(l => l.status === 'pending' || l.approval_status === 'pending').length,
      approved: letters.filter(l => l.approval_status === 'approved').length,
      rejected: letters.filter(l => l.approval_status === 'rejected').length,
      draft: letters.filter(l => l.status === 'draft').length,
      by_type: {}
    };

    // Count by type
    letters.forEach(letter => {
      const type = letter.letter_type || 'other';
      summary.by_type[type] = (summary.by_type[type] || 0) + 1;
    });

    // Recent letters (last 10)
    const recentLetters = letters
      .sort((a, b) => {
        const aTime = a.created_at ? a.created_at.toDate() : new Date(0);
        const bTime = b.created_at ? b.created_at.toDate() : new Date(0);
        return bTime - aTime;
      })
      .slice(0, 10)
      .map(letter => ({
        id: letter.id,
        subject: letter.subject,
        sender_name: letter.sender_name,
        recipient_name: letter.recipient_name,
        status: letter.status,
        approval_status: letter.approval_status,
        created_at: letter.created_at
      }));

    res.json({
      success: true,
      message: 'Letters dashboard summary retrieved successfully',
      data: {
        summary,
        recent_letters: recentLetters
      }
    });

  } catch (error) {
    console.error('Error fetching letters dashboard summary:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching letters dashboard summary',
      error: error.message
    });
  }
});

// Get all letters for admin with advanced filtering
router.get('/admin/all', auth, requireAdminRole, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      letter_type,
      approval_status,
      search,
      start_date,
      end_date,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;

    let query = db.collection('letters');

    // Apply filters
    if (status && status !== 'all') {
      query = query.where('status', '==', status);
    }
    if (letter_type && letter_type !== 'all') {
      query = query.where('letter_type', '==', letter_type);
    }
    if (approval_status && approval_status !== 'all') {
      query = query.where('approval_status', '==', approval_status);
    }

    // Get all matching documents
    const snapshot = await query.get();
    let letters = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      letters.push({
        id: doc.id,
        ...data,
        created_at: data.created_at ? data.created_at.toDate() : null,
        updated_at: data.updated_at ? data.updated_at.toDate() : null
      });
    });

    // Apply search filter
    if (search) {
      const searchLower = search.toLowerCase();
      letters = letters.filter(letter =>
        letter.subject?.toLowerCase().includes(searchLower) ||
        letter.content?.toLowerCase().includes(searchLower) ||
        letter.sender_name?.toLowerCase().includes(searchLower) ||
        letter.recipient_name?.toLowerCase().includes(searchLower)
      );
    }

    // Apply date range filter
    if (start_date || end_date) {
      const startDate = start_date ? new Date(start_date) : new Date(0);
      const endDate = end_date ? new Date(end_date) : new Date();
      
      letters = letters.filter(letter => {
        const letterDate = letter.created_at || new Date(0);
        return letterDate >= startDate && letterDate <= endDate;
      });
    }

    // Apply sorting
    letters.sort((a, b) => {
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
    const paginatedLetters = letters.slice(startIndex, endIndex);

    res.json({
      success: true,
      message: 'All letters retrieved successfully',
      data: {
        letters: paginatedLetters,
        pagination: {
          current_page: parseInt(page),
          per_page: parseInt(limit),
          total_items: letters.length,
          total_pages: Math.ceil(letters.length / limit),
          has_next: endIndex < letters.length,
          has_prev: page > 1
        },
        filters_applied: { status, letter_type, approval_status, search, start_date, end_date }
      }
    });

  } catch (error) {
    console.error('Error fetching all letters:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching all letters',
      error: error.message
    });
  }
});

// Bulk approve/reject letters
router.post('/admin/bulk-action', auth, requireAdminRole, async (req, res) => {
  try {
    const { letter_ids, action, reason } = req.body;
    
    if (!letter_ids || !Array.isArray(letter_ids) || letter_ids.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Letter IDs are required'
      });
    }

    if (!['approve', 'reject'].includes(action)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid action. Must be approve or reject'
      });
    }

    const batch = db.batch();
    const results = [];

    for (const letterId of letter_ids) {
      const letterRef = db.collection('letters').doc(letterId);
      const letterDoc = await letterRef.get();

      if (letterDoc.exists) {
        const updateData = {
          approval_status: action === 'approve' ? 'approved' : 'rejected',
          status: action === 'approve' ? 'approved' : 'rejected',
          approved_by: req.user.userId,
          approved_at: getServerTimestamp(),
          updated_at: getServerTimestamp()
        };

        if (reason) {
          updateData.approval_reason = reason;
        }

        batch.update(letterRef, updateData);
        results.push({
          letter_id: letterId,
          status: 'success',
          action: action
        });
      } else {
        results.push({
          letter_id: letterId,
          status: 'error',
          message: 'Letter not found'
        });
      }
    }

    await batch.commit();

    res.json({
      success: true,
      message: `Bulk ${action} completed`,
      data: {
        results,
        action_count: results.filter(r => r.status === 'success').length
      }
    });

  } catch (error) {
    console.error('Error in bulk letter action:', error);
    res.status(500).json({
      success: false,
      message: 'Error processing bulk action',
      error: error.message
    });
  }
});

module.exports = router;