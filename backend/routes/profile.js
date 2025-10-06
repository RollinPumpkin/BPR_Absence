const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { getFirestore } = require('../config/database');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const upload = require('../middleware/upload');
const { profileValidation, passwordChangeValidation } = require('../middleware/validation');

const db = getFirestore();

// Get current user profile
router.get('/', auth, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    
    // Remove sensitive information
    const { password, ...profileData } = userData;
    
    // Convert timestamps to readable format
    if (profileData.created_at) {
      profileData.created_at = profileData.created_at.toDate();
    }
    if (profileData.updated_at) {
      profileData.updated_at = profileData.updated_at.toDate();
    }
    if (profileData.last_login) {
      profileData.last_login = profileData.last_login.toDate();
    }

    res.json({
      success: true,
      data: {
        profile: {
          id: userId,
          ...profileData
        }
      }
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get profile'
    });
  }
});

// Update user profile
router.put('/', auth, profileValidation, async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      full_name,
      phone,
      address,
      emergency_contact,
      emergency_phone,
      date_of_birth,
      gender,
      marital_status,
      national_id,
      bank_account,
      bank_name
    } = req.body;

    // Check if user exists
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Prepare update data
    const updateData = {
      updated_at: new Date()
    };

    // Only update fields that are provided
    if (full_name !== undefined) updateData.full_name = full_name;
    if (phone !== undefined) updateData.phone = phone;
    if (address !== undefined) updateData.address = address;
    if (emergency_contact !== undefined) updateData.emergency_contact = emergency_contact;
    if (emergency_phone !== undefined) updateData.emergency_phone = emergency_phone;
    if (date_of_birth !== undefined) updateData.date_of_birth = date_of_birth;
    if (gender !== undefined) updateData.gender = gender;
    if (marital_status !== undefined) updateData.marital_status = marital_status;
    if (national_id !== undefined) updateData.national_id = national_id;
    if (bank_account !== undefined) updateData.bank_account = bank_account;
    if (bank_name !== undefined) updateData.bank_name = bank_name;

    // Update user profile
    await db.collection('users').doc(userId).update(updateData);

    // Get updated profile
    const updatedDoc = await db.collection('users').doc(userId).get();
    const updatedData = updatedDoc.data();
    const { password, ...profileData } = updatedData;

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        profile: {
          id: userId,
          ...profileData
        }
      }
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile'
    });
  }
});

// Change password
router.put('/password', auth, passwordChangeValidation, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { current_password, new_password } = req.body;

    // Get current user data
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(current_password, userData.password);
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Hash new password
    const saltRounds = 10;
    const hashedNewPassword = await bcrypt.hash(new_password, saltRounds);

    // Update password
    await db.collection('users').doc(userId).update({
      password: hashedNewPassword,
      updated_at: new Date(),
      password_changed_at: new Date()
    });

    res.json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to change password'
    });
  }
});

// Upload profile picture
router.post('/picture', auth, upload.single('profile_picture'), async (req, res) => {
  try {
    const userId = req.user.userId;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file uploaded'
      });
    }

    // Update user with profile picture path
    const profilePicturePath = `/uploads/${req.file.filename}`;
    
    await db.collection('users').doc(userId).update({
      profile_picture: profilePicturePath,
      updated_at: new Date()
    });

    res.json({
      success: true,
      message: 'Profile picture uploaded successfully',
      data: {
        profile_picture: profilePicturePath
      }
    });

  } catch (error) {
    console.error('Upload profile picture error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload profile picture'
    });
  }
});

// Delete profile picture
router.delete('/picture', auth, async (req, res) => {
  try {
    const userId = req.user.userId;

    await db.collection('users').doc(userId).update({
      profile_picture: null,
      updated_at: new Date()
    });

    res.json({
      success: true,
      message: 'Profile picture deleted successfully'
    });

  } catch (error) {
    console.error('Delete profile picture error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete profile picture'
    });
  }
});

// Get user by ID (Admin only)
router.get('/user/:userId', auth, adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    const { password, ...profileData } = userData;

    // Convert timestamps
    if (profileData.created_at) {
      profileData.created_at = profileData.created_at.toDate();
    }
    if (profileData.updated_at) {
      profileData.updated_at = profileData.updated_at.toDate();
    }
    if (profileData.last_login) {
      profileData.last_login = profileData.last_login.toDate();
    }

    res.json({
      success: true,
      data: {
        profile: {
          id: userId,
          ...profileData
        }
      }
    });

  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user profile'
    });
  }
});

// Update user profile (Admin only)
router.put('/user/:userId', auth, adminAuth, profileValidation, async (req, res) => {
  try {
    const { userId } = req.params;
    const {
      full_name,
      email,
      phone,
      address,
      emergency_contact,
      emergency_phone,
      date_of_birth,
      gender,
      marital_status,
      national_id,
      bank_account,
      bank_name,
      employee_id,
      position,
      department,
      hire_date,
      salary,
      status,
      role
    } = req.body;

    // Check if user exists
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // If email is being updated, check for uniqueness
    if (email) {
      const existingUserQuery = await db.collection('users')
        .where('email', '==', email)
        .where('__name__', '!=', userId)
        .get();

      if (!existingUserQuery.empty) {
        return res.status(400).json({
          success: false,
          message: 'Email already exists'
        });
      }
    }

    // If employee_id is being updated, check for uniqueness
    if (employee_id) {
      const existingEmployeeQuery = await db.collection('users')
        .where('employee_id', '==', employee_id)
        .where('__name__', '!=', userId)
        .get();

      if (!existingEmployeeQuery.empty) {
        return res.status(400).json({
          success: false,
          message: 'Employee ID already exists'
        });
      }
    }

    // Prepare update data
    const updateData = {
      updated_at: new Date()
    };

    // Update all provided fields
    if (full_name !== undefined) updateData.full_name = full_name;
    if (email !== undefined) updateData.email = email;
    if (phone !== undefined) updateData.phone = phone;
    if (address !== undefined) updateData.address = address;
    if (emergency_contact !== undefined) updateData.emergency_contact = emergency_contact;
    if (emergency_phone !== undefined) updateData.emergency_phone = emergency_phone;
    if (date_of_birth !== undefined) updateData.date_of_birth = date_of_birth;
    if (gender !== undefined) updateData.gender = gender;
    if (marital_status !== undefined) updateData.marital_status = marital_status;
    if (national_id !== undefined) updateData.national_id = national_id;
    if (bank_account !== undefined) updateData.bank_account = bank_account;
    if (bank_name !== undefined) updateData.bank_name = bank_name;
    if (employee_id !== undefined) updateData.employee_id = employee_id;
    if (position !== undefined) updateData.position = position;
    if (department !== undefined) updateData.department = department;
    if (hire_date !== undefined) updateData.hire_date = hire_date;
    if (salary !== undefined) updateData.salary = salary;
    if (status !== undefined) updateData.status = status;
    if (role !== undefined) updateData.role = role;

    // Update user profile
    await db.collection('users').doc(userId).update(updateData);

    // Get updated profile
    const updatedDoc = await db.collection('users').doc(userId).get();
    const updatedData = updatedDoc.data();
    const { password, ...profileData } = updatedData;

    res.json({
      success: true,
      message: 'User profile updated successfully',
      data: {
        profile: {
          id: userId,
          ...profileData
        }
      }
    });

  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user profile'
    });
  }
});

// Get all users (Admin only) - with filtering and pagination
router.get('/users', auth, adminAuth, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      department,
      status = 'active',
      role,
      sort_by = 'created_at',
      sort_order = 'desc'
    } = req.query;

    // Simplified query to avoid index issues
    let usersRef = db.collection('users');

    // Only apply basic ordering for now
    usersRef = usersRef.orderBy('created_at', 'desc');

    // Get users
    const snapshot = await usersRef.get();
    let users = [];

    snapshot.forEach(doc => {
      const userData = doc.data();
      const { password, ...profileData } = userData;
      
      // Convert timestamps
      if (profileData.created_at && typeof profileData.created_at.toDate === 'function') {
        profileData.created_at = profileData.created_at.toDate();
      }
      if (profileData.updated_at && typeof profileData.updated_at.toDate === 'function') {
        profileData.updated_at = profileData.updated_at.toDate();
      }
      if (profileData.last_login && typeof profileData.last_login.toDate === 'function') {
        profileData.last_login = profileData.last_login.toDate();
      }

      users.push({
        id: doc.id,
        ...profileData
      });
    });

    // Apply filters in memory
    let filteredUsers = users;

    // Status filter
    if (status && status !== 'all') {
      filteredUsers = filteredUsers.filter(user => user.status === status);
    }

    // Department filter
    if (department) {
      filteredUsers = filteredUsers.filter(user => user.department === department);
    }

    // Role filter
    if (role) {
      filteredUsers = filteredUsers.filter(user => user.role === role);
    }

    // Apply search filter if provided
    if (search) {
      const searchTerm = search.toLowerCase();
      filteredUsers = filteredUsers.filter(user => 
        user.full_name?.toLowerCase().includes(searchTerm) ||
        user.email?.toLowerCase().includes(searchTerm) ||
        user.employee_id?.toLowerCase().includes(searchTerm) ||
        user.department?.toLowerCase().includes(searchTerm) ||
        user.position?.toLowerCase().includes(searchTerm)
      );
    }

    // Apply pagination
    const startIndex = (parseInt(page) - 1) * parseInt(limit);
    const endIndex = startIndex + parseInt(limit);
    const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

    res.json({
      success: true,
      data: {
        users: paginatedUsers,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(filteredUsers.length / parseInt(limit)),
          total_records: filteredUsers.length,
          limit: parseInt(limit),
          has_next_page: endIndex < filteredUsers.length,
          has_prev_page: parseInt(page) > 1
        },
        filters: {
          search,
          department,
          status,
          role,
          sort_by: 'created_at',
          sort_order: 'desc'
        }
      }
    });

  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get users'
    });
  }
});

// Reset user password (Admin only)
router.put('/user/:userId/reset-password', auth, adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const { new_password } = req.body;

    if (!new_password || new_password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters long'
      });
    }

    // Check if user exists
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Hash new password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(new_password, saltRounds);

    // Update password
    await db.collection('users').doc(userId).update({
      password: hashedPassword,
      updated_at: new Date(),
      password_changed_at: new Date(),
      password_reset_by_admin: true
    });

    res.json({
      success: true,
      message: 'User password reset successfully'
    });

  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reset user password'
    });
  }
});

module.exports = router;