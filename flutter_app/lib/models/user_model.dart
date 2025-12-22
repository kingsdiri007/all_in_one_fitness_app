class UserModel {
  final String? name;
  final int? age;
  final String? gender;
  final double? height; // en cm
  final double? weight; // en kg
  final String? goal;
  final int? activityLevel;

  UserModel({
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
  });

  // Calculer l'IMC
  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // Catégorie d'IMC
  String? get bmiCategory {
    if (bmi == null) return null;
    if (bmi! < 18.5) return 'Insuffisance pondérale';
    if (bmi! < 25) return 'Poids normal';
    if (bmi! < 30) return 'Surpoids';
    return 'Obésité';
  }

  // Calculer les calories quotidiennes (formule de Mifflin-St Jeor)
  int? get dailyCalories {
    if (age == null || height == null || weight == null || gender == null || activityLevel == null) {
      return null;
    }
    
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }
    
    // Multiplicateur d'activité
    final activityMultipliers = [1.2, 1.375, 1.55, 1.725, 1.9];
    final multiplier = activityMultipliers[activityLevel! - 1];
    
    double tdee = bmr * multiplier;
    
    // Ajuster selon l'objectif
    if (goal == 'lose_weight') {
      tdee -= 500; // Déficit calorique
    } else if (goal == 'gain_muscle') {
      tdee += 300; // Surplus calorique
    }
    
    return tdee.round();
  }

  // Copier avec modifications
  UserModel copyWith({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
    int? activityLevel,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  // Vérifier si le profil est complet
  bool get isComplete {
    return name != null &&
        age != null &&
        gender != null &&
        height != null &&
        weight != null &&
        goal != null &&
        activityLevel != null;
  }
}