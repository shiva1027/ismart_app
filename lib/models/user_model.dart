class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final List<String> preferences;
  final String rollNumber;
  final String enrollmentNumber;
  final int currentSemester;
  final String department;
  final int yearOfStudy;
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.preferences,
    required this.rollNumber,
    required this.enrollmentNumber,
    required this.currentSemester,
    required this.department,
    required this.yearOfStudy,
  });
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      preferences: List<String>.from(data['preferences'] ?? []),
      rollNumber: data['rollNumber'] ?? '',
      enrollmentNumber: data['enrollmentNumber'] ?? '',
      currentSemester: data['currentSemester'] ?? 1,
      department: data['department'] ?? '',
      yearOfStudy: data['yearOfStudy'] ?? 1,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'preferences': preferences,
      'rollNumber': rollNumber,
      'enrollmentNumber': enrollmentNumber,
      'currentSemester': currentSemester,
      'department': department,
      'yearOfStudy': yearOfStudy,
    };
  }
}