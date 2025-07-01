// 文件: utils/constants.dart
// 应用常量定义

class AppConstants {
  // API端点
  static const String baseUrl = 'https://api.ismart-edu.com';
  static const String newsApiUrl = 'https://newsapi.org/v2';

  // 新闻类别
  static const List<String> newsCategories = [
    '技术',
    '政治',
    '体育',
    '时尚',
    '科学',
    '健康',
    '商业',
    '娱乐'
  ];

  // 绩效级别
  static const String PERFORMANCE_BELOW_BASIC = '基础水平以下';
  static const String PERFORMANCE_BASIC = '基础水平';
  static const String PERFORMANCE_PROFICIENT = '熟练水平';
  static const String PERFORMANCE_ADVANCED = '高级水平';

  // 存储键
  static const String USER_PREFERENCES_KEY = 'user_preferences';
  static const String USER_TOKEN_KEY = 'user_token';
  static const String USER_DATA_KEY = 'user_data';

  // 分数权重
  static const double CLASSTEST_WEIGHT = 0.2;  // 班级测试占总成绩的20%
  static const double INTERNAL_WEIGHT = 0.2;   // 内部评分占总成绩的20%
  static const double FINAL_EXAM_WEIGHT = 0.6; // 期末考试占总成绩的60%

  // 推荐阈值
  static const double RECOMMENDATION_THRESHOLD_HIGH = 80.0;   // 高绩效阈值
  static const double RECOMMENDATION_THRESHOLD_MEDIUM = 60.0; // 中等绩效阈值
  static const double RECOMMENDATION_THRESHOLD_LOW = 40.0;    // 低绩效阈值
}

class RouteConstants {
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String DASHBOARD = '/dashboard';
  static const String COURSE_DETAIL = '/course_detail';
  static const String COURSES = '/courses';
  static const String PROFILE = '/profile';
  static const String PREFERENCES = '/preferences';
  static const String CHATBOT = '/chatbot';
  static const String MESSAGES = '/messages';
}

class FirestoreCollections {
  static const String USERS = 'users';
  static const String COURSES = 'courses';
  static const String SCORES = 'scores';
  static const String TEACHERS = 'teachers';
  static const String PERFORMANCE = 'performance';
  static const String NEWS_PREFERENCES = 'news_preferences';
  static const String MESSAGES = 'messages';
}
