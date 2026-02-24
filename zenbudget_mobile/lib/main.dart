import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ZenBudgetApp(),
    ),
  );
}

class ZenBudgetApp extends StatelessWidget {
  const ZenBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenBudget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('ZenBudget'),
        ),
      ),
    );
  }
}