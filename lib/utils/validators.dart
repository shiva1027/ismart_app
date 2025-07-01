// 文件: utils/validators.dart
// 表单验证工具类

class Validators {
  // 电子邮件验证
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入电子邮件地址';
    }

    // 使用正则表达式验证电子邮件格式
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return '请输入有效的电子邮件地址';
    }

    return null; // 验证通过
  }

  // 密码验证
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码长度必须至少为6个字符';
    }

    return null; // 验证通过
  }

  // 学号验证
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入学号';
    }

    // 假设学号必须是8位数字
    final studentIdRegExp = RegExp(r'^\d{8}$');
    if (!studentIdRegExp.hasMatch(value)) {
      return '学号必须是8位数字';
    }

    return null; // 验证通过
  }

  // 入学号验证
  static String? validateEnrollmentId(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入入学号';
    }

    // 假设入学号的格式为：YYYY-XXXXXXXX (年份后跟8位数字)
    final enrollmentIdRegExp = RegExp(r'^\d{4}-\d{8}$');
    if (!enrollmentIdRegExp.hasMatch(value)) {
      return '入学号格式无效 (应为: YYYY-XXXXXXXX)';
    }

    return null; // 验证通过
  }

  // 手机号验证
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号码';
    }

    // 假设手机号必须是11位数字
    final phoneRegExp = RegExp(r'^\d{11}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '请输入有效的11位手机号码';
    }

    return null; // 验证通过
  }

  // 通用非空验证
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }

    return null; // 验证通过
  }

  // 分数验证 (0-100)
  static String? validateScore(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入分数';
    }

    try {
      final score = double.parse(value);
      if (score < 0 || score > 100) {
        return '分数必须在0到100之间';
      }
    } catch (e) {
      return '请输入有效的数字';
    }

    return null; // 验证通过
  }
}
