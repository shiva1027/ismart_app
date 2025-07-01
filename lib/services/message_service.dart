import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendMessage(String userId, String message, String sender) async {
    await _db.collection('users').doc(userId).collection('messages').add({
      'text': message,
      'sender': sender,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessageStream(String userId) {
    return _db.collection('users').doc(userId).collection('messages')
      .orderBy('timestamp')
      .snapshots();
  }
}
