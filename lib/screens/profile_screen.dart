import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String verificationId = '';

  Future<void> sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verId, int? resendToken) {
        setState(() => verificationId = verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        setState(() => verificationId = verId);
      },
    );
  }

  Future<void> verifyOTP(String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.currentUser?.updatePhoneNumber(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            ElevatedButton(onPressed: sendOTP, child: Text('Send OTP')),
            TextField(
              decoration: InputDecoration(labelText: 'Enter OTP'),
              onSubmitted: verifyOTP,
            ),
          ],
        ),
      ),
    );
  }
}
