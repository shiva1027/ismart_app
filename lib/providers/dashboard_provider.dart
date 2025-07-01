import 'package:flutter/foundation.dart';
import 'package:either_dart/either.dart';
import '../models/news_model.dart';
import '../models/performance_model.dart';
import '../services/firestore_service.dart';

class DashboardProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  
  bool _isLoading = false;
  String? _error;
  PerformanceModel? _performance;
  List<NewsModel> _news = [];

  DashboardProvider(this._firestoreService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  PerformanceModel? get performance => _performance;
  List<NewsModel> get news => _news;

  Future<void> loadDashboard(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load performance data
      final performanceResult = await _firestoreService.getPerformance(uid);
      performanceResult.fold(
        (error) => _error = error,
        (data) => _performance = data
      );

      if (_error != null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load preferences and news
      final prefsResult = await _firestoreService.getPreferences(uid);
      await prefsResult.fold(
        (error) => _error = error,
        (prefs) async {
          final newsResult = await _firestoreService.getNewsForPreferences(prefs);
          newsResult.fold(
            (error) => _error = error,
            (data) => _news = data
          );
        }
      );
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard(String uid) async {
    _error = null;
    notifyListeners();
    await loadDashboard(uid);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
