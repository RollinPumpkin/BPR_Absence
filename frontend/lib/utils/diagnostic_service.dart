import 'package:flutter/foundation.dart';

class DiagnosticService {
  static void logApiResponse(String endpoint, dynamic response) {
    if (kDebugMode) {
      print('🔍 DIAGNOSTIC: $endpoint Response');
      print('================================');
      print('Response Type: ${response.runtimeType}');
      if (response is Map) {
        print('Response Keys: ${response.keys.toList()}');
        if (response.containsKey('success')) {
          print('Success: ${response['success']}');
        }
        if (response.containsKey('data')) {
          print('Data Type: ${response['data'].runtimeType}');
          if (response['data'] is Map) {
            print('Data Keys: ${response['data'].keys.toList()}');
          }
        }
        if (response.containsKey('message')) {
          print('Message: ${response['message']}');
        }
      }
      print('Raw Response: $response');
      print('================================\n');
    }
  }

  static void logParsingAttempt(String modelName, Map<String, dynamic> json) {
    if (kDebugMode) {
      print('🔍 PARSING $modelName');
      print('===================');
      print('JSON Keys: ${json.keys.toList()}');
      print('JSON Values: $json');
      print('===================\n');
    }
  }

  static void logError(String context, dynamic error, [dynamic stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR in $context');
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack: $stackTrace');
      }
      print('===================\n');
    }
  }
}