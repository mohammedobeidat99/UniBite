import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';
import 'package:unibite/core/design_system/app_text.dart';

export 'app_text.dart';

/// Backward-compatible alias class for typography builder.
class UniBiteTypography {
  UniBiteTypography._();

  static const String latinFont = AppText.latinFont;
  static const String arabicFont = AppText.arabicFont;

  static String fontFamilyFor(String languageCode) =>
      AppText.fontFamilyFor(languageCode);

  static TextTheme buildTextTheme(String languageCode) {
    final family = fontFamilyFor(languageCode);
    final fallbacks = AppText.fontFallbacks(languageCode);

    TextStyle style({
      required double size,
      required FontWeight weight,
      Color color = AppColors.ink,
      double height = 1.4,
    }) {
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallbacks,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }

    return TextTheme(
      displayLarge: style(size: 28, weight: FontWeight.w800, height: 36 / 28),
      displaySmall: style(size: 24, weight: FontWeight.w700, height: 32 / 24),
      headlineMedium: style(size: 22, weight: FontWeight.w700, height: 30 / 22),
      titleLarge: style(size: 22, weight: FontWeight.w700, height: 30 / 22),
      titleMedium: style(size: 18, weight: FontWeight.w700, height: 26 / 18),
      titleSmall: style(size: 16, weight: FontWeight.w700, height: 22 / 16),
      bodyLarge: style(size: 16, weight: FontWeight.w500, height: 24 / 16),
      bodyMedium: style(size: 14, weight: FontWeight.w400, height: 22 / 14),
      bodySmall: style(
        size: 12,
        weight: FontWeight.w500,
        color: AppColors.inkMuted,
        height: 16 / 12,
      ),
      labelLarge: style(size: 15, weight: FontWeight.w700, height: 20 / 15),
      labelMedium: style(
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.inkMuted,
      ),
      labelSmall: style(
        size: 12,
        weight: FontWeight.w500,
        color: AppColors.inkMuted,
      ),
    );
  }
}
