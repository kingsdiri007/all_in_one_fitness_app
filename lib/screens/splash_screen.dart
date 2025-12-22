import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Check authentication status
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuthStatus();
    
    if (isAuthenticated && mounted) {
      // Wait 2 seconds before navigating to home
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.splashGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // App Icon/Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Title
                  Text(
                    'Welcome to\n${AppConstants.appName}',
                    textAlign: TextAlign.center,
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 32,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    AppConstants.appDescription,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Begin Journey Button
                  CustomButton(
                    text: 'Begin Journey',
                    onPressed: () {
                      Navigator.pushNamed(context, AppConstants.registrationRoute);
                    },
                    color: Colors.white,
                    textColor: AppTheme.primaryColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppConstants.loginRoute);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Login',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
