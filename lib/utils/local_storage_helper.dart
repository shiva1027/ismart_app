// 文件: utils/local_storage_helper.dart
// 本地存储辅助工具类

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageHelper {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // 保存用户令牌（使用安全存储）
  static Future<void> saveUserToken(String token) async {
    await _secureStorage.write(key: AppConstants.USER_TOKEN_KEY, value: token);
  }

  // 获取用户令牌
  static Future<String?> getUserToken() async {
    return await _secureStorage.read(key: AppConstants.USER_TOKEN_KEY);
  }

  // 删除用户令牌
  static Future<void> deleteUserToken() async {
    await _secureStorage.delete(key: AppConstants.USER_TOKEN_KEY);
  }

  // 保存用户数据
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.USER_DATA_KEY, jsonEncode(user.toJson()));
  }

  // 获取用户数据
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.USER_DATA_KEY);

    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }

    return null;
  }

  // 删除用户数据
  static Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.USER_DATA_KEY);
  }

  // 保存用户偏好设置
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.USER_PREFERENCES_KEY, jsonEncode(preferences));
  }

  // 获取用户偏好设置
  static Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userPrefs = prefs.getString(AppConstants.USER_PREFERENCES_KEY);

    if (userPrefs != null) {
      return jsonDecode(userPrefs);
    }

    return {};
  }

  // 更新单个偏好设置
  static Future<void> updatePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final userPrefs = prefs.getString(AppConstants.USER_PREFERENCES_KEY);

    Map<String, dynamic> preferences = {};
    if (userPrefs != null) {
      preferences = jsonDecode(userPrefs);
    }

    preferences[key] = value;
    await prefs.setString(AppConstants.USER_PREFERENCES_KEY, jsonEncode(preferences));
  }

  // 保存缓存数据（带有过期时间）
  static Future<void> saveCache(String key, dynamic data, Duration expiration) async {
    final prefs = await SharedPreferences.getInstance();

    final cacheData = {
      'data': data,
      'expiry': DateTime.now().add(expiration).millisecondsSinceEpoch,
    };

    await prefs.setString('cache_$key', jsonEncode(cacheData));
  }

  // 获取缓存数据（如果未过期）
  static Future<dynamic> getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cache_$key');

    if (cachedData != null) {
      final Map<String, dynamic> data = jsonDecode(cachedData);
      final int expiry = data['expiry'];

      // 检查是否过期
      if (expiry > DateTime.now().millisecondsSinceEpoch) {
        return data['data'];
      } else {
        // 已过期，清除缓存
        await prefs.remove('cache_$key');
      }
    }

    return null;
  }

  // 清除所有缓存
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith('cache_')) {
        await prefs.remove(key);
      }
    }
  }

  // 保存离线数据
  static Future<void> saveOfflineData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offline_$key', jsonEncode(data));
  }

  // 获取离线数据
  static Future<dynamic> getOfflineData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('offline_$key');

    if (data != null) {
      return jsonDecode(data);
    }

    return null;
  }

  // 保存最近的查询
  static Future<void> saveRecentSearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = await getRecentSearches();

    // 如果已存在，移除旧的再添加到首位
    searches.remove(search);
    searches.insert(0, search);

    // 限制最多保存20条记录
    if (searches.length > 20) {
      searches = searches.sublist(0, 20);
    }

    await prefs.setStringList('recent_searches', searches);
  }

  // 获取最近的查询
  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_searches') ?? [];
  }

  // 清除最近的查询
  static Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  // 保存课程进度
  static Future<void> saveCourseProgress(String courseId, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allProgress = await getCourseProgressMap();

    allProgress[courseId] = progress;
    await prefs.setString('course_progress', jsonEncode(allProgress));
  }

  // 获取课程进度
  static Future<double> getCourseProgress(String courseId) async {
    final allProgress = await getCourseProgressMap();
    return allProgress[courseId] ?? 0.0;
  }

  // 获取所有课程进度
  static Future<Map<String, dynamic>> getCourseProgressMap() async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString('course_progress');

    if (progressData != null) {
      return jsonDecode(progressData);
    }

    return {};
  }

  // 清除用户登录状态（用于注销）
  static Future<void> clearUserSession() async {
    await deleteUserToken();
    await deleteUserData();
  }

  // 检查是否是首次启动应用
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('is_first_launch', false);
    }

    return isFirstLaunch;
  }
}
