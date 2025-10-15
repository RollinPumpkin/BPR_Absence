const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const admin = require('firebase-admin');
const axios = require('axios');

// Color output functions
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
  white: '\x1b[37m'
};

function colorLog(color, message) {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function testHeader(title) {
  colorLog('cyan', '\n' + '='.repeat(60));
  colorLog('cyan', `  ${title}`);
  colorLog('cyan', '='.repeat(60));
}

// Test results tracker
const testResults = {
  passed: 0,
  failed: 0,
  total: 0,
  errors: []
};

function testResult(testName, passed, error = null) {
  testResults.total++;
  if (passed) {
    testResults.passed++;
    colorLog('green', `✅ ${testName}`);
  } else {
    testResults.failed++;
    colorLog('red', `❌ ${testName}`);
    if (error) {
      colorLog('red', `   Error: ${error}`);
      testResults.errors.push({ test: testName, error: error });
    }
  }
}

async function runBackendTests() {
  testHeader('🚀 BACKEND COMPREHENSIVE TESTS');
  
  try {
    // Test 1: Check if backend server is running
    await testServerConnection();
    
    // Test 2: Test Firebase connection
    await testFirebaseConnection();
    
    // Test 3: Test user data in Firebase
    await testFirebaseUserData();
    
    // Test 4: Test API endpoints
    await testApiEndpoints();
    
    // Test 5: Test authentication
    await testAuthentication();
    
    // Test 6: Test data consistency
    await testDataConsistency();
    
    // Print final results
    printFinalResults();
    
  } catch (error) {
    colorLog('red', `❌ CRITICAL ERROR: ${error.message}`);
    process.exit(1);
  }
}

async function testServerConnection() {
  testHeader('🌐 Testing Server Connection');
  
  try {
    const response = await axios.get('http://localhost:3000/api/health', {
      timeout: 5000
    });
    testResult('Backend server health check', response.status === 200);
    colorLog('blue', `   Server response: ${JSON.stringify(response.data)}`);
  } catch (error) {
    testResult('Backend server health check', false, error.message);
    
    // Try alternative endpoints
    try {
      const altResponse = await axios.get('http://localhost:3000/', {
        timeout: 5000
      });
      testResult('Backend server root endpoint', altResponse.status === 200);
    } catch (altError) {
      testResult('Backend server root endpoint', false, altError.message);
    }
  }
}

async function testFirebaseConnection() {
  testHeader('🔥 Testing Firebase Connection');
  
  try {
    // Initialize Firebase Admin if not already initialized
    if (!admin.apps.length) {
      const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com"
      });
    }
    
    const db = admin.firestore();
    
    // Test Firestore connection
    const testDoc = await db.collection('test').doc('connection').get();
    testResult('Firebase Firestore connection', true);
    colorLog('blue', '   Firestore connection successful');
    
    // Test Auth connection
    const userList = await admin.auth().listUsers(1);
    testResult('Firebase Auth connection', true);
    colorLog('blue', `   Auth connection successful, found ${userList.users.length} user(s)`);
    
  } catch (error) {
    testResult('Firebase connection', false, error.message);
  }
}

async function testFirebaseUserData() {
  testHeader('👥 Testing Firebase User Data');
  
  try {
    const db = admin.firestore();
    
    // Test users collection
    const usersSnapshot = await db.collection('users').get();
    const userCount = usersSnapshot.size;
    testResult('Firebase users collection access', userCount > 0, userCount === 0 ? 'No users found' : null);
    colorLog('blue', `   Found ${userCount} users in Firestore`);
    
    if (userCount > 0) {
      // Analyze user data structure
      const sampleUser = usersSnapshot.docs[0].data();
      colorLog('blue', '   Sample user structure:');
      colorLog('blue', `   - ID: ${usersSnapshot.docs[0].id}`);
      colorLog('blue', `   - Full Name: ${sampleUser.fullName || 'N/A'}`);
      colorLog('blue', `   - Email: ${sampleUser.email || 'N/A'}`);
      colorLog('blue', `   - Role: ${sampleUser.role || 'N/A'}`);
      colorLog('blue', `   - Employee ID: ${sampleUser.employeeId || 'N/A'}`);
      colorLog('blue', `   - Is Active: ${sampleUser.isActive || 'N/A'}`);
      
      // Check for required fields
      const requiredFields = ['fullName', 'email', 'role'];
      let validUsers = 0;
      let invalidUsers = 0;
      
      usersSnapshot.docs.forEach(doc => {
        const userData = doc.data();
        const hasAllRequired = requiredFields.every(field => userData[field]);
        if (hasAllRequired) {
          validUsers++;
        } else {
          invalidUsers++;
        }
      });
      
      testResult('User data validation', invalidUsers === 0, 
        invalidUsers > 0 ? `${invalidUsers} users missing required fields` : null);
      colorLog('blue', `   Valid users: ${validUsers}, Invalid users: ${invalidUsers}`);
      
      // Check role distribution
      const roles = {};
      usersSnapshot.docs.forEach(doc => {
        const role = doc.data().role || 'undefined';
        roles[role] = (roles[role] || 0) + 1;
      });
      
      colorLog('blue', '   Role distribution:');
      Object.entries(roles).forEach(([role, count]) => {
        colorLog('blue', `     - ${role}: ${count}`);
      });
    }
    
    // Test Auth users
    const authUsers = await admin.auth().listUsers();
    testResult('Firebase Auth users access', authUsers.users.length > 0);
    colorLog('blue', `   Found ${authUsers.users.length} users in Firebase Auth`);
    
    // Check Auth vs Firestore consistency
    const authUserEmails = new Set(authUsers.users.map(u => u.email));
    const firestoreUserEmails = new Set();
    usersSnapshot.docs.forEach(doc => {
      const email = doc.data().email;
      if (email) firestoreUserEmails.add(email);
    });
    
    const onlyInAuth = authUserEmails.size - firestoreUserEmails.size;
    const onlyInFirestore = firestoreUserEmails.size - authUserEmails.size;
    
    testResult('Auth vs Firestore consistency', onlyInAuth === 0 && onlyInFirestore === 0,
      onlyInAuth !== 0 || onlyInFirestore !== 0 ? 
      `${onlyInAuth} users only in Auth, ${onlyInFirestore} users only in Firestore` : null);
    
  } catch (error) {
    testResult('Firebase user data access', false, error.message);
  }
}

async function testApiEndpoints() {
  testHeader('🔗 Testing API Endpoints');
  
  const endpoints = [
    { name: 'Admin Users List', url: 'http://localhost:3000/api/admin/users?page=1&limit=5' },
    { name: 'Create Employee', url: 'http://localhost:3000/api/users/admin/create-employee', method: 'post' },
    { name: 'Auth Login', url: 'http://localhost:3000/api/auth/login', method: 'post' },
    { name: 'Auth Profile', url: 'http://localhost:3000/api/auth/profile' }
  ];
  
  for (const endpoint of endpoints) {
    try {
      let response;
      
      if (endpoint.method === 'post') {
        // For POST endpoints, just test if they return proper error for missing data
        response = await axios.post(endpoint.url, {}, {
          timeout: 5000,
          validateStatus: () => true // Accept all status codes
        });
      } else {
        response = await axios.get(endpoint.url, {
          timeout: 5000,
          validateStatus: () => true // Accept all status codes
        });
      }
      
      const isSuccessful = response.status < 500; // Consider anything except server errors as successful
      testResult(`${endpoint.name} endpoint availability`, isSuccessful, 
        !isSuccessful ? `Status: ${response.status}` : null);
      
      colorLog('blue', `   ${endpoint.name}: ${response.status} ${response.statusText}`);
      
      if (response.data) {
        colorLog('blue', `   Response sample: ${JSON.stringify(response.data).substring(0, 100)}...`);
      }
      
    } catch (error) {
      testResult(`${endpoint.name} endpoint availability`, false, error.message);
    }
  }
}

async function testAuthentication() {
  testHeader('🔐 Testing Authentication');
  
  try {
    // Test with a known admin user
    const db = admin.firestore();
    const adminUsers = await db.collection('users')
      .where('role', 'in', ['admin', 'super_admin'])
      .limit(1)
      .get();
    
    if (adminUsers.empty) {
      testResult('Find admin user for testing', false, 'No admin users found in database');
      return;
    }
    
    const adminUser = adminUsers.docs[0].data();
    testResult('Find admin user for testing', true);
    colorLog('blue', `   Using admin user: ${adminUser.email}`);
    
    // Test login endpoint (without actual password to avoid security issues)
    try {
      const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
        email: adminUser.email,
        password: 'test_password' // This will fail, but we test endpoint response
      }, {
        timeout: 5000,
        validateStatus: () => true
      });
      
      const hasProperErrorStructure = loginResponse.data && 
        (loginResponse.data.hasOwnProperty('success') || loginResponse.data.hasOwnProperty('error'));
      
      testResult('Login endpoint structure', hasProperErrorStructure);
      colorLog('blue', `   Login response: ${JSON.stringify(loginResponse.data)}`);
      
    } catch (error) {
      testResult('Login endpoint test', false, error.message);
    }
    
  } catch (error) {
    testResult('Authentication testing', false, error.message);
  }
}

async function testDataConsistency() {
  testHeader('📊 Testing Data Consistency');
  
  try {
    const db = admin.firestore();
    
    // Test employee ID uniqueness
    const usersSnapshot = await db.collection('users').get();
    const employeeIds = new Set();
    const duplicateEmployeeIds = new Set();
    
    usersSnapshot.docs.forEach(doc => {
      const employeeId = doc.data().employeeId;
      if (employeeId) {
        if (employeeIds.has(employeeId)) {
          duplicateEmployeeIds.add(employeeId);
        } else {
          employeeIds.add(employeeId);
        }
      }
    });
    
    testResult('Employee ID uniqueness', duplicateEmployeeIds.size === 0,
      duplicateEmployeeIds.size > 0 ? 
      `Duplicate employee IDs: ${Array.from(duplicateEmployeeIds).join(', ')}` : null);
    
    // Test email uniqueness
    const emails = new Set();
    const duplicateEmails = new Set();
    
    usersSnapshot.docs.forEach(doc => {
      const email = doc.data().email;
      if (email) {
        if (emails.has(email)) {
          duplicateEmails.add(email);
        } else {
          emails.add(email);
        }
      }
    });
    
    testResult('Email uniqueness', duplicateEmails.size === 0,
      duplicateEmails.size > 0 ? 
      `Duplicate emails: ${Array.from(duplicateEmails).join(', ')}` : null);
    
    // Test role validity
    const validRoles = ['super_admin', 'admin', 'employee'];
    let invalidRoles = 0;
    const foundRoles = new Set();
    
    usersSnapshot.docs.forEach(doc => {
      const role = doc.data().role;
      if (role) {
        foundRoles.add(role);
        if (!validRoles.includes(role)) {
          invalidRoles++;
        }
      }
    });
    
    testResult('Role validity', invalidRoles === 0,
      invalidRoles > 0 ? `${invalidRoles} users with invalid roles` : null);
    
    colorLog('blue', `   Found roles: ${Array.from(foundRoles).join(', ')}`);
    
  } catch (error) {
    testResult('Data consistency testing', false, error.message);
  }
}

function printFinalResults() {
  testHeader('📋 TEST RESULTS SUMMARY');
  
  colorLog('white', `Total Tests: ${testResults.total}`);
  colorLog('green', `Passed: ${testResults.passed}`);
  colorLog('red', `Failed: ${testResults.failed}`);
  
  const successRate = ((testResults.passed / testResults.total) * 100).toFixed(2);
  colorLog('cyan', `Success Rate: ${successRate}%`);
  
  if (testResults.failed > 0) {
    colorLog('yellow', '\n🔍 FAILED TESTS DETAILS:');
    testResults.errors.forEach((error, index) => {
      colorLog('red', `${index + 1}. ${error.test}`);
      colorLog('red', `   ${error.error}`);
    });
  }
  
  if (successRate >= 80) {
    colorLog('green', '\n✅ OVERALL: Backend is in good condition!');
  } else if (successRate >= 60) {
    colorLog('yellow', '\n⚠️  OVERALL: Backend has some issues that need attention.');
  } else {
    colorLog('red', '\n❌ OVERALL: Backend has significant issues that need immediate attention.');
  }
}

// Run tests
runBackendTests().catch(console.error);