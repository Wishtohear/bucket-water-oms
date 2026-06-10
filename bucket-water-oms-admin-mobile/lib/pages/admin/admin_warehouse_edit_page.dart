import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/admin_warehouse_service.dart';
import '../../models/admin_models.dart';

class AdminWarehouseEditPage extends StatefulWidget {
  final String? warehouseId;

  const AdminWarehouseEditPage({super.key, this.warehouseId});

  bool get isEdit => warehouseId != null && warehouseId!.isNotEmpty;

  @override
  State<AdminWarehouseEditPage> createState() => _AdminWarehouseEditPageState();
}

class _AdminWarehouseEditPageState extends State<AdminWarehouseEditPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminWarehouseService _warehouseService = AdminWarehouseService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingWarehouse = false;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedType = 'branch';
  String _selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadWarehouseDetail();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouseDetail() async {
    setState(() {
      _isLoadingWarehouse = true;
    });

    try {
      final warehouse = await _warehouseService.getWarehouseDetail(widget.warehouseId!);
      setState(() {
        _nameController.text = warehouse.name ?? '';
        _addressController.text = warehouse.address ?? '';
        _contactController.text = warehouse.contact ?? '';
        _phoneController.text = warehouse.contactPhone ?? '';
        _areaController.text = warehouse.coverageArea ?? '';
        _selectedType = warehouse.type ?? 'branch';
        _selectedStatus = warehouse.status ?? 'active';
        _isLoadingWarehouse = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWarehouse = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载仓库详情失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final warehouse = WarehouseModel(
        id: widget.warehouseId,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        contact: _contactController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        coverageArea: _areaController.text.trim().isNotEmpty ? _areaController.text.trim() : null,
        type: _selectedType,
        status: _selectedStatus,
      );

      final password = _passwordController.text.trim();

      if (widget.isEdit) {
        await _warehouseService.updateWarehouse(
          widget.warehouseId!,
          warehouse,
          password: password.isNotEmpty ? password : null,
        );
      } else {
        await _warehouseService.createWarehouse(
          warehouse,
          password: password.isNotEmpty ? password : '123456',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdit ? '修改成功' : '添加成功'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isEdit ? '修改' : '添加'}失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

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
          widget.isEdit ? '编辑仓库' : '新增仓库',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingWarehouse
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoCard(),
                    const SizedBox(height: 16),
                    _buildContactInfoCard(),
                    const SizedBox(height: 16),
                    _buildWorkInfoCard(),
                    const SizedBox(height: 16),
                    _buildPasswordCard(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('基本信息'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: '仓库名称',
            hint: '请输入仓库名称',
            icon: Icons.warehouse,
            required: true,
            maxLength: 50,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入仓库名称';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: '详细地址',
            hint: '请输入详细地址',
            icon: Icons.location_on,
            required: true,
            maxLines: 2,
            maxLength: 200,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入详细地址';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: '仓库类型',
                  value: _selectedType,
                  hint: '请选择类型',
                  items: const [
                    {'label': '分仓', 'value': 'branch'},
                    {'label': '总仓', 'value': 'main'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? 'branch';
                    });
                  },
                ),
              ),
              if (widget.isEdit) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                    label: '运营状态',
                    value: _selectedStatus,
                    hint: '请选择状态',
                    items: const [
                      {'label': '正常运营', 'value': 'active'},
                      {'label': '暂停运营', 'value': 'suspended'},
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'active';
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('联系人信息'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _contactController,
                  label: '仓库管理员',
                  hint: '请输入管理员姓名',
                  icon: Icons.person,
                  required: true,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入管理员';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: '联系电话',
                  hint: '请输入手机号',
                  icon: Icons.phone,
                  required: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入联系电话';
                    }
                    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value.trim())) {
                      return '请输入正确手机号';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('运营信息'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _areaController,
            label: '覆盖区域',
            hint: '请输入覆盖区域（选填）',
            icon: Icons.map,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '覆盖区域用于划分配送范围，帮助司机了解配送区域',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('账号设置'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: widget.isEdit ? '新密码' : '登录密码',
            hint: widget.isEdit ? '留空则不修改密码' : '留空则使用默认密码123456',
            icon: Icons.lock,
            obscureText: true,
            maxLength: 20,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isEdit
                        ? '如需修改密码请输入新密码，否则请留空'
                        : '默认密码为123456，创建后可告知仓库管理员',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AppButton(
        text: _isSubmitting
            ? (widget.isEdit ? '保存中...' : '添加中...')
            : (widget.isEdit ? '保存修改' : '确认添加'),
        type: AppButtonType.primary,
        onPressed: _isSubmitting ? null : _handleSubmit,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool required = false,
    bool obscureText = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.body1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body1.copyWith(
              color: AppColors.textPlaceholder,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required String hint,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(
              hint,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPlaceholder,
              ),
            ),
            icon:
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['label'] ?? '',
                  style: AppTextStyles.body1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
