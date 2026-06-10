import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../services/admin_policy_service.dart' show AdminPolicyService;
import '../../models/policy_models.dart';

class AdminPoliciesPage extends StatefulWidget {
  const AdminPoliciesPage({super.key});

  @override
  State<AdminPoliciesPage> createState() => _AdminPoliciesPageState();
}

class _AdminPoliciesPageState extends State<AdminPoliciesPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PolicyModel> _policies = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final policyService = AdminPolicyService();
      final response = await policyService.getPolicyTemplates(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _policies = response.policies;
          _totalPages = (response.total / _pageSize).ceil();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '销售政策',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _showCreatePolicyDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_policies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.policy_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无销售政策',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreatePolicyDialog,
              icon: const Icon(Icons.add),
              label: const Text('创建政策'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _policies.length + 1,
        itemBuilder: (context, index) {
          if (index == _policies.length) {
            return _buildLoadMoreButton();
          }
          return _buildPolicyCard(_policies[index]);
        },
      ),
    );
  }

  Widget _buildPolicyCard(PolicyModel policy) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      onTap: () => _showPolicyDetail(policy),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(policy.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  policy.typeText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: _getTypeColor(policy.type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: policy.isActive
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  policy.statusText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: policy.isActive
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            policy.name ?? '未命名政策',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (policy.description != null) ...[
            const SizedBox(height: 8),
            Text(
              policy.description!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPolicyInfoItem(
                icon: Icons.payments_outlined,
                label: '账期',
                value: policy.billingCycleText,
              ),
              const SizedBox(width: 24),
              _buildPolicyInfoItem(
                icon: Icons.water_drop_outlined,
                label: '押金',
                value: '¥${(policy.barrelDeposit ?? 0).toStringAsFixed(0)}',
              ),
              const Spacer(),
              if (policy.stationCount != null && policy.stationCount! > 0)
                Text(
                  '覆盖 ${policy.stationCount} 家水站',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    if (_currentPage >= _totalPages) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: TextButton(
          onPressed: () {
            setState(() {
              _currentPage++;
            });
            _loadData();
          },
          child: const Text('加载更多'),
        ),
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'default':
        return AppColors.primary;
      case 'vip':
        return AppColors.success;
      case 'promotion':
        return AppColors.orange;
      case 'trial':
        return AppColors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showPolicyDetail(PolicyModel policy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PolicyDetailPage(policy: policy),
      ),
    );
  }

  void _showCreatePolicyDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PolicyCreatePage(),
      ),
    );
  }
}

class PolicyDetailPage extends StatefulWidget {
  final PolicyModel policy;

  const PolicyDetailPage({super.key, required this.policy});

  @override
  State<PolicyDetailPage> createState() => _PolicyDetailPageState();
}

class _PolicyDetailPageState extends State<PolicyDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '政策详情',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: _editPolicy,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.policy.typeText,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.policy.statusText,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: widget.policy.isActive
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.policy.name ?? '未命名政策',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.policy.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.policy.description!,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '政策配置',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('账期类型', widget.policy.billingCycleText),
                  _buildDetailRow('预存金要求', '¥${(widget.policy.prepaidAmount ?? 0).toStringAsFixed(2)}'),
                  _buildDetailRow('欠桶阈值', '${widget.policy.barrelThreshold ?? 0} 桶'),
                  _buildDetailRow('每桶押金', '¥${(widget.policy.barrelDeposit ?? 0).toStringAsFixed(2)}'),
                ],
              ),
            ),
            if (widget.policy.stationCount != null && widget.policy.stationCount! > 0) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.store_outlined, color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Text(
                      '已分配给 ${widget.policy.stationCount} 家水站',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _editPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PolicyEditPage(policy: widget.policy),
      ),
    );
  }
}

class PolicyCreatePage extends StatefulWidget {
  const PolicyCreatePage({super.key});

  @override
  State<PolicyCreatePage> createState() => _PolicyCreatePageState();
}

class _PolicyCreatePageState extends State<PolicyCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepaidAmountController = TextEditingController();
  final _barrelThresholdController = TextEditingController();
  final _barrelDepositController = TextEditingController();

  String _selectedType = 'default';
  String _selectedBillingCycle = 'monthly';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepaidAmountController.dispose();
    _barrelThresholdController.dispose();
    _barrelDepositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '创建政策',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '基本信息',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '政策名称',
                      hintText: '请输入政策名称',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入政策名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '政策描述',
                      hintText: '请输入政策描述',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: '政策类型',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'default', child: Text('默认通用')),
                      DropdownMenuItem(value: 'vip', child: Text('VIP客户')),
                      DropdownMenuItem(value: 'promotion', child: Text('限时促销')),
                      DropdownMenuItem(value: 'trial', child: Text('试用期')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '财务配置',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBillingCycle,
                    decoration: const InputDecoration(
                      labelText: '账期类型',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'immediate', child: Text('现结')),
                      DropdownMenuItem(value: 'monthly', child: Text('月结')),
                      DropdownMenuItem(value: 'quarterly', child: Text('季结')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBillingCycle = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prepaidAmountController,
                    decoration: const InputDecoration(
                      labelText: '预存金要求',
                      prefixText: '¥ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barrelThresholdController,
                    decoration: const InputDecoration(
                      labelText: '欠桶阈值',
                      suffixText: '桶',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barrelDepositController,
                    decoration: const InputDecoration(
                      labelText: '每桶押金',
                      prefixText: '¥ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('创建政策'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final policyService = AdminPolicyService();
      final policy = PolicyModel(
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
        billingCycle: _selectedBillingCycle,
        prepaidAmount: double.tryParse(_prepaidAmountController.text),
        barrelThreshold: int.tryParse(_barrelThresholdController.text),
        barrelDeposit: double.tryParse(_barrelDepositController.text),
        status: 'active',
      );

      await policyService.createPolicyTemplate(policy);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('政策创建成功'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class PolicyEditPage extends StatefulWidget {
  final PolicyModel policy;

  const PolicyEditPage({super.key, required this.policy});

  @override
  State<PolicyEditPage> createState() => _PolicyEditPageState();
}

class _PolicyEditPageState extends State<PolicyEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepaidAmountController;
  late TextEditingController _barrelThresholdController;
  late TextEditingController _barrelDepositController;

  late String _selectedType;
  late String _selectedBillingCycle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.policy.name);
    _descriptionController = TextEditingController(text: widget.policy.description);
    _prepaidAmountController = TextEditingController(
        text: widget.policy.prepaidAmount?.toString() ?? '');
    _barrelThresholdController = TextEditingController(
        text: widget.policy.barrelThreshold?.toString() ?? '');
    _barrelDepositController = TextEditingController(
        text: widget.policy.barrelDeposit?.toString() ?? '');
    _selectedType = widget.policy.type ?? 'default';
    _selectedBillingCycle = widget.policy.billingCycle ?? 'monthly';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepaidAmountController.dispose();
    _barrelThresholdController.dispose();
    _barrelDepositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '编辑政策',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '基本信息',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '政策名称',
                      hintText: '请输入政策名称',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入政策名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '政策描述',
                      hintText: '请输入政策描述',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: '政策类型',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'default', child: Text('默认通用')),
                      DropdownMenuItem(value: 'vip', child: Text('VIP客户')),
                      DropdownMenuItem(value: 'promotion', child: Text('限时促销')),
                      DropdownMenuItem(value: 'trial', child: Text('试用期')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '财务配置',
                    style: AppTextStyles.subtitle2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBillingCycle,
                    decoration: const InputDecoration(
                      labelText: '账期类型',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'immediate', child: Text('现结')),
                      DropdownMenuItem(value: 'monthly', child: Text('月结')),
                      DropdownMenuItem(value: 'quarterly', child: Text('季结')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBillingCycle = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prepaidAmountController,
                    decoration: const InputDecoration(
                      labelText: '预存金要求',
                      prefixText: '¥ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barrelThresholdController,
                    decoration: const InputDecoration(
                      labelText: '欠桶阈值',
                      suffixText: '桶',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barrelDepositController,
                    decoration: const InputDecoration(
                      labelText: '每桶押金',
                      prefixText: '¥ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('保存修改'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final policyService = AdminPolicyService();
      final policy = PolicyModel(
        id: widget.policy.id,
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
        billingCycle: _selectedBillingCycle,
        prepaidAmount: double.tryParse(_prepaidAmountController.text),
        barrelThreshold: int.tryParse(_barrelThresholdController.text),
        barrelDeposit: double.tryParse(_barrelDepositController.text),
        status: widget.policy.status,
      );

      await policyService.updatePolicyTemplate(widget.policy.id!, policy);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('政策更新成功'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
