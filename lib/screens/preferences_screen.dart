import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  List<String> preferences = ['tech', 'politics', 'sports', 'fashion'];
  List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Preferences')),
      body: ListView(
        children:
            preferences
                .map(
                  (pref) => CheckboxListTile(
                    title: Text(pref),
                    value: selected.contains(pref),
                    onChanged: (val) {
                      setState(() {
                        if (val!) {
                          selected.add(pref);
                        } else {
                          selected.remove(pref);
                        }
                      });
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}
