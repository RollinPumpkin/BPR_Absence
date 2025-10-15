// Script untuk debug routing dengan fresh state
console.log('🧹 STARTING FRESH DEBUG TEST...');

// Clear all browser storage
console.log('🧹 Clearing localStorage...');
localStorage.clear();

console.log('🧹 Clearing sessionStorage...');  
sessionStorage.clear();

// Clear any cached data
console.log('🧹 Clearing any cached navigation state...');
if ('caches' in window) {
  caches.keys().then(names => {
    names.forEach(name => {
      caches.delete(name);
    });
  });
}

// Force reload page
console.log('🧹 Forcing page reload...');
setTimeout(() => {
  location.reload(true);
}, 1000);