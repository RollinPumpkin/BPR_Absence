const axios = require('axios');

async function testSearchFunctionality() {
    try {
        console.log('🧪 Testing Search Functionality...');
        
        // Login first
        console.log('🔑 Logging in...');
        const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
            email: 'admin@gmail.com',
            password: 'admin123'
        });
        
        console.log('✅ Login successful!');
        const token = loginResponse.data.token;
        
        // Test different search terms
        const searchTerms = ['Bo', 'boh', 'bo', 'Boh', 'BOH'];
        
        for (const search of searchTerms) {
            console.log(`\n🔍 Testing search: "${search}"`);
            
            try {
                const response = await axios.get(`http://localhost:3000/api/admin/users?search=${encodeURIComponent(search)}`, {
                    headers: {
                        'Authorization': `Bearer ${token}`
                    }
                });
                
                console.log('✅ Search successful!');
                console.log('📊 Response status:', response.status);
                console.log('📋 Results count:', response.data.data?.users?.length || 0);
                
                if (response.data.data?.users?.length > 0) {
                    response.data.data.users.forEach((user, index) => {
                        console.log(`   ${index + 1}. ${user.full_name} (${user.email})`);
                    });
                } else {
                    console.log('   No users found');
                }
                
            } catch (error) {
                console.error(`❌ Search "${search}" failed:`, error.message);
                if (error.response) {
                    console.error('📋 Status:', error.response.status);
                    console.error('📋 Data:', error.response.data);
                }
            }
        }
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        if (error.response) {
            console.error('📋 Response:', error.response.data);
        }
    }
}

testSearchFunctionality();