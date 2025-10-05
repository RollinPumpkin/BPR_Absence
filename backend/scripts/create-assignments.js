const { getFirestore, getServerTimestamp } = require('../config/database');

const db = getFirestore();

// Create assignments collection if it doesn't exist
const createAssignmentsCollection = async () => {
  try {
    console.log('Creating assignments collection...');
    
    // Check if assignments collection exists
    const assignmentsSnapshot = await db.collection('assignments').limit(1).get();
    
    if (assignmentsSnapshot.empty) {
      console.log('Assignments collection is empty, creating sample data...');
      
      // Get sample users
      const usersSnapshot = await db.collection('users').where('role', '==', 'employee').limit(3).get();
      
      if (!usersSnapshot.empty) {
        const sampleAssignments = [
          {
            title: 'Complete Monthly Report',
            description: 'Prepare and submit the monthly financial report for September 2024',
            status: 'assigned',
            priority: 'high',
            due_date: '2024-10-15',
            created_at: getServerTimestamp(),
            updated_at: getServerTimestamp()
          },
          {
            title: 'Client Meeting Preparation',
            description: 'Prepare presentation materials for upcoming client meeting',
            status: 'in_progress',
            priority: 'medium',
            due_date: '2024-10-10',
            created_at: getServerTimestamp(),
            updated_at: getServerTimestamp()
          },
          {
            title: 'System Documentation Update',
            description: 'Update system documentation with new features and processes',
            status: 'assigned',
            priority: 'low',
            due_date: '2024-10-20',
            created_at: getServerTimestamp(),
            updated_at: getServerTimestamp()
          }
        ];

        // Assign to different users
        let userIndex = 0;
        for (const assignment of sampleAssignments) {
          if (userIndex < usersSnapshot.docs.length) {
            assignment.user_id = usersSnapshot.docs[userIndex].id;
            assignment.assigned_by = 'admin'; // You can replace with actual admin ID
            await db.collection('assignments').add(assignment);
            console.log(`Created assignment: ${assignment.title} for user ${userIndex + 1}`);
            userIndex++;
          }
        }
        
        console.log('✅ Sample assignments created successfully');
      } else {
        console.log('No users found to assign tasks to');
      }
    } else {
      console.log('✅ Assignments collection already exists');
    }
    
  } catch (error) {
    console.error('❌ Error creating assignments collection:', error);
  }
};

module.exports = { createAssignmentsCollection };