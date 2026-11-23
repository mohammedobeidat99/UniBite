import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';
import 'package:unibite/core/design_system/app_text.dart';

export 'app_text.dart';

/// Backward-compatible alias for typography builders.
class UniBiteTypography {
  UniBiteTypography._();

  static const String latinFont = AppText.latinFont;
  static const String arabicFont = AppText.arabicFont;

  static String fontFamilyFor(String languageCode) =>
      AppText.fontFamilyFor(languageCode);

  static TextTheme buildTextTheme(String languageCode) {
    final family = fontFamilyFor(languageCode);
    final fallbacks = AppText.fontFallbacksFor(languageCode);
    final isAr = languageCode == 'ar';

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
      displayLarge: style(size: isAr ? 31 : 30, weight: FontWeight.w800, height: 38 / 30),
      displaySmall: style(size: isAr ? 27 : 26, weight: FontWeight.w800, height: 34 / 26),
      headlineMedium: style(size: isAr ? 23 : 22, weight: FontWeight.w700, height: 30 / 22),
      titleLarge: style(size: isAr ? 23 : 22, weight: FontWeight.w700, height: 30 / 22),
      titleMedium: style(size: isAr ? 19 : 18, weight: FontWeight.w700, height: 26 / 18),
      titleSmall: style(size: isAr ? 17 : 16, weight: FontWeight.w700, height: 22 / 16),
      bodyLarge: style(size: isAr ? 17 : 16, weight: isAr ? FontWeight.w600 : FontWeight.w500, height: 24 / 16),
      bodyMedium: style(size: isAr ? 15 : 14, weight: isAr ? FontWeight.w500 : FontWeight.w400, color: AppColors.inkSoft, height: 22 / 14),
      bodySmall: style(size: isAr ? 13 : 12, weight: FontWeight.w500, color: AppColors.inkSoft, height: 16 / 12),
      labelLarge: style(size: isAr ? 17 : 16, weight: FontWeight.w700, height: 20 / 16),
      labelMedium: style(size: isAr ? 13 : 12, weight: FontWeight.w700, color: AppColors.inkSoft),
      labelSmall: style(size: isAr ? 13 : 12, weight: FontWeight.w500, color: AppColors.inkMuted),
    );
  }
}
