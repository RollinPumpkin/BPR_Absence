// Test script to verify attendance data parsing
const attendanceRecord = {
  "id": "osDgSV2mNJSNW6JNsy4m",
  "userId": "gAHwMdJ8WOREVCxUSyGnMGfu7pG2",
  "employeeId": "EMP001",
  "userName": "Ahmad Suryono",
  "department": "Lending",
  "date": "2025-10-17",
  "checkInTime": "08:45:00",
  "checkOutTime": "17:45:00",
  "status": "present",
  "notes": "Regular work day",
  "hoursWorked": 8,
  "overtimeHours": 0.75,
  "createdAt": {
    "_seconds": 1760708367,
    "_nanoseconds": 384000000
  },
  "updatedAt": {
    "_seconds": 1760794767,
    "_nanoseconds": 735000000
  }
};

console.log('📝 Sample attendance record structure:');
console.log('✅ ID:', attendanceRecord.id);
console.log('✅ User Name:', attendanceRecord.userName);
console.log('✅ Department:', attendanceRecord.department);
console.log('✅ Status:', attendanceRecord.status);
console.log('✅ Check In:', attendanceRecord.checkInTime);
console.log('✅ Check Out:', attendanceRecord.checkOutTime);
console.log('✅ Date:', attendanceRecord.date);

// Check what Flutter should expect
console.log('\n🔧 Flutter Attendance.fromJson() should handle:');
console.log('- userName (camelCase) ✅');
console.log('- checkInTime (camelCase) ✅');
console.log('- checkOutTime (camelCase) ✅');
console.log('- userId (camelCase) ✅');
console.log('- employeeId (camelCase) ✅');
console.log('- department (same) ✅');
console.log('- status (same) ✅');
console.log('- date (same) ✅');