import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/gym_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);

      if (result['success'] == true) {
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load user data
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      _errorMessage = 'Failed to load user: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.forgotPassword(email);

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Request failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        await loadUser();
        return _user != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get nearby gyms
  Future<List<GymModel>> getNearbyGyms(String location) async {
    try {
      return await AuthService.getNearbyGyms(location);
    } catch (e) {
      _errorMessage = 'Failed to load gyms: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
