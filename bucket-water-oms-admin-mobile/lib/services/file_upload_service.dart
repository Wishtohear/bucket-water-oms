import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/config/api_config.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  static const int maxPhotoSize = 10 * 1024 * 1024;
  static const int maxFileSize = 50 * 1024 * 1024;
  static const int minPhotosRequired = 3;

  Future<FileUploadResponse> uploadPhoto(File file, {String? token}) async {
    return await _uploadFile(
      file: file,
      type: 'photos',
      token: token,
      maxSize: maxPhotoSize,
    );
  }

  Future<List<FileUploadResponse>> uploadPhotos(
    List<File> files, {
    String? token,
    int? minRequired,
  }) async {
    if (files.isEmpty) {
      throw FileUploadException('文件列表不能为空');
    }

    if (minRequired != null && files.length < minRequired) {
      throw FileUploadException('至少需要${minRequired}张照片');
    }

    final responses = <FileUploadResponse>[];
    for (final file in files) {
      try {
        final response = await uploadPhoto(file, token: token);
        responses.add(response);
      } catch (e) {
        if (e is FileUploadException) {
          rethrow;
        }
        throw FileUploadException('部分文件上传失败: $e');
      }
    }
    return responses;
  }

  Future<FileUploadResponse> uploadSignature(File file, {String? token}) async {
    return await _uploadFile(
      file: file,
      type: 'signatures',
      token: token,
      maxSize: maxPhotoSize,
    );
  }

  Future<FileUploadResponse> uploadDocument(
    File file, {
    String? token,
  }) async {
    return await _uploadFile(
      file: file,
      type: 'documents',
      token: token,
      maxSize: maxFileSize,
    );
  }

  Future<FileUploadResponse> uploadFile(
    File file, {
    required String type,
    String? token,
    int? maxSize,
  }) async {
    return await _uploadFile(
      file: file,
      type: type,
      token: token,
      maxSize: maxSize ?? maxFileSize,
    );
  }

  Future<FileUploadResponse> _uploadFile({
    required File file,
    required String type,
    String? token,
    required int maxSize,
  }) async {
    if (!await file.exists()) {
      throw FileUploadException('文件不存在');
    }

    final fileSize = await file.length();
    if (fileSize > maxSize) {
      throw FileUploadException(
        '文件大小超过限制，最大允许 ${maxSize ~/ (1024 * 1024)}MB',
      );
    }

    if (fileSize == 0) {
      throw FileUploadException('文件不能为空');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/files/upload/$type');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer ${token ?? ApiConfig.getToken()}';

    final mimeType = _getMimeType(file.path);
    final fileName = file.path.split(Platform.pathSeparator).last;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );

    try {
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw FileUploadException('网络连接失败，请检查网络');
    } catch (e) {
      if (e is FileUploadException) {
        rethrow;
      }
      throw FileUploadException('文件上传失败: $e');
    }
  }

  FileUploadResponse _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = Map<String, dynamic>.from(
          Uri.parse('{"data":${response.body}}').queryParameters.isEmpty
              ? _parseJson(response.body)
              : _parseJson(response.body),
        );

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'] as Map<String, dynamic>;
          return FileUploadResponse(
            fileName: data['fileName'] ?? '',
            filePath: data['filePath'] ?? '',
            fileUrl: data['fileUrl'] ?? '',
            fileSize: data['fileSize']?.toInt() ?? 0,
            originalName: data['originalName'] ?? '',
          );
        } else {
          throw FileUploadException(
            jsonData['message'] ?? '文件上传失败',
          );
        }
      } catch (e) {
        if (e is FileUploadException) {
          rethrow;
        }
        throw FileUploadException('解析响应失败');
      }
    } else if (response.statusCode == 401) {
      throw FileUploadException('登录已过期，请重新登录', statusCode: 401);
    } else if (response.statusCode == 403) {
      throw FileUploadException('没有权限上传文件', statusCode: 403);
    } else {
      try {
        final data = _parseJson(response.body);
        throw FileUploadException(
          data['message'] ?? '文件上传失败',
          statusCode: response.statusCode,
        );
      } catch (e) {
        if (e is FileUploadException) {
          rethrow;
        }
        throw FileUploadException(
          '服务器错误: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
  }

  Map<String, dynamic> _parseJson(String body) {
    try {
      final trimmed = body.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        return Map<String, dynamic>.from(
          (trimmed.substring(0, 1) + trimmed.substring(trimmed.length - 1))
              as Map,
        );
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  bool isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  bool isDocumentFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'].contains(extension);
  }

  bool isValidFileSize(int size, {int? maxSize}) {
    return size <= (maxSize ?? maxFileSize);
  }

  bool isValidPhotoCount(int count, {int? minRequired}) {
    return count >= (minRequired ?? minPhotosRequired);
  }
}

class FileUploadResponse {
  final String fileName;
  final String filePath;
  final String fileUrl;
  final int fileSize;
  final String originalName;

  FileUploadResponse({
    required this.fileName,
    required this.filePath,
    required this.fileUrl,
    required this.fileSize,
    required this.originalName,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileSize: json['fileSize']?.toInt() ?? 0,
      originalName: json['originalName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'filePath': filePath,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'originalName': originalName,
      };

  @override
  String toString() => toJson().toString();
}

class FileUploadException implements Exception {
  final String message;
  final int? statusCode;

  FileUploadException(this.message, {this.statusCode});

  @override
  String toString() => 'FileUploadException: $message (Status: $statusCode)';
}
