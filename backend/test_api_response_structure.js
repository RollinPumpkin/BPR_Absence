const axios = require('axios');

async function testAPIResponseStructure() {
    try {
        console.log('🧪 Testing API Response Structure...');
        
        // First, let's try to login to get a token
        console.log('🔑 Step 1: Attempting to login...');
        
        // Try admin login with Firebase-enabled users
        let loginResponse;
        try {
            console.log('🔑 Trying admin@gmail.com...');
            loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
                email: 'admin@gmail.com',
                password: 'admin123'
            });
        } catch (err) {
            console.log('ℹ️  admin@gmail.com failed, trying user@gmail.com...');
            try {
                loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
                    email: 'user@gmail.com',
                    password: 'user123'
                });
            } catch (err2) {
                console.log('ℹ️  user@gmail.com failed, trying ahmad.wijaya@bpr.com...');
                loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
                    email: 'ahmad.wijaya@bpr.com',
                    password: 'password123'
                });
            }
        }
        
        console.log('✅ Login successful!');
        console.log('🔑 Token received:', loginResponse.data.token ? 'YES' : 'NO');
        
        const token = loginResponse.data.token;
        
        // Now test the users endpoint
        console.log('\n📊 Step 2: Testing /api/admin/users endpoint...');
        
        const usersResponse = await axios.get('http://localhost:3000/api/admin/users', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        
        console.log('✅ Users API call successful!');
        console.log('📋 Response structure analysis:');
        console.log('- Status Code:', usersResponse.status);
        console.log('- Response Type:', typeof usersResponse.data);
        console.log('- Top-level keys:', Object.keys(usersResponse.data));
        
        const data = usersResponse.data;
        
        // Case analysis
        if (Array.isArray(data)) {
            console.log('📌 CASE 3: Direct array response');
            console.log('- Array length:', data.length);
            if (data.length > 0) {
                console.log('- First item keys:', Object.keys(data[0]));
            }
        } else if (data.users && Array.isArray(data.users)) {
            console.log('📌 CASE 1: Response with users array');
            console.log('- Users array length:', data.users.length);
            console.log('- Pagination present:', !!data.pagination);
            if (data.users.length > 0) {
                console.log('- First user keys:', Object.keys(data.users[0]));
            }
        } else if (data.data && data.data.users && Array.isArray(data.data.users)) {
            console.log('📌 CASE 2: Nested data structure');
            console.log('- Users array length:', data.data.users.length);
            console.log('- Pagination present:', !!data.data.pagination);
            if (data.data.users.length > 0) {
                console.log('- First user keys:', Object.keys(data.data.users[0]));
            }
        } else {
            console.log('📌 UNKNOWN CASE: Unexpected structure');
            console.log('- Full response:', JSON.stringify(data, null, 2));
        }
        
        console.log('\n🎯 Flutter UserService should handle this case correctly now!');
        
    } catch (error) {
        console.error('❌ Error testing API:', error.message);
        if (error.response) {
            console.error('📋 Response status:', error.response.status);
            console.error('📋 Response data:', error.response.data);
        }
    }
}

testAPIResponseStructure();