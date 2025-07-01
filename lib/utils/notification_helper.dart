// 文件: utils/notification_helper.dart
// 通知管理工具类

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // 通知渠道ID和名称
  static const String _channelId = 'ismart_notifications';
  static const String _channelName = 'iSmart通知';
  static const String _channelDescription = '学习提醒和成绩更新通知';

  // 通知类型
  static const String TYPE_SCORE_UPDATE = 'score_update';
  static const String TYPE_EXAM_REMINDER = 'exam_reminder';
  static const String TYPE_ASSIGNMENT_DUE = 'assignment_due';
  static const String TYPE_GENERAL = 'general';
  static const String TYPE_ACHIEVEMENT = 'achievement';
  static const String TYPE_PERFORMANCE_UPDATE = 'performance_update';

  // 初始化通知插件
  static Future<void> init() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    // 初始化设置
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // 处理通知点击事件
        _handleNotificationTap(response.payload);
      },
    );

    _isInitialized = true;
  }

  // 检查通知权限并请求（仅限iOS，Android默认授予）
  static Future<bool> requestPermissions() async {
    if (!_isInitialized) await init();

    // 对于iOS，请求权限
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android默认返回true
  }

  // 显示即时通知
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String notificationType = TYPE_GENERAL,
  }) async {
    if (!_isInitialized) await init();

    // 检查通知是否已启用
    if (!await _isNotificationsEnabled()) return;

    // 创建通知详情
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1E88E5), // 匹配应用主色调
      // 根据通知类型设置不同的通知样式
      styleInformation: _getNotificationStyle(notificationType),
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 显示通知
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    // 保存通知到本地存储
    _saveNotificationToHistory(NotificationModel(
      id: id,
      title: title,
      body: body,
      type: notificationType,
      timestamp: DateTime.now(),
      isRead: false,
      payload: payload,
    ));
  }

  // 安排未来的通知
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String notificationType = TYPE_GENERAL,
  }) async {
    if (!_isInitialized) await init();

    // 检查通知是否已启用
    if (!await _isNotificationsEnabled()) return;

    // 创建通知详情
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1E88E5), // 匹配应用主色调
      styleInformation: _getNotificationStyle(notificationType),
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 安排通知
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    // 保存通知到计划列表
    _saveScheduledNotification(NotificationModel(
      id: id,
      title: title,
      body: body,
      type: notificationType,
      timestamp: scheduledDate,
      isRead: false,
      payload: payload,
      isScheduled: true,
    ));
  }

  // 创建重复性通知（如学习提醒）
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    required DateTime firstDate,
    String? payload,
    String notificationType = TYPE_GENERAL,
  }) async {
    if (!_isInitialized) await init();

    // 检查通知是否已启用
    if (!await _isNotificationsEnabled()) return;

    // 创建通知详情
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1E88E5), // 匹配应用主色调
      styleInformation: _getNotificationStyle(notificationType),
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 安排重复通知
    await _notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      notificationDetails,
      androidAllowWhileIdle: true,
      payload: payload,
    );

    // 保存通知设置
    _saveScheduledNotification(NotificationModel(
      id: id,
      title: title,
      body: body,
      type: notificationType,
      timestamp: firstDate,
      isRead: false,
      payload: payload,
      isScheduled: true,
      isRepeating: true,
      repeatInterval: repeatInterval.index,
    ));
  }

  // 取消特定通知
  static Future<void> cancelNotification(int id) async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancel(id);
    await _removeScheduledNotification(id);
  }

  // 取消所有通知
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _notificationsPlugin.cancelAll();
    await _clearAllScheduledNotifications();
  }

  // 获取通知历史
  static Future<List<NotificationModel>> getNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notification_history');

    if (notificationsJson == null) {
      return [];
    }

    List<dynamic> decodedList = json.decode(notificationsJson);
    return decodedList.map((item) => NotificationModel.fromJson(item)).toList();
  }

  // 标记通知为已读
  static Future<void> markNotificationAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notification_history');

    if (notificationsJson == null) {
      return;
    }

    List<dynamic> decodedList = json.decode(notificationsJson);
    List<NotificationModel> notifications = 
        decodedList.map((item) => NotificationModel.fromJson(item)).toList();

    for (int i = 0; i < notifications.length; i++) {
      if (notifications[i].id == id) {
        notifications[i] = notifications[i].copyWith(isRead: true);
        break;
      }
    }

    await prefs.setString('notification_history', 
        json.encode(notifications.map((n) => n.toJson()).toList()));
  }

  // 清除所有通知历史
  static Future<void> clearNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
  }

  // 启用/禁用通知
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    // 如果禁用，取消所有活跃通知
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  // 检查通知是否已启用
  static Future<bool> _isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true; // 默认启用
  }

  // 保存通知到历史记录
  static Future<void> _saveNotificationToHistory(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notification_history');

    List<NotificationModel> notifications = [];
    if (notificationsJson != null) {
      List<dynamic> decodedList = json.decode(notificationsJson);
      notifications = decodedList.map((item) => NotificationModel.fromJson(item)).toList();
    }

    // 添加新通知到列表开头
    notifications.insert(0, notification);

    // 限制历史记录大小（最多保留100条）
    if (notifications.length > 100) {
      notifications = notifications.sublist(0, 100);
    }

    await prefs.setString('notification_history', 
        json.encode(notifications.map((n) => n.toJson()).toList()));
  }

  // 保存计划通知信息
  static Future<void> _saveScheduledNotification(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final String? scheduledJson = prefs.getString('scheduled_notifications');

    List<NotificationModel> scheduled = [];
    if (scheduledJson != null) {
      List<dynamic> decodedList = json.decode(scheduledJson);
      scheduled = decodedList.map((item) => NotificationModel.fromJson(item)).toList();
    }

    // 检查是否已存在相同ID的通知，如果有则替换
    bool found = false;
    for (int i = 0; i < scheduled.length; i++) {
      if (scheduled[i].id == notification.id) {
        scheduled[i] = notification;
        found = true;
        break;
      }
    }

    if (!found) {
      scheduled.add(notification);
    }

    await prefs.setString('scheduled_notifications', 
        json.encode(scheduled.map((n) => n.toJson()).toList()));
  }

  // 移除计划通知
  static Future<void> _removeScheduledNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? scheduledJson = prefs.getString('scheduled_notifications');

    if (scheduledJson == null) {
      return;
    }

    List<dynamic> decodedList = json.decode(scheduledJson);
    List<NotificationModel> scheduled = 
        decodedList.map((item) => NotificationModel.fromJson(item)).toList();

    scheduled.removeWhere((notification) => notification.id == id);

    await prefs.setString('scheduled_notifications', 
        json.encode(scheduled.map((n) => n.toJson()).toList()));
  }

  // 清除所有计划通知
  static Future<void> _clearAllScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_notifications');
  }

  // 处理通知点击事件
  static void _handleNotificationTap(String? payload) {
    // 如果payload不为空，可以解析并执行相应的导航操作
    // 例如：payload可以包含要导航到的页面信息和所需的参数
    if (payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(payload);
        // 这里的导航逻辑将在应用内实现
        print('通知点击：$data');
      } catch (e) {
        print('通知payload解析错误：$e');
      }
    }
  }

  // 根据通知类型获取相应的样式
  static StyleInformation _getNotificationStyle(String type) {
    switch (type) {
      case TYPE_SCORE_UPDATE:
      case TYPE_PERFORMANCE_UPDATE:
        // 使用大文本样式显示成绩或性能更新详情
        return const BigTextStyleInformation('');
      case TYPE_EXAM_REMINDER:
      case TYPE_ASSIGNMENT_DUE:
        // 使用默认样式
        return const DefaultStyleInformation(true, true);
      case TYPE_ACHIEVEMENT:
        // 可以使用大图标样式显示成就图标
        return const BigTextStyleInformation('');
      default:
        return const DefaultStyleInformation(true, true);
    }
  }
}
