import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  
  // Couleurs secondaires
  static const Color secondary = Color(0xFF00D9A5);
  static const Color accent = Color(0xFFFF6B6B);
  
  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFE53935);
  
  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Gradient principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient pour les cartes
  static const LinearGradient cardGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
