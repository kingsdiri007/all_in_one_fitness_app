import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../home/home_screen.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Données utilisateur
  UserModel _user = UserModel();

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _complete() {
    // Mettre à jour le nom
    _user = _user.copyWith(name: _nameController.text);

    // Naviguer vers l'écran principal
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen(user: _user)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _previousStep,
              )
            : null,
        title: Text('Étape ${_currentStep + 1} / $_totalSteps'),
      ),
      body: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.textSecondary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),

          // Contenu
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGenderStep(),
                _buildMeasurementsStep(),
                _buildGoalStep(),
                _buildActivityStep(),
                _buildNameStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Étape 1: Genre
  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Quel est votre genre ?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cela nous aide à personnaliser vos programmes',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Homme',
                  icon: Icons.male_rounded,
                  isSelected: _user.gender == 'male',
                  onTap: () {
                    setState(() {
                      _user = _user.copyWith(gender: 'male');
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderCard(
                  label: 'Femme',
                  icon: Icons.female_rounded,
                  isSelected: _user.gender == 'female',
                  onTap: () {
                    setState(() {
                      _user = _user.copyWith(gender: 'female');
                    });
                  },
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _user.gender != null ? _nextStep : null,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  // Étape 2: Mesures
  Widget _buildMeasurementsStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Vos mesures',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ces informations nous aident à calculer vos besoins',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 40),

            // Âge
            _buildInputField(
              label: 'Âge',
              hint: 'Entrez votre âge',
              suffix: 'ans',
              controller: _ageController,
              onChanged: (value) {
                final age = int.tryParse(value);
                if (age != null) {
                  setState(() {
                    _user = _user.copyWith(age: age);
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // Taille
            _buildInputField(
              label: 'Taille',
              hint: 'Entrez votre taille',
              suffix: 'cm',
              controller: _heightController,
              onChanged: (value) {
                final height = double.tryParse(value);
                if (height != null) {
                  setState(() {
                    _user = _user.copyWith(height: height);
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // Poids
            _buildInputField(
              label: 'Poids',
              hint: 'Entrez votre poids',
              suffix: 'kg',
              controller: _weightController,
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null) {
                  setState(() {
                    _user = _user.copyWith(weight: weight);
                  });
                }
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _user.age != null &&
                        _user.height != null &&
                        _user.weight != null
                    ? _nextStep
                    : null,
                child: const Text('Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required String suffix,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Étape 3: Objectif
  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Quel est votre objectif ?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nous adapterons votre programme en conséquence',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              itemCount: AppConstants.fitnessGoals.length,
              itemBuilder: (context, index) {
                final goal = AppConstants.fitnessGoals[index];
                final isSelected = _user.goal == goal['id'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GoalCard(
                    title: goal['title'],
                    description: goal['description'],
                    icon: _getIconData(goal['icon']),
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _user = _user.copyWith(goal: goal['id']);
                      });
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _user.goal != null ? _nextStep : null,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'trending_down':
        return Icons.trending_down_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // Étape 4: Niveau d'activité
  Widget _buildActivityStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Votre niveau d\'activité ? ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cela nous aide à calculer vos besoins caloriques',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              itemCount: AppConstants.activityLevels.length,
              itemBuilder: (context, index) {
                final level = AppConstants.activityLevels[index];
                final isSelected = _user.activityLevel == level['id'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ActivityCard(
                    title: level['title'],
                    description: level['description'],
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _user = _user.copyWith(activityLevel: level['id']);
                      });
                    },
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _user.activityLevel != null ? _nextStep : null,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  // Étape 5: Nom
  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Comment vous appelez-vous ?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pour personnaliser votre expérience',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 40),

          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Votre prénom',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),

          const Spacer(),

          // Résumé
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Résumé de votre profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Genre',
                  _user.gender == 'male' ? 'Homme' : 'Femme',
                ),
                _buildSummaryRow('Âge', '${_user.age} ans'),
                _buildSummaryRow(
                  'Taille',
                  '${_user.height?.toStringAsFixed(0)} cm',
                ),
                _buildSummaryRow(
                  'Poids',
                  '${_user.weight?.toStringAsFixed(1)} kg',
                ),
                if (_user.bmi != null)
                  _buildSummaryRow(
                    'IMC',
                    '${_user.bmi!.toStringAsFixed(1)} (${_user.bmiCategory})',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nameController.text.isNotEmpty ? _complete : null,
              child: const Text('Terminer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour sélection du genre
class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour sélection d'objectif
class _GoalCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Widget pour sélection niveau d'activité
class _ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
