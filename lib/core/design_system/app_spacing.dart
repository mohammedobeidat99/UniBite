import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';

/// 4-pt grid spacing tokens for UniBite.
class AppSpacing {
  AppSpacing._();

  /// 4 dp micro gap.
  static const double xs4 = 4;

  /// 8 dp compact gap.
  static const double sm8 = 8;

  /// 12 dp standard element gap.
  static const double md12 = 12;

  /// 16 dp card padding.
  static const double lg16 = 16;

  /// 20 dp screen horizontal padding.
  static const double xl20 = 20;

  /// 24 dp section gap.
  static const double xxl24 = 24;

  /// 32 dp major vertical separation.
  static const double xxxl32 = 32;

  // Aliases for screen & card layouts
  static const double screenPadding = xl20;
  static const double sectionGap = xxl24;
  static const double cardPadding = lg16;
}

/// Standardized corner radii across the app.
class AppRadius {
  AppRadius._();

  /// 14 dp radius for inputs and chips.
  static const double input = 14;
  static const double chip = 14;

  /// 16 dp radius for standard buttons.
  static const double button = 16;

  /// 20 dp radius for cards.
  static const double card = 20;

  /// 28 dp radius for bottom sheets, modals, and hero banners.
  static const double sheet = 28;
  static const double hero = 28;

  /// Full pill radius (999 dp).
  static const double pill = 999;
}

/// Soft multi-layer shadows tinted with [AppColors.green900].
class AppShadow {
  AppShadow._();

  /// Subtle level-1 shadow for cards and surfaces (ambient + directional).
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.green900.withValues(alpha: 0.025),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: AppColors.green900.withValues(alpha: 0.055),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Elevated level-2 shadow for floating bars, modals, and tooltips.
  static final List<BoxShadow> raised = [
    BoxShadow(
      color: AppColors.green900.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.green900.withValues(alpha: 0.10),
      blurRadius: 26,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Standardized motion curves and durations.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration stagger = Duration(milliseconds: 45);

  static const Curve easeOut = Curves.easeOutCubic;

  /// Whether the app is currently running inside widget tests.
  static bool get isTestEnvironment {
    final name = WidgetsBinding.instance.runtimeType.toString();
    return name.contains('TestWidgetsFlutterBinding') ||
        name.contains('AutomatedTestWidgetsFlutterBinding');
  }

  /// Whether animations should be disabled/minimized.
  static bool reduceMotion(BuildContext context) =>
      isTestEnvironment || MediaQuery.disableAnimationsOf(context);
}
