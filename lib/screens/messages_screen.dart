import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  final List<String> messages = ['Hello sir!', 'Please clarify topic X.'];

  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (_, i) => ListTile(title: Text(messages[i])),
      ),
    );
  }
}
