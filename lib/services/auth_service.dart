import '../models/user_model.dart';
import '../models/registration_data.dart';
import '../models/gym_model.dart';
import 'api_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // Register new user
  static Future<Map<String, dynamic>> register(RegistrationData data) async {
    try {
      final response = await ApiService.post(
        ApiConfig.authRegister,
        data.toJson(),
      );
      return {'success': true, 'message': response['message'] ?? 'Registration successful'};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Registration failed: ${e.toString()}'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        ApiConfig.authLogin,
        {'email': email, 'password': password},
      );

      // Extract token and user data
      final token = response['access_token'];
      final userData = response['user'];

      if (token != null) {
        // Save token
        await StorageService.saveToken(token);

        // Save user data if available
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          await StorageService.saveUser(user);
        }

        return {
          'success': true,
          'token': token,
          'user': userData != null ? UserModel.fromJson(userData) : null,
        };
      } else {
        return {'success': false, 'error': 'No token received'};
      }
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Login failed: ${e.toString()}'};
    }
  }

  // Get current user
  static Future<UserModel?> getCurrentUser() async {
    try {
      final response = await ApiService.get(
        ApiConfig.authMe,
        requiresAuth: true,
      );

      if (response != null) {
        final user = UserModel.fromJson(response);
        await StorageService.saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      // If API call fails, try to get user from storage
      return await StorageService.getUser();
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await ApiService.post(
        ApiConfig.authForgotPassword,
        {'email': email},
      );
      return {'success': true, 'message': response['message'] ?? 'Password reset email sent'};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Request failed: ${e.toString()}'};
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Get nearby gyms
  static Future<List<GymModel>> getNearbyGyms(String location) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.gymsNearby}?location=$location',
        requiresAuth: true,
      );

      if (response is List) {
        return response.map((gym) => GymModel.fromJson(gym)).toList();
      }
      return [];
    } catch (e) {
      // Return mock data if API fails (for demo purposes)
      return _getMockGyms();
    }
  }

  // Mock gym data for demo
  static List<GymModel> _getMockGyms() {
    return [
      GymModel(
        id: 1,
        name: 'FitZone Gym',
        address: '123 Fitness Street, Downtown',
        distance: '0.5 km',
        phone: '+1 (555) 123-4567',
        rating: 4.5,
        amenities: ['WiFi', 'Parking', 'Showers', 'Personal Training'],
      ),
      GymModel(
        id: 2,
        name: 'PowerHouse Fitness',
        address: '456 Strength Ave, City Center',
        distance: '1.2 km',
        phone: '+1 (555) 234-5678',
        rating: 4.8,
        amenities: ['Pool', 'Sauna', 'Cafe', 'Group Classes'],
      ),
      GymModel(
        id: 3,
        name: 'Elite Fitness Center',
        address: '789 Health Boulevard, Uptown',
        distance: '2.0 km',
        phone: '+1 (555) 345-6789',
        rating: 4.3,
        amenities: ['Yoga Studio', 'Cardio Zone', 'Free Weights', 'Lockers'],
      ),
    ];
  }
}
