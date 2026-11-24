import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';

/// Backward-compatible alias class for [AppColors].
class UniBiteColors {
  UniBiteColors._();

  static const Color primary900 = AppColors.green900;
  static const Color primary700 = AppColors.green700;
  static const Color primary500 = AppColors.green500;
  static const Color primary100 = AppColors.green100;
  static const Color primary50 = AppColors.green50;

  static const Color surface = AppColors.surface;
  static const Color ink = AppColors.ink;
  static const Color inkMuted = AppColors.inkMuted;
  static const Color border = AppColors.outline;
  static const Color completedMuted = AppColors.completedMuted;

  static const Color secondary = AppColors.orange;
  static const Color secondaryPressed = AppColors.orangePressed;
  static const Color secondarySoft = AppColors.orangeSoft;
  static const Color secondaryText = AppColors.orangeText;

  static const Color accent = AppColors.yellow;
  static const Color accentSoft = AppColors.yellow;
  static const Color onAccent = AppColors.onYellow;

  static const Color danger = AppColors.danger;
  static const Color dangerSoft = AppColors.dangerSoft;
  static const Color dangerText = AppColors.dangerText;

  static const Color warning = AppColors.warning;
  static const Color success = AppColors.success;
}
