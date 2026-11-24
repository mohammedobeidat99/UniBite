import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/app_colors.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/tokens.dart';

/// Custom painter rendering UniBite's deep-green hero canvas with orange swoosh,
/// diagonal sheet cutout, speed lines, and campus cap/fork motifs.
class SwooshHeroPainter extends CustomPainter {
  /// Creates a [SwooshHeroPainter] with optional floating [floatPhase] (`0..1`).
  const SwooshHeroPainter({this.floatPhase = 0});

  /// Normalized phase (`0..1`) driving subtle parallax drift on background motifs.
  final double floatPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 70% Deep campus green hero background.
    final bgPaint = Paint()..color = UniBiteColors.primary900;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Subtle radial highlight for depth (non-neon, organic green).
    final glowPaint = Paint()
      ..color = UniBiteColors.primary700.withValues(alpha: 0.45);
    canvas.drawCircle(
      Offset(w * 0.22, h * 0.30 + math.sin(floatPhase * math.pi * 2) * 4),
      w * 0.34,
      glowPaint,
    );

    // Campus graduation-cap diamond silhouette (subtle watermark).
    final capOffset = Offset(
      w * 0.78,
      h * 0.26 + math.cos(floatPhase * math.pi * 2) * 5,
    );
    final capPaint = Paint()
      ..color = UniBiteColors.primary500.withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;
    final capPath = Path()
      ..moveTo(capOffset.dx, capOffset.dy - 24)
      ..lineTo(capOffset.dx + 44, capOffset.dy - 6)
      ..lineTo(capOffset.dx, capOffset.dy + 12)
      ..lineTo(capOffset.dx - 44, capOffset.dy - 6)
      ..close();
    canvas.drawPath(capPath, capPaint);

    // Subtle grain/dots texture across the upper hero canvas.
    final dotPaint = Paint()
      ..color = UniBiteColors.primary100.withValues(alpha: 0.08);
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 8; col++) {
        canvas.drawCircle(
          Offset(24 + col * (w / 8), 22 + row * 28),
          1.4,
          dotPaint,
        );
      }
    }

    // Speed lines sweeping horizontally from the emblem.
    final speedPaint = Paint()
      ..color = AppColors.crimson.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final lineWidths = [36.0, 52.0, 28.0];
    for (var i = 0; i < lineWidths.length; i++) {
      final y = h * 0.44 + i * 11;
      final startX = w - 28 - lineWidths[i];
      canvas.drawLine(Offset(startX, y), Offset(w - 22, y), speedPaint);
    }

    // Signature UniBite dual-color swoosh from the emblem:
    // 1. Royal Blue lower ribbon
    final blueSwooshPaint = Paint()
      ..color = AppColors.royalBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final blueSwooshPath = Path()
      ..moveTo(-12, h * 0.88)
      ..quadraticBezierTo(w * 0.44, h * 1.02, w + 14, h * 0.76);
    canvas.drawPath(blueSwooshPath, blueSwooshPaint);

    // 2. Vibrant Crimson Red signature ribbon
    final redSwooshPaint = Paint()
      ..color = AppColors.crimson
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final redSwooshPath = Path()
      ..moveTo(-10, h * 0.84)
      ..quadraticBezierTo(w * 0.42, h * 0.97, w + 12, h * 0.71);
    canvas.drawPath(redSwooshPath, redSwooshPaint);
  }

  @override
  bool shouldRepaint(covariant SwooshHeroPainter oldDelegate) =>
      oldDelegate.floatPhase != floatPhase;
}

/// Looping empty-state food bowl illustration with rising animated steam wisps.
class SteamEmptyIllustration extends StatefulWidget {
  /// Creates a [SteamEmptyIllustration] sized to [size].
  const SteamEmptyIllustration({super.key, this.size = 110});

  /// Square dimension of the illustration.
  final double size;

  @override
  State<SteamEmptyIllustration> createState() => _SteamEmptyIllustrationState();
}

class _SteamEmptyIllustrationState extends State<SteamEmptyIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (!UniBiteTokens.isTestEnvironment) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    if (reduceMotion) {
      return CustomPaint(
        size: Size.square(widget.size),
        painter: const _SteamBowlPainter(phase: 0.35),
      );
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _SteamBowlPainter(phase: _controller.value),
        ),
      ),
    );
  }
}

class _SteamBowlPainter extends CustomPainter {
  const _SteamBowlPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft circular green base backdrop.
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.54),
      w * 0.42,
      Paint()..color = UniBiteColors.primary100,
    );

    // Rising animated steam wisps.
    final steamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final localPhase = (phase + i * 0.33) % 1.0;
      final alpha = math.sin(localPhase * math.pi).clamp(0.0, 1.0);
      steamPaint.color = UniBiteColors.primary700.withValues(
        alpha: alpha * 0.7,
      );
      final baseX = w * (0.36 + i * 0.14);
      final bottomY = h * 0.50 - localPhase * 12;
      final topY = bottomY - 16;
      final wave = math.sin(localPhase * math.pi * 2) * 3.5;

      final path = Path()
        ..moveTo(baseX, bottomY)
        ..quadraticBezierTo(
          baseX + wave,
          (bottomY + topY) / 2,
          baseX - wave,
          topY,
        );
      canvas.drawPath(path, steamPaint);
    }

    // Bowl body in Campus Green.
    final bowlRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.56,
      height: h * 0.42,
    );
    canvas.drawArc(
      bowlRect,
      0,
      math.pi,
      true,
      Paint()..color = UniBiteColors.primary700,
    );

    // Orange rim & swoosh highlight.
    canvas.drawLine(
      Offset(w * 0.20, h * 0.58),
      Offset(w * 0.80, h * 0.58),
      Paint()
        ..color = UniBiteColors.secondary
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SteamBowlPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

/// Consistent custom vector meal artwork replacing generic icons.
class AppetizingFoodPainter extends CustomPainter {
  /// Creates an [AppetizingFoodPainter] for a given meal category [presetKey].
  const AppetizingFoodPainter({required this.presetKey});

  /// Preset food style key (`preset:sandwich`, `preset:hotmeal`, etc.).
  final String presetKey;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final (Color bg, Color plate, Color accent) = switch (presetKey) {
      'preset:sandwich' => (
        UniBiteColors.secondarySoft,
        UniBiteColors.surface,
        UniBiteColors.secondary,
      ),
      'preset:hotmeal' => (
        UniBiteColors.primary100,
        UniBiteColors.surface,
        UniBiteColors.primary700,
      ),
      'preset:salad' => (
        UniBiteColors.primary100,
        UniBiteColors.surface,
        UniBiteColors.primary500,
      ),
      'preset:beverage' => (
        UniBiteColors.accentSoft,
        UniBiteColors.surface,
        UniBiteColors.secondary,
      ),
      'preset:dessert' => (
        UniBiteColors.secondarySoft,
        UniBiteColors.surface,
        UniBiteColors.accent,
      ),
      _ => (
        UniBiteColors.primary100,
        UniBiteColors.surface,
        UniBiteColors.primary700,
      ),
    };

    // Warm food-toned background.
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // Soft plate circle.
    final center = Offset(w * 0.5, h * 0.52);
    canvas.drawCircle(center, math.min(w, h) * 0.36, Paint()..color = plate);
    canvas.drawCircle(
      center,
      math.min(w, h) * 0.30,
      Paint()
        ..color = UniBiteColors.primary100.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    switch (presetKey) {
      case 'preset:sandwich':
        // Layered grilled wrap / sandwich with golden crust & green leaf.
        final bunPaint = Paint()..color = UniBiteColors.secondary;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: w * 0.44, height: h * 0.24),
            const Radius.circular(12),
          ),
          bunPaint,
        );
        canvas.drawLine(
          Offset(w * 0.29, h * 0.52),
          Offset(w * 0.71, h * 0.52),
          Paint()
            ..color = UniBiteColors.primary500
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(w * 0.31, h * 0.47),
          Offset(w * 0.69, h * 0.47),
          Paint()
            ..color = UniBiteColors.accent
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      case 'preset:hotmeal':
        // Steaming campus hot meal bowl with saffron rice & roasted herbs.
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.52),
            width: w * 0.46,
            height: h * 0.34,
          ),
          0,
          math.pi,
          true,
          Paint()..color = accent,
        );
        canvas.drawCircle(
          Offset(w * 0.44, h * 0.48),
          w * 0.09,
          Paint()..color = UniBiteColors.accent,
        );
        canvas.drawCircle(
          Offset(w * 0.56, h * 0.48),
          w * 0.08,
          Paint()..color = UniBiteColors.secondary,
        );
      case 'preset:salad':
        // Fresh layered salad leaves & cherry tomatoes.
        for (var i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          canvas.drawCircle(
            Offset(
              center.dx + math.cos(angle) * w * 0.11,
              center.dy + math.sin(angle) * h * 0.11,
            ),
            w * 0.10,
            Paint()..color = UniBiteColors.primary500,
          );
        }
        canvas.drawCircle(
          Offset(center.dx - 4, center.dy - 4),
          w * 0.055,
          Paint()..color = UniBiteColors.secondary,
        );
        canvas.drawCircle(
          Offset(center.dx + 7, center.dy + 5),
          w * 0.05,
          Paint()..color = UniBiteColors.accent,
        );
      case 'preset:beverage':
        // Tall iced campus cup with straw.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(center.dx, center.dy + 3),
              width: w * 0.28,
              height: h * 0.38,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = UniBiteColors.secondary,
        );
        canvas.drawLine(
          Offset(center.dx + 3, center.dy - 14),
          Offset(center.dx + 12, center.dy - 26),
          Paint()
            ..color = UniBiteColors.primary700
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
      case 'preset:dessert':
        // Golden kunafa / brownie slice with pistachio garnish.
        final slice = Path()
          ..moveTo(center.dx - w * 0.18, center.dy + h * 0.12)
          ..lineTo(center.dx + w * 0.18, center.dy + h * 0.12)
          ..lineTo(center.dx, center.dy - h * 0.18)
          ..close();
        canvas.drawPath(slice, Paint()..color = UniBiteColors.secondary);
        canvas.drawCircle(
          Offset(center.dx, center.dy - h * 0.02),
          w * 0.05,
          Paint()..color = UniBiteColors.primary500,
        );
      default:
        canvas.drawCircle(center, w * 0.18, Paint()..color = accent);
    }
  }

  @override
  bool shouldRepaint(covariant AppetizingFoodPainter oldDelegate) =>
      oldDelegate.presetKey != presetKey;
}

/// Subtle accent-yellow confetti sparkles rendered when an order reaches Ready.
class YellowConfettiOverlay extends StatelessWidget {
  /// Creates a [YellowConfettiOverlay].
  const YellowConfettiOverlay({super.key, this.height = 56});

  /// Height of the decorative confetti strip.
  final double height;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: const _ConfettiPainter(),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final spots = [
      (0.08, 0.25, 4.0, UniBiteColors.accent),
      (0.18, 0.72, 3.0, UniBiteColors.secondary),
      (0.32, 0.20, 3.5, UniBiteColors.primary500),
      (0.49, 0.80, 4.0, UniBiteColors.accent),
      (0.64, 0.30, 3.0, UniBiteColors.secondary),
      (0.79, 0.68, 4.5, UniBiteColors.accent),
      (0.91, 0.28, 3.5, UniBiteColors.primary500),
    ];
    for (final (fx, fy, r, color) in spots) {
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        r,
        Paint()..color = color.withValues(alpha: 0.75),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}
