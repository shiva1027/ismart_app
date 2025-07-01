// 文件: utils/api_service.dart
// API服务工具类 - 处理与后端服务器的通信

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API响应结果封装类
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResponse.success(
    T data, {
    String message = '操作成功',
    int statusCode = 200,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 400, T? data}) {
    return ApiResponse(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic json)? fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '未知消息',
      data:
          json['data'] != null && fromJson != null
              ? fromJson(json['data'])
              : null,
      statusCode: json['statusCode'] ?? 200,
    );
  }
}

/// API服务配置
class ApiConfig {
  final String baseUrl;
  final int timeoutSeconds;
  final Map<String, String> defaultHeaders;
  final bool useHttps;

  ApiConfig({
    required this.baseUrl,
    this.timeoutSeconds = 30,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.useHttps = true,
  });
}

/// API服务类 - 处理所有网络请求
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  late ApiConfig _config;
  String? _authToken;

  // 初始化API服务
  void init(ApiConfig config) {
    _config = config;
    _loadAuthToken();
  }

  // 从本地存储加载认证Token
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // 保存认证Token到本地存储
  Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 清除认证Token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 获取完整URL
  String _getFullUrl(String endpoint) {
    final scheme = _config.useHttps ? 'https' : 'http';
    String baseUrl = _config.baseUrl;

    // 移除前导斜杠
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    // 确保baseUrl以斜杠结尾
    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    return '$scheme://$baseUrl$endpoint';
  }

  // 构建请求头
  Map<String, String> _buildHeaders() {
    final headers = Map<String, String>.from(_config.defaultHeaders);

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // 处理HTTP响应
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T? Function(dynamic json)? fromJson,
  ) async {
    try {
      final responseBody = utf8.decode(response.bodyBytes);
      final jsonData = json.decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          return ApiResponse.fromJson(jsonData, fromJson);
        } else {
          return ApiResponse.success(
            fromJson != null ? fromJson(jsonData) : jsonData as T,
            statusCode: response.statusCode,
          );
        }
      } else {
        final message =
            jsonData is Map<String, dynamic> && jsonData.containsKey('message')
                ? jsonData['message']
                : '请求失败 (${response.statusCode})';
        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('解析响应失败: $e', statusCode: response.statusCode);
    }
  }

  // 处理请求异常
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is SocketException) {
      return ApiResponse.error('网络连接错误，请检查网络', statusCode: 0);
    } else if (error is TimeoutException) {
      return ApiResponse.error('请求超时，请稍后重试', statusCode: 408);
    } else {
      return ApiResponse.error('请求出错: ${error.toString()}', statusCode: 500);
    }
  }

  // GET请求
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T? Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        _getFullUrl(endpoint),
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(Duration(seconds: _config.timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST请求
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T? Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_getFullUrl(endpoint));
      final bodyJson = body != null ? json.encode(body) : null;

      final response = await http
          .post(uri, headers: _buildHeaders(), body: bodyJson)
          .timeout(Duration(seconds: _config.timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT请求
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T? Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_getFullUrl(endpoint));
      final bodyJson = body != null ? json.encode(body) : null;

      final response = await http
          .put(uri, headers: _buildHeaders(), body: bodyJson)
          .timeout(Duration(seconds: _config.timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T? Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_getFullUrl(endpoint));
      final bodyJson = body != null ? json.encode(body) : null;

      final response = await http
          .delete(uri, headers: _buildHeaders(), body: bodyJson)
          .timeout(Duration(seconds: _config.timeoutSeconds));

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // 上传文件
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    T? Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_getFullUrl(endpoint));
      final request = http.MultipartRequest('POST', uri);

      // 添加文件
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // 添加其他字段
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // 添加头信息
      request.headers.addAll(_buildHeaders());

      // 发送请求
      final streamedResponse = await request.send().timeout(
        Duration(seconds: _config.timeoutSeconds),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // 下载文件
  Future<ApiResponse<File>> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, String>? queryParams,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final uri = Uri.parse(
        _getFullUrl(endpoint),
      ).replace(queryParameters: queryParams);

      final request = http.Request('GET', uri);
      request.headers.addAll(_buildHeaders());

      // 发送请求
      final streamedResponse = await http.Client()
          .send(request)
          .timeout(Duration(seconds: _config.timeoutSeconds));

      // 检查响应状态
      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        // 创建文件
        final file = File(savePath);
        final fileStream = file.openWrite();

        // 获取总大小
        final totalBytes = streamedResponse.contentLength ?? -1;
        int receivedBytes = 0;

        // 监听下载进度
        await streamedResponse.stream.listen((List<int> chunk) {
          receivedBytes += chunk.length;
          if (onProgress != null && totalBytes != -1) {
            onProgress(receivedBytes, totalBytes);
          }
          fileStream.add(chunk);
        }).asFuture();

        // 关闭文件流
        await fileStream.close();

        return ApiResponse.success(file, message: '文件下载成功');
      } else {
        return ApiResponse.error(
          '文件下载失败: ${streamedResponse.statusCode}',
          statusCode: streamedResponse.statusCode,
        );
      }
    } catch (e) {
      return _handleError<File>(e);
    }
  }

  // 使用强类型模型进行请求
  Future<ApiResponse<T>> request<T, U>(
    String endpoint, {
    required HttpMethod method,
    U? data,
    Map<String, String>? queryParams,
    required T Function(dynamic json) fromJson,
    required Map<String, dynamic> Function(U data)? toJson,
  }) async {
    switch (method) {
      case HttpMethod.get:
        return get<T>(endpoint, queryParams: queryParams, fromJson: fromJson);
      case HttpMethod.post:
        return post<T>(
          endpoint,
          body: data != null && toJson != null ? toJson(data) : null,
          fromJson: fromJson,
        );
      case HttpMethod.put:
        return put<T>(
          endpoint,
          body: data != null && toJson != null ? toJson(data) : null,
          fromJson: fromJson,
        );
      case HttpMethod.delete:
        return delete<T>(
          endpoint,
          body: data != null && toJson != null ? toJson(data) : null,
          fromJson: fromJson,
        );
    }
  }
}

// HTTP方法枚举
enum HttpMethod { get, post, put, delete }

// API服务扩展 - 示例特定API请求封装
extension ApiServiceExtensions on ApiService {
  // 用户登录示例
  Future<ApiResponse<Map<String, dynamic>>> login(
    String username,
    String password,
  ) async {
    final response = await post<Map<String, dynamic>>(
      'auth/login',
      body: {'username': username, 'password': password},
    );

    // 保存Token
    if (response.success &&
        response.data != null &&
        response.data!.containsKey('token')) {
      await saveAuthToken(response.data!['token']);
    }

    return response;
  }

  // 获取用户信息示例
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return get<Map<String, dynamic>>('user/profile');
  }
}
