import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../services/admin_station_service.dart';
import '../../services/admin_warehouse_service.dart';
import '../../services/admin_region_service.dart';
import '../../models/admin_models.dart';

class AdminStationEditPage extends StatefulWidget {
  final String? stationId;

  const AdminStationEditPage({super.key, this.stationId});

  bool get isEdit => stationId != null && stationId!.isNotEmpty;

  @override
  State<AdminStationEditPage> createState() => _AdminStationEditPageState();
}

class _AdminStationEditPageState extends State<AdminStationEditPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminStationService _stationService = AdminStationService();
  final AdminWarehouseService _warehouseService = AdminWarehouseService();
  final AdminRegionService _regionService = AdminRegionService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingWarehouses = true;
  bool _isLoadingStation = false;
  bool _isLoadingRegions = true;

  List<WarehouseModel> _warehouses = [];
  List<RegionModel> _regions = [];

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _remarkController = TextEditingController();
  final _passwordController = TextEditingController();

  final _depositBalanceController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _owedThresholdController = TextEditingController();
  final _bucketDepositController = TextEditingController();

  String _selectedArea = '';
  String _selectedWarehouseId = '';
  String _selectedStationType = 'normal';
  String _selectedPaymentType = 'PREPAID';
  String _selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    _depositBalanceController.text = '0';
    _creditLimitController.text = '0';
    _owedThresholdController.text = '30';
    _bucketDepositController.text = '20';
    _loadWarehouses();
    _loadRegions();
    if (widget.isEdit) {
      _loadStationDetail();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _remarkController.dispose();
    _passwordController.dispose();
    _depositBalanceController.dispose();
    _creditLimitController.dispose();
    _owedThresholdController.dispose();
    _bucketDepositController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouses() async {
    setState(() {
      _isLoadingWarehouses = true;
    });

    try {
      final response = await _warehouseService.getWarehouses(pageSize: 100);
      setState(() {
        _warehouses = response.warehouses;
        _isLoadingWarehouses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWarehouses = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载仓库列表失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadRegions() async {
    setState(() {
      _isLoadingRegions = true;
    });

    try {
      final regions = await _regionService.getRegionTree();
      setState(() {
        _regions = _flattenRegions(regions);
        _isLoadingRegions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRegions = false;
      });
    }
  }

  List<RegionModel> _flattenRegions(List<RegionModel> regions) {
    List<RegionModel> flattened = [];
    for (var region in regions) {
      flattened.add(region);
      if (region.children != null && region.children!.isNotEmpty) {
        flattened.addAll(_flattenRegions(region.children!));
      }
    }
    return flattened;
  }

  String? _findRegionValue(String? areaValue) {
    if (areaValue == null || areaValue.isEmpty) return null;

    for (var region in _regions) {
      if (region.code == areaValue || region.name == areaValue) {
        return region.code;
      }
    }
    return null;
  }

  String _getRegionDisplayName(String? code) {
    if (code == null || code.isEmpty) return '';
    for (var region in _regions) {
      if (region.code == code) {
        return region.name ?? code;
      }
    }
    return code;
  }

  Future<void> _loadStationDetail() async {
    setState(() {
      _isLoadingStation = true;
    });

    try {
      final station = await _stationService.getStationDetail(widget.stationId!);
      setState(() {
        _nameController.text = station.name ?? '';
        _contactController.text = station.contactName ?? '';
        _phoneController.text = station.contactPhone ?? '';
        _addressController.text = station.address ?? '';
        _remarkController.text = station.remark ?? '';

        if (station.latitude != null) {
          _latController.text = station.latitude!.toStringAsFixed(6);
        }
        if (station.longitude != null) {
          _lngController.text = station.longitude!.toStringAsFixed(6);
        }

        _depositBalanceController.text = (station.balance ?? 0).toStringAsFixed(2);
        _creditLimitController.text = (station.creditLimit ?? 0).toStringAsFixed(2);
        _owedThresholdController.text = (station.barrelThreshold ?? 30).toString();
        _bucketDepositController.text = (station.barrelDeposit ?? 20).toStringAsFixed(2);

        _selectedArea = _findRegionValue(station.area) ?? station.area ?? '';
        _selectedWarehouseId = station.warehouseId ?? '';
        _selectedStationType = station.stationType ?? 'normal';
        _selectedPaymentType = station.billingCycle ?? 'PREPAID';
        _selectedStatus = station.status ?? 'active';

        _isLoadingStation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载水站详情失败: $e'),
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
      final station = StationModel(
        id: widget.stationId,
        name: _nameController.text.trim(),
        contactName: _contactController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        warehouseId: _selectedWarehouseId.isNotEmpty ? _selectedWarehouseId : null,
        area: _selectedArea.isNotEmpty ? _selectedArea : null,
        status: _selectedStatus,
        balance: double.tryParse(_depositBalanceController.text) ?? 0,
        creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
        barrelThreshold: int.tryParse(_owedThresholdController.text) ?? 30,
        barrelDeposit: double.tryParse(_bucketDepositController.text) ?? 20,
        stationType: _selectedStationType,
        billingCycle: _selectedPaymentType,
        remark: _remarkController.text.trim().isNotEmpty ? _remarkController.text.trim() : null,
        latitude: double.tryParse(_latController.text),
        longitude: double.tryParse(_lngController.text),
      );

      final password = _passwordController.text.trim();

      if (widget.isEdit) {
        await _stationService.updateStation(
          widget.stationId!,
          station,
          password: password.isNotEmpty ? password : null,
        );
      } else {
        await _stationService.createStation(
          station,
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
          widget.isEdit ? '编辑水站' : '新增水站',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingStation
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
                    _buildLocationCard(),
                    const SizedBox(height: 16),
                    _buildFinancialCard(),
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
            label: '水站名称',
            hint: '请输入水站名称',
            icon: Icons.store,
            required: true,
            maxLength: 50,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入水站名称';
              }
              if (value.trim().length < 2) {
                return '水站名称至少2个字符';
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
              if (value.trim().length < 5) {
                return '地址至少5个字符';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: '所属区域',
                  value: _selectedArea,
                  hint: '请选择区域',
                  items: _regions.map((r) => {
                    'label': r.name ?? r.code ?? '',
                    'value': r.code ?? '',
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: '负责仓库',
                  value: _selectedWarehouseId,
                  hint: '请选择仓库',
                  items: _warehouses.map((w) => {
                    'label': w.name ?? '',
                    'value': w.id ?? '',
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWarehouseId = value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: '水站类型',
                  value: _selectedStationType,
                  hint: '请选择类型',
                  items: const [
                    {'label': '普通水站', 'value': 'normal'},
                    {'label': 'VIP水站', 'value': 'vip'},
                    {'label': '社区水站', 'value': 'community'},
                    {'label': '企业水站', 'value': 'enterprise'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStationType = value ?? 'normal';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: '账期类型',
                  value: _selectedPaymentType,
                  hint: '请选择账期',
                  items: const [
                    {'label': '预存金', 'value': 'PREPAID'},
                    {'label': '月结', 'value': 'MONTHLY'},
                    {'label': '季结', 'value': 'QUARTERLY'},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentType = value ?? 'PREPAID';
                    });
                  },
                ),
              ),
            ],
          ),
          if (widget.isEdit) ...[
            const SizedBox(height: 16),
            _buildDropdownField(
              label: '运营状态',
              value: _selectedStatus,
              hint: '请选择状态',
              items: const [
                {'label': '正常运营', 'value': 'active'},
                {'label': '欠费停供', 'value': 'suspended'},
                {'label': '已注销', 'value': 'closed'},
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? 'active';
                });
              },
            ),
          ],
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
                  label: '联系人',
                  hint: '请输入联系人姓名',
                  icon: Icons.person,
                  required: true,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入联系人';
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

  Widget _buildLocationCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('坐标信息'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _latController,
                  label: '纬度',
                  hint: '25.281000',
                  icon: Icons.north,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lngController,
                  label: '经度',
                  hint: '110.290000',
                  icon: Icons.east,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                ),
              ),
            ],
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
                    '坐标用于司机GPS打卡和导航定位，请确保坐标准确',
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

  Widget _buildFinancialCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('财务配置'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _depositBalanceController,
                  label: '预存金余额',
                  icon: Icons.account_balance_wallet,
                  prefix: '¥ ',
                  decimals: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _creditLimitController,
                  label: '信用额度',
                  icon: Icons.credit_card,
                  prefix: '¥ ',
                  decimals: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _owedThresholdController,
                  label: '欠桶阈值',
                  icon: Icons.warning_amber,
                  suffix: '个',
                  decimals: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _bucketDepositController,
                  label: '每桶押金',
                  icon: Icons.inventory_2,
                  prefix: '¥ ',
                  decimals: 2,
                ),
              ),
            ],
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
                        : '默认密码为123456，创建后可告知水站负责人',
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
            prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondary, size: 20) : null,
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? prefix,
    String? suffix,
    int decimals = 2,
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
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: decimals > 0),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: AppTextStyles.body1,
          decoration: InputDecoration(
            prefixText: prefix,
            prefixStyle: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            suffixText: suffix,
            suffixStyle: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final effectiveValue = items.any((item) => item['value'] == value) ? value : '';

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
            value: effectiveValue.isNotEmpty ? effectiveValue : null,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(
              hint,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPlaceholder,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
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
