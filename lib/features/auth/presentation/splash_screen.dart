import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';

/// Branded splash screen running a skippable 1.7s sequenced logo reveal.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: UniBiteTokens.isTestEnvironment
                ? const Duration(milliseconds: 50)
                : const Duration(milliseconds: 1700),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _proceed();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_navigated || !mounted) return;
    _navigated = true;

    final user = ref.read(currentUserProvider);
    if (user != null) {
      switch (user.role) {
        case UserRole.student:
          context.go(user.hasCompletedOnboarding ? '/student' : '/onboarding');
        case UserRole.cafeteriaAdmin:
          context.go('/cafeteria-admin');
        case UserRole.cafeteriaStaff:
          context.go('/cafeteria-staff');
        case UserRole.systemAdmin:
          context.go('/system-admin');
      }
      return;
    }

    final introSeen = ref.read(localStorageServiceProvider).getIntroSeen();
    context.go(introSeen ? '/login' : '/intro');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = UniBiteTokens.reduceMotion(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _proceed,
      child: Scaffold(
        backgroundColor: UniBiteColors.primary900,
        body: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = reduceMotion ? 1.0 : _controller.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(180, 140),
                        painter: _SplashLogoSequencePainter(progress: t),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _WordmarkReveal(progress: ((t - 0.58) / 0.28).clamp(0, 1)),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: ((t - 0.78) / 0.22).clamp(0.0, 1.0),
                      child: Text(
                        l10n.appTagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: UniBiteColors.primary100,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WordmarkReveal extends StatelessWidget {
  const _WordmarkReveal({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const letters = ['U', 'n', 'i', 'B', 'i', 't', 'e'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (i) {
        final start = i * 0.1;
        final visible = ((progress - start) / 0.3).clamp(0.0, 1.0);
        final isBite = i >= 3;
        final isLeafI = i == 4;

        return Opacity(
          opacity: visible,
          child: Transform.translate(
            offset: Offset(0, (1 - visible) * 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Text(
                  letters[i],
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isBite
                        ? UniBiteColors.secondary
                        : UniBiteColors.surface,
                  ),
                ),
                if (isLeafI && visible > 0.7)
                  Positioned(
                    top: -2,
                    right: 0,
                    child: Transform.scale(
                      scale: visible,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: UniBiteColors.primary500,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SplashLogoSequencePainter extends CustomPainter {
  const _SplashLogoSequencePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.56;

    // 1. Orange swoosh draws itself (0.00 -> 0.35).
    final swooshT = (progress / 0.35).clamp(0.0, 1.0);
    if (swooshT > 0) {
      final fullSwoosh = Path()
        ..moveTo(cx - 56, cy + 28)
        ..quadraticBezierTo(cx, cy + 54, cx + 58, cy + 16);
      for (final metric in fullSwoosh.computeMetrics()) {
        final partial = metric.extractPath(0, metric.length * swooshT);
        canvas.drawPath(
          partial,
          Paint()
            ..color = UniBiteColors.secondary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // 2. Stylized U fills in green (left) and orange (right) (0.18 -> 0.48).
    final uT = ((progress - 0.18) / 0.30).clamp(0.0, 1.0);
    if (uT > 0) {
      final leftU = Paint()
        ..color = UniBiteColors.primary500.withValues(alpha: uT)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: 64, height: 68),
        math.pi * 0.5,
        math.pi * 0.5 * uT,
        false,
        leftU,
      );
      canvas.drawLine(
        Offset(cx - 32, cy),
        Offset(cx - 32, cy - 26 * uT),
        leftU,
      );

      final rightU = Paint()
        ..color = UniBiteColors.secondary.withValues(alpha: uT)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: 64, height: 68),
        0,
        math.pi * 0.5 * uT,
        false,
        rightU,
      );
      canvas.drawLine(
        Offset(cx + 32, cy),
        Offset(cx + 32, cy - 26 * uT),
        rightU,
      );
    }

    // 3. Graduation cap drops and settles with bounce (0.34 -> 0.60).
    final capT = ((progress - 0.34) / 0.26).clamp(0.0, 1.0);
    if (capT > 0) {
      final bounce = Curves.bounceOut.transform(capT);
      final capY = (cy - 68) + bounce * 30;
      final capX = cx - 22;
      final capPath = Path()
        ..moveTo(capX, capY - 12)
        ..lineTo(capX + 28, capY)
        ..lineTo(capX, capY + 12)
        ..lineTo(capX - 28, capY)
        ..close();
      canvas.drawPath(capPath, Paint()..color = UniBiteColors.primary100);
      // Tassel in accent sunny yellow.
      canvas.drawLine(
        Offset(capX - 18, capY + 2),
        Offset(capX - 18, capY + 18),
        Paint()
          ..color = UniBiteColors.accent
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    // 4. Fork rises into center of U (0.44 -> 0.66).
    final forkT = ((progress - 0.44) / 0.22).clamp(0.0, 1.0);
    if (forkT > 0) {
      final forkOffset = (1 - Curves.easeOutBack.transform(forkT)) * 18;
      final fy = cy - 4 + forkOffset;
      final forkPaint = Paint()
        ..color = UniBiteColors.surface.withValues(alpha: forkT)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, fy + 18), Offset(cx, fy - 4), forkPaint);
      canvas.drawLine(
        Offset(cx - 7, fy - 4),
        Offset(cx + 7, fy - 4),
        forkPaint,
      );
      for (final dx in [-7.0, 0.0, 7.0]) {
        canvas.drawLine(
          Offset(cx + dx, fy - 4),
          Offset(cx + dx, fy - 15),
          forkPaint,
        );
      }
    }

    // 5. Speed lines sweep right (0.54 -> 0.78).
    final speedT = ((progress - 0.54) / 0.24).clamp(0.0, 1.0);
    if (speedT > 0) {
      final speedPaint = Paint()
        ..color = UniBiteColors.accent.withValues(alpha: speedT)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final y = cy - 22 + i * 11;
        final len = (24 - i * 4) * speedT;
        canvas.drawLine(
          Offset(cx + 46, y),
          Offset(cx + 46 + len, y),
          speedPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashLogoSequencePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
