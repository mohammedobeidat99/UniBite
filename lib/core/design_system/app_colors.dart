import 'package:flutter/material.dart';

/// Concrete 70 / 20 / 10 color system for UniBite "Fresh Campus Market".
class AppColors {
  AppColors._();

  // PRIMARY green family ≈ 70 % of area (backgrounds, surfaces, text, hero, nav)
  static const Color green900 = Color(0xFF12301B);
  static const Color green700 = Color(0xFF1F4D2B);
  static const Color green500 = Color(0xFF2F7A43);
  static const Color green100 = Color(0xFFDDEBDD);
  static const Color green50 = Color(0xFFF6F9F4); // screen background
  static const Color surface = Color(0xFFFFFFFF); // cards, inputs, sheets
  static const Color outline = Color(0xFFE3EAE0);
  static const Color ink = Color(0xFF13261A); // main text
  static const Color inkSoft = Color(0xFF55695B); // secondary text
  static const Color inkMuted = Color(0xFF8A9B8F); // placeholders/disabled

  // SECONDARY orange ≈ 20 % (actions, active, loaders)
  static const Color orange = Color(0xFFF26B0F);
  static const Color orangePressed = Color(0xFFD95A06);
  static const Color orangeSoft = Color(0xFFFFEBDC);
  static const Color orangeText = Color(0xFFB34700);

  // ACCENT yellow ≈ 10 % (micro highlights only)
  static const Color yellow = Color(0xFFFFC145);
  static const Color onYellow = Color(0xFF3A2A00);

  // FUNCTIONAL
  static const Color danger = Color(0xFFD64545);
  static const Color dangerSoft = Color(0xFFFCE8E8);
  static const Color dangerText = Color(0xFF9E1C1C);

  // Status mapping
  static const Color statusPending = yellow;
  static const Color statusAccepted = orange;
  static const Color statusPreparing = orange;
  static const Color statusReady = green500;
  static const Color statusCompleted = inkMuted;
  static const Color statusRejected = danger;
  static const Color statusCancelled = danger;

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green700, green500],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [orange, orangePressed],
  );
}
