const jwt = require('jsonwebtoken');

// Test API dari frontend perspective
async function testLettersApprovalFlow() {
  try {
    console.log('🧪 TESTING LETTERS APPROVAL FLOW');
    console.log('================================\n');
    
    // 1. Get admin token
    console.log('1️⃣ Testing Admin Login...');
    const loginResponse = await fetch('http://localhost:3000/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'test@bpr.com',
        password: '123456'
      })
    });
    
    const loginData = await loginResponse.json();
    
    if (loginData.success) {
      console.log('✅ Admin login successful');
      console.log(`   Token: ${loginData.data.token.substring(0, 50)}...`);
      console.log(`   Role: ${loginData.data.user.role}`);
      console.log(`   Employee ID: ${loginData.data.user.employee_id || loginData.data.user.employeeId}`);
      
      const token = loginData.data.token;
      
      // 2. Test get pending letters
      console.log('\n2️⃣ Testing Get Pending Letters...');
      const pendingResponse = await fetch('http://localhost:3000/api/letters/pending', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        }
      });
      
      const pendingData = await pendingResponse.json();
      
      if (pendingData.success) {
        console.log('✅ Pending letters retrieved successfully');
        console.log(`   Found: ${pendingData.data.letters.length} pending letters`);
        
        if (pendingData.data.letters.length > 0) {
          console.log('\n📋 Sample Letters:');
          pendingData.data.letters.slice(0, 3).forEach((letter, index) => {
            console.log(`   ${index + 1}. ${letter.subject}`);
            console.log(`      From: ${letter.senderName || letter.requester?.full_name || 'Unknown'}`);
            console.log(`      Type: ${letter.letter_type}`);
            console.log(`      Status: ${letter.status}`);
            console.log(`      ID: ${letter.id}`);
            console.log('      ---');
          });
          
          // 3. Test approve first letter
          console.log('\n3️⃣ Testing Letter Approval...');
          const firstLetter = pendingData.data.letters[0];
          
          const approveResponse = await fetch(`http://localhost:3000/api/letters/${firstLetter.id}/status`, {
            method: 'PUT',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              status: 'approved',
              reason: 'Test approval via API'
            })
          });
          
          const approveData = await approveResponse.json();
          
          if (approveData.success) {
            console.log('✅ Letter approved successfully');
            console.log(`   Letter: ${firstLetter.subject}`);
            console.log(`   Previous Status: ${firstLetter.status} → approved`);
          } else {
            console.log('❌ Letter approval failed:', approveData.message);
          }
          
          // 4. Test reject second letter (if exists)
          if (pendingData.data.letters.length > 1) {
            console.log('\n4️⃣ Testing Letter Rejection...');
            const secondLetter = pendingData.data.letters[1];
            
            const rejectResponse = await fetch(`http://localhost:3000/api/letters/${secondLetter.id}/status`, {
              method: 'PUT',
              headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                status: 'rejected',
                reason: 'Test rejection via API - Missing documentation'
              })
            });
            
            const rejectData = await rejectResponse.json();
            
            if (rejectData.success) {
              console.log('✅ Letter rejected successfully');
              console.log(`   Letter: ${secondLetter.subject}`);
              console.log(`   Previous Status: ${secondLetter.status} → rejected`);
            } else {
              console.log('❌ Letter rejection failed:', rejectData.message);
            }
          }
          
          // 5. Verify status changes
          console.log('\n5️⃣ Verifying Status Changes...');
          const verifyResponse = await fetch('http://localhost:3000/api/letters/pending', {
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            }
          });
          
          const verifyData = await verifyResponse.json();
          
          if (verifyData.success) {
            console.log('✅ Status verification completed');
            console.log(`   Remaining pending letters: ${verifyData.data.letters.length}`);
            
            if (verifyData.data.letters.length < pendingData.data.letters.length) {
              console.log('✅ Status changes reflected correctly');
            } else {
              console.log('⚠️ Status changes may not be reflected yet');
            }
          }
          
        } else {
          console.log('ℹ️ No pending letters found for testing approval/rejection');
        }
      } else {
        console.log('❌ Failed to get pending letters:', pendingData.message);
      }
      
    } else {
      console.log('❌ Admin login failed:', loginData.message);
    }
    
    console.log('\n🎯 Test Completed!');
    
  } catch (error) {
    console.error('🚨 Test failed with error:', error);
  }
}

// Run the test
testLettersApprovalFlow();