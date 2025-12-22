class ApiConfig {
  // Base URL for API
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000';
  
  // For iOS Simulator - uncomment if using iOS
  // static const String baseUrl = 'http://localhost:5000';
  
  // For Physical Device - replace with your computer's IP
  // static const String baseUrl = 'http://192.168.1.XXX:5000';
  
  // For Production
  // static const String baseUrl = 'https://your-api-domain.com';

  // API Endpoints
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authMe = '/api/auth/me';
  static const String authForgotPassword = '/api/auth/forgot-password';
  static const String gymsNearby = '/api/gyms/nearby';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithToken(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
