import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_theme.dart';
import 'package:trackademic/core/widgets/app_depth_background.dart';
import 'package:trackademic/features/authentication/presentation/auth_gate.dart';

class TrackademicApp extends StatelessWidget {
  const TrackademicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trackademic',
      theme: AppTheme.light,
      builder: (context, child) {
        return AppDepthBackground(child: child ?? const SizedBox.shrink());
      },
      home: const AuthGate(),
    );
  }
}
