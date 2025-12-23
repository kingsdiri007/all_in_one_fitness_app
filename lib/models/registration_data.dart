class RegistrationData {
  // Step 1 - Goal
  String? fitnessGoal;

  // Step 2 - Personal Information
  double? currentWeight;
  String weightUnit;
  double? goalWeight;
  double? height;
  String heightUnit;
  int? estimatedDailySteps;
  String? workoutDifficulty;
  String? location;

  // Step 3 - Workout Schedule (NEW)
  Map<String, String?> workoutSchedule;

  // Step 4 - Healthy Habits
  List<String> healthyHabits;

  // Step 5 - Account Information
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  bool termsAccepted;

  RegistrationData({
    this.fitnessGoal,
    this.currentWeight,
    this.weightUnit = 'kg',
    this.goalWeight,
    this.height,
    this.heightUnit = 'cm',
    this.estimatedDailySteps,
    this.workoutDifficulty,
    this.location,
    Map<String, String?>? workoutSchedule,
    this.healthyHabits = const [],
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.termsAccepted = false,
  }) : workoutSchedule = workoutSchedule ??
            {
              'Monday': null,
              'Tuesday': null,
              'Wednesday': null,
              'Thursday': null,
              'Friday': null,
              'Saturday': null,
              'Sunday': null,
            };

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'fitness_goal': fitnessGoal,
      'weight': currentWeight,
      'weight_unit': weightUnit,
      'goal_weight': goalWeight,
      'height': height,
      'height_unit': heightUnit,
      'estimated_daily_steps': estimatedDailySteps,
      'workout_difficulty': workoutDifficulty,
      'location': location,
      'workout_schedule': workoutSchedule, // NEW
      'healthy_habits': healthyHabits,
    };
  }

  // Validation methods for each step
  bool isStep1Valid() {
    return fitnessGoal != null && fitnessGoal!.isNotEmpty;
  }

  bool isStep2Valid() {
    return currentWeight != null &&
        currentWeight! > 0 &&
        goalWeight != null &&
        goalWeight! > 0 &&
        height != null &&
        height! > 0 &&
        estimatedDailySteps != null &&
        estimatedDailySteps! >= 0 &&
        workoutDifficulty != null &&
        workoutDifficulty!.isNotEmpty &&
        location != null &&
        location!.isNotEmpty;
  }

  bool isStep3Valid() {
    // At least one day must be selected
    return workoutSchedule.values.any((timeSlot) => timeSlot != null);
  }

  bool isStep4Valid() {
    return healthyHabits.isNotEmpty;
  }

  bool isStep5Valid() {
    if (firstName == null || firstName!.isEmpty) return false;
    if (lastName == null || lastName!.isEmpty) return false;
    if (email == null || email!.isEmpty) return false;
    if (password == null || password!.isEmpty) return false;
    if (password!.length < 8) return false;
    if (!termsAccepted) return false;

    // Validate email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email!);
  }

  // Reset all data
  void reset() {
    fitnessGoal = null;
    currentWeight = null;
    weightUnit = 'kg';
    goalWeight = null;
    height = null;
    heightUnit = 'cm';
    estimatedDailySteps = null;
    workoutDifficulty = null;
    location = null;
    workoutSchedule = {
      'Monday': null,
      'Tuesday': null,
      'Wednesday': null,
      'Thursday': null,
      'Friday': null,
      'Saturday': null,
      'Sunday': null,
    };
    healthyHabits = [];
    firstName = null;
    lastName = null;
    email = null;
    password = null;
    termsAccepted = false;
  }
}
