// Server Configuration for Firebase NPM Server Integration
class ServerConfig {
  // Firebase NPM Server Configuration
  static const String firebaseServerHost = 'localhost';
  static const int firebaseServerPort = 3000;
  static const String firebaseServerUrl = 'http://$firebaseServerHost:$firebaseServerPort';
  
  // Flutter Web Server Configuration  
  static const String flutterWebHost = 'localhost';
  static const int flutterWebPort = 8080;
  static const String flutterWebUrl = 'http://$flutterWebHost:$flutterWebPort';
  
  // API Endpoints
  static const String apiBasePath = '/api';
  static const String firebaseApiUrl = '$firebaseServerUrl$apiBasePath';
  
  // Development Mode Settings
  static const bool isDevelopmentMode = true;
  static const bool useFirebaseNpmServer = true;
  static const bool enableHotReload = true;
  static const bool enableDebugLogging = true;
  
  // CORS Configuration for development
  static const List<String> allowedOrigins = [
    flutterWebUrl,
    'http://localhost:8080',
    'http://127.0.0.1:8080',
  ];
  
  // Headers for Firebase NPM Server
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };
  
  // Get the current API URL based on configuration
  static String get currentApiUrl {
    if (isDevelopmentMode && useFirebaseNpmServer) {
      return firebaseApiUrl;
    }
    return firebaseApiUrl; // Default to Firebase NPM server
  }
  
  // Print current configuration
  static void printConfiguration() {
    if (enableDebugLogging) {
      print('🔧 Server Configuration:');
      print('📡 Firebase NPM Server: $firebaseServerUrl');
      print('🌐 Flutter Web Server: $flutterWebUrl');
      print('🔗 API Base URL: $currentApiUrl');
      print('🛠️ Development Mode: $isDevelopmentMode');
      print('🔥 Using Firebase NPM Server: $useFirebaseNpmServer');
    }
  }
}