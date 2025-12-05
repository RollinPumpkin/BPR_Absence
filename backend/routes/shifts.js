const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const requireAdminRole = require('../middleware/requireAdminRole');
const admin = require('firebase-admin');
const db = admin.firestore();

// Get server timestamp helper
function getServerTimestamp() {
  return admin.firestore.FieldValue.serverTimestamp();
}

// Get shift assignments for a date range
router.get('/assignments', auth, async (req, res) => {
  try {
    const { startDate, endDate, employeeId, role } = req.query;

    let query = db.collection('shift_assignments');

    // Filter by date range
    if (startDate) {
      query = query.where('date', '>=', startDate);
    }
    if (endDate) {
      query = query.where('date', '<=', endDate);
    }

    // Filter by employee
    if (employeeId) {
      query = query.where('employee_id', '==', employeeId);
    }

    // Filter by role
    if (role) {
      query = query.where('role', '==', role);
    }

    const snapshot = await query.orderBy('date', 'asc').get();

    const assignments = [];
    snapshot.forEach(doc => {
      assignments.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json({
      success: true,
      data: assignments
    });
  } catch (error) {
    console.error('Error fetching shift assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch shift assignments',
      error: error.message
    });
  }
});

// Get shift assignment for specific date and employee
router.get('/assignment/:date/:employeeId', auth, async (req, res) => {
  try {
    const { date, employeeId } = req.params;

    const snapshot = await db.collection('shift_assignments')
      .where('date', '==', date)
      .where('employee_id', '==', employeeId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.json({
        success: true,
        data: null,
        message: 'No shift assignment found'
      });
    }

    const assignment = {
      id: snapshot.docs[0].id,
      ...snapshot.docs[0].data()
    };

    res.json({
      success: true,
      data: assignment
    });
  } catch (error) {
    console.error('Error fetching shift assignment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch shift assignment',
      error: error.message
    });
  }
});

// Create or update shift assignment (Admin only)
router.post('/assignments', auth, requireAdminRole, async (req, res) => {
  try {
    const {
      date,
      employee_id,
      employee_name,
      role,
      shift_type, // 'morning' or 'evening'
      shift_start_time,
      shift_end_time,
      notes
    } = req.body;

    // Validation
    if (!date || !employee_id || !shift_type) {
      return res.status(400).json({
        success: false,
        message: 'Date, employee_id, and shift_type are required'
      });
    }

    // Check if assignment already exists for this date and employee
    const existingSnapshot = await db.collection('shift_assignments')
      .where('date', '==', date)
      .where('employee_id', '==', employee_id)
      .limit(1)
      .get();

    const assignmentData = {
      date,
      employee_id,
      employee_name,
      role,
      shift_type,
      shift_start_time,
      shift_end_time,
      notes,
      updated_at: getServerTimestamp(),
      updated_by: req.user.userId
    };

    let assignmentId;

    if (!existingSnapshot.empty) {
      // Update existing assignment
      assignmentId = existingSnapshot.docs[0].id;
      await db.collection('shift_assignments').doc(assignmentId).update(assignmentData);
    } else {
      // Create new assignment
      assignmentData.created_at = getServerTimestamp();
      assignmentData.created_by = req.user.userId;
      
      const docRef = await db.collection('shift_assignments').add(assignmentData);
      assignmentId = docRef.id;
    }

    res.json({
      success: true,
      message: 'Shift assignment saved successfully',
      data: {
        id: assignmentId,
        ...assignmentData
      }
    });
  } catch (error) {
    console.error('Error saving shift assignment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save shift assignment',
      error: error.message
    });
  }
});

// Bulk create shift assignments (Admin only)
router.post('/assignments/bulk', auth, requireAdminRole, async (req, res) => {
  try {
    const { assignments } = req.body;

    if (!Array.isArray(assignments) || assignments.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Assignments array is required'
      });
    }

    const batch = db.batch();
    const results = [];

    for (const assignment of assignments) {
      const {
        date,
        employee_id,
        employee_name,
        role,
        shift_type,
        shift_start_time,
        shift_end_time,
        notes
      } = assignment;

      if (!date || !employee_id || !shift_type) {
        continue; // Skip invalid assignments
      }

      // Check if exists
      const existingSnapshot = await db.collection('shift_assignments')
        .where('date', '==', date)
        .where('employee_id', '==', employee_id)
        .limit(1)
        .get();

      const assignmentData = {
        date,
        employee_id,
        employee_name,
        role,
        shift_type,
        shift_start_time,
        shift_end_time,
        notes,
        updated_at: getServerTimestamp(),
        updated_by: req.user.userId
      };

      if (!existingSnapshot.empty) {
        // Update
        const docRef = db.collection('shift_assignments').doc(existingSnapshot.docs[0].id);
        batch.update(docRef, assignmentData);
        results.push({ id: existingSnapshot.docs[0].id, action: 'updated' });
      } else {
        // Create
        assignmentData.created_at = getServerTimestamp();
        assignmentData.created_by = req.user.userId;
        
        const docRef = db.collection('shift_assignments').doc();
        batch.set(docRef, assignmentData);
        results.push({ id: docRef.id, action: 'created' });
      }
    }

    await batch.commit();

    res.json({
      success: true,
      message: `Successfully processed ${results.length} shift assignments`,
      data: results
    });
  } catch (error) {
    console.error('Error bulk saving shift assignments:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to bulk save shift assignments',
      error: error.message
    });
  }
});

// Delete shift assignment (Admin only)
router.delete('/assignments/:assignmentId', auth, requireAdminRole, async (req, res) => {
  try {
    const { assignmentId } = req.params;

    await db.collection('shift_assignments').doc(assignmentId).delete();

    res.json({
      success: true,
      message: 'Shift assignment deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting shift assignment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete shift assignment',
      error: error.message
    });
  }
});

// Get shift definitions (shift types available)
router.get('/definitions', auth, async (req, res) => {
  try {
    const snapshot = await db.collection('shift_definitions').get();

    const definitions = [];
    snapshot.forEach(doc => {
      definitions.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // If no definitions, return default ones
    if (definitions.length === 0) {
      return res.json({
        success: true,
        data: [
          {
            id: 'morning',
            name: 'Shift Pagi',
            start_time: '06:00',
            end_time: '14:00',
            color: '#FFA500'
          },
          {
            id: 'evening',
            name: 'Shift Malam',
            start_time: '18:00',
            end_time: '02:00',
            color: '#4169E1'
          }
        ]
      });
    }

    res.json({
      success: true,
      data: definitions
    });
  } catch (error) {
    console.error('Error fetching shift definitions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch shift definitions',
      error: error.message
    });
  }
});

// Create or update shift definition
router.post('/definitions', auth, requireAdminRole, async (req, res) => {
  try {
    const { id, name, start_time, end_time, color, description } = req.body;

    // Validation
    if (!name || !start_time || !end_time) {
      return res.status(400).json({
        success: false,
        message: 'Name, start time, and end time are required'
      });
    }

    const shiftData = {
      name,
      start_time,
      end_time,
      color: color || '#4169E1',
      description: description || '',
      updated_at: getServerTimestamp(),
      updated_by: req.user.userId
    };

    let docRef;
    let message;

    if (id) {
      // Update existing
      docRef = db.collection('shift_definitions').doc(id);
      const doc = await docRef.get();
      
      if (!doc.exists) {
        return res.status(404).json({
          success: false,
          message: 'Shift definition not found'
        });
      }

      await docRef.update(shiftData);
      message = 'Shift definition updated successfully';
    } else {
      // Create new
      shiftData.created_at = getServerTimestamp();
      shiftData.created_by = req.user.userId;
      
      docRef = await db.collection('shift_definitions').add(shiftData);
      message = 'Shift definition created successfully';
    }

    res.json({
      success: true,
      message,
      data: {
        id: id || docRef.id,
        ...shiftData
      }
    });
  } catch (error) {
    console.error('Error saving shift definition:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save shift definition',
      error: error.message
    });
  }
});

// Delete shift definition
router.delete('/definitions/:definitionId', auth, requireAdminRole, async (req, res) => {
  try {
    const { definitionId } = req.params;

    // Check if used in any assignments
    const assignmentsSnapshot = await db.collection('shift_assignments')
      .where('shift_type', '==', definitionId)
      .limit(1)
      .get();

    if (!assignmentsSnapshot.empty) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete shift definition that is being used in assignments'
      });
    }

    await db.collection('shift_definitions').doc(definitionId).delete();

    res.json({
      success: true,
      message: 'Shift definition deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting shift definition:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete shift definition',
      error: error.message
    });
  }
});

module.exports = router;
