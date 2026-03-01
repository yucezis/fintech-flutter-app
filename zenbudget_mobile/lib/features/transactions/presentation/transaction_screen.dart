import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget { 
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAEE),
      body: Center(
        child: Text('Transaction Ekranı Yakında!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}