import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class AdminDriverDetailPage extends StatelessWidget {
  final Map<String, dynamic> driver;

  const AdminDriverDetailPage({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '司机详情',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _showComingSoon('编辑'),
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined, color: AppColors.primary),
            onPressed: () => _showComingSoon('重置密码'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 16),
            _buildPerformanceStats(),
            const SizedBox(height: 16),
            _buildTodaySummary(),
            const SizedBox(height: 16),
            _buildBucketBalance(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildRecentTasks(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: driver['statusColor'] ?? AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(Icons.check, color: AppColors.white, size: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'] ?? '未知司机',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '工号: ${driver['id'] ?? '未知'} | 入职: ${driver['joinDate'] ?? '未知'}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (driver['statusColor'] as Color?)?.withOpacity(0.1) ?? AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: driver['statusColor'] as Color? ?? AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver['status'] ?? '在线',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: driver['statusColor'] as Color? ?? AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow('联系电话', driver['phone'] ?? '未知'),
          const SizedBox(height: 12),
          _buildInfoRow('紧急联系人', '王小红 (妻子) 139-0000-1002'),
          const SizedBox(height: 12),
          _buildInfoRow('车牌号', '浙A·88888'),
          const SizedBox(height: 12),
          _buildInfoRow('车辆类型', '厢式货车 4.2米'),
          const SizedBox(height: 12),
          _buildInfoRow('负责仓库', '中心仓库 A库区'),
          const SizedBox(height: 12),
          _buildInfoRow('负责区域', '中心城区、滨江区'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceStats() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '配送业绩统计',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('本月完成', '312 单', AppColors.primary, Icons.shopping_cart)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('配送桶数', '8,560 桶', AppColors.success, Icons.inventory_2)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('好评率', '99.2%', AppColors.purple, Icons.star)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('配送里程', '1,850 km', AppColors.orange, Icons.directions_car)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('本月完成', '312 单', AppColors.primary, Icons.shopping_cart)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('配送桶数', '8,560 桶', AppColors.success, Icons.inventory_2)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('好评率', '99.2%', AppColors.purple, Icons.star)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('配送里程', '1,850 km', AppColors.orange, Icons.directions_car)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '本月配送效率趋势',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '4月份',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      _buildBar(60, '周一'),
                      const SizedBox(width: 8),
                      _buildBar(75, '周二'),
                      const SizedBox(width: 8),
                      _buildBar(55, '周三'),
                      const SizedBox(width: 8),
                      _buildBar(80, '周四'),
                      const SizedBox(width: 8),
                      _buildBar(70, '周五'),
                      const SizedBox(width: 8),
                      _buildBar(85, '周六'),
                      const SizedBox(width: 8),
                      _buildBar(90, '周日'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String day) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                height: height * 0.6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日汇总',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.check_circle, '完成配送', '12 单', AppColors.success),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.water_drop, '送水桶数', '320 桶', AppColors.primary),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.map, '行驶里程', '85 km', AppColors.orange),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.access_time, '工作时长', '6.5 小时', AppColors.purple),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body2,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBucketBalance() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '空桶往来',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '车上空桶',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '45',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '个',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '回收空桶',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '+120 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '送出空桶',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '-75 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快捷操作',
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: _buildActionButton(Icons.phone, '联系司机', AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionButton(Icons.location_on, '查看位置', AppColors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionButton(Icons.pause_circle, '设为休息', AppColors.error)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildActionButton(Icons.phone, '联系司机', AppColors.success)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionButton(Icons.location_on, '查看位置', AppColors.orange)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(Icons.pause_circle, '设为休息', AppColors.error),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => _showComingSoon(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks() {
    final tasks = [
      {'id': 'ORD2026041901', 'station': '滨江花园水站', 'time': '04-19 14:20', 'buckets': 50, 'status': '已完成'},
      {'id': 'ORD2026041902', 'station': '西湖灵隐路水站', 'time': '04-19 10:30', 'buckets': 80, 'status': '已完成'},
      {'id': 'ORD2026041805', 'station': '上城湖滨水站', 'time': '04-18 16:15', 'buckets': 100, 'status': '已完成'},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近配送任务',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _showComingSoon('查看全部'),
                child: Text(
                  '查看全部',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${task['id']}',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  task['station'],
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['time'],
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${task['buckets']} 桶',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task['status'],
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    // ignore: avoid_print
    print('$feature 功能开发中');
  }
}
