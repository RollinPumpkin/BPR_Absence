// Quick script untuk clear browser localStorage dan test fresh login

console.clear();
console.log('🧹 Clearing localStorage and sessionStorage...');

// Clear all stored data
localStorage.clear();
sessionStorage.clear();

// Clear specific auth-related items
const authKeys = [
  'auth_token',
  'user_data', 
  'remember_me',
  'saved_email',
  'saved_password',
  'firebase_auth_token'
];

authKeys.forEach(key => {
  localStorage.removeItem(key);
  sessionStorage.removeItem(key);
});

console.log('✅ Storage cleared!');
console.log('📋 Now:');
console.log('1. Refresh the page (F5)');
console.log('2. You should go to login page');
console.log('3. Login with admin@gmail.com / 123456');
console.log('4. Check console for debug messages:');
console.log('   - 🚀 LOGIN_ATTEMPT: Starting login process...');
console.log('   - 🎯 LOGIN_PAGE DEBUG: User role received...');
console.log('   - 🚀 NAVIGATION: About to navigate to...');
console.log('');
console.log('🎯 Expected result: Should go to /admin/dashboard');

// Force page refresh after clearing
setTimeout(() => {
  window.location.reload();
}, 1000);