import 'package:frontend/data/services/api_service.dart';

class DummyDataSeeder {
  static final ApiService _apiService = ApiService.instance;

  /// Seeds the database with comprehensive dummy data via backend API
  static Future<bool> seedDatabase() async {
    print('🌱 Starting comprehensive database seeding...');
    
    try {
      // Call the backend seeding endpoint
      final response = await _apiService.post<Map<String, dynamic>>(
        '/seeder/seed-database',
        data: {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        print('🔍 DEBUG: Full response: ${response.data}');
        
        // The backend returns the results directly in 'data', not nested in 'data.data'
        final results = response.data!;
        print('🔍 DEBUG: Results data: $results');
        
        print('✅ Database seeding completed successfully!');
        print('📊 Seeding results:');
        print('   - Letters: ${results['letters']}');
        print('   - Assignments: ${results['assignments']}');
        print('   - Attendance: ${results['attendance']}');
        print('   - Users: ${results['users']}');
        
        // Check if there were any errors
        final hasErrors = results['errors'] != null && 
                         results['errors'] is List && 
                         (results['errors'] as List).isNotEmpty;
        
        print('🔍 DEBUG: Has errors: $hasErrors');
        print('🔍 DEBUG: Errors array: ${results['errors']}');
        
        if (hasErrors) {
          print('⚠️ Some errors occurred:');
          for (String error in results['errors']) {
            print('   - $error');
          }
          // Return false only if there were errors AND no data was created
          final totalCreated = (results['letters'] ?? 0) + 
                              (results['assignments'] ?? 0) + 
                              (results['attendance'] ?? 0) + 
                              (results['users'] ?? 0);
          print('🔍 DEBUG: Total created: $totalCreated');
          return totalCreated > 0; // Success if any data was created
        }
        
        print('🔍 DEBUG: Returning true - complete success');
        return true; // Complete success - no errors
      } else {
        print('❌ Database seeding failed: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Error seeding database: $e');
      return false;
    }
  }

  /// Clears seeded dummy data from database
  static Future<bool> clearSeededData() async {
    print('🧹 Clearing seeded data...');
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/seeder/clear-seeded-data',
        data: {},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final results = response.data!;
        print('✅ Seeded data cleared successfully!');
        print('📊 Cleared:');
        print('   - Letters: ${results['letters']}');
        print('   - Assignments: ${results['assignments']}');
        print('   - Attendance: ${results['attendance']}');
        
        return true;
      } else {
        print('❌ Failed to clear seeded data: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Error clearing seeded data: $e');
      return false;
    }
  }
}