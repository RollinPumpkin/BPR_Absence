// Simple test endpoint tanpa auth untuk testing response structure
const express = require('express');
const admin = require('firebase-admin');

const serviceAccount = require('./bpr-absens-firebase-adminsdk-fbsvc-3de050422d.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://bpr-absens-default-rtdb.firebaseio.com/"
    });
}

const db = admin.firestore();

async function testUserEndpointStructure() {
    try {
        console.log('🧪 Testing direct Firestore query for user structure...');
        
        const usersSnapshot = await db.collection('users')
            .where('isActive', '==', true)
            .limit(5)
            .get();
            
        console.log('📊 Found', usersSnapshot.size, 'users');
        
        if (usersSnapshot.empty) {
            console.log('⚠️ No users found in database');
            return;
        }
        
        const users = [];
        usersSnapshot.forEach(doc => {
            const userData = doc.data();
            users.push({
                id: doc.id,
                employeeId: userData.employeeId,
                email: userData.email,
                fullName: userData.fullName,
                role: userData.role,
                position: userData.position,
                department: userData.department,
                isActive: userData.isActive,
                firebaseUID: userData.firebaseUID
            });
        });
        
        console.log('\n📋 Sample user structure:');
        console.log(JSON.stringify(users[0], null, 2));
        
        // Test different response formats
        console.log('\n🎯 Testing response formats that UserService should handle:');
        
        // Case 1: Direct users array
        const format1 = {
            users: users,
            pagination: {
                currentPage: 1,
                totalPages: 1,
                totalItems: users.length,
                itemsPerPage: 10
            }
        };
        console.log('\n📌 CASE 1 - Response with users array:');
        console.log('Keys:', Object.keys(format1));
        console.log('Users array length:', format1.users.length);
        
        // Case 2: Nested data structure
        const format2 = {
            data: {
                users: users,
                pagination: {
                    currentPage: 1,
                    totalPages: 1,
                    totalItems: users.length,
                    itemsPerPage: 10
                }
            }
        };
        console.log('\n📌 CASE 2 - Nested data structure:');
        console.log('Keys:', Object.keys(format2));
        console.log('Data keys:', Object.keys(format2.data));
        
        // Case 3: Direct array
        const format3 = users;
        console.log('\n📌 CASE 3 - Direct array:');
        console.log('Type:', Array.isArray(format3) ? 'Array' : 'Object');
        console.log('Length:', format3.length);
        
        console.log('\n✅ Flutter UserService should handle all these cases correctly!');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

testUserEndpointStructure();