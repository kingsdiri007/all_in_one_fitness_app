class AppConstants {
  // Fitness Goals
  static const List<String> fitnessGoals = [
    'Lose Weight',
    'Gain Muscle',
    'Maintain Figure',
    'Gain Weight',
  ];

  // Workout Difficulty Levels
  static const List<String> workoutDifficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // Healthy Habits
  static const List<String> healthyHabits = [
    'Eat more protein',
    'Track nutrients',
    'Drink more water',
    'Get better sleep',
    'Reduce sugar intake',
    'Eat more vegetables',
    'Increase cardio',
    'Build strength',
  ];

  // Weight Units
  static const List<String> weightUnits = ['kg', 'lbs'];

  // Height Units
  static const List<String> heightUnits = ['cm', 'ft'];

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // API Response Keys
  static const String accessTokenKey = 'access_token';
  static const String messageKey = 'message';
  static const String errorKey = 'error';
  static const String userDataKey = 'user';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const double minWeight = 0.0;
  static const double maxWeight = 500.0;
  static const double minHeight = 0.0;
  static const double maxHeight = 300.0;

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registrationRoute = '/registration';
  static const String homeRoute = '/home';
  static const String dashboardRoute = '/dashboard';

  // App Info
  static const String appName = 'All-in-One Fitness App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Start Your Journey With Us';
}
