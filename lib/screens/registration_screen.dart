import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/goal_card.dart';
import '../widgets/habit_checkbox.dart';
import '../widgets/progress_bar.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late PageController _pageController;

  // Step 2 Controllers
  final _currentWeightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _stepsController = TextEditingController();

  // Step 4 Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _step2FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentWeightController.dispose();
    _goalWeightController.dispose();
    _heightController.dispose();
    _stepsController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create'),
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AnimatedProgressBar(
              progress: provider.progress,
            ),
          ),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(provider),
                _buildStep2(provider),
                _buildStep3(provider), // NEW:  Workout Schedule
                _buildStep4(provider), // Now:  Healthy Habits
                _buildStep5(provider), // Now: Account Setup
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: Choose Goal
  Widget _buildStep1(RegistrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose Your Goal',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              GoalCard(
                title: 'Lose Weight',
                icon: Icons.trending_down,
                isSelected: provider.data.fitnessGoal == 'Lose Weight',
                onTap: () => provider.setGoal('Lose Weight'),
              ),
              GoalCard(
                title: 'Gain Muscle',
                icon: Icons.fitness_center,
                isSelected: provider.data.fitnessGoal == 'Gain Muscle',
                onTap: () => provider.setGoal('Gain Muscle'),
              ),
              GoalCard(
                title: 'Maintain Figure',
                icon: Icons.favorite,
                isSelected: provider.data.fitnessGoal == 'Maintain Figure',
                onTap: () => provider.setGoal('Maintain Figure'),
              ),
              GoalCard(
                title: 'Gain Weight',
                icon: Icons.trending_up,
                isSelected: provider.data.fitnessGoal == 'Gain Weight',
                onTap: () => provider.setGoal('Gain Weight'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Next',
            onPressed: provider.canProceedFromStep(0)
                ? () {
                    provider.nextStep();
                    _animateToPage(1);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Step 2: Personal Information
  Widget _buildStep2(RegistrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Information',
              style: AppTheme.headingStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Current Weight
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Current Weight',
                    hint: 'Enter weight',
                    controller: _currentWeightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.validateWeight,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unit',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: provider.data.weightUnit,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        items: AppConstants.weightUnits.map((unit) {
                          return DropdownMenuItem(
                              value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.data.weightUnit = value;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Goal Weight
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Goal Weight',
                    hint: 'Enter goal',
                    controller: _goalWeightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.validateWeight,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unit',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: provider.data.weightUnit,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        items: AppConstants.weightUnits.map((unit) {
                          return DropdownMenuItem(
                              value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.data.weightUnit = value;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Height
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Height',
                    hint: 'Enter height',
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.validateHeight,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unit',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: provider.data.heightUnit,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        items: AppConstants.heightUnits.map((unit) {
                          return DropdownMenuItem(
                              value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            provider.data.heightUnit = value;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Estimated Daily Steps
            CustomTextField(
              label: 'Estimated Daily Steps',
              hint: 'e.g., 10000',
              controller: _stepsController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateInteger(value, 'Steps'),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 20),

            // Workout Difficulty
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Difficulty',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: provider.data.workoutDifficulty,
                  decoration: const InputDecoration(
                    hintText: 'Select difficulty',
                  ),
                  validator: (value) =>
                      Validators.validateRequired(value, 'Workout difficulty'),
                  items: AppConstants.workoutDifficulties.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.data.workoutDifficulty = value;
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Location
            const SizedBox(height: 20),

// Location - Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: provider.data.location?.isNotEmpty == true
                        ? provider.data.location
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Select your city',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                    icon: Icon(Icons.arrow_drop_down,
                        color: AppTheme.primaryColor),
                    isExpanded: true,
                    items: [
                      'Tunis',
                      'Sfax',
                      'Sousse',
                      'Kairouan',
                      'Bizerte',
                      'Gabès',
                      'Ariana',
                      'Gafsa',
                      'Monastir',
                      'Ben Arous',
                      'Kasserine',
                      'Médenine',
                      'Nabeul',
                      'Tataouine',
                      'Béja',
                      'Jendouba',
                      'Mahdia',
                      'Sidi Bouzid',
                      'Zaghouan',
                      'Siliana',
                      'Kébili',
                      'Tozeur',
                      'Manouba',
                      'Kef',
                    ].map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.data.location = value;
                        provider.setPersonalInfo(
                          currentWeight: provider.data.currentWeight ?? 0,
                          weightUnit: provider.data.weightUnit,
                          goalWeight: provider.data.goalWeight ?? 0,
                          height: provider.data.height ?? 0,
                          heightUnit: provider.data.heightUnit,
                          estimatedDailySteps:
                              provider.data.estimatedDailySteps ?? 0,
                          workoutDifficulty:
                              provider.data.workoutDifficulty ?? '',
                          location: value,
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a city';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Back',
                    isOutlined: true,
                    onPressed: () {
                      provider.previousStep();
                      _animateToPage(0);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      if (_step2FormKey.currentState!.validate()) {
                        provider.setPersonalInfo(
                          currentWeight:
                              double.parse(_currentWeightController.text),
                          weightUnit: provider.data.weightUnit,
                          goalWeight: double.parse(_goalWeightController.text),
                          height: double.parse(_heightController.text),
                          heightUnit: provider.data.heightUnit,
                          estimatedDailySteps: int.parse(_stepsController.text),
                          workoutDifficulty: provider.data.workoutDifficulty!,
                          location: provider.data.location ?? '',
                        );
                        provider.nextStep();
                        _animateToPage(2);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Workout Schedule
  Widget _buildStep3(RegistrationProvider provider) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final timeSlots = ['Morning', 'Midday', 'Evening', 'Night'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Workout Schedule',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select your available workout days and times',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Days list
          ...days.map((day) {
            final isSelected = provider.data.workoutSchedule[day] != null;
            final selectedTime = provider.data.workoutSchedule[day];

            return Column(
              children: [
                // Day checkbox
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.05)
                        : Colors.white,
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      day,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    value: isSelected,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      if (value == true) {
                        // Select first time slot by default
                        provider.setWorkoutDay(day, timeSlots[0]);
                      } else {
                        provider.clearWorkoutDay(day);
                      }
                    },
                  ),
                ),

                // Time slot selection (show only if day is selected)
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeSlots.map((timeSlot) {
                        final isTimeSelected = selectedTime == timeSlot;
                        return ChoiceChip(
                          label: Text(timeSlot),
                          selected: isTimeSelected,
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color:
                                isTimeSelected ? Colors.white : Colors.black87,
                            fontWeight: isTimeSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              provider.setWorkoutDay(day, timeSlot);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            );
          }).toList(),

          const SizedBox(height: 24),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  isOutlined: true,
                  onPressed: () {
                    provider.previousStep();
                    _animateToPage(1);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
                    if (provider.canProceedFromStep(2)) {
                      provider.nextStep();
                      _animateToPage(3);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please select at least one workout day'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Step 4: Healthy Habits
  Widget _buildStep4(RegistrationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Healthy Habits',
            style: AppTheme.headingStyle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Which healthy habits are most important to you?',
            style: AppTheme.bodySecondaryStyle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Habits List
          ...AppConstants.healthyHabits.map((habit) {
            return HabitCheckbox(
              label: habit,
              isSelected: provider.data.healthyHabits.contains(habit),
              onChanged: (selected) {
                provider.toggleHealthyHabit(habit);
              },
            );
          }),

          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  isOutlined: true,
                  onPressed: () {
                    provider.previousStep();
                    _animateToPage(2);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Next',
                  onPressed: provider.canProceedFromStep(2)
                      ? () {
                          provider.nextStep();
                          _animateToPage(4);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 5: Account Setup
  Widget _buildStep5(RegistrationProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _step4FormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Account Setup',
                        style: AppTheme.headingStyle,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),
                      CustomTextField(
                        label: 'First Name',
                        hint: 'Enter your first name',
                        controller: _firstNameController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'First name'),
                      ),
                      const SizedBox(height: 20),

// Last Name
                      CustomTextField(
                        label: 'Last Name',
                        hint: 'Enter your last name',
                        controller: _lastNameController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Last name'),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),

                      const SizedBox(height: 20),

                      // Password
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter password (min 8 characters)',
                        controller: _passwordController,
                        obscureText: true,
                        validator: Validators.validatePassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Re-enter password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined),
                      ),

                      const SizedBox(height: 24),

                      // Terms & Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: provider.data.termsAccepted,
                            onChanged: (value) {
                              provider.setAccountInfo(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                termsAccepted: value ?? false,
                              );
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'I agree to the Terms & Conditions',
                                style: AppTheme.bodyStyle,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Navigation Buttons
                      // Navigation Buttons
                      Row(
                        children: [
                          Flexible(
                            // Changed from Expanded
                            child: CustomButton(
                              text: 'Back',
                              isOutlined: true,
                              onPressed: () {
                                provider.previousStep();
                                _animateToPage(3);
                              },
                            ),
                          ),
                          const SizedBox(width: 12), // Reduced from 16
                          Flexible(
                            // Changed from Expanded
                            child: CustomButton(
                              text: 'Register',
                              isLoading: provider.isLoading,
                              onPressed: () async {
                                if (_step4FormKey.currentState!.validate()) {
                                  if (!provider.data.termsAccepted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please accept the Terms & Conditions'),
                                        backgroundColor: AppTheme.errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                  provider.setAccountInfo(
                                    firstName: _firstNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                    termsAccepted: provider.data.termsAccepted,
                                  );

                                  final success = await provider.register();

                                  if (mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Account created successfully! Please login.'),
                                          backgroundColor:
                                              AppTheme.successColor,
                                        ),
                                      );
                                      Navigator.pushReplacementNamed(
                                          context, AppConstants.loginRoute);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(provider.errorMessage ??
                                              'Registration failed'),
                                          backgroundColor: AppTheme.errorColor,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
