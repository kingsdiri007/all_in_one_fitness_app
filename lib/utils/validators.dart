class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (value.length > 50) {
      return 'Password must not exceed 50 characters';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  // Weight validation
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }
    
    if (weight <= 0 || weight > 500) {
      return 'Weight must be between 0 and 500';
    }
    
    return null;
  }

  // Height validation
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid height';
    }
    
    if (height <= 0 || height > 300) {
      return 'Height must be between 0 and 300';
    }
    
    return null;
  }

  // Integer validation
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid whole number';
    }
    
    if (number < 0) {
      return '$fieldName must be a positive number';
    }
    
    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }
}
