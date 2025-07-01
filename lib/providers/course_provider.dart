
import 'package:flutter/material.dart';
import 'package:either_dart/either.dart';
import '../models/course_model.dart';
import '../services/firestore_service.dart';

class CourseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;

  // 获取所有属性
  List<CourseModel> get courses => _courses;
  CourseModel? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CourseProvider(this._firestoreService);

  // 加载所有课程
  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _firestoreService.getCourses();

    result.fold(
      (error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
      },
      (courses) {
        _courses = courses;
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  // 加载单个课程详情
  Future<void> loadCourseDetails(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _firestoreService.getCourseById(courseId);

    result.fold(
      (error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
      },
      (course) {
        _selectedCourse = course;
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  // 清除选中的课程
  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  // 按分类过滤课程
  List<CourseModel> filterCoursesByCategory(String category) {
    return _courses.where((course) => 
      course.topics.contains(category.toLowerCase())).toList();
  }

  // 按名称搜索课程
  List<CourseModel> searchCourses(String query) {
    final lowerCaseQuery = query.toLowerCase();
    return _courses.where((course) => 
      course.title.toLowerCase().contains(lowerCaseQuery) || 
      course.description.toLowerCase().contains(lowerCaseQuery) ||
      course.instructor.toLowerCase().contains(lowerCaseQuery)
    ).toList();
  }

  // 获取热门课程（根据评分和注册人数）
  List<CourseModel> getPopularCourses() {
    final sortedCourses = List<CourseModel>.from(_courses);
    sortedCourses.sort((a, b) => 
      ((b.rating * 10) + b.enrolledCount).compareTo((a.rating * 10) + a.enrolledCount)
    );
    return sortedCourses.take(5).toList();
  }
}
