import 'package:flutter/material.dart';
import 'package:trackademic/features/welcome/presentation/welcome_screen.dart';

class TrackademicApp extends StatelessWidget {
  const TrackademicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trackademic',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3454D1),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FF),
      ),
      home: const WelcomeScreen(),
    );
  }
}