import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';
import 'package:unibite/core/design_system/app_spacing.dart';

/// Circular progress indicator standard for UniBite.
///
/// Strictly circular across the entire app. Never uses linear bars.
/// Automatically safe for `flutter test` environments.
class AppLoader extends StatelessWidget {
  /// Creates an [AppLoader] with predefined size options.
  const AppLoader({
    super.key,
    this.size = AppLoaderSize.regular,
    this.color,
    this.trackColor,
    this.value,
  });

  /// Button inline spinner (size 22).
  const AppLoader.button({super.key, Color? color})
      : size = AppLoaderSize.button,
        color = color ?? AppColors.ink,
        trackColor = Colors.transparent,
        value = null;

  /// Small inline icon spinner (size 24).
  const AppLoader.small({super.key, this.color, this.trackColor, this.value})
      : size = AppLoaderSize.small;

  /// Regular section/card spinner (size 40).
  const AppLoader.regular({super.key, this.color, this.trackColor, this.value})
      : size = AppLoaderSize.regular;

  /// Full-page hero spinner (size 56).
  const AppLoader.large({super.key, this.color, this.trackColor, this.value})
      : size = AppLoaderSize.large;

  final AppLoaderSize size;
  final Color? color;
  final Color? trackColor;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.green700;
    final effectiveTrack = trackColor ?? AppColors.green100;
    final strokeWidth = switch (size) {
      AppLoaderSize.button => 2.5,
      AppLoaderSize.small => 2.5,
      AppLoaderSize.regular => 3.2,
      AppLoaderSize.large => 4.0,
    };
    final diameter = switch (size) {
      AppLoaderSize.button => 22.0,
      AppLoaderSize.small => 24.0,
      AppLoaderSize.regular => 40.0,
      AppLoaderSize.large => 56.0,
    };

    final testVal = AppMotion.isTestEnvironment ? (value ?? 0.5) : value;

    return Center(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: effectiveColor,
          backgroundColor: effectiveTrack,
          strokeCap: StrokeCap.round,
          value: testVal,
        ),
      ),
    );
  }
}

enum AppLoaderSize {
  button,
  small,
  regular,
  large,
}

/// Determinate circular countdown ring (used on order board for 3-minute timeout).
class AppCountdownRing extends StatelessWidget {
  const AppCountdownRing({
    super.key,
    required this.progress,
    required this.remainingText,
    this.size = 44,
    this.isUrgent = false,
  });

  /// Progress from 0.0 to 1.0 (1.0 = full time remaining, 0.0 = expired).
  final double progress;

  /// Display string e.g. "2:45".
  final String remainingText;

  /// Diameter of the ring.
  final double size;

  /// Whether less than 45s remain.
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final activeColor = isUrgent ? AppColors.danger : AppColors.orange;
    final trackColor = isUrgent ? AppColors.dangerSoft : AppColors.orangeSoft;

    final effectiveVal = AppMotion.isTestEnvironment
        ? 0.75
        : progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: effectiveVal,
            strokeWidth: 3.5,
            strokeCap: StrokeCap.round,
            color: activeColor,
            backgroundColor: trackColor,
          ),
          Text(
            remainingText,
            style: TextStyle(
              fontSize: size > 40 ? 11 : 9.5,
              fontWeight: FontWeight.w800,
              color: isUrgent ? AppColors.dangerText : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
