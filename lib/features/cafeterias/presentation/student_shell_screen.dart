import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/meal_image_widget.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/core/widgets/unibite_logo.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/cart/presentation/cart_notifier.dart';
import 'package:unibite/features/cart/presentation/cart_screen.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/presentation/student_orders_screen.dart';

/// Mobile-first Student shell with floating pill navigation and sticky cart bar.
class StudentShellScreen extends ConsumerStatefulWidget {
  /// Creates a [StudentShellScreen] optionally opening [initialTab].
  const StudentShellScreen({super.key, this.initialTab = 0});

  /// Initial content index (`0`=Home, `1`=Cart, `2`=Orders, `3`=Settings).
  final int initialTab;

  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 3);
  }

  @override
  void didUpdateWidget(covariant StudentShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedTab = widget.initialTab.clamp(0, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final student = ref.watch(currentUserProvider);
    if (student == null) {
      return const Scaffold(
        backgroundColor: AppColors.green50,
        body: SizedBox.shrink(),
      );
    }

    final cart = ref.watch(cartProvider);
    final activeOrdersCount =
        ref
            .watch(studentOrdersStreamProvider(student.id))
            .valueOrNull
            ?.where((o) => o.status.isActive)
            .length ??
        0;

    final tabs = [
      _StudentCafeteriasTab(student: student),
      CartScreen(onOrderPlaced: () => setState(() => _selectedTab = 2)),
      StudentOrdersScreen(student: student),
      _StudentSettingsTab(student: student),
    ];

    final navSelectedIndex = switch (_selectedTab) {
      0 => 0,
      2 => 1,
      3 => 2,
      _ => 0,
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UniBiteLogo(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedTab == 1 ? l10n.cartTitle : l10n.appTitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: UniBiteColors.primary700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedTab != 1 && cart.totalCount > 0)
            IconButton(
              tooltip: l10n.navCart,
              onPressed: () => setState(() => _selectedTab = 1),
              icon: Badge(
                backgroundColor: UniBiteColors.secondary,
                label: Text('${cart.totalCount}'),
                child: const Icon(LucideIcons.shoppingBag),
              ),
            ),
          IconButton(
            tooltip: l10n.languageLabel,
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            icon: const Icon(LucideIcons.languages),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(index: _selectedTab, children: tabs),
              ),
              if (_selectedTab != 1 && cart.totalCount > 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 8,
                  child: UbStickyCartBar(
                    itemCount: cart.totalCount,
                    cafeteriaName: cart.cafeteriaName ?? '',
                    totalAmount: cart.totalAmount,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: UbFloatingPillNav(
            selectedIndex: navSelectedIndex,
            onSelected: (navIdx) {
              setState(() {
                _selectedTab = switch (navIdx) {
                  0 => 0,
                  1 => 2,
                  2 => 3,
                  _ => 0,
                };
              });
            },
            destinations: [
              UbNavDestination(
                icon: LucideIcons.store,
                label: l10n.navCafeterias,
              ),
              UbNavDestination(
                icon: LucideIcons.receipt,
                label: l10n.navOrders,
                badgeCount: activeOrdersCount,
              ),
              UbNavDestination(icon: LucideIcons.user, label: l10n.navSettings),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCafeteriasTab extends ConsumerStatefulWidget {
  const _StudentCafeteriasTab({required this.student});

  final AppUser student;

  @override
  ConsumerState<_StudentCafeteriasTab> createState() =>
      _StudentCafeteriasTabState();
}

class _StudentCafeteriasTabState extends ConsumerState<_StudentCafeteriasTab> {
  String _searchQuery = '';
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final campusId = widget.student.campusId;

    final cafeteriasAsync = ref.watch(
      cafeteriasStreamProvider((campusId: campusId, activeOnly: true)),
    );
    final allMeals = ref.watch(allMealsStreamProvider).valueOrNull ?? [];
    final campuses =
        ref
            .watch(
              campusesStreamProvider((universityId: null, activeOnly: false)),
            )
            .valueOrNull ??
        [];
    final currentCampus = campuses.where((c) => c.id == campusId).firstOrNull;
    final firstName = widget.student.name.split(' ').first;

    return RefreshIndicator(
      color: UniBiteColors.secondary,
      onRefresh: () async {
        ref.invalidate(
          cafeteriasStreamProvider((campusId: campusId, activeOnly: true)),
        );
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          UniBiteTokens.screenPadding,
          UniBiteTokens.s12,
          UniBiteTokens.screenPadding,
          100,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(UniBiteTokens.s16),
            decoration: BoxDecoration(
              color: UniBiteColors.primary900,
              borderRadius: BorderRadius.circular(UniBiteTokens.r20),
              boxShadow: UniBiteTokens.shadow1,
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(UniBiteTokens.r20),
                    ),
                    child: CustomPaint(painter: SwooshHeroPainter()),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.homeGreeting} $firstName',
                            style: textTheme.titleLarge?.copyWith(
                              color: UniBiteColors.surface,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: UniBiteColors.accent,
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: UniBiteColors.onAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentCampus != null) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => context.go('/onboarding'),
                        borderRadius: BorderRadius.circular(
                          UniBiteTokens.rPill,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: UniBiteColors.surface.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(
                              UniBiteTokens.rPill,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: UniBiteColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  currentCampus.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: UniBiteColors.surface,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                LucideIcons.chevronRight,
                                size: 14,
                                color: UniBiteColors.primary100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: UniBiteTokens.s16),
          TextField(
            decoration: InputDecoration(
              hintText: l10n.searchCafeteriasAndMealsHint,
              prefixIcon: const Icon(LucideIcons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: const Icon(LucideIcons.x),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
          ),
          const SizedBox(height: UniBiteTokens.s12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'All',
                    'Sandwiches',
                    'Hot Meals',
                    'Salads',
                    'Beverages',
                    'Desserts',
                  ].map((cat) {
                    final selected = _categoryFilter == cat;
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        selected: selected,
                        label: Text(
                          cat == 'All'
                              ? l10n.all
                              : l10n.localizedMealCategory(cat),
                          style: TextStyle(
                            color: selected
                                ? UniBiteColors.surface
                                : UniBiteColors.ink,
                          ),
                        ),
                        onSelected: (_) =>
                            setState(() => _categoryFilter = cat),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: UniBiteTokens.sectionGap),
          cafeteriasAsync.when(
            loading: () => const SizedBox(height: 260, child: LoadingView()),
            error: (e, _) => ErrorStateView(message: e.toString()),
            data: (cafeterias) {
              if (cafeterias.isEmpty) {
                return EmptyStateView(
                  icon: LucideIcons.store,
                  title: l10n.noCafeteriasOnCampus,
                );
              }

              final query = _searchQuery.toLowerCase();
              final campusCafeIds = cafeterias.map((c) => c.id).toSet();
              final matchingMeals = allMeals.where((m) {
                if (!campusCafeIds.contains(m.cafeteriaId)) return false;
                final catOk =
                    _categoryFilter == 'All' || m.category == _categoryFilter;
                final queryOk =
                    query.isEmpty || m.name.toLowerCase().contains(query);
                return catOk && queryOk;
              }).toList();

              final filtered = cafeterias.where((c) {
                if (query.isEmpty && _categoryFilter == 'All') return true;
                final nameMatch =
                    query.isNotEmpty && c.name.toLowerCase().contains(query);
                final mealMatch = matchingMeals.any(
                  (m) => m.cafeteriaId == c.id,
                );
                return (_categoryFilter == 'All' && nameMatch) || mealMatch;
              }).toList();

              if (filtered.isEmpty) {
                return EmptyStateView(
                  icon: LucideIcons.searchX,
                  title: l10n.noMatchingResults,
                );
              }

              final now = DateTime.now();
              final openCafes = filtered.where((c) => c.isOpenAt(now)).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (openCafes.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: UniBiteColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.openNowSection, style: textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: UniBiteTokens.s12),
                    ...List.generate(openCafes.length, (i) {
                      final cafe = openCafes[i];
                      Widget card = Padding(
                        padding: const EdgeInsets.only(
                          bottom: UniBiteTokens.s12,
                        ),
                        child: _CafeteriaCard(
                          cafeteria: cafe,
                          matchedMeals:
                              (query.isEmpty && _categoryFilter == 'All')
                              ? const []
                              : matchingMeals
                                    .where((m) => m.cafeteriaId == cafe.id)
                                    .toList(),
                          onTap: () =>
                              context.push('/student/cafeteria/${cafe.id}'),
                        ),
                      );
                      if (!reduceMotion) {
                        card = card
                            .animate()
                            .fadeIn(delay: UniBiteTokens.stagger * i)
                            .slideY(begin: 0.08, end: 0);
                      }
                      return card;
                    }),
                    const SizedBox(height: UniBiteTokens.s12),
                  ],
                  Text(l10n.allCafeteriasSection, style: textTheme.titleMedium),
                  const SizedBox(height: UniBiteTokens.s12),
                  ...List.generate(filtered.length, (i) {
                    final cafe = filtered[i];
                    Widget card = Padding(
                      padding: const EdgeInsets.only(bottom: UniBiteTokens.s12),
                      child: _CafeteriaCard(
                        cafeteria: cafe,
                        matchedMeals:
                            (query.isEmpty && _categoryFilter == 'All')
                            ? const []
                            : matchingMeals
                                  .where((m) => m.cafeteriaId == cafe.id)
                                  .toList(),
                        onTap: () =>
                            context.push('/student/cafeteria/${cafe.id}'),
                      ),
                    );
                    if (!reduceMotion) {
                      card = card
                          .animate()
                          .fadeIn(delay: UniBiteTokens.stagger * i)
                          .slideY(begin: 0.08, end: 0);
                    }
                    return card;
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CafeteriaCard extends StatelessWidget {
  const _CafeteriaCard({
    required this.cafeteria,
    required this.matchedMeals,
    required this.onTap,
  });

  final Cafeteria cafeteria;
  final List<Meal> matchedMeals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOpenNow = cafeteria.isOpenAt(DateTime.now());

    return Opacity(
      opacity: isOpenNow ? 1.0 : 0.72,
      child: Container(
        decoration: BoxDecoration(
          color: UniBiteColors.surface,
          borderRadius: BorderRadius.circular(UniBiteTokens.r20),
          border: Border.all(color: UniBiteColors.border),
          boxShadow: UniBiteTokens.shadow1,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 68,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: SwooshHeroPainter()),
                    ),
                    Positioned(
                      top: 12,
                      right: 14,
                      child: UbOpenClosedPill(isOpen: isOpenNow),
                    ),
                    Positioned(
                      left: 16,
                      bottom: -22,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: UniBiteColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: UniBiteTokens.shadow1,
                        ),
                        child: MealImageWidget(
                          imagePath: cafeteria.logo,
                          width: 52,
                          height: 52,
                          borderRadius: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafeteria.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: UniBiteColors.inkMuted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${l10n.workingHoursFormat(cafeteria.workingHours)} • ${l10n.prepTimeFormat(cafeteria.prepTimeMinutes)}',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (matchedMeals.isNotEmpty) ...[
                      const Divider(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: matchedMeals
                            .map(
                              (m) => Chip(
                                label: Text(
                                  '${m.name} (${m.price.toStringAsFixed(2)})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentSettingsTab extends ConsumerWidget {
  const _StudentSettingsTab({required this.student});

  final AppUser student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final universities =
        ref.watch(universitiesStreamProvider(false)).valueOrNull ?? [];
    final campuses =
        ref
            .watch(
              campusesStreamProvider((universityId: null, activeOnly: false)),
            )
            .valueOrNull ??
        [];

    final uni = universities
        .where((u) => u.id == student.universityId)
        .firstOrNull;
    final campus = campuses.where((c) => c.id == student.campusId).firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        UniBiteTokens.screenPadding,
        UniBiteTokens.s16,
        UniBiteTokens.screenPadding,
        100,
      ),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: UniBiteColors.primary100,
              child: const Icon(
                LucideIcons.user,
                color: UniBiteColors.primary700,
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${student.email}\n${l10n.roleLabel(student.role)}'),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: UniBiteTokens.s12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UniBiteTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.currentCampusLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(uni?.name ?? ''),
                Text(
                  campus != null ? '${campus.name} — ${campus.location}' : '',
                  style: const TextStyle(color: UniBiteColors.inkMuted),
                ),
                const SizedBox(height: 12),
                UbSecondaryButton(
                  onPressed: () => context.go('/onboarding'),
                  icon: LucideIcons.arrowLeftRight,
                  label: l10n.changeCampusButton,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: UniBiteTokens.s12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(UniBiteTokens.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.languageLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text(l10n.englishLabel),
                    ),
                    ButtonSegment<String>(
                      value: 'ar',
                      label: Text(l10n.arabicLabel),
                    ),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (sel) {
                    ref.read(localeProvider.notifier).setLocale(sel.first);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: UniBiteTokens.s16),
        UbSecondaryButton(
          isDanger: true,
          onPressed: () async {
            ref.read(cartProvider.notifier).clear();
            await ref.read(authRepositoryProvider).logout();
            if (context.mounted) context.go('/login');
          },
          icon: LucideIcons.logOut,
          label: l10n.logoutButton,
        ),
      ],
    );
  }
}
