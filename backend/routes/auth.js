const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
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
      role, // allow custom role
      place_of_birth,
      date_of_birth,
      nik,
      account_holder_name,
      account_number,
      division,
      gender,
      contract_type,
      bank,
      last_education,
      warning_letter_type
    } = req.body;

    const usersRef = db.collection('users');
    
    // Check email (fetch all with this email, then filter out terminated)
    const emailQuery = await usersRef.where('email', '==', email).get();
    const activeEmailUsers = emailQuery.docs.filter(doc => doc.data().status !== 'terminated');
    
    // Check employee ID (fetch all with this ID, then filter out terminated)
    const employeeIdQuery = await usersRef.where('employee_id', '==', employee_id).get();
    const activeEmployeeIdUsers = employeeIdQuery.docs.filter(doc => doc.data().status !== 'terminated');
    
    if (activeEmailUsers.length > 0 || activeEmployeeIdUsers.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'User with this email or employee ID already exists'
      });
    }

    // Allowed roles
    const allowedRoles = ['employee', 'admin', 'super_admin', 'account_officer', 'security', 'office_boy'];
    let userRole = role;
    if (!allowedRoles.includes(userRole)) {
      userRole = 'employee'; // default
    }

    // Create user in Firebase Auth (with fallback for development)
    const { getAuth } = require('../config/database');
    const auth = getAuth();
    let firebaseUser = null;
    let firebaseUid = null;
    
    try {
      firebaseUser = await auth.createUser({
        email,
        password,
        displayName: full_name,
        disabled: false
      });
      firebaseUid = firebaseUser.uid;
      console.log(`✅ Firebase Auth user created: ${email}`);
    } catch (err) {
      console.log(`⚠️ Firebase Auth creation failed, continuing with Firestore only: ${err.message}`);
      // Continue without Firebase Auth for development
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
      
      // Personal Information
      place_of_birth: place_of_birth || '',
      date_of_birth: date_of_birth || null,
      gender: gender || '',
      nik: nik || '',
      
      // Employment
      division: division || '',
      contract_type: contract_type || '',
      last_education: last_education || '',
      
      // Banking
      bank: bank || '',
      account_holder_name: account_holder_name || '',
      account_number: account_number || '',
      
      // Other
      warning_letter_type: warning_letter_type || 'None',
      
      profile_image: '', // nullable
      is_active: true,
      created_at: getServerTimestamp(),
      updated_at: getServerTimestamp(),
      firebase_uid: firebaseUid
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
        firebase_uid: firebaseUid
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

    const response = {
      success: true,
      message: 'Login successful',
      data: {
        user,
        token
      }
    };

    console.log(`📤 Sending response:`, JSON.stringify(response, null, 2));
    
    // Add explicit headers for Flutter
    res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
    res.header('Access-Control-Allow-Credentials', 'true');
    res.header('Content-Type', 'application/json');
    
    res.status(200).json(response);
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

// Forgot password - request reset
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    // Check if user exists
    const usersSnapshot = await db.collection('users').where('email', '==', email).get();
    
    if (usersSnapshot.empty) {
      return res.status(404).json({
        success: false,
        message: 'User with this email does not exist'
      });
    }

    // Get user data
    const userData = usersSnapshot.docs[0].data();
    const userId = usersSnapshot.docs[0].id;

    // Generate reset token (in production, use crypto.randomBytes)
    const resetToken = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    const expirationTime = Date.now() + (24 * 60 * 60 * 1000); // 24 hours

    // Save reset token to database
    await db.collection('password_resets').doc(userId).set({
      email: email,
      token: resetToken,
      expires_at: admin.firestore.Timestamp.fromMillis(expirationTime),
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      used: false
    });

    // Try to send real email (if email service is configured)
    try {
      const { sendForgotPasswordEmail } = require('../services/emailService');
      const emailResult = await sendForgotPasswordEmail(email, resetToken);
      
      if (emailResult.success) {
        console.log(`✅ Real email sent to ${email}`);
        res.status(200).json({
          success: true,
          message: 'Password reset instructions sent to your email',
          emailSent: true
        });
      } else {
        // Fallback to mock response if email fails
        console.log(`⚠️ Email service failed, using demo mode for ${email}`);
        console.log(`🔗 Demo reset link: http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(email)}`);
        res.status(200).json({
          success: true,
          message: 'Password reset instructions sent to your email (Demo Mode)',
          emailSent: false,
          demo: true,
          resetToken: resetToken, // Include token in demo mode
          resetLink: `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(email)}`
        });
      }
    } catch (emailError) {
      // Fallback to mock if email service is not available
      console.log(`ℹ️ Email service not available, using demo mode for ${email}`);
      console.log(`🔗 Demo reset link: http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(email)}`);
      res.status(200).json({
        success: true,
        message: 'Password reset instructions sent to your email (Demo Mode)',
        emailSent: false,
        demo: true,
        resetToken: resetToken, // Include token in demo mode
        resetLink: `http://localhost:8080/#/reset-password?token=${resetToken}&email=${encodeURIComponent(email)}`
      });
    }

  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process password reset request'
    });
  }
});

// Reset password with token
router.post('/reset-password', async (req, res) => {
  try {
    const { token, email, newPassword } = req.body;

    if (!token || !email || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Token, email, and new password are required'
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters long'
      });
    }

    // Validate password strength
    if (!/^(?=.*[a-zA-Z])(?=.*\d)/.test(newPassword)) {
      return res.status(400).json({
        success: false,
        message: 'Password must contain both letters and numbers'
      });
    }

    // Validate token from password_resets collection
    const resetDoc = await db.collection('password_resets').where('email', '==', email).where('token', '==', token).get();
    
    if (resetDoc.empty) {
      return res.status(400).json({
        success: false,
        message: 'Invalid reset token'
      });
    }
    
    const resetData = resetDoc.docs[0].data();
    
    // Check if token is already used
    if (resetData.used) {
      return res.status(400).json({
        success: false,
        message: 'Reset token has already been used'
      });
    }
    
    // Check if token is expired
    const now = Date.now();
    const expirationTime = resetData.expires_at.toMillis();
    
    if (now > expirationTime) {
      return res.status(400).json({
        success: false,
        message: 'Reset token has expired'
      });
    }

    // Find user by email
    const usersRef = db.collection('users');
    const userQuery = await usersRef.where('email', '==', email).get();

    if (userQuery.empty) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const userDoc = userQuery.docs[0];
    const userRef = userDoc.ref;

    // Hash new password
    const saltRounds = 12;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    await userRef.update({
      password: hashedNewPassword,
      updated_at: getServerTimestamp()
    });

    // Mark token as used
    await resetDoc.docs[0].ref.update({
      used: true,
      used_at: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({
      success: true,
      message: 'Password reset successfully'
    });

  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reset password'
    });
  }
});

module.exports = router;
