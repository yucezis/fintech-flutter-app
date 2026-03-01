import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget { 
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAEE),
      body: Center(
        child: Text('Profil Ekranı Yakında!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}