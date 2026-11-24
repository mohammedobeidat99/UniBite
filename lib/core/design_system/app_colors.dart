import 'package:flutter/material.dart';

/// Professional 70 / 20 / 10 design system color tokens for UniBite.
///
/// 70% Canvas & Base:
///   - [green50]: Screen canvas background everywhere (never flat grey).
///   - [surface]: Pure card, sheet, and input background.
///   - [outline]: Crisp 1px subtle border.
///   - [green900], [green700], [green500], [green100]: Brand emerald green hierarchy.
///   - [ink], [inkSoft], [inkMuted]: Legibility-tested text hierarchy.
///
/// 20% Secondary:
///   - [orange], [orangePressed], [orangeSoft], [orangeText]: Primary actions & accents.
///
/// 10% Accent & Semantic:
///   - [yellow], [onYellow]: Sunny highlights, pre-order badges.
///   - [danger], [dangerSoft], [dangerText]: Errors, cancellations, warnings.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // 70% Canvas & Base — Green Family & Crisp Surfaces
  // ---------------------------------------------------------------------------
  static const Color green900 = Color(0xFF0C2B18);
  static const Color green700 = Color(0xFF1B5E20);
  static const Color green500 = Color(0xFF2E7D32);
  static const Color green100 = Color(0xFFE0EEDD);
  static const Color green50 = Color(0xFFF6F9F4);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE3EAE0);

  static const Color ink = Color(0xFF111E16);
  static const Color inkSoft = Color(0xFF415347);
  static const Color inkMuted = Color(0xFF728478);

  // ---------------------------------------------------------------------------
  // 20% Secondary — Energy Orange
  // ---------------------------------------------------------------------------
  static const Color orange = Color(0xFFFF6B00);
  static const Color orangePressed = Color(0xFFE05D00);
  static const Color orangeSoft = Color(0xFFFFF2E8);
  static const Color orangeText = Color(0xFFB84700);

  // ---------------------------------------------------------------------------
  // 10% Accent & Semantic
  // ---------------------------------------------------------------------------
  static const Color yellow = Color(0xFFFFB703);
  static const Color onYellow = Color(0xFF3D2800);

  static const Color danger = Color(0xFFD64545);
  static const Color dangerSoft = Color(0xFFFDE8E8);
  static const Color dangerText = Color(0xFF9E1C1C);

  // Muted secondary helpers
  static const Color completedMuted = Color(0xFF8AA394);

  // Semantic aliases
  static const Color warning = yellow;
  static const Color success = green500;
}
