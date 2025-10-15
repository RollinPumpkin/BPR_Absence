// Admin Endpoints Testing Script
// Test semua admin endpoints yang telah diimplementasikan

const API_BASE_URL = 'http://localhost:3000/api';
let adminToken = '';

// Helper function untuk testing API calls
async function testApiCall(endpoint, method = 'GET', data = null, description = '') {
    try {
        console.log(`\n🧪 Testing: ${description || endpoint}`);
        
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...(adminToken && { 'Authorization': `Bearer ${adminToken}` })
            }
        };
        
        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }
        
        const response = await fetch(`${API_BASE_URL}${endpoint}`, options);
        const result = await response.json();
        
        console.log(`   Status: ${response.status} ${response.statusText}`);
        console.log(`   Success: ${result.success}`);
        
        if (result.success) {
            console.log(`   ✅ PASSED: ${result.message || 'Success'}`);
            if (result.data) {
                // Show summary of returned data
                if (Array.isArray(result.data)) {
                    console.log(`   📊 Data: Array with ${result.data.length} items`);
                } else if (typeof result.data === 'object') {
                    const keys = Object.keys(result.data);
                    console.log(`   📊 Data: Object with keys: ${keys.slice(0, 5).join(', ')}${keys.length > 5 ? '...' : ''}`);
                }
            }
            // For login, show user role
            if (endpoint === '/auth/login' && result.data.user) {
                console.log(`   👤 User Role: ${result.data.user.role}`);
                console.log(`   🆔 Employee ID: ${result.data.user.employee_id}`);
            }
        } else {
            console.log(`   ❌ FAILED: ${result.message}`);
        }
        
        return { success: result.success, data: result.data, status: response.status };
    } catch (error) {
        console.log(`   ❌ ERROR: ${error.message}`);
        return { success: false, error: error.message };
    }
}

// Test 1: Login Admin
async function testAdminLogin() {
    console.log('\n🔐 === TESTING ADMIN LOGIN ===');
    
    const loginData = {
        email: 'admin@gmail.com',
        password: '123456'
    };
    
    const result = await testApiCall('/auth/login', 'POST', loginData, 'Admin Login');
    
    if (result.success && result.data.token) {
        adminToken = result.data.token;
        console.log('   🎯 Admin token obtained successfully');
        return true;
    } else {
        console.log('   ❌ Failed to get admin token');
        return false;
    }
}

// Test 2: Letters Admin Endpoints
async function testLettersAdmin() {
    console.log('\n📝 === TESTING LETTERS ADMIN ENDPOINTS ===');
    
    await testApiCall('/letters/admin/dashboard/summary', 'GET', null, 'Letters Dashboard Summary');
    await testApiCall('/letters/admin/all', 'GET', null, 'All Letters with Admin Access');
    await testApiCall('/letters/admin/all?status=pending&page=1&limit=5', 'GET', null, 'Letters with Filters');
}

// Test 3: Assignments Admin Endpoints  
async function testAssignmentsAdmin() {
    console.log('\n📋 === TESTING ASSIGNMENTS ADMIN ENDPOINTS ===');
    
    await testApiCall('/assignments/admin/dashboard/summary', 'GET', null, 'Assignments Dashboard Summary');
    await testApiCall('/assignments/admin/all', 'GET', null, 'All Assignments with Admin Access');
    await testApiCall('/assignments/admin/all?status=completed&page=1&limit=5', 'GET', null, 'Assignments with Filters');
}

// Test 4: Attendance Admin Endpoints
async function testAttendanceAdmin() {
    console.log('\n📅 === TESTING ATTENDANCE ADMIN ENDPOINTS ===');
    
    await testApiCall('/attendance/admin/dashboard', 'GET', null, 'Attendance Dashboard Summary');
    await testApiCall('/attendance/admin/all', 'GET', null, 'All Attendance with Admin Access');
    await testApiCall('/attendance/admin/all?status=present&page=1&limit=5', 'GET', null, 'Attendance with Filters');
}

// Test 5: Employee Admin Endpoints
async function testEmployeeAdmin() {
    console.log('\n👥 === TESTING EMPLOYEE ADMIN ENDPOINTS ===');
    
    await testApiCall('/users/admin/dashboard/summary', 'GET', null, 'Employee Dashboard Summary');
    await testApiCall('/users/admin/employees', 'GET', null, 'All Employees with Admin Access');
    await testApiCall('/users/admin/analytics', 'GET', null, 'Employee Analytics');
    await testApiCall('/users/admin/departments', 'GET', null, 'Departments List');
}

// Test 6: Access Control - Test with regular user
async function testAccessControl() {
    console.log('\n🚫 === TESTING ACCESS CONTROL ===');
    
    // Save admin token
    const savedAdminToken = adminToken;
    
    // Try to login as regular user  
    const userLoginData = {
        email: 'siti.rahayu@bpr.com',
        password: 'password123'
    };
    
    const userLogin = await testApiCall('/auth/login', 'POST', userLoginData, 'Regular User Login');
    
    if (userLogin.success && userLogin.data.token) {
        // Use user token to try admin endpoints
        adminToken = userLogin.data.token;
        console.log('\n   Testing admin endpoints with regular user token:');
        
        await testApiCall('/letters/admin/dashboard', 'GET', null, 'Letters Dashboard (should fail)');
        await testApiCall('/users/admin/employees', 'GET', null, 'Employees List (should fail)');
    }
    
    // Restore admin token
    adminToken = savedAdminToken;
}

// Main test function
async function runAllTests() {
    console.log('🚀 Starting Admin Endpoints Testing...');
    console.log('='.repeat(50));
    
    // Test admin login first
    const loginSuccess = await testAdminLogin();
    
    if (!loginSuccess) {
        console.log('\n❌ Cannot proceed without admin access. Check credentials.');
        return;
    }
    
    // Test all admin endpoints
    await testLettersAdmin();
    await testAssignmentsAdmin();
    await testAttendanceAdmin();
    await testEmployeeAdmin();
    
    // Test access control
    await testAccessControl();
    
    console.log('\n🏁 === TESTING COMPLETED ===');
    console.log('Check the results above for any failures.');
}

// Export for use in browser console or Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { runAllTests, testApiCall };
} else {
    // For browser console
    window.adminEndpointsTest = { runAllTests, testApiCall };
}

// Auto-run if loaded directly
if (typeof window === 'undefined') {
    // Node.js environment
    runAllTests();
} else {
    // Browser environment
    console.log('Admin Endpoints Test loaded. Run adminEndpointsTest.runAllTests() to start testing.');
}