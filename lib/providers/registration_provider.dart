import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../services/auth_service.dart';

class RegistrationProvider with ChangeNotifier {
  int _currentStep = 0;
  final RegistrationData _data = RegistrationData();
  bool _isLoading = false;
  String? _errorMessage;

  int get currentStep => _currentStep;
  RegistrationData get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculate progress based on current step (0.20, 0.40, 0.60, 0.80, 1.0)
  double get progress => (_currentStep + 1) * 0.20;

  // Set fitness goal (Step 1)
  void setGoal(String goal) {
    _data.fitnessGoal = goal;
    notifyListeners();
  }

  // Set personal information (Step 2)
  void setPersonalInfo({
    required double currentWeight,
    required String weightUnit,
    required double goalWeight,
    required double height,
    required String heightUnit,
    required int estimatedDailySteps,
    required String workoutDifficulty,
    required String location,
  }) {
    _data.currentWeight = currentWeight;
    _data.weightUnit = weightUnit;
    _data.goalWeight = goalWeight;
    _data.height = height;
    _data.heightUnit = heightUnit;
    _data.estimatedDailySteps = estimatedDailySteps;
    _data.workoutDifficulty = workoutDifficulty;
    _data.location = location;
    notifyListeners();
  }

  // Set workout schedule (Step 3 - NEW)
  void setWorkoutDay(String day, String? timeSlot) {
    _data.workoutSchedule[day] = timeSlot;
    notifyListeners();
  }

  void clearWorkoutDay(String day) {
    _data.workoutSchedule[day] = null;
    notifyListeners();
  }

  // Toggle healthy habit (Step 4)
  void toggleHealthyHabit(String habit) {
    final habits = List<String>.from(_data.healthyHabits);
    if (habits.contains(habit)) {
      habits.remove(habit);
    } else {
      habits.add(habit);
    }
    _data.healthyHabits = habits;
    notifyListeners();
  }

  // Set account information (Step 5)
  void setAccountInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool termsAccepted,
  }) {
    _data.firstName = firstName;
    _data.lastName = lastName;
    _data.email = email;
    _data.password = password;
    _data.termsAccepted = termsAccepted;
    notifyListeners();
  }

  // Navigate to next step
  void nextStep() {
    if (_currentStep < 4) {
      // Changed from 3 to 4
      _currentStep++;
      notifyListeners();
    }
  }

  // Navigate to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Check if can proceed from current step
  bool canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _data.isStep1Valid();
      case 1:
        return _data.isStep2Valid();
      case 2:
        return _data.isStep3Valid();
      case 3:
        return _data.isStep4Valid();
      case 4:
        return _data.isStep5Valid();
      default:
        return false;
    }
  }

  // Register user
  Future<bool> register() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.register(_data);

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
      _errorMessage = 'Registration failed:  ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset registration data
  void reset() {
    _currentStep = 0;
    _data.reset();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
