import 'package:flutter/material.dart';
import 'app_colors.dart';

class ModernFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const ModernFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.backgroundColor = AppColors.primaryPurple,
    this.foregroundColor = Colors.white,
  });

  const ModernFloatingActionButton.circular({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label = '',
    this.backgroundColor = AppColors.primaryPurple,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: label.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            )
          : FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,
              child: Icon(icon),
            ),
    );
  }
}