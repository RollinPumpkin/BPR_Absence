// Server Configuration for Firebase NPM Server Integration
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ServerConfig {
  // ============================================
  // PRODUCTION SERVER CONFIGURATION
  // ============================================
  static const String productionServerHost = 'api.khatulistiwareklame.com'; // ✅ Production API
  static const int productionServerPort = 443; // Port 443 untuk HTTPS
  static const bool useHttpsInProduction = true; // Gunakan HTTPS untuk production
  
  // ============================================
  // DEVELOPMENT/LOCAL SERVER CONFIGURATION
  // ============================================
  static const String localServerHost = '192.168.68.130'; // IP lokal untuk WiFi development
  static const int localServerPort = 3000;
  
  // ============================================
  // NGROK CONFIGURATION (Temporary Internet Access)
  // ============================================
  // Set true untuk akses via internet (data seluler) tanpa deploy ke cPanel
  static const bool useNgrok = false; // ✅ Production mode: Ngrok disabled
  static const String ngrokUrl = 'boyish-corneal-claudio.ngrok-free.dev';
  static const bool ngrokUseHttps = true;
  
  // Firebase NPM Server Configuration (Legacy)
  static const String firebaseServerHost = 'localhost';
  static const int firebaseServerPort = 3000;
  
  // ============================================
  // DYNAMIC SERVER URL (Smart Routing)
  // ============================================
  static String get firebaseServerUrl {
    // 1. NGROK MODE: Untuk development via internet (data seluler)
    if (useNgrok) {
      final protocol = ngrokUseHttps ? 'https' : 'http';
      print('🌐 Using NGROK: $protocol://$ngrokUrl');
      return '$protocol://$ngrokUrl';
    }
    
    // 2. PRODUCTION MODE: Untuk app yang sudah di-deploy
    // Cek apakah sudah dalam mode release build
    if (kReleaseMode || useHttpsInProduction) {
      final protocol = useHttpsInProduction ? 'https' : 'http';
      print('🚀 Using PRODUCTION: $protocol://$productionServerHost');
      return '$protocol://$productionServerHost';
    }
    
    // 3. DEVELOPMENT MODE: Localhost atau Local WiFi IP
    // Desktop/Web: gunakan localhost
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      print('💻 Using LOCALHOST: http://$firebaseServerHost:$firebaseServerPort');
      return 'http://$firebaseServerHost:$firebaseServerPort';
    }
    
    // Mobile: gunakan IP lokal WiFi
    print('📱 Using LOCAL WIFI: http://$localServerHost:$localServerPort');
    return 'http://$localServerHost:$localServerPort';
  }
  
  // Flutter Web Server Configuration  
  static const String flutterWebHost = 'localhost';
  static const int flutterWebPort = 8080;
  static const String flutterWebUrl = 'http://$flutterWebHost:$flutterWebPort';
  
  // API Endpoints
  static const String apiBasePath = '/api';
  static String get firebaseApiUrl => '$firebaseServerUrl$apiBasePath';
  
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
    return firebaseApiUrl;
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