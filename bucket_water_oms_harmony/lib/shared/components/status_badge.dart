import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum BadgeType { primary, success, warning, error, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.primary,
    this.fontSize = 10,
  });

  Color get backgroundColor {
    switch (type) {
      case BadgeType.primary:
        return AppColors.primary.withOpacity(0.1);
      case BadgeType.success:
        return AppColors.success.withOpacity(0.1);
      case BadgeType.warning:
        return AppColors.warning.withOpacity(0.1);
      case BadgeType.error:
        return AppColors.error.withOpacity(0.1);
      case BadgeType.info:
        return AppColors.textSecondary.withOpacity(0.1);
    }
  }

  Color get textColor {
    switch (type) {
      case BadgeType.primary:
        return AppColors.primary;
      case BadgeType.success:
        return AppColors.success;
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.error:
        return AppColors.error;
      case BadgeType.info:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  BadgeType get type {
    switch (status) {
      case '待接单':
        return BadgeType.warning;
      case '配送中':
        return BadgeType.primary;
      case '已完成':
        return BadgeType.success;
      case '已拒单':
        return BadgeType.error;
      case '已取消':
        return BadgeType.info;
      default:
        return BadgeType.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusBadge(text: status, type: type);
  }
}

class CountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const CountBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 18),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        textAlign: TextAlign.center,
        style: AppTextStyles.captionSmall.copyWith(
          color: textColor ?? AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
