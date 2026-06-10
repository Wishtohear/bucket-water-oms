import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

class ImagePickerWidget extends StatefulWidget {
  final int maxImages;
  final int minImages;
  final List<String>? initialUrls;
  final Function(List<String>) onImagesChanged;
  final bool allowCamera;
  final bool allowGallery;
  final String? hintText;
  final String? errorText;

  const ImagePickerWidget({
    Key? key,
    this.maxImages = 10,
    this.minImages = 0,
    this.initialUrls,
    required this.onImagesChanged,
    this.allowCamera = true,
    this.allowGallery = true,
    this.hintText,
    this.errorText,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<String> _uploadedUrls = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrls != null) {
      _uploadedUrls.addAll(widget.initialUrls!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        if (_selectedImages.length + _uploadedUrls.length >= widget.maxImages) {
          _showError('最多只能选择${widget.maxImages}张图片');
          return;
        }

        setState(() {
          _selectedImages.add(File(image.path));
        });
        widget.onImagesChanged(_getAllUrls());
      }
    } catch (e) {
      _showError('选择图片失败: $e');
    }
  }

  void _removeImage(int index, bool isUploaded) {
    setState(() {
      if (isUploaded) {
        _uploadedUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index - _uploadedUrls.length);
      }
    });
    widget.onImagesChanged(_getAllUrls());
  }

  List<String> _getAllUrls() {
    return [..._uploadedUrls];
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showImageSourceDialog() {
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
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewImage(int index, bool isUploaded) {
    final List<String> allUrls = _getAllUrls();
    if (index < 0 || index >= allUrls.length) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(
          imageUrls: allUrls,
          initialIndex: index,
          onDelete: (deletedIndex) {
            _removeImage(deletedIndex, deletedIndex < _uploadedUrls.length);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allImages = <Widget>[];

    for (int i = 0; i < _uploadedUrls.length; i++) {
      allImages.add(_buildImageTile(
        imageUrl: _uploadedUrls[i],
        index: i,
        isUploaded: true,
      ));
    }

    for (int i = 0; i < _selectedImages.length; i++) {
      allImages.add(_buildLocalImageTile(
        file: _selectedImages[i],
        index: _uploadedUrls.length + i,
        isUploaded: false,
      ));
    }

    if (_selectedImages.length + _uploadedUrls.length < widget.maxImages) {
      allImages.add(_buildAddButton());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allImages,
        ),
        if (widget.minImages > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.minImages > 0 ? '最少需要${widget.minImages}张图片' : '',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageTile({
    required String imageUrl,
    required int index,
    required bool isUploaded,
  }) {
    return GestureDetector(
      onTap: () => _previewImage(index, isUploaded),
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.bgPage,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.bgPage,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index, isUploaded),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalImageTile({
    required File file,
    required int index,
    required bool isUploaded,
  }) {
    return GestureDetector(
      onTap: () => _previewImage(index, isUploaded),
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index, isUploaded),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              '添加图片',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePreviewPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final Function(int)? onDelete;

  const ImagePreviewPage({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.imageUrls.length}'),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                widget.onDelete!(_currentIndex);
              },
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final url = widget.imageUrls[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: url.startsWith('http')
                  ? Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 100,
                        );
                      },
                    )
                  : Image.file(
                      File(url),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 100,
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
