import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(147, 147, 147, 1.0),
        title: Text("Settings", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
