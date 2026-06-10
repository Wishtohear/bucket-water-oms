import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PhoneUtils {
  static Future<bool> makePhoneCall(String phoneNumber, {BuildContext? context}) async {
    if (phoneNumber.isEmpty) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('电话号码为空'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return false;
    }

    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final phoneUrl = 'tel:$cleanedNumber';

    try {
      final canLaunch = await canLaunchUrl(Uri.parse(phoneUrl));
      if (canLaunch) {
        await launchUrl(Uri.parse(phoneUrl));
        return true;
      } else {
        if (context != null) {
          _showPhoneDialog(context, cleanedNumber);
        }
        return false;
      }
    } catch (e) {
      if (context != null) {
        _showPhoneDialog(context, cleanedNumber);
      }
      return false;
    }
  }

  static void _showPhoneDialog(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拨打电话'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('是否拨打: $phoneNumber'),
            const SizedBox(height: 16),
            Text(
              '无法自动跳转，请手动拨打',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('电话号码已复制: $phoneNumber'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('复制号码'),
          ),
        ],
      ),
    );
  }

  static Future<bool> canMakePhoneCall() async {
    try {
      return await canLaunchUrl(Uri.parse('tel:'));
    } catch (e) {
      return false;
    }
  }
}
