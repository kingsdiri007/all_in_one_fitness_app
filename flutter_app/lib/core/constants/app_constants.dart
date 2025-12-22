class AppConstants {
  // Nom de l'application
  static const String appName = 'FitLife';

  // Objectifs disponibles
  static const List<Map<String, dynamic>> fitnessGoals = [
    {
      'id': 'lose_weight',
      'title': 'Perdre du poids',
      'description': 'Brûler des graisses et affiner ma silhouette',
      'icon': 'trending_down',
    },
    {
      'id': 'gain_muscle',
      'title': 'Prendre du muscle',
      'description': 'Développer ma masse musculaire',
      'icon': 'fitness_center',
    },
    {
      'id': 'stay_fit',
      'title': 'Rester en forme',
      'description': 'Maintenir mon niveau de forme actuel',
      'icon': 'favorite',
    },
    {
      'id': 'improve_health',
      'title': 'Améliorer ma santé',
      'description': 'Adopter un mode de vie plus sain',
      'icon': 'health_and_safety',
    },
  ];

  // Niveaux d'activité
  static const List<Map<String, dynamic>> activityLevels = [
    {'id': 1, 'title': 'Sédentaire', 'description': 'Peu ou pas d\'exercice'},
    {
      'id': 2,
      'title': 'Légèrement actif',
      'description': 'Exercice léger 1-3 fois/semaine',
    },
    {
      'id': 3,
      'title': 'Modérément actif',
      'description': 'Exercice modéré 3-5 fois/semaine',
    },
    {
      'id': 4,
      'title': 'Très actif',
      'description': 'Exercice intense 6-7 fois/semaine',
    },
    {
      'id': 5,
      'title': 'Extrêmement actif',
      'description': 'Exercice très intense quotidien',
    },
  ];
}
