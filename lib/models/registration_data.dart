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
  double? freeTimePerWeek;
  String? workoutDifficulty;
  String? location;

  // Step 3 - Healthy Habits
  List<String> healthyHabits;

  // Step 4 - Account Information
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
    this.freeTimePerWeek,
    this.workoutDifficulty,
    this.location,
    this.healthyHabits = const [],
    this.email,
    this.password,
    this.termsAccepted = false,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fitness_goal': fitnessGoal,
      'weight': currentWeight,
      'weight_unit': weightUnit,
      'goal_weight': goalWeight,
      'height': height,
      'height_unit': heightUnit,
      'estimated_daily_steps': estimatedDailySteps,
      'free_time_per_week': freeTimePerWeek,
      'workout_difficulty': workoutDifficulty,
      'location': location,
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
        freeTimePerWeek != null &&
        freeTimePerWeek! > 0 &&
        workoutDifficulty != null &&
        workoutDifficulty!.isNotEmpty &&
        location != null &&
        location!.isNotEmpty;
  }

  bool isStep3Valid() {
    return healthyHabits.isNotEmpty;
  }

  bool isStep4Valid() {
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
    freeTimePerWeek = null;
    workoutDifficulty = null;
    location = null;
    healthyHabits = [];
    email = null;
    password = null;
    termsAccepted = false;
  }
}
