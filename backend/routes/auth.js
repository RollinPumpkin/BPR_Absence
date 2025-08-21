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
      phone
    } = req.body;

    // Check if user already exists
    const usersRef = db.collection('users');
    const emailQuery = await usersRef.where('email', '==', email).get();
    const employeeIdQuery = await usersRef.where('employee_id', '==', employee_id).get();

    if (!emailQuery.empty || !employeeIdQuery.empty) {
      return res.status(400).json({
        success: false,
        message: 'User with this email or employee ID already exists'
      });
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create new user document
    const userDoc = {
      employee_id,
      full_name,
      email,
      password: hashedPassword,
      role: 'employee', // Default role
      department: department || '',
      position: position || '',
      phone: phone || '',
      profile_image: '',
      is_active: true,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp()
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
        role: 'employee'
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Registration failed'
    });
  }
});

// Login user
router.post('/login', validateLogin, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const usersRef = db.collection('users');
    const userQuery = await usersRef.where('email', '==', email).get();

    if (userQuery.empty) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
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

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT token
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
      message: 'Login failed'
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
