
class TeacherModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String department;
  final List<String> subjects;
  final bool isAdmin;

  TeacherModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.subjects,
    this.isAdmin = false,
  });

  factory TeacherModel.fromMap(String uid, Map<String, dynamic> data) {
    return TeacherModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      subjects: List<String>.from(data['subjects'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'subjects': subjects,
      'isAdmin': isAdmin,
    };
  }
}
