import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/courses_screen.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'providers/dashboard_provider.dart';
import 'providers/course_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

</edit>

<origin>
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        // 如果正在初始化，显示加载界面
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        // 如果初始化出错，显示错误信息
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }
        
        return MultiProvider(
</origin>
<edit>
  Widget build(BuildContext context) {
    return MultiProvider(
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        // 如果正在初始化，显示加载界面
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        // 如果初始化出错，显示错误信息
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        }
        
        return MultiProvider(
          providers: [
            Provider<FirestoreService>(
              create: (_) => FirestoreService(),
            ),
            Provider<AuthService>(
              create: (_) => AuthService(),
            ),
            ChangeNotifierProxyProvider<FirestoreService, DashboardProvider>(
              create: (context) => DashboardProvider(
                Provider.of<FirestoreService>(context, listen: false),
              ),
              update: (context, firestoreService, previous) =>
                  DashboardProvider(firestoreService),
            ),
            ChangeNotifierProxyProvider<FirestoreService, CourseProvider>(
              create: (context) => CourseProvider(
                Provider.of<FirestoreService>(context, listen: false),
              ),
              update: (context, firestoreService, previous) =>
                  CourseProvider(firestoreService),
            ),
          ],
          child: MaterialApp(
            title: 'Student App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
              ),
            ),
            home: _handleAuthState(),
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/course_detail': (context) => const CourseDetailScreen(),
              '/courses': (context) => const CoursesScreen(),
            },
          ),
        );
      },
    );
  }
  
  // 处理身份认证状态
  Widget _handleAuthState() {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, AsyncSnapshot snapshot) {
        // 如果有用户登录，跳转到首页
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        // 否则显示登录页
        else {
          return const LoginScreen();
        }
      },
    );
  }
}