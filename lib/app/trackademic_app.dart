import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_theme.dart';
import 'package:trackademic/features/welcome/presentation/welcome_screen.dart';

class TrackademicApp extends StatelessWidget {
  const TrackademicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trackademic',
      theme: AppTheme.light,
      home: const WelcomeScreen(),
    );
  }
}