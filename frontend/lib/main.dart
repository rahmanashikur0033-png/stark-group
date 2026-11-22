import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const VmsApp());
}

class VmsApp extends StatelessWidget {
  const VmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stark Group VMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4E79)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
