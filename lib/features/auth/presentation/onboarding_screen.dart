import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/core/widgets/unibite_logo.dart';
import 'package:unibite/features/cart/presentation/cart_notifier.dart';

/// Searchable university and campus branch selector for student onboarding.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates an [OnboardingScreen].
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _selectedUniversityId;
  String? _selectedCampusId;
  String _universitySearch = '';
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _selectedUniversityId = user?.universityId;
    _selectedCampusId = user?.campusId;
  }

  Future<void> _saveCampus() async {
    final user = ref.read(currentUserProvider);
    if (user == null ||
        _selectedUniversityId == null ||
        _selectedCampusId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      ref.read(cartProvider.notifier).clear();
      await ref
          .read(authRepositoryProvider)
          .updateStudentCampus(
            userId: user.id,
            universityId: _selectedUniversityId!,
            campusId: _selectedCampusId!,
          );
      if (mounted) {
        context.go('/student');
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final universitiesAsync = ref.watch(universitiesStreamProvider(true));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingTitle),
        actions: [
          IconButton(
            tooltip: l10n.logoutButton,
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(LucideIcons.logOut),
          ),
        ],
      ),
      body: universitiesAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorStateView(message: err.toString()),
        data: (universities) {
          if (universities.isEmpty) {
            return EmptyStateView(
              icon: LucideIcons.landmark,
              title: l10n.noCampusesForUniversity,
            );
          }

          final filteredUniversities = _universitySearch.isEmpty
              ? universities
              : universities
                    .where(
                      (u) => u.name.toLowerCase().contains(
                        _universitySearch.toLowerCase(),
                      ),
                    )
                    .toList();

          final effectiveUniId =
              universities.any((u) => u.id == _selectedUniversityId)
              ? _selectedUniversityId!
              : universities.first.id;

          final campusesAsync = ref.watch(
            campusesStreamProvider((
              universityId: effectiveUniId,
              activeOnly: true,
            )),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(UniBiteTokens.screenPadding),
                children: [
                  Text(
                    l10n.onboardingSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: UniBiteColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: UniBiteTokens.s16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.searchUniversitiesHint,
                      prefixIcon: const Icon(LucideIcons.search),
                    ),
                    onChanged: (v) =>
                        setState(() => _universitySearch = v.trim()),
                  ),
                  const SizedBox(height: UniBiteTokens.s16),
                  Text(
                    l10n.selectUniversityLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: UniBiteTokens.s12),
                  ...List.generate(filteredUniversities.length, (idx) {
                    final uni = filteredUniversities[idx];
                    final selected = uni.id == effectiveUniId;
                    Widget card = Padding(
                      padding: const EdgeInsets.only(bottom: UniBiteTokens.s12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedUniversityId = uni.id;
                            _selectedCampusId = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(UniBiteTokens.r20),
                        child: AnimatedContainer(
                          duration: UniBiteTokens.fast,
                          padding: const EdgeInsets.all(UniBiteTokens.s16),
                          decoration: BoxDecoration(
                            color: selected
                                ? UniBiteColors.primary100
                                : UniBiteColors.surface,
                            borderRadius: BorderRadius.circular(
                              UniBiteTokens.r20,
                            ),
                            border: Border.all(
                              color: selected
                                  ? UniBiteColors.primary700
                                  : UniBiteColors.border,
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: UniBiteTokens.shadow1,
                          ),
                          child: Row(
                            children: [
                              const UniBiteLogo(size: 46),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  uni.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: UniBiteColors.ink),
                                ),
                              ),
                              Icon(
                                selected
                                    ? LucideIcons.checkCircle2
                                    : LucideIcons.circle,
                                color: selected
                                    ? UniBiteColors.primary700
                                    : UniBiteColors.inkMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    if (!reduceMotion) {
                      card = card
                          .animate()
                          .fadeIn(delay: UniBiteTokens.stagger * idx)
                          .slideY(begin: 0.08, end: 0);
                    }
                    return card;
                  }),
                  const SizedBox(height: UniBiteTokens.s16),
                  Text(
                    l10n.selectCampusLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: UniBiteTokens.s12),
                  campusesAsync.when(
                    loading: () =>
                        const SizedBox(height: 60, child: AppLoader.small()),
                    error: (e, _) => ErrorStateView(message: e.toString()),
                    data: (campuses) {
                      if (campuses.isEmpty) {
                        return EmptyStateView(
                          icon: LucideIcons.mapPinOff,
                          title: l10n.noCampusesForUniversity,
                        );
                      }

                      final effectiveCampusId =
                          campuses.any((c) => c.id == _selectedCampusId)
                          ? _selectedCampusId!
                          : campuses.first.id;
                      _selectedUniversityId ??= effectiveUniId;
                      _selectedCampusId = effectiveCampusId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: campuses.map((campus) {
                              final chosen = campus.id == effectiveCampusId;
                              return ChoiceChip(
                                selected: chosen,
                                avatar: Icon(
                                  LucideIcons.mapPin,
                                  size: 16,
                                  color: chosen
                                      ? UniBiteColors.surface
                                      : UniBiteColors.primary700,
                                ),
                                label: Text(
                                  '${campus.name} • ${campus.location}',
                                  style: TextStyle(
                                    color: chosen
                                        ? UniBiteColors.surface
                                        : UniBiteColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedUniversityId = effectiveUniId;
                                    _selectedCampusId = campus.id;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: const TextStyle(
                                color: UniBiteColors.dangerText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: UniBiteTokens.sectionGap),
                          UbPrimaryButton(
                            label: l10n.continueButton,
                            icon: LucideIcons.arrowRight,
                            isLoading: _isSaving,
                            onPressed: () {
                              _selectedUniversityId = effectiveUniId;
                              _selectedCampusId = effectiveCampusId;
                              _saveCampus();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
