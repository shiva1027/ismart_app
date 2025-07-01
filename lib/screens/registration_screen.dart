import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _enrollmentNumberController = TextEditingController();
  final _departmentController = TextEditingController();
  int _currentSemester = 1;
  int _yearOfStudy = 1;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rollNumberController.dispose();
    _enrollmentNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _phoneController.text.trim(),
        _rollNumberController.text.trim(),
        _enrollmentNumberController.text.trim(),
        _departmentController.text.trim(),
        _currentSemester,
        _yearOfStudy,
      );

      if (user != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('注册成功!')));
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('注册失败: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建账户')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // App logo or image
                const Icon(Icons.school, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  '创建您的学生账户',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入您的姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '电子邮箱',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入电子邮箱';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return '请输入有效的电子邮箱';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '手机号码',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入手机号码';
                    }
                    if (value.length != 11) {
                      return '请输入有效的手机号码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '密码',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码必须至少6个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认您的密码';
                    }
                    if (value != _passwordController.text) {
                      return '两次输入的密码不匹配';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Roll Number field
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(
                    labelText: '学号',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment_ind),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入学号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Enrollment Number field
                TextFormField(
                  controller: _enrollmentNumberController,
                  decoration: const InputDecoration(
                    labelText: '注册号码',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入注册号码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department field
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: '系/专业',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入系/专业';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Current Semester dropdown
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: '当前学期',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  value: _currentSemester,
                  items: List.generate(8, (index) => index + 1).map((semester) {
                    return DropdownMenuItem<int>(
                      value: semester,
                      child: Text('第 $semester 学期'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentSemester = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '请选择当前学期';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Year of Study dropdown
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: '学习年限',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  value: _yearOfStudy,
                  items: List.generate(4, (index) => index + 1).map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text('第 $year 年'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _yearOfStudy = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '请选择学习年限';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Register button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('注册', style: TextStyle(fontSize: 18)),
                    ),
                const SizedBox(height: 16),

                // Login link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('已有账户？ 登录'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}