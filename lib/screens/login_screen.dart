import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Login failed'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => _ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Welcome Back!',
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to continue your fitness journey',
                  style: AppTheme.bodySecondaryStyle,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                
                const SizedBox(height: 12),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                CustomButton(
                  text: 'Login',
                  onPressed: _handleLogin,
                  isLoading: authProvider.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Back to Registration
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppConstants.registrationRoute);
                    },
                    child: const Text('Back to Registration'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.forgotPassword(_emailController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Password reset link sent to your email'
                  : authProvider.errorMessage ?? 'Request failed',
            ),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Forgot Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: AppTheme.bodySecondaryStyle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
