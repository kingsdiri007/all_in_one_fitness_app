import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../config/theme/app_colors.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(), bottomNavigationBar: _buildBottomNav());
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _DashboardTab(user: widget.user);
      case 1:
        return const _WorkoutTab();
      case 2:
        return const _NutritionTab();
      case 3:
        return const _ChatTab();
      case 4:
        return _ProfileTab(user: widget.user);
      default:
        return _DashboardTab(user: widget.user);
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'Accueil'),
              _buildNavItem(1, Icons.fitness_center_rounded, 'Workout'),
              _buildCenterNavItem(),
              _buildNavItem(3, Icons.chat_bubble_rounded, 'Coach'),
              _buildNavItem(4, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.restaurant_menu_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// Tab Dashboard
class _DashboardTab extends StatelessWidget {
  final UserModel user;

  const _DashboardTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${user.name ?? 'Utilisateur'} 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Prêt pour votre entraînement ? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Carte de statistiques quotidiennes
            _buildDailyStatsCard(),

            const SizedBox(height: 24),

            // Entraînement du jour
            _buildSectionHeader('Entraînement du jour', 'Voir tout'),
            const SizedBox(height: 12),
            _buildWorkoutCard(),

            const SizedBox(height: 24),

            // Nutrition
            _buildSectionHeader('Nutrition', 'Voir tout'),
            const SizedBox(height: 12),
            _buildNutritionCard(user),

            const SizedBox(height: 24),

            // Actions rapides
            _buildSectionHeader('Actions rapides', ''),
            const SizedBox(height: 12),
            _buildQuickActions(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.directions_walk_rounded, '8,432', 'Pas', 0.7),
          _buildStatItem(
            Icons.local_fire_department_rounded,
            '1,842',
            'Calories',
            0.6,
          ),
          _buildStatItem(Icons.water_drop_rounded, '6/8', 'Verres', 0.75),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    double progress,
  ) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 35,
          lineWidth: 4,
          percent: progress,
          center: Icon(icon, color: Colors.white, size: 28),
          progressColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(onPressed: () {}, child: Text(actionText)),
      ],
    );
  }

  Widget _buildWorkoutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upper Body Workout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '6 exercices • 45 min',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(UserModel user) {
    final dailyCalories = user.dailyCalories ?? 2000;
    final consumed = 1450;
    final progress = consumed / dailyCalories;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calories consommées',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '$consumed / $dailyCalories kcal',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protéines', '85g', AppColors.primary),
              _buildMacroItem('Glucides', '180g', AppColors.secondary),
              _buildMacroItem('Lipides', '55g', AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.camera_alt_rounded,
        'label': 'Scanner',
        'color': AppColors.accent,
      },
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'Exercice',
        'color': AppColors.primary,
      },
      {'icon': Icons.water_drop_outlined, 'label': 'Eau', 'color': Colors.blue},
      {
        'icon': Icons.scale_rounded,
        'label': 'Poids',
        'color': AppColors.secondary,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action['label'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Tab Workout (placeholder)
class _WorkoutTab extends StatelessWidget {
  const _WorkoutTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Workout Tab\n(À implémenter)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// Tab Nutrition (placeholder)
class _NutritionTab extends StatelessWidget {
  const _NutritionTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nutrition Tab\n(À implémenter)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// Tab Chat (placeholder)
class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Coach IA Tab\n(À implémenter)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// Tab Profile

class _ProfileTab extends StatelessWidget {
  final UserModel user;

  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar et nom
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  user.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              user.name ?? 'Utilisateur',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _getGoalText(user.goal),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            // Statistiques
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes informations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.cake_rounded, 'Âge', '${user.age} ans'),
                  _buildInfoRow(
                    Icons.height_rounded,
                    'Taille',
                    '${user.height?.toStringAsFixed(0)} cm',
                  ),
                  _buildInfoRow(
                    Icons.monitor_weight_rounded,
                    'Poids',
                    '${user.weight?.toStringAsFixed(1)} kg',
                  ),
                  _buildInfoRow(
                    Icons.speed_rounded,
                    'IMC',
                    '${user.bmi?.toStringAsFixed(1)} (${user.bmiCategory})',
                  ),
                  _buildInfoRow(
                    Icons.local_fire_department_rounded,
                    'Calories/jour',
                    '${user.dailyCalories} kcal',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Options du menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.settings_rounded, 'Paramètres', () {}),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.notifications_rounded,
                    'Notifications',
                    () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(Icons.help_rounded, 'Aide', () {}),
                  _buildDivider(),
                  _buildMenuItem(Icons.info_rounded, 'À propos', () {}),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.logout_rounded,
                    'Déconnexion',
                    () {},
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getGoalText(String? goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Objectif : Perdre du poids';
      case 'gain_muscle':
        return 'Objectif : Prendre du muscle';
      case 'stay_fit':
        return 'Objectif : Rester en forme';
      case 'improve_health':
        return 'Objectif : Améliorer ma santé';
      default:
        return 'Aucun objectif défini';
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.shade200);
  }
}
