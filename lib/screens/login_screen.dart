import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登录')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入您的邮箱';
                  }
                  if (!value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入您的密码';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        try {
                          final user = await AuthService().signIn(
                            emailController.text,
                            passwordController.text,
                          );
                          if (user != null) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/dashboard',
                            );
                          } else {
                            setState(() {
                              _errorMessage = '登录失败，请检查您的邮箱和密码';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            _errorMessage = '登录出错: ${e.toString()}';
                          });
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('登录', style: TextStyle(fontSize: 16)),
                  ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text("还没有账号？注册"),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
