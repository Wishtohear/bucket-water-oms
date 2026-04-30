import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double size;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                icon,
                size: size * 0.5,
                color: iconColor ?? AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> items;
  final int crossAxisCount;
  final double spacing;

  const QuickActionGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 4,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: items.map((item) {
        return QuickActionButton(
          icon: item.icon,
          label: item.label,
          iconColor: item.iconColor,
          backgroundColor: item.backgroundColor,
          onTap: item.onTap,
        );
      }).toList(),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const QuickActionItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });
}
