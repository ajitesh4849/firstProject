import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class FoodImagePlaceholder extends StatelessWidget {
  const FoodImagePlaceholder({
    super.key,
    this.height = 220,
    this.icon = Icons.restaurant_rounded,
    this.label = 'Food preview',
  });

  final double height;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE3F0E8),
            Color(0xFFC8DFD1),
          ],
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
