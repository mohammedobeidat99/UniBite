import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_spacing.dart';

export 'app_spacing.dart';

/// Backward-compatible alias for [AppSpacing], [AppRadius], [AppShadow], [AppMotion].
class UniBiteTokens {
  UniBiteTokens._();

  static const double s4 = AppSpacing.s4;
  static const double s8 = AppSpacing.s8;
  static const double s12 = AppSpacing.s12;
  static const double s16 = AppSpacing.s16;
  static const double s20 = AppSpacing.s20;
  static const double s24 = AppSpacing.s24;
  static const double s32 = AppSpacing.s32;

  static const double screenPadding = AppSpacing.screenPadding;
  static const double sectionGap = AppSpacing.sectionGap;
  static const double cardPadding = AppSpacing.cardPadding;

  static const double r12 = AppRadius.input;
  static const double r20 = AppRadius.card;
  static const double r28 = AppRadius.sheet;
  static const double rPill = AppRadius.pill;

  static List<BoxShadow> get shadow1 => AppShadow.soft;
  static List<BoxShadow> get shadow2 => AppShadow.raised;

  static const Duration fast = AppMotion.fast;
  static const Duration normal = AppMotion.normal;
  static const Duration slow = AppMotion.slow;
  static const Duration stagger = AppMotion.stagger;
  static const Curve easeOut = AppMotion.easeOut;

  static bool get isTestEnvironment => AppMotion.isTestEnvironment;
  static bool reduceMotion(BuildContext context) =>
      AppMotion.reduceMotion(context);
}
