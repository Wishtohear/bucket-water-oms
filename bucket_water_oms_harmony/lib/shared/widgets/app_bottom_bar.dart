import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AppBottomBarItem> items;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = items[index];
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class OwnerBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const OwnerBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        AppBottomBarItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '首页',
        ),
        AppBottomBarItem(
          icon: Icons.list_alt_outlined,
          activeIcon: Icons.list_alt,
          label: '订单',
        ),
        AppBottomBarItem(
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet,
          label: '财务',
        ),
        AppBottomBarItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: '我的',
        ),
      ],
    );
  }
}

class DriverBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DriverBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        AppBottomBarItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: '任务',
        ),
        AppBottomBarItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: '空桶',
        ),
        AppBottomBarItem(
          icon: Icons.description_outlined,
          activeIcon: Icons.description,
          label: '对账',
        ),
        AppBottomBarItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: '我的',
        ),
      ],
    );
  }
}

class WarehouseBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WarehouseBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        AppBottomBarItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '首页',
        ),
        AppBottomBarItem(
          icon: Icons.move_to_inbox,
          activeIcon: Icons.move_to_inbox,
          label: '入库',
        ),
        AppBottomBarItem(
          icon: Icons.outbox,
          activeIcon: Icons.outbox,
          label: '出库',
        ),
        AppBottomBarItem(
          icon: Icons.warehouse_outlined,
          activeIcon: Icons.warehouse,
          label: '库存',
        ),
        AppBottomBarItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: '我的',
        ),
      ],
    );
  }
}
