import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/news_model.dart';
import '../models/performance_model.dart';
import '../models/course_model.dart';
import 'news_service.dart';
class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _logger = Logger();
  final _cache = <String, dynamic>{};
  static const _cacheExpiration = Duration(minutes: 5);

  Future<Either<String, void>> savePreferences(String uid, List<String> prefs) async {
    try {
      await _db.collection('users').doc(uid).update({'preferences': prefs});
      return const Right(null);
    } catch (e) {
      _logger.e('Error saving preferences', e);
      return Left('Failed to save preferences: ${e.toString()}');
    }
  }

  Future<Either<String, List<NewsModel>>> getNewsForPreferences(List<String> prefs) async {
    try {
      final cacheKey = 'news_${prefs.join("_")}';
      final cachedNews = await _getCachedData<List<NewsModel>>(cacheKey);
      if (cachedNews != null) return Right(cachedNews);

      final newsService = NewsService();
      final newsData = await newsService.fetchNews(prefs);
      final news = newsData.map((n) => NewsModel.fromMap(n)).toList();
      
      await _cacheData(cacheKey, news);
      return Right(news);
    } catch (e) {
      _logger.e('Error fetching news', e);
      return Left('Failed to fetch news: ${e.toString()}');
    }
  }

  Future<Either<String, List<String>>> getPreferences(String uid) async {
    try {
      final cacheKey = 'prefs_$uid';
      final cachedPrefs = await _getCachedData<List<String>>(cacheKey);
      if (cachedPrefs != null) return Right(cachedPrefs);

      final snap = await _db.collection('users').doc(uid).get();
      final prefs = List<String>.from(snap['preferences'] ?? []);
      
      await _cacheData(cacheKey, prefs);
      return Right(prefs);
    } catch (e) {
      _logger.e('Error fetching preferences', e);
      return Left('Failed to fetch preferences: ${e.toString()}');
    }
  }

  Future<Either<String, void>> sendMessage(String uid, String message) async {
    try {
      await _db.collection('users').doc(uid).collection('messages').add({
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': 'student',
      });
      return const Right(null);
    } catch (e) {
      _logger.e('Error sending message', e);
      return Left('Failed to send message: ${e.toString()}');
    }
  }

  Stream<Either<String, QuerySnapshot>> getMessages(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => Right(snapshot))
        .handleError((e) {
          _logger.e('Error streaming messages', e);
          return Left('Failed to stream messages: ${e.toString()}');
        });
  }

  Future<Either<String, PerformanceModel>> getPerformance(String uid) async {
    try {
      final cacheKey = 'performance_$uid';
      final cachedPerformance = await _getCachedData<PerformanceModel>(cacheKey);
      if (cachedPerformance != null) return Right(cachedPerformance);

      final result = await _db.collection('performance').doc(uid).get();
      final performance = PerformanceModel.fromMap(result.data() ?? {});
      
      await _cacheData(cacheKey, performance);
      return Right(performance);
    } catch (e) {
      _logger.e('Error fetching performance', e);
      return Left('Failed to fetch performance: ${e.toString()}');
    }
  }

  Future<Either<String, List<CourseModel>>> getCourses() async {
    try {
      const cacheKey = 'courses';
      final cachedCourses = await _getCachedData<List<CourseModel>>(cacheKey);
      if (cachedCourses != null) return Right(cachedCourses);

      final querySnapshot = await _db.collection('courses').get();
      final courses = querySnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.id, doc.data()))
          .toList();
      
      await _cacheData(cacheKey, courses);
      return Right(courses);
    } catch (e) {
      _logger.e('Error fetching courses', e);
      return Left('Failed to fetch courses: ${e.toString()}');
    }
  }

  Future<Either<String, CourseModel>> getCourseById(String courseId) async {
    try {
      final cacheKey = 'course_$courseId';
      final cachedCourse = await _getCachedData<CourseModel>(cacheKey);
      if (cachedCourse != null) return Right(cachedCourse);

      final docSnapshot = await _db.collection('courses').doc(courseId).get();
      if (!docSnapshot.exists) {
        return Left('Course not found');
      }
      
      final course = CourseModel.fromMap(docSnapshot.id, docSnapshot.data()!);
      
      await _cacheData(cacheKey, course);
      return Right(course);
    } catch (e) {
      _logger.e('Error fetching course details', e);
      return Left('Failed to fetch course details: ${e.toString()}');
    }
  }

  Future<T?> _getCachedData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('${key}_timestamp');
    if (timestamp == null) return null;

    final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp > 
        _cacheExpiration.inMilliseconds;
    if (isExpired) {
      await prefs.remove(key);
      await prefs.remove('${key}_timestamp');
      return null;
    }

    return _cache[key] as T?;
  }

  Future<void> _cacheData<T>(String key, T data) async {
    final prefs = await SharedPreferences.getInstance();
    _cache[key] = data;
    await prefs.setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}