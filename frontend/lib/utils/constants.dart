class AppConstants {
  // API Base URL - Update this to match your Django backend
  static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // For iOS simulator
  // static const String baseUrl = 'http://your-ip:8000'; // For physical device
  
  // API Endpoints
  static const String loginUrl = '/api/auth/login/';
  static const String registerUrl = '/api/auth/register/';
  static const String userProfileUrl = '/api/auth/profile/';

  static const String transactionsUrl = '/api/transactions/';
  static const String receiptProcessUrl = '/api/receipts/process/';

  
  // App Colors
  static const int primaryColor = 0xFF2196F3;
  static const int accentColor = 0xFF03DAC6;
  static const int backgroundColor = 0xFFF5F5F5;
  static const int cardColor = 0xFFFFFFFF;
  static const int textColor = 0xFF212121;
  static const int secondaryTextColor = 0xFF757575;
  
  // App Dimensions
  static const double padding = 16.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 50.0;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
}
