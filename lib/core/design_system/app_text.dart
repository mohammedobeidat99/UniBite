import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';

/// Typography definitions for UniBite "Fresh Campus Market".
///
/// Bundled offline: Plus Jakarta Sans (Latin) + IBM Plex Sans Arabic (Arabic; fallback Cairo).
class AppText {
  AppText._();

  static const String latinFont = 'PlusJakartaSans';
  static const String arabicFont = 'IBMPlexSansArabic';
  static const String arabicFallback = 'Cairo';

  static String fontFamily(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? arabicFont : latinFont;
  }

  static List<String> fontFallbacks(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? const [arabicFallback, latinFont] : const [arabicFont, arabicFallback];
  }

  static String fontFamilyFor(String languageCode) =>
      languageCode == 'ar' ? arabicFont : latinFont;

  static List<String> fontFallbacksFor(String languageCode) =>
      languageCode == 'ar' ? const [arabicFallback, latinFont] : const [arabicFont, arabicFallback];

  /// display: 30/38, 800, ink
  static TextStyle display(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 31 : 30,
      height: 38 / 30 * (isAr ? 1.15 : 1.0),
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.ink,
    );
  }

  /// h1: 22/30, 700, ink
  static TextStyle h1(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 23 : 22,
      height: 30 / 22 * (isAr ? 1.15 : 1.0),
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.ink,
    );
  }

  /// h2: 18/26, 700, ink
  static TextStyle h2(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 19 : 18,
      height: 26 / 18 * (isAr ? 1.15 : 1.0),
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.ink,
    );
  }

  /// bodyL: 16/24, 500, ink
  static TextStyle bodyL(BuildContext context, {Color? color, FontWeight? weight}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 17 : 16,
      height: 24 / 16 * (isAr ? 1.15 : 1.0),
      fontWeight: weight ?? (isAr ? FontWeight.w600 : FontWeight.w500),
      color: color ?? AppColors.ink,
    );
  }

  /// bodyM: 14/22, 400, inkSoft (min w500 in Arabic)
  static TextStyle bodyM(BuildContext context, {Color? color, FontWeight? weight}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 15 : 14,
      height: 22 / 14 * (isAr ? 1.15 : 1.0),
      fontWeight: weight ?? (isAr ? FontWeight.w500 : FontWeight.w400),
      color: color ?? AppColors.inkSoft,
    );
  }

  /// caption: 12/16, 500, inkSoft
  static TextStyle caption(BuildContext context, {Color? color, FontWeight? weight}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 13 : 12,
      height: 16 / 12 * (isAr ? 1.15 : 1.0),
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.inkSoft,
    );
  }

  /// button: 16/20, 700, ink
  static TextStyle button(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 17 : 16,
      height: 20 / 16 * (isAr ? 1.15 : 1.0),
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.ink,
    );
  }

  /// price: 16/20, 800, orangeText/ink
  static TextStyle price(BuildContext context, {Color? color}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TextStyle(
      fontFamily: isAr ? arabicFont : latinFont,
      fontFamilyFallback: fontFallbacks(context),
      fontSize: isAr ? 17 : 16,
      height: 20 / 16 * (isAr ? 1.15 : 1.0),
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.orangeText,
    );
  }
}
