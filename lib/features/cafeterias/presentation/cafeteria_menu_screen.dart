import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/meal_image_widget.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/cart/presentation/cart_notifier.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';

/// Cafeteria menu screen with collapsing cover header, sticky category tabs,
/// staggered meal cards, Hero transitions, and a sticky cart bar.
class CafeteriaMenuScreen extends ConsumerStatefulWidget {
  /// Creates a [CafeteriaMenuScreen] for [cafeteriaId].
  const CafeteriaMenuScreen({super.key, required this.cafeteriaId});

  /// Identifier of the cafeteria whose menu is rendered.
  final String cafeteriaId;

  @override
  ConsumerState<CafeteriaMenuScreen> createState() =>
      _CafeteriaMenuScreenState();
}

class _CafeteriaMenuScreenState extends ConsumerState<CafeteriaMenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  Future<void> _quickAddMeal(Cafeteria cafeteria, Meal meal) async {
    final l10n = context.l10n;
    final notifier = ref.read(cartProvider.notifier);

    var outcome = notifier.addItem(
      meal: meal,
      cafeteriaName: cafeteria.name,
      quantity: 1,
    );

    if (outcome == CartAddResult.differentCafeteriaConflict) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.differentCafeteriaTitle),
          content: Text(l10n.differentCafeteriaMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.clearAndAddButton),
            ),
          ],
        ),
      );
      if (replace == true) {
        outcome = notifier.addItem(
          meal: meal,
          cafeteriaName: cafeteria.name,
          quantity: 1,
          replaceIfDifferentCafeteria: true,
        );
      }
    }

    if (outcome == CartAddResult.added && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addedToCartMessage(meal.name))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final cafeAsync = ref.watch(
      cafeteriaByIdStreamProvider(widget.cafeteriaId),
    );
    final mealsAsync = ref.watch(
      cafeteriaMealsStreamProvider(widget.cafeteriaId),
    );
    final cart = ref.watch(cartProvider);

    return Scaffold(
      body: cafeAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (cafeteria) {
          if (cafeteria == null) {
            return EmptyStateView(
              icon: LucideIcons.store,
              title: l10n.noCafeteriasOnCampus,
            );
          }
          final isOpenNow = cafeteria.isOpenAt(DateTime.now());

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 164,
                    pinned: true,
                    backgroundColor: UniBiteColors.primary900,
                    foregroundColor: UniBiteColors.surface,
                    title: Text(
                      cafeteria.name,
                      style: const TextStyle(color: UniBiteColors.surface),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          const CustomPaint(painter: SwooshHeroPainter()),
                          Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                64,
                                20,
                                14,
                              ),
                              child: Row(
                                children: [
                                  MealImageWidget(
                                    imagePath: cafeteria.logo,
                                    width: 56,
                                    height: 56,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        UbOpenClosedPill(isOpen: isOpenNow),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${l10n.workingHoursFormat(cafeteria.workingHours)} • ${l10n.prepTimeFormat(cafeteria.prepTimeMinutes)}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: UniBiteColors.primary100,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Material(
                      color: UniBiteColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isOpenNow) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: UniBiteColors.dangerSoft,
                                  borderRadius: BorderRadius.circular(
                                    UniBiteTokens.r12,
                                  ),
                                ),
                                child: Text(
                                  l10n.cafeteriaClosedOrderBlocked,
                                  style: const TextStyle(
                                    color: UniBiteColors.dangerText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            TextField(
                              decoration: InputDecoration(
                                hintText: l10n.search,
                                prefixIcon: const Icon(LucideIcons.search),
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v.trim()),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 8,
                                    ),
                                    child: ChoiceChip(
                                      selected: _selectedCategory == 'All',
                                      label: Text(
                                        l10n.all,
                                        style: TextStyle(
                                          color: _selectedCategory == 'All'
                                              ? UniBiteColors.surface
                                              : UniBiteColors.ink,
                                        ),
                                      ),
                                      onSelected: (_) => setState(
                                        () => _selectedCategory = 'All',
                                      ),
                                    ),
                                  ),
                                  ...SeedData.mealCategories.map(
                                    (cat) => Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        end: 8,
                                      ),
                                      child: ChoiceChip(
                                        selected: _selectedCategory == cat,
                                        label: Text(
                                          l10n.localizedMealCategory(cat),
                                          style: TextStyle(
                                            color: _selectedCategory == cat
                                                ? UniBiteColors.surface
                                                : UniBiteColors.ink,
                                          ),
                                        ),
                                        onSelected: (_) => setState(
                                          () => _selectedCategory = cat,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  mealsAsync.when(
                    loading: () =>
                        const SliverFillRemaining(child: LoadingView()),
                    error: (e, _) => SliverFillRemaining(
                      child: ErrorStateView(message: e.toString()),
                    ),
                    data: (meals) {
                      final filtered = meals.where((m) {
                        final catMatch =
                            _selectedCategory == 'All' ||
                            m.category == _selectedCategory;
                        final queryMatch =
                            _searchQuery.isEmpty ||
                            m.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            m.description.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                        return catMatch && queryMatch;
                      }).toList();

                      if (filtered.isEmpty) {
                        return SliverFillRemaining(
                          child: EmptyStateView(
                            icon: LucideIcons.utensilsCrossed,
                            title: l10n.noMealsInCategory,
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                        sliver: SliverList.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final meal = filtered[index];
                            Widget card = _MealCard(
                              meal: meal,
                              onTap: () =>
                                  _openMealDetails(context, cafeteria, meal),
                              onQuickAdd: meal.isAvailable
                                  ? () => _quickAddMeal(cafeteria, meal)
                                  : null,
                            );
                            if (!reduceMotion) {
                              card = card
                                  .animate()
                                  .fadeIn(delay: UniBiteTokens.stagger * index)
                                  .slideY(begin: 0.08, end: 0);
                            }
                            return card;
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (cart.totalCount > 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: SafeArea(
                    top: false,
                    child: UbStickyCartBar(
                      itemCount: cart.totalCount,
                      cafeteriaName: cart.cafeteriaName ?? '',
                      totalAmount: cart.totalAmount,
                      onTap: () => context.go('/student?tab=1'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openMealDetails(
    BuildContext context,
    Cafeteria cafeteria,
    Meal meal,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: UniBiteColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UniBiteTokens.r28),
        ),
      ),
      builder: (_) => _MealDetailSheet(cafeteria: cafeteria, meal: meal),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.onTap,
    required this.onQuickAdd,
  });

  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: UniBiteColors.surface,
        borderRadius: BorderRadius.circular(UniBiteTokens.r20),
        border: Border.all(color: UniBiteColors.border),
        boxShadow: UniBiteTokens.shadow1,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UniBiteTokens.r20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'meal_${meal.id}',
                    child: MealImageWidget(
                      imagePath: meal.imagePath,
                      width: 84,
                      height: 84,
                    ),
                  ),
                  if (!meal.isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: UniBiteColors.primary900.withValues(
                            alpha: 0.72,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          l10n.unavailable,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: UniBiteColors.surface,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${meal.price.toStringAsFixed(2)} ${l10n.currencyJod}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: UniBiteColors.secondaryText,
                          ),
                        ),
                        if (onQuickAdd != null)
                          IconButton.filled(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: AppColors.ink,
                            ),
                            onPressed: onQuickAdd,
                            icon: const Icon(LucideIcons.plus, size: 18),
                          ),
                      ],
                    ),
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

class _MealDetailSheet extends ConsumerStatefulWidget {
  const _MealDetailSheet({required this.cafeteria, required this.meal});

  final Cafeteria cafeteria;
  final Meal meal;

  @override
  ConsumerState<_MealDetailSheet> createState() => _MealDetailSheetState();
}

class _MealDetailSheetState extends ConsumerState<_MealDetailSheet> {
  int _quantity = 1;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    final l10n = context.l10n;
    final notifier = ref.read(cartProvider.notifier);

    var outcome = notifier.addItem(
      meal: widget.meal,
      cafeteriaName: widget.cafeteria.name,
      quantity: _quantity,
      note: _noteCtrl.text,
    );

    if (outcome == CartAddResult.differentCafeteriaConflict) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.differentCafeteriaTitle),
          content: Text(l10n.differentCafeteriaMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.clearAndAddButton),
            ),
          ],
        ),
      );
      if (replace == true) {
        outcome = notifier.addItem(
          meal: widget.meal,
          cafeteriaName: widget.cafeteria.name,
          quantity: _quantity,
          note: _noteCtrl.text,
          replaceIfDifferentCafeteria: true,
        );
      }
    }

    if (outcome == CartAddResult.added && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addedToCartMessage(widget.meal.name))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'meal_${widget.meal.id}',
                  child: MealImageWidget(
                    imagePath: widget.meal.imagePath,
                    width: 88,
                    height: 88,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.meal.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.meal.price.toStringAsFixed(2)} ${l10n.currencyJod}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: UniBiteColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.meal.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                labelText: l10n.specialNoteLabel,
                hintText: l10n.specialNoteHint,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.quantityLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                UbQuantityStepper(
                  quantity: _quantity,
                  minValue: 1,
                  onChanged: (val) => setState(() => _quantity = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!widget.meal.isAvailable)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UniBiteColors.dangerSoft,
                  borderRadius: BorderRadius.circular(UniBiteTokens.r12),
                ),
                child: Text(
                  l10n.mealUnavailableBlocked,
                  style: const TextStyle(
                    color: UniBiteColors.dangerText,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              UbPrimaryButton(
                onPressed: _addToCart,
                icon: LucideIcons.shoppingBag,
                label:
                    '${l10n.addToCartButton} • ${(widget.meal.price * _quantity).toStringAsFixed(2)} ${l10n.currencyJod}',
              ),
          ],
        ),
      ),
    );
  }
}
