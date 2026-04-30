import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<Widget>? tabWidgets;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.tabWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: tabWidgets != null
          ? Row(
              children: List.generate(
                tabWidgets!.length,
                (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index == selectedIndex
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(child: tabWidgets![index]),
                    ),
                  ),
                ),
              ),
            )
          : Row(
              children: List.generate(
                tabs.length,
                (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index == selectedIndex
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: AppTextStyles.subtitle2.copyWith(
                            color: index == selectedIndex
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: index == selectedIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        tabs.length,
        (index) => Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: index == selectedIndex
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[index],
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle2.copyWith(
                  color: index == selectedIndex
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: index == selectedIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
