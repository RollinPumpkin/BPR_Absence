const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getFirestore, getServerTimestamp } = require('../config/database');
const { validateLogin, validateRegister } = require('../middleware/validation');

const router = express.Router();
const db = getFirestore();

// Register new user
router.post('/register', validateRegister, async (req, res) => {
  try {
    const {
      employee_id,
      full_name,
      email,
      password,
      department,
      position,
      phone,
      role // allow custom role
    } = req.body;

    const usersRef = db.collection('users');
    const emailQuery = await usersRef.where('email', '==', email).get();
    const employeeIdQuery = await usersRef.where('employee_id', '==', employee_id).get();
    if (!emailQuery.empty || !employeeIdQuery.empty) {
      return res.status(400).json({
        success: false,
        message: 'User with this email or employee ID already exists'
      });
    }

    // Allowed roles
    const allowedRoles = ['employee', 'account_officer', 'security', 'office_boy'];
    let userRole = role;
    if (!allowedRoles.includes(userRole)) {
      userRole = 'employee'; // default
    }

    // Create user in Firebase Auth
    const { getAuth } = require('../config/database');
    const auth = getAuth();
    let firebaseUser;
    try {
      firebaseUser = await auth.createUser({
        email,
        password,
        displayName: full_name,
        disabled: false
      });
    } catch (err) {
      return res.status(400).json({
        success: false,
        message: 'Failed to create user in Firebase Auth',
        error: err.message
      });
    }

    // Hash password for Firestore (optional, for legacy reasons)
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create new user document in Firestore
    const userDoc = {
      employee_id,
      full_name,
      email,
      password: hashedPassword,
      role: userRole,
      department: department || '',
      position: position || '',
      phone: phone || '',
      profile_image: '', // nullable
      is_active: true,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp(),
      firebase_uid: firebaseUser.uid
    };
    const userRef = await usersRef.add(userDoc);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        id: userRef.id,
        employee_id,
        full_name,
        email,
        department,
        position,
        role: userDoc.role,
        firebase_uid: firebaseUser.uid
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed',
      error: error.message
    });
  }
});

// Login user
router.post('/login', validateLogin, async (req, res) => {
  try {
    const { email, password } = req.body; // email field can contain email, phone, or employee_id
    const { getAuth } = require('../config/database');
    const auth = getAuth();

    // Find user in Firestore by email, phone, or employee_id
    const usersRef = db.collection('users');
    let userQuery;
    let userEmail = email; // Store the actual email for Firebase Auth
    
    // Try to find user by email first
    userQuery = await usersRef.where('email', '==', email).get();
    
    // If not found by email, try by phone
    if (userQuery.empty) {
      userQuery = await usersRef.where('phone', '==', email).get();
      if (!userQuery.empty) {
        userEmail = userQuery.docs[0].data().email; // Get actual email for Firebase Auth
      }
    }
    
    // If not found by phone, try by employee_id
    if (userQuery.empty) {
      userQuery = await usersRef.where('employee_id', '==', email).get();
      if (!userQuery.empty) {
        userEmail = userQuery.docs[0].data().email; // Get actual email for Firebase Auth
      }
    }
    
    if (userQuery.empty) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials (user not found)'
      });
    }
    
    const userDoc = userQuery.docs[0];
    const user = { id: userDoc.id, ...userDoc.data() };

    // Check if user is active
    if (!user.is_active) {
      return res.status(401).json({
        success: false,
        message: 'Account is disabled'
      });
    }

    // For development/testing: verify password directly with bcrypt
    // TODO: Replace with Firebase Auth in production
    const bcrypt = require('bcryptjs');
    const isValidPassword = await bcrypt.compare(password, user.password);
    
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials (password incorrect)'
      });
    }

    console.log(`✅ Login successful for: ${userEmail}`);

    // Generate JWT token for your app
    const token = jwt.sign(
      {
        userId: user.id,
        employeeId: user.employee_id,
        role: user.role
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Remove password from response
    delete user.password;

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user,
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login failed',
      error: error.message
    });
  }
});

// Verify token
router.get('/verify', require('../middleware/auth'), async (req, res) => {
  try {
    const userRef = db.collection('users').doc(req.user.userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userData = userDoc.data();
    delete userData.password; // Remove password from response

    res.json({
      success: true,
      data: { 
        user: {
          id: userDoc.id,
          ...userData
        }
      }
    });

  } catch (error) {
    console.error('Token verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Token verification failed'
    });
  }
});

// Change password
router.put('/change-password', require('../middleware/auth'), async (req, res) => {
  try {
    const { current_password, new_password } = req.body;

    if (!current_password || !new_password) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }

    if (new_password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters long'
      });
    }

    // Get current user
    const userRef = db.collection('users').doc(req.user.userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const user = userDoc.data();

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(current_password, user.password);
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Hash new password
    const saltRounds = 12;
    const hashedNewPassword = await bcrypt.hash(new_password, saltRounds);

    // Update password
    await userRef.update({
      password: hashedNewPassword,
      updated_at: getServerTimestamp()
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

module.exports = router;
