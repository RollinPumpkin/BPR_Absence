// Simple test untuk verify routing

void main() {
  print('🔍 CHECKING ADMIN DASHBOARD ROUTING');
  print('===================================');
  
  // Simulate route checking
  final routes = {
    '/admin/dashboard': 'AdminDashboardPage',
    '/user/dashboard': 'UserDashboardPage',
  };
  
  print('\n📋 Available Routes:');
  routes.forEach((route, page) {
    print('   $route → $page');
  });
  
  // Test routing logic
  final testEmployeeIds = ['SUP001', 'ADM003', 'EMP008', 'TEST001'];
  
  print('\n🎯 Routing Logic Test:');
  for (final id in testEmployeeIds) {
    String destination = '';
    if (id.startsWith('SUP') || id.startsWith('ADM')) {
      destination = '/admin/dashboard';
    } else {
      destination = '/user/dashboard';
    }
    print('   Employee ID: $id → $destination');
  }
}