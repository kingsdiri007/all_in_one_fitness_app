import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HabitCheckbox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const HabitCheckbox({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
