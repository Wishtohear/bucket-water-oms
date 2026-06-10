import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/phone_utils.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/scanner_widget.dart';
import '../../shared/widgets/image_picker_widget.dart';
import '../../services/map_service.dart';
import '../../services/file_upload_service.dart';
import '../../services/driver_service.dart';
import '../../models/driver_task_model.dart';

class DriverOrderDetailPage extends StatefulWidget {
  final String? taskId;

  const DriverOrderDetailPage({super.key, this.taskId});

  @override
  State<DriverOrderDetailPage> createState() => _DriverOrderDetailPageState();
}

class _DriverOrderDetailPageState extends State<DriverOrderDetailPage> {
  final TextEditingController _deliveryQuantityController =
      TextEditingController();
  final TextEditingController _returnBarrelController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _bossCodeController = TextEditingController();
  final List<String> _scannedBarrels = [];
  final List<String> _uploadedPhotoUrls = [];
  final FileUploadService _fileUploadService = FileUploadService();
  final DriverService _driverService = DriverService();
  bool _isUploadingPhotos = false;
  bool _isLoading = true;
  bool _isCheckingIn = false;
  bool _hasCheckedIn = false;
  bool _gpsLocationFailed = false;
  bool _isUploadingCheckInPhoto = false;
  String? _checkInPhotoUrl;
  DriverTaskModel? _taskData;
  String _selectedSignMethod = 'signature';
  String? _verificationCode;
  DateTime? _checkInTime;
  double? _checkInDistance;
  bool? _isWithinTolerance;
  double? _currentLat;
  double? _currentLng;
  static const double _distanceTolerance = 50.0;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await MapService.getCurrentLocation();
      if (mounted && position != null) {
        setState(() {
          _currentLat = position['latitude'];
          _currentLng = position['longitude'];
          _gpsLocationFailed = false;
        });
        debugPrint('GPS定位成功: lat=${_currentLat}, lng=${_currentLng}');
      } else {
        setState(() {
          _gpsLocationFailed = true;
        });
        debugPrint('GPS定位失败: 返回位置为空');
      }
    } catch (e) {
      debugPrint('获取位置失败: $e');
      if (mounted) {
        setState(() {
          _gpsLocationFailed = true;
        });
      }
    }
  }

  Future<void> _handlePhotoCheckIn() async {
    if (_checkInPhotoUrl == null || _checkInPhotoUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先拍摄打卡照片'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final checkIn = DriverCheckIn(
        orderId: widget.taskId ?? '',
        checkInType: 'photo',
        photoUrl: _checkInPhotoUrl,
        latitude: _currentLat,
        longitude: _currentLng,
        address: '拍照打卡',
      );

      final result = await _driverService.driverCheckIn(checkIn);

      if (mounted && result) {
        setState(() {
          _hasCheckedIn = true;
          _checkInTime = DateTime.now();
          _isWithinTolerance = null;
          _isCheckingIn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('拍照打卡成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打卡失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法获取当前位置，请检查定位权限'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final stationLat = _taskData?.latitude ?? 0;
      final stationLng = _taskData?.longitude ?? 0;
      final distance = _calculateDistance(
        _currentLat!,
        _currentLng!,
        stationLat,
        stationLng,
      );

      final isWithinTolerance = distance <= _distanceTolerance;

      final checkIn = DriverCheckIn(
        orderId: widget.taskId ?? '',
        latitude: _currentLat!,
        longitude: _currentLng!,
        address: '当前位置',
        checkInType: 'gps',
        distance: distance,
        isWithinTolerance: isWithinTolerance,
      );

      final result = await _driverService.driverCheckIn(checkIn);

      if (mounted && result) {
        setState(() {
          _hasCheckedIn = true;
          _checkInTime = DateTime.now();
          _checkInDistance = distance;
          _isWithinTolerance = isWithinTolerance;
          _isCheckingIn = false;
        });

        if (isWithinTolerance) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GPS打卡成功！距离水站 ${distance.toStringAsFixed(0)}米（在${_distanceTolerance.toStringAsFixed(0)}米容差范围内）'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('打卡成功，但距离水站较远（${distance.toStringAsFixed(0)}米），建议靠近后再打卡'),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打卡失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c * 1000;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('验证码签收'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '请将验证码 ${_verificationCode ?? '------'} 告知客户',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 16),
            Text(
              '客户收到验证码后，输入确认码完成签收',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _verificationCode = (1000 + (math.Random().nextInt(9000))).toString();
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      _showVerificationCodeDialog();
    }
  }

  Future<void> _loadTaskData() async {
    if (widget.taskId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final driverId = ApiConfig.getDriverId();
      final tasks = await _driverService.getDriverTasks(driverId);
      final task = tasks.firstWhere(
        (t) => t.id == widget.taskId,
        orElse: () => DriverTaskModel(),
      );

      setState(() {
        _taskData = task;
        _deliveryQuantityController.text =
            task.totalQuantity?.toString() ?? '0';
        _returnBarrelController.text =
            task.currentReturnBuckets?.toString() ?? '0';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _deliveryQuantityController.dispose();
    _returnBarrelController.dispose();
    _smsCodeController.dispose();
    _bossCodeController.dispose();
    super.dispose();
  }

  int get _shortageBarrel {
    final delivery = int.tryParse(_deliveryQuantityController.text) ?? 0;
    final returnBarrel = int.tryParse(_returnBarrelController.text) ?? 0;
    return delivery - returnBarrel;
  }

  void _handleConfirmDelivery() {
    if (_selectedSignMethod == 'sms') {
      final code = _smsCodeController.text.trim();
      if (code.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请输入6位验证码'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    } else if (_selectedSignMethod == 'boss') {
      final code = _bossCodeController.text.trim();
      if (code.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请输入4位确认码'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认送达'),
        content: Text('确认订单 ${_taskData?.orderNo ?? '#'} 已完成配送？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _driverService.deliverOrder(
                  widget.taskId ?? '',
                  confirm: DriverDeliveryConfirm(
                    orderId: _taskData?.orderId,
                    returnBuckets: int.tryParse(_returnBarrelController.text),
                    owedBuckets: _shortageBarrel > 0 ? _shortageBarrel : null,
                    photos: _uploadedPhotoUrls,
                    signType: _selectedSignMethod,
                    verificationCode: _selectedSignMethod == 'sms'
                        ? _smsCodeController.text
                        : null,
                    bossCode: _selectedSignMethod == 'boss'
                        ? _bossCodeController.text
                        : null,
                  ),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('订单已确认完成')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('操作失败: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarrelCode() async {
    final code = await showScanDialog(
      context,
      title: '扫描桶条码',
      hint: '请扫描桶上的条码',
      onScanned: (String code) {},
    );

    if (code != null && code.isNotEmpty && mounted) {
      setState(() {
        if (!_scannedBarrels.contains(code)) {
          _scannedBarrels.add(code);
        }
        _returnBarrelController.text = _scannedBarrels.length.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已扫描: $code'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _scanOrderCode() async {
    final code = await showScanDialog(
      context,
      title: '扫描订单二维码',
      hint: '请扫描订单上的二维码',
      onScanned: (String code) {},
    );

    if (code != null && code.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('订单码: $code'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _uploadPhotos(List<File> files) async {
    if (files.isEmpty) return;

    setState(() {
      _isUploadingPhotos = true;
    });

    try {
      final responses = await _fileUploadService.uploadPhotos(
        files,
        minRequired: 3,
      );

      setState(() {
        for (final response in responses) {
          _uploadedPhotoUrls.add(response.fileUrl);
        }
        _isUploadingPhotos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功上传${responses.length}张照片'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on FileUploadException catch (e) {
      setState(() {
        _isUploadingPhotos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败: ${e.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingPhotos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!_hasCheckedIn) ...[
                    _buildCheckInCard(),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildCheckInStatusCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildDeliveryProgress(),
                  const SizedBox(height: 16),
                  _buildCustomerInfo(),
                  const SizedBox(height: 16),
                  _buildProductInfo(),
                  const SizedBox(height: 16),
                  _buildConfirmationForm(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '订单详情 ${_taskData?.orderNo ?? ""}',
              style: AppTextStyles.h3,
            ),
          ),
          GestureDetector(
            onTap: _scanOrderCode,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
    final hasValidLocation = _currentLat != null && _currentLng != null && !_gpsLocationFailed;
    final canGpsCheckIn = hasValidLocation && _currentLat != 0 && _currentLng != 0;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '到达打卡',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildGpsStatusIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          if (canGpsCheckIn) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前距离水站',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _checkInDistance != null
                                  ? '${_checkInDistance!.toStringAsFixed(0)}'
                                  : '--',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '米',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.border,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '容差范围',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${_distanceTolerance.toInt()}',
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '米',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_checkInDistance != null && _checkInDistance! > _distanceTolerance) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '距离较远，建议靠近水站后再打卡',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCheckingIn ? null : _handleCheckIn,
                icon: _isCheckingIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.location_on, color: Colors.white),
                label: Text(_isCheckingIn ? '打卡中...' : 'GPS定位打卡'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.gps_off,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GPS定位失败',
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '无法获取当前位置，请使用拍照打卡',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _getCurrentLocation();
                            });
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('重新定位'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bgInput,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoCheckInSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildGpsStatusIndicator() {
    final hasValidLocation = _currentLat != null && _currentLng != null && !_gpsLocationFailed;
    final hasNonZeroLocation = hasValidLocation && _currentLat != 0 && _currentLng != 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasNonZeroLocation
            ? AppColors.success.withOpacity(0.1)
            : (hasValidLocation
                ? AppColors.warning.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasNonZeroLocation
              ? AppColors.success.withOpacity(0.3)
              : (hasValidLocation
                  ? AppColors.warning.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasNonZeroLocation
                ? Icons.gps_fixed
                : (hasValidLocation ? Icons.gps_not_fixed : Icons.gps_off),
            size: 14,
            color: hasNonZeroLocation
                ? AppColors.success
                : (hasValidLocation ? AppColors.warning : AppColors.error),
          ),
          const SizedBox(width: 4),
          Text(
            hasNonZeroLocation
                ? 'GPS正常'
                : (hasValidLocation ? 'GPS异常' : 'GPS未开启'),
            style: AppTextStyles.captionSmall.copyWith(
              color: hasNonZeroLocation
                  ? AppColors.success
                  : (hasValidLocation ? AppColors.warning : AppColors.error),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCheckInSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.camera_alt,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '拍照打卡',
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '备选方案',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '当GPS定位失败时，可拍摄现场照片进行打卡',
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (_checkInPhotoUrl != null && _checkInPhotoUrl!.isNotEmpty) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _checkInPhotoUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.bgInput,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: AppColors.textTertiary,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '图片加载失败',
                                style: TextStyle(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _checkInPhotoUrl = null;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '已拍照',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCheckingIn || _isUploadingCheckInPhoto
                    ? null
                    : _handlePhotoCheckIn,
                icon: _isCheckingIn || _isUploadingCheckInPhoto
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white),
                label: Text(
                  _isCheckingIn
                      ? '打卡中...'
                      : '确认拍照打卡',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _isUploadingCheckInPhoto ? null : _takeCheckInPhoto,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击拍摄打卡照片',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _takeCheckInPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary),
                  ),
                  title: const Text('拍照'),
                  subtitle: const Text('拍摄现场照片进行打卡'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndUploadPhoto(picker, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.success),
                  ),
                  title: const Text('从相册选择'),
                  subtitle: const Text('选择已有照片进行打卡'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndUploadPhoto(picker, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                  title: const Text('取消'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('选择图片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto(ImagePicker picker, ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingCheckInPhoto = true;
      });

      final uploadedUrl = await _uploadCheckInPhoto(image.path);

      if (mounted) {
        setState(() {
          _checkInPhotoUrl = uploadedUrl;
          _isUploadingCheckInPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('照片上传成功'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingCheckInPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('照片上传失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String> _uploadCheckInPhoto(String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) {
      throw Exception('文件不存在');
    }

    final responses = await _fileUploadService.uploadPhotos([file], minRequired: 1);
    if (responses.isEmpty) {
      throw Exception('上传失败');
    }
    return responses.first.fileUrl;
  }

  Widget _buildCheckInStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isWithinTolerance == null ? Icons.camera_alt : Icons.location_on,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isWithinTolerance == null ? '已拍照打卡' : '已到达打卡',
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '打卡时间: ${_checkInTime != null ? _formatDateTime(_checkInTime!) : ""}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isWithinTolerance != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isWithinTolerance!
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isWithinTolerance!
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWithinTolerance! ? Icons.verified : Icons.warning_amber,
                    color: _isWithinTolerance! ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isWithinTolerance!
                          ? '距离在容差范围内（≤${_distanceTolerance.toInt()}米）'
                          : '距离超出容差范围（${_distanceTolerance.toInt()}米）',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: _isWithinTolerance! ? AppColors.success : const Color(0xFFB45309),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _buildCheckInInfo(
                  '打卡方式',
                  _isWithinTolerance == null ? '拍照打卡' : 'GPS定位',
                  Icons.gps_fixed,
                ),
              ),
              const SizedBox(width: 12),
              if (_isWithinTolerance != null)
                Expanded(
                  child: _buildCheckInInfo(
                    '距离水站',
                    _checkInDistance != null
                        ? '${_checkInDistance!.toStringAsFixed(0)}米'
                        : '--',
                    _isWithinTolerance!
                        ? Icons.check_circle
                        : Icons.warning_amber,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInInfo(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryProgress() {
    final steps = [
      {
        'title': '待配送',
        'time': _taskData?.assignedAt != null
            ? _formatDateTime(_taskData!.assignedAt!)
            : '',
        'isCompleted':
            _taskData?.status != 'pending' && _taskData?.status != 'assigned',
        'icon': Icons.check,
      },
      {
        'title': '配送中',
        'time': _taskData?.pickedUpAt != null
            ? _formatDateTime(_taskData!.pickedUpAt!)
            : '',
        'isCompleted': _taskData?.status == 'completed' ||
            _taskData?.status == 'delivered',
        'icon': Icons.local_shipping,
      },
      {
        'title': '已送达',
        'time': _taskData?.deliveredAt != null
            ? _formatDateTime(_taskData!.deliveredAt!)
            : '',
        'isCompleted': false,
        'icon': Icons.home,
      },
    ];

    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '配送进度',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isCompleted = step['isCompleted'] as bool;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            isCompleted ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isCompleted ? step['icon'] as IconData : Icons.circle,
                        color: AppColors.white,
                        size: isCompleted ? 18 : 8,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: AppTextStyles.subtitle2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (step['time'] as String).isNotEmpty
                              ? step['time'] as String
                              : '未完成',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: isCompleted
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCustomerInfo() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _taskData?.contactName ?? '未知联系人',
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _taskData?.contactPhone ?? '',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final phone = _taskData?.contactPhone;
                  if (phone != null && phone.isNotEmpty) {
                    PhoneUtils.makePhoneCall(phone, context: context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('暂无客户电话'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _taskData?.deliveryAddress ?? '地址待确认',
                        style: AppTextStyles.subtitle2,
                      ),
                      if (_taskData?.estimatedDeliveryTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '预约时间: ${_formatDateTime(_taskData!.estimatedDeliveryTime!)}',
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              final address = _taskData?.deliveryAddress;
              final lat = _taskData?.latitude;
              final lng = _taskData?.longitude;
              if (address != null && address.isNotEmpty) {
                MapService.navigateWithAddress(
                  context: context,
                  address: address,
                  stationName: _taskData?.stationName ?? '水站',
                );
              } else if (lat != null && lng != null && lat != 0 && lng != 0) {
                MapService.navigateToStation(
                  context: context,
                  lat: lat,
                  lng: lng,
                  stationName: _taskData?.stationName ?? '水站',
                  address: address,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('水站位置信息缺失，无法导航'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.navigation,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '查看地图位置',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final items = _taskData?.items;

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品信息',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (items != null && items.isNotEmpty)
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.productName ?? '商品',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '× ${item.quantity ?? 0} 桶',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '桶装水',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '× ${_taskData?.totalQuantity ?? 0} 桶',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmationForm() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '实收确认',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: '配送数量',
                  controller: _deliveryQuantityController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: '回收空桶',
                            controller: _returnBarrelController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _scanBarrelCode,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_scannedBarrels.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '已扫描 ${_scannedBarrels.length} 个桶',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '欠桶数量: $_shortageBarrel 个',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '签收照片',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_isUploadingPhotos)
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '上传中...',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ImagePickerWidget(
                maxImages: 10,
                minImages: 3,
                initialUrls: _uploadedPhotoUrls,
                onImagesChanged: (List<String> urls) async {
                  final localFiles =
                      urls.where((url) => !url.startsWith('http')).toList();
                  if (localFiles.isNotEmpty && !_isUploadingPhotos) {
                    await _uploadPhotos(localFiles.cast<File>());
                  }
                },
                hintText: '点击添加签收照片',
                errorText: '至少需要上传3张签收照片',
              ),
              const SizedBox(height: 8),
              Text(
                '请上传至少3张签收照片（门头照、签收单、货物照）',
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSignMethodSection(),
        ],
      ),
    );
  }

  Widget _buildSignMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '签收方式',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSignMethodButton(
                'signature',
                Icons.draw,
                '签字签收',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSignMethodButton(
                'sms',
                Icons.message,
                '验证码',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSignMethodButton(
                'boss',
                Icons.phone_android,
                '老板确认',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedSignMethod == 'signature')
          _buildSignatureSection()
        else if (_selectedSignMethod == 'sms')
          _buildSmsSection()
        else if (_selectedSignMethod == 'boss')
          _buildBossConfirmSection(),
      ],
    );
  }

  Widget _buildSignMethodButton(
    String method,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedSignMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSignMethod = method;
        });
        if (method == 'sms') {
          _sendVerificationCode();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                '请客户在此签字',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '清除重写',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.message,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '验证码已发送',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '请客户收到验证码后输入确认',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _smsCodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: '请输入6位验证码',
              counterText: '',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossConfirmSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '等待水站老板确认',
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '老板可在APP或小程序中确认订单',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bossCodeController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              hintText: '或输入老板确认码',
              counterText: '',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.success, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    final canConfirm = _hasCheckedIn && _uploadedPhotoUrls.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.95),
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '取消',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: canConfirm ? _handleConfirmDelivery : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      canConfirm ? AppColors.primary : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: canConfirm
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '确认送达',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
