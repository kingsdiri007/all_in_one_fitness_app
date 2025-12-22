class UserModel {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String? fitnessGoal;
  final double? goalWeight;
  final int? estimatedDailySteps;
  final double? freeTimePerWeek;
  final String? workoutDifficulty;
  final String? location;
  final List<String>? healthyHabits;
  final String? weightUnit;
  final String? heightUnit;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.fitnessGoal,
    this.goalWeight,
    this.estimatedDailySteps,
    this.freeTimePerWeek,
    this.workoutDifficulty,
    this.location,
    this.healthyHabits,
    this.weightUnit,
    this.heightUnit,
    this.createdAt,
  });

  // Getter for full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email.split('@')[0]; // Use email prefix if no name available
  }

  // Factory constructor to create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      age: json['age'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      gender: json['gender'],
      fitnessGoal: json['fitness_goal'] ?? json['fitnessGoal'],
      goalWeight: json['goal_weight']?.toDouble() ?? json['goalWeight']?.toDouble(),
      estimatedDailySteps: json['estimated_daily_steps'] ?? json['estimatedDailySteps'],
      freeTimePerWeek: json['free_time_per_week']?.toDouble() ?? json['freeTimePerWeek']?.toDouble(),
      workoutDifficulty: json['workout_difficulty'] ?? json['workoutDifficulty'],
      location: json['location'],
      healthyHabits: json['healthy_habits'] != null
          ? List<String>.from(json['healthy_habits'])
          : (json['healthyHabits'] != null
              ? List<String>.from(json['healthyHabits'])
              : null),
      weightUnit: json['weight_unit'] ?? json['weightUnit'] ?? 'kg',
      heightUnit: json['height_unit'] ?? json['heightUnit'] ?? 'cm',
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'fitness_goal': fitnessGoal,
      'goal_weight': goalWeight,
      'estimated_daily_steps': estimatedDailySteps,
      'free_time_per_week': freeTimePerWeek,
      'workout_difficulty': workoutDifficulty,
      'location': location,
      'healthy_habits': healthyHabits,
      'weight_unit': weightUnit,
      'height_unit': heightUnit,
      'created_at': createdAt,
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? fitnessGoal,
    double? goalWeight,
    int? estimatedDailySteps,
    double? freeTimePerWeek,
    String? workoutDifficulty,
    String? location,
    List<String>? healthyHabits,
    String? weightUnit,
    String? heightUnit,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      goalWeight: goalWeight ?? this.goalWeight,
      estimatedDailySteps: estimatedDailySteps ?? this.estimatedDailySteps,
      freeTimePerWeek: freeTimePerWeek ?? this.freeTimePerWeek,
      workoutDifficulty: workoutDifficulty ?? this.workoutDifficulty,
      location: location ?? this.location,
      healthyHabits: healthyHabits ?? this.healthyHabits,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
