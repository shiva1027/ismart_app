class ScoreModel {
  final String subjectId;
  final String subjectName;
  final int semester;
  final int ct1;
  final int ct2;
  final List<int> assignments; // 4 scores (2 before CT-1, 2 after CT-1)
  final int finalExam;
  final int internalMarks;
  final int practical;
  final bool isPracticalSubject;
  final String updatedBy;
  final DateTime lastUpdated;
  ScoreModel({
    required this.subjectId,
    required this.subjectName,
    required this.semester,
    required this.ct1,
    required this.ct2,
    required this.assignments,
    required this.finalExam,
    required this.internalMarks,
    required this.practical,
    required this.isPracticalSubject,
    required this.updatedBy,
    required this.lastUpdated,
  });

  factory ScoreModel.fromMap(Map<String, dynamic> data) {
    return ScoreModel(
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      semester: data['semester'] ?? 0,
      ct1: data['ct1'] ?? 0,
      ct2: data['ct2'] ?? 0,
      assignments: List<int>.from(data['assignments'] ?? []),
      finalExam: data['finalExam'] ?? 0,
      internalMarks: data['internalMarks'] ?? 0,
      practical: data['practical'] ?? 0,
      isPracticalSubject: data['isPracticalSubject'] ?? false,
      updatedBy: data['updatedBy'] ?? '',
      lastUpdated: data['lastUpdated'] != null 
          ? DateTime.parse(data['lastUpdated']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'semester': semester,
      'ct1': ct1,
      'ct2': ct2,
      'assignments': assignments,
      'finalExam': finalExam,
      'internalMarks': internalMarks,
      'practical': practical,
      'isPracticalSubject': isPracticalSubject,
      'updatedBy': updatedBy,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double calculateFinalScore() {
    // CT marks aggregated to 20
    double ctScore = (ct1 + ct2) / 2 * 0.2;
    
    // Assignments aggregated to 20
    double assignmentScore = 0;
    if (assignments.isNotEmpty) {
      int totalAssignmentMarks = assignments.reduce((a, b) => a + b);
      assignmentScore = (totalAssignmentMarks / assignments.length) * 5;  // 4 assignments, total 20 marks
    }
    
    // Final exam of 100 (scaled to 60 for final score)
    double examScore = finalExam * 0.6;
    
    // Total score
    return ctScore + assignmentScore + examScore;
  }
}