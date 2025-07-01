// 文件: utils/performance_analyzer.dart
// 学生性能分析与预测工具类

import 'dart:math';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/performance_model.dart';
import '../models/score_model.dart';
import '../utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceAnalyzer {
  // 分析学生在特定学科的表现趋势
  static Map<String, dynamic> analyzePerformanceTrend(List<ScoreModel> historicalScores) {
    if (historicalScores.isEmpty) {
      return {
        'trend': 'insufficient_data',
        'averageScore': 0.0,
        'highestScore': 0.0,
        'lowestScore': 0.0,
        'improvement': 0.0,
        'consistencyScore': 0.0,
      };
    }

    // 按时间排序成绩
    historicalScores.sort((a, b) => a.date.compareTo(b.date));

    // 计算关键指标
    double averageScore = historicalScores.map((score) => score.value).reduce((a, b) => a + b) / historicalScores.length;
    double highestScore = historicalScores.map((score) => score.value).reduce(max);
    double lowestScore = historicalScores.map((score) => score.value).reduce((a, b) => a < b ? a : b);

    // 计算进步情况
    double firstScore = historicalScores.first.value;
    double lastScore = historicalScores.last.value;
    double improvement = lastScore - firstScore;

    // 计算一致性得分（标准差的倒数，越一致分数越高）
    double mean = averageScore;
    double sumSquaredDiff = historicalScores.map((score) => pow(score.value - mean, 2)).reduce((a, b) => a + b);
    double standardDeviation = sqrt(sumSquaredDiff / historicalScores.length);
    double consistencyScore = standardDeviation > 0 ? 100 / standardDeviation : 100;

    // 确定趋势
    String trend;
    if (historicalScores.length < 3) {
      trend = 'insufficient_data';
    } else {
      // 简单线性回归分析趋势
      int n = historicalScores.length;
      List<double> x = List.generate(n, (i) => i.toDouble());
      List<double> y = historicalScores.map((score) => score.value).toList();

      double sumX = x.reduce((a, b) => a + b);
      double sumY = y.reduce((a, b) => a + b);
      double sumXY = 0;
      double sumXX = 0;

      for (int i = 0; i < n; i++) {
        sumXY += x[i] * y[i];
        sumXX += x[i] * x[i];
      }

      double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);

      if (slope > 0.5) {
        trend = 'strong_improvement';
      } else if (slope > 0.1) {
        trend = 'moderate_improvement';
      } else if (slope > -0.1) {
        trend = 'stable';
      } else if (slope > -0.5) {
        trend = 'moderate_decline';
      } else {
        trend = 'strong_decline';
      }
    }

    return {
      'trend': trend,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
      'improvement': improvement,
      'consistencyScore': consistencyScore,
    };
  }

  // 预测未来成绩
  static Map<String, dynamic> predictFuturePerformance(List<ScoreModel> historicalScores, int periodsAhead) {
    if (historicalScores.length < 3 || periodsAhead < 1) {
      return {
        'predictedScores': <double>[],
        'confidence': 0.0,
        'predictionModel': 'insufficient_data',
      };
    }

    // 按时间排序成绩
    historicalScores.sort((a, b) => a.date.compareTo(b.date));

    // 提取分数序列
    List<double> scores = historicalScores.map((score) => score.value).toList();

    // 使用简单的线性回归预测
    int n = scores.length;
    List<double> x = List.generate(n, (i) => i.toDouble());
    List<double> y = scores;

    double sumX = x.reduce((a, b) => a + b);
    double sumY = y.reduce((a, b) => a + b);
    double sumXY = 0;
    double sumXX = 0;

    for (int i = 0; i < n; i++) {
      sumXY += x[i] * y[i];
      sumXX += x[i] * x[i];
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    // 计算预测值
    List<double> predictedScores = List.generate(periodsAhead, (i) {
      double rawPrediction = intercept + slope * (n + i);
      // 确保预测值在合理范围内（0-100）
      return max(0, min(100, rawPrediction));
    });

    // 计算预测置信度（基于历史数据的一致性）
    double mean = sumY / n;
    double sumSquaredDiff = 0;
    for (int i = 0; i < n; i++) {
      double predicted = intercept + slope * i;
      sumSquaredDiff += pow(y[i] - predicted, 2);
    }
    double standardError = sqrt(sumSquaredDiff / (n - 2));
    double confidence = max(0, min(100, 100 - standardError * 10));

    return {
      'predictedScores': predictedScores,
      'confidence': confidence,
      'predictionModel': 'linear_regression',
    };
  }

  // 识别学生的优势与弱点学科
  static Map<String, List<SubjectModel>> identifyStrengthsAndWeaknesses(Map<String, List<ScoreModel>> subjectScores) {
    if (subjectScores.isEmpty) {
      return {
        'strengths': <SubjectModel>[],
        'weaknesses': <SubjectModel>[],
        'average': <SubjectModel>[],
      };
    }

    // 计算每个学科的平均分
    Map<String, double> subjectAverages = {};
    Map<String, SubjectModel> subjectModels = {};

    subjectScores.forEach((subjectId, scores) {
      if (scores.isNotEmpty) {
        double average = scores.map((score) => score.value).reduce((a, b) => a + b) / scores.length;
        subjectAverages[subjectId] = average;

        // 假设我们可以从分数中获取学科信息（这里只是示例，实际项目中需要调整）
        String subjectName = scores.first.subjectName ?? "未知学科";
        subjectModels[subjectId] = SubjectModel(
          id: subjectId,
          name: subjectName,
          teacherId: scores.first.teacherId,
          averageScore: average,
        );
      }
    });

    // 计算总平均分
    double overallAverage = subjectAverages.values.reduce((a, b) => a + b) / subjectAverages.length;

    // 识别优势和弱点（与平均分相比）
    List<SubjectModel> strengths = [];
    List<SubjectModel> weaknesses = [];
    List<SubjectModel> average = [];

    subjectAverages.forEach((subjectId, avgScore) {
      if (avgScore >= overallAverage + 10) {
        strengths.add(subjectModels[subjectId]!);
      } else if (avgScore <= overallAverage - 10) {
        weaknesses.add(subjectModels[subjectId]!);
      } else {
        average.add(subjectModels[subjectId]!);
      }
    });

    // 按平均分排序
    strengths.sort((a, b) => b.averageScore!.compareTo(a.averageScore!));
    weaknesses.sort((a, b) => a.averageScore!.compareTo(b.averageScore!));
    average.sort((a, b) => b.averageScore!.compareTo(a.averageScore!));

    return {
      'strengths': strengths,
      'weaknesses': weaknesses,
      'average': average,
    };
  }

  // 比较学生与班级平均水平的差距
  static Map<String, dynamic> compareWithClassAverage(
      Map<String, double> studentAverages, Map<String, double> classAverages) {
    if (studentAverages.isEmpty || classAverages.isEmpty) {
      return {
        'overall': {
          'studentAverage': 0.0,
          'classAverage': 0.0,
          'difference': 0.0,
          'percentile': 50.0,
        },
        'subjects': <Map<String, dynamic>>[],
      };
    }

    // 计算学生总平均分
    double studentOverallAvg = studentAverages.values.reduce((a, b) => a + b) / studentAverages.length;

    // 计算班级总平均分
    double classOverallAvg = classAverages.values.reduce((a, b) => a + b) / classAverages.length;

    // 假设百分位数（在实际应用中，这需要额外的数据）
    double assumedPercentile = studentOverallAvg > classOverallAvg ? 75.0 : 25.0;

    // 按学科比较
    List<Map<String, dynamic>> subjectComparisons = [];

    studentAverages.forEach((subjectId, studentAvg) {
      if (classAverages.containsKey(subjectId)) {
        double classAvg = classAverages[subjectId]!;
        double difference = studentAvg - classAvg;
        double subjectPercentile = studentAvg > classAvg ? 75.0 : 25.0;

        subjectComparisons.add({
          'subjectId': subjectId,
          'studentAverage': studentAvg,
          'classAverage': classAvg,
          'difference': difference,
          'percentile': subjectPercentile,
        });
      }
    });

    // 按差异大小排序
    subjectComparisons.sort((a, b) => b['difference'].abs().compareTo(a['difference'].abs()));

    return {
      'overall': {
        'studentAverage': studentOverallAvg,
        'classAverage': classOverallAvg,
        'difference': studentOverallAvg - classOverallAvg,
        'percentile': assumedPercentile,
      },
      'subjects': subjectComparisons,
    };
  }

  // 生成学习建议
  static List<Map<String, String>> generateLearningRecommendations(
      Map<String, List<SubjectModel>> strengthsAndWeaknesses) {
    List<Map<String, String>> recommendations = [];

    // 针对弱势学科的建议
    for (var subject in strengthsAndWeaknesses['weaknesses'] ?? []) {
      recommendations.add({
        'subjectId': subject.id,
        'subjectName': subject.name,
        'type': 'weakness',
        'recommendation': '增加${subject.name}的学习时间，重点关注基础概念。考虑寻求额外的辅导或参加学习小组。',
      });
    }

    // 针对优势学科的建议
    for (var subject in strengthsAndWeaknesses['strengths'] ?? []) {
      recommendations.add({
        'subjectId': subject.id,
        'subjectName': subject.name,
        'type': 'strength',
        'recommendation': '继续保持${subject.name}的良好表现，可以尝试更具挑战性的内容或辅导其他同学。',
      });
    }

    // 通用建议
    recommendations.add({
      'subjectId': 'general',
      'subjectName': '学习习惯',
      'type': 'general',
      'recommendation': '建立规律的学习计划，每天复习所学内容，使用闪卡和练习题巩固知识点。',
    });

    recommendations.add({
      'subjectId': 'general',
      'subjectName': '时间管理',
      'type': 'general',
      'recommendation': '使用番茄工作法提高专注度，合理分配各学科的学习时间，优先处理较难的科目。',
    });

    return recommendations;
  }

  // 生成性能可视化数据
  static Map<String, dynamic> generatePerformanceVisualData(List<ScoreModel> historicalScores) {
    if (historicalScores.isEmpty) {
      return {
        'lineChartData': <FlSpot>[],
        'barChartData': <double>[],
        'radarChartData': <double>[],
        'labels': <String>[],
      };
    }

    // 按时间排序成绩
    historicalScores.sort((a, b) => a.date.compareTo(b.date));

    // 生成折线图数据
    List<FlSpot> lineChartSpots = [];
    for (int i = 0; i < historicalScores.length; i++) {
      lineChartSpots.add(FlSpot(i.toDouble(), historicalScores[i].value));
    }

    // 生成柱状图数据
    List<double> barChartData = historicalScores.map((score) => score.value).toList();

    // 生成雷达图数据（假设按考试类型分组）
    Map<String, List<double>> scoresByType = {};
    for (var score in historicalScores) {
      String type = score.examType ?? '未知';
      if (!scoresByType.containsKey(type)) {
        scoresByType[type] = [];
      }
      scoresByType[type]!.add(score.value);
    }

    List<String> labels = scoresByType.keys.toList();
    List<double> radarData = [];

    for (var type in labels) {
      var scores = scoresByType[type]!;
      double average = scores.reduce((a, b) => a + b) / scores.length;
      radarData.add(average);
    }

    // 如果没有分组数据，使用总平均分
    if (radarData.isEmpty) {
      labels = ['平均分'];
      radarData = [historicalScores.map((score) => score.value).reduce((a, b) => a + b) / historicalScores.length];
    }

    return {
      'lineChartData': lineChartSpots,
      'barChartData': barChartData,
      'radarChartData': radarData,
      'labels': labels,
    };
  }
}
