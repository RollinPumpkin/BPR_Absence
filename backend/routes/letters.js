const express = require('express');
const moment = require('moment');
const { getFirestore, getServerTimestamp } = require('../config/database');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
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

    const isAdmin = req.user.role === 'admin' || req.user.role === 'account_officer';
    let lettersRef = db.collection('letters');

    // Filter by user if not admin - simplified query
    if (!isAdmin) {
      lettersRef = lettersRef.where('recipient_id', '==', req.user.userId);
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
      status: 'sent',
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

module.exports = router;