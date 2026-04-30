import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.borderLight,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            autofocus: autofocus,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: AppTextStyles.body1,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.textPlaceholder,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              counterText: '',
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final double borderRadius;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: AppTextStyles.body2,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body2.copyWith(
            color: AppColors.textPlaceholder,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
