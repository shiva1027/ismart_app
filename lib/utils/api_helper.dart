// 文件: utils/api_helper.dart
// API请求辅助类

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../utils/constants.dart';

class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  ApiResponse({
    this.data,
    this.errorMessage,
    this.isSuccess = true,
  });

  // 成功响应
  factory ApiResponse.success(T data) {
    return ApiResponse(
      data: data,
      isSuccess: true,
    );
  }

  // 错误响应
  factory ApiResponse.error(String message) {
    return ApiResponse(
      errorMessage: message,
      isSuccess: false,
    );
  }
}

class ApiHelper {
  final logger = Logger();
  final baseUrl = AppConstants.baseUrl;

  // 构建带有认证标头的请求头
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.USER_TOKEN_KEY);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // 检查网络连接
  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // 处理错误响应
  ApiResponse<T> _handleError<T>(dynamic error) {
    logger.e('API错误: $error');

    if (error is SocketException) {
      return ApiResponse.error('网络连接失败，请检查您的互联网连接');
    } else if (error is FormatException) {
      return ApiResponse.error('数据格式无效');
    } else if (error is http.ClientException) {
      return ApiResponse.error('请求处理失败: ${error.message}');
    } else {
      return ApiResponse.error('发生错误: $error');
    }
  }

  // 解析响应
  ApiResponse<T> _parseResponse<T>(http.Response response, T Function(dynamic) parser) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(parser(jsonData));
      } else if (response.statusCode == 401) {
        return ApiResponse.error('认证失败，请重新登录');
      } else if (response.statusCode == 404) {
        return ApiResponse.error('请求的资源不存在');
      } else {
        return ApiResponse.error('服务器错误: ${response.statusCode}');
      }
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // GET请求
  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic) parser) async {
    try {
      if (!await _checkConnectivity()) {
        return ApiResponse.error('无网络连接');
      }

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      return _parseResponse(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST请求
  Future<ApiResponse<T>> post<T>(String endpoint, dynamic body, T Function(dynamic) parser) async {
    try {
      if (!await _checkConnectivity()) {
        return ApiResponse.error('无网络连接');
      }

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      return _parseResponse(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT请求
  Future<ApiResponse<T>> put<T>(String endpoint, dynamic body, T Function(dynamic) parser) async {
    try {
      if (!await _checkConnectivity()) {
        return ApiResponse.error('无网络连接');
      }

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      return _parseResponse(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE请求
  Future<ApiResponse<T>> delete<T>(String endpoint, T Function(dynamic) parser) async {
    try {
      if (!await _checkConnectivity()) {
        return ApiResponse.error('无网络连接');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      return _parseResponse(response, parser);
    } catch (e) {
      return _handleError<T>(e);
    }
  }
}
