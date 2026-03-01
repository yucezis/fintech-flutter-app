import 'package:flutter/material.dart';

class AichatScreen extends StatelessWidget { 
  const AichatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAEE),
      body: Center(
        child: Text('AI Ekranı Yakında!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}