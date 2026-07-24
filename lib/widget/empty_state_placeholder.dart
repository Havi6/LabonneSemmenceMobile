import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';

class EmptyStatePlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool compact;

  const EmptyStatePlaceholder({
    super.key,
    required this.icon,
    required this.message,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: compact ? 16 : 24,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceLight.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 34 : 56,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: compact ? 13 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
