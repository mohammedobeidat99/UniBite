import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';

/// Typography definitions for UniBite design system.
///
/// Supports Latin (Plus Jakarta Sans) and Arabic (IBM Plex Sans Arabic)
/// with optical sizing adjustments for Arabic script (+1 sp, min w500).
class AppText {
  AppText._();

  static const String latinFont = 'PlusJakartaSans';
  static const String arabicFont = 'IBMPlexSansArabic';

  static String fontFamily(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' ? arabicFont : latinFont;
  }

  static String fontFamilyFor(String languageCode) =>
      languageCode == 'ar' ? arabicFont : latinFont;

  static List<String> fontFallbacks(String languageCode) =>
      languageCode == 'ar' ? const [latinFont] : const [arabicFont];

  /// Display: 28 sp / line-height 36 / w800.
  static TextStyle display(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 29 : 28,
      height: 36 / 28,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.ink,
    );
  }

  /// H1: 22 sp / line-height 30 / w700.
  static TextStyle h1(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 23 : 22,
      height: 30 / 22,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.ink,
    );
  }

  /// H2: 18 sp / line-height 26 / w700.
  static TextStyle h2(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 19 : 18,
      height: 26 / 18,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.ink,
    );
  }

  /// BodyL: 16 sp / line-height 24 / w500.
  static TextStyle bodyL(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 17 : 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.ink,
    );
  }

  /// BodyM: 14 sp / line-height 22 / w400 (w500 in Arabic).
  static TextStyle bodyM(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 15 : 14,
      height: 22 / 14,
      fontWeight: isAr ? FontWeight.w500 : FontWeight.w400,
      color: color ?? AppColors.ink,
    );
  }

  /// Caption: 12 sp / line-height 16 / w500.
  static TextStyle caption(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 13 : 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.inkMuted,
    );
  }

  /// Button: 16 sp / line-height 20 / w700 / color: ink.
  static TextStyle button(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 16 : 15,
      height: 20 / 15,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.ink,
    );
  }

  /// Price: 16 sp / line-height 20 / w800.
  static TextStyle price(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(isAr ? 'ar' : 'en'),
      fontSize: isAr ? 17 : 16,
      height: 20 / 16,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.orangeText,
    );
  }
}
