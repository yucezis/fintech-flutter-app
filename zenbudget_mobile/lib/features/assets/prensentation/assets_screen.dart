import 'package:flutter/material.dart';

class AssetsScreen extends StatelessWidget { 
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAEE),
      body: Center(
        child: Text('Assets Ekranı Yakında!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}