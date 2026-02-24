import 'package:flutter/material.dart';

void main() {
  runApp(const ZenBudgetApp());
}

class ZenBudgetApp extends StatelessWidget {
  const ZenBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenBudget',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('ZenBudget'),
        ),
      ),
    );
  }
}