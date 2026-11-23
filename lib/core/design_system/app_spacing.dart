import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';

/// 4-pt grid spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32
class AppSpacing {
  AppSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;

  // Semantic layout gaps
  static const double screenPadding = 20;
  static const double sectionGap = 24;
  static const double listGap = 12;
  static const double cardPadding = 16;
  static const double cardPaddingCompact = 12;

  // SizedBox spacing shortcuts
  static const Widget v4 = SizedBox(height: s4);
  static const Widget v8 = SizedBox(height: s8);
  static const Widget v12 = SizedBox(height: s12);
  static const Widget v16 = SizedBox(height: s16);
  static const Widget v20 = SizedBox(height: s20);
  static const Widget v24 = SizedBox(height: s24);
  static const Widget v32 = SizedBox(height: s32);

  static const Widget h4 = SizedBox(width: s4);
  static const Widget h8 = SizedBox(width: s8);
  static const Widget h12 = SizedBox(width: s12);
  static const Widget h16 = SizedBox(width: s16);
  static const Widget h20 = SizedBox(width: s20);
  static const Widget h24 = SizedBox(width: s24);
  static const Widget h32 = SizedBox(width: s32);
}

/// Standard corner radii: inputs/chips 14, buttons 16, cards 20, sheets/hero 28, pills full (999).
class AppRadius {
  AppRadius._();

  static const double input = 14;
  static const double chip = 14;
  static const double button = 16;
  static const double card = 20;
  static const double sheet = 28;
  static const double hero = 28;
  static const double pill = 999;

  static const BorderRadius inputBorder = BorderRadius.all(Radius.circular(input));
  static const BorderRadius chipBorder = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius buttonBorder = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetBorder = BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
}

/// Shadow styles: soft (cards) and raised (floating elements).
class AppShadow {
  AppShadow._();

  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.green900.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> raised = [
    BoxShadow(
      color: AppColors.green900.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Motion curves and timings: 150-350ms, easeOutCubic/spring.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration stagger = Duration(milliseconds: 40);

  static const Curve easeOut = Curves.easeOutCubic;

  static bool get isTestEnvironment {
    final name = WidgetsBinding.instance.runtimeType.toString();
    return name.contains('TestWidgetsFlutterBinding') ||
        name.contains('AutomatedTestWidgetsFlutterBinding');
  }

  static bool reduceMotion(BuildContext context) =>
      isTestEnvironment || MediaQuery.disableAnimationsOf(context);
}
