import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;
  final double fontSize;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height = 48,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = AppColors.primary;
        textColor = AppColors.white;
        borderColor = AppColors.primary;
        break;
      case AppButtonType.secondary:
        backgroundColor = AppColors.success;
        textColor = AppColors.white;
        borderColor = AppColors.success;
        break;
      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case AppButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        borderColor = Colors.transparent;
        break;
      case AppButtonType.danger:
        backgroundColor = AppColors.error;
        textColor = AppColors.white;
        borderColor = AppColors.error;
        break;
    }

    Widget child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: textColor,
              fontSize: fontSize,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const CircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, size: size * 0.5, color: iconColor),
          ),
        ),
      ),
    );
  }
}
