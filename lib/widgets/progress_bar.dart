import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Gradient? progressGradient;
  final Color? progressColor;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.backgroundColor,
    this.progressGradient,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: progressGradient ?? AppTheme.primaryGradient,
              color: progressColor,
            ),
          ),
        ),
      ),
    );
  }
}
