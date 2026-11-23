import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';

/// First-launch 3-slide visual onboarding tour with parallax swoosh illustrations.
class IntroOnboardingScreen extends ConsumerStatefulWidget {
  /// Creates an [IntroOnboardingScreen].
  const IntroOnboardingScreen({super.key});

  @override
  ConsumerState<IntroOnboardingScreen> createState() =>
      _IntroOnboardingScreenState();
}

class _IntroOnboardingScreenState extends ConsumerState<IntroOnboardingScreen> {
  final PageController _pageController = PageController();
  double _pageOffset = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() => _pageOffset = _pageController.page ?? 0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStorageServiceProvider).setIntroSeen(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final slides = [
      (
        l10n.introSlide1Title,
        l10n.introSlide1Body,
        LucideIcons.utensils,
        'preset:sandwich',
      ),
      (
        l10n.introSlide2Title,
        l10n.introSlide2Body,
        LucideIcons.clock,
        'preset:hotmeal',
      ),
      (
        l10n.introSlide3Title,
        l10n.introSlide3Body,
        LucideIcons.qrCode,
        'preset:beverage',
      ),
    ];

    return Scaffold(
      backgroundColor: UniBiteColors.primary50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UniBiteTokens.screenPadding,
                vertical: UniBiteTokens.s8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: l10n.languageLabel,
                    onPressed: () =>
                        ref.read(localeProvider.notifier).toggleLocale(),
                    icon: const Icon(LucideIcons.languages),
                  ),
                  UbGhostButton(
                    label: l10n.skipButton,
                    underlinedOrange: true,
                    onPressed: _finish,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final delta = index - _pageOffset;
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(UniBiteTokens.screenPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(delta * 42, 0),
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              color: UniBiteColors.primary900,
                              borderRadius: BorderRadius.circular(
                                UniBiteTokens.r28,
                              ),
                              boxShadow: UniBiteTokens.shadow2,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: SwooshHeroPainter(
                                      floatPhase: (_pageOffset % 1.0),
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(delta * 20, -6),
                                  child: Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      color: UniBiteColors.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: UniBiteTokens.shadow2,
                                    ),
                                    child: Icon(
                                      slide.$3,
                                      size: 48,
                                      color: UniBiteColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: UniBiteTokens.s32),
                        Text(
                          slide.$1,
                          style: textTheme.displaySmall?.copyWith(
                            color: UniBiteColors.primary900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: UniBiteTokens.s12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Text(
                            slide.$2,
                            style: textTheme.bodyLarge?.copyWith(
                              color: UniBiteColors.inkMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(UniBiteTokens.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(slides.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: UniBiteTokens.normal,
                        curve: UniBiteTokens.easeOut,
                        width: active ? 28 : 10,
                        height: 10,
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? UniBiteColors.secondary
                              : UniBiteColors.primary100,
                          borderRadius: BorderRadius.circular(
                            UniBiteTokens.rPill,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: 170,
                    child: UbPrimaryButton(
                      label: _currentPage == slides.length - 1
                          ? l10n.getStartedButton
                          : l10n.nextButton,
                      icon: LucideIcons.arrowRight,
                      onPressed: () {
                        if (_currentPage < slides.length - 1) {
                          _pageController.nextPage(
                            duration: UniBiteTokens.normal,
                            curve: UniBiteTokens.easeOut,
                          );
                        } else {
                          _finish();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
