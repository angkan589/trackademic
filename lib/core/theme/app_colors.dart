import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF3454D1);
  static const Color primaryDark = Color(0xFF2947B7);
  static const Color primaryLight = Color(0xFF7892FF);
  static const Color secondary = Color(0xFF6D5CE7);
  static const Color accent = Color(0xFF22B8CF);

  // Background and surfaces
  static const Color background = Color(0xFFF7F9FF);
  static const Color backgroundSoft = Color(0xFFEEF2FF);
  static const Color surface = Colors.white;
  static const Color surfaceHighlight = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF1F4FC);

  // Text colors
  static const Color textPrimary = Color(0xFF17203B);
  static const Color textSecondary = Color(0xFF68728B);
  static const Color textTertiary = Color(0xFF8C94A8);

  // Borders
  static const Color border = Color(0xFFE1E6F2);
  static const Color borderStrong = Color(0xFFD3DAEA);

  // Status colors
  static const Color success = Color(0xFF16865D);
  static const Color successBackground = Color(0xFFEAF8F2);

  static const Color warning = Color(0xFFD88919);
  static const Color warningBackground = Color(0xFFFFF5DF);

  static const Color danger = Color(0xFFD64545);
  static const Color dangerBackground = Color(0xFFFFECEC);

  static const Color information = Color(0xFF3454D1);
  static const Color informationBackground = Color(0xFFEAF0FF);
}

abstract final class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primary, AppColors.secondary],
    stops: [0, 0.52, 1],
  );

  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.surfaceHighlight, Color(0xFFF6F8FF)],
  );

  static const LinearGradient page = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9FBFF), Color(0xFFEEF2FF), Color(0xFFF8F5FF)],
    stops: [0, 0.55, 1],
  );
}

abstract final class AppShadows {
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x1F23366F),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0xBFFFFFFF),
      blurRadius: 8,
      offset: Offset(-5, -5),
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1423366F),
      blurRadius: 14,
      offset: Offset(0, 7),
    ),
    BoxShadow(
      color: Color(0x99FFFFFF),
      blurRadius: 6,
      offset: Offset(-3, -3),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x333454D1),
      blurRadius: 34,
      offset: Offset(0, 18),
    ),
    BoxShadow(
      color: Color(0x1A6D5CE7),
      blurRadius: 12,
      offset: Offset(0, 5),
    ),
  ];
}
