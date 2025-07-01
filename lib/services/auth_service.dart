import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Authentication state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> register(String name, String email, String password, String phone, 
      String rollNumber, String enrollmentNumber, String department, int currentSemester, int yearOfStudy) async {
    try {
      // Create user with email and password
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user model
        final userModel = UserModel(
          uid: result.user!.uid,
          name: name,
          email: email,
          phone: phone,
          preferences: [],
          rollNumber: rollNumber,
          enrollmentNumber: enrollmentNumber,
          department: department,
          currentSemester: currentSemester,
          yearOfStudy: yearOfStudy,
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(result.user!.uid).set(userModel.toMap());
      }

      return result.user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }
}