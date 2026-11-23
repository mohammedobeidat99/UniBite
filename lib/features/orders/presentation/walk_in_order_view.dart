import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/meal_image_widget.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';

/// Walk-in counter order entry view for Cafeteria Staff and Admins.
class WalkInOrderView extends ConsumerStatefulWidget {
  /// Creates a [WalkInOrderView] for [cafeteriaId] operated by [actor].
  const WalkInOrderView({
    super.key,
    required this.cafeteriaId,
    required this.actor,
  });

  /// Fulfilling cafeteria identifier.
  final String cafeteriaId;

  /// Authenticated Cafeteria Admin or Staff actor.
  final AppUser actor;

  @override
  ConsumerState<WalkInOrderView> createState() => _WalkInOrderViewState();
}

class _WalkInOrderViewState extends ConsumerState<WalkInOrderView> {
  final Map<String, int> _quantities = {};
  final _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitWalkIn(List<Meal> meals) async {
    final selectedItems = <OrderItem>[];
    for (final meal in meals) {
      final qty = _quantities[meal.id] ?? 0;
      if (qty > 0) {
        selectedItems.add(
          OrderItem(
            mealId: meal.id,
            name: meal.name,
            price: meal.price,
            qty: qty,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          ),
        );
      }
    }
    if (selectedItems.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final created = await ref
          .read(orderRepositoryProvider)
          .createWalkInOrder(
            cafeteriaId: widget.cafeteriaId,
            items: selectedItems,
            customerNote: _noteCtrl.text,
            actor: widget.actor,
          );
      if (mounted) {
        setState(() {
          _quantities.clear();
          _noteCtrl.clear();
        });
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.orderNumberLabel(created.orderNumber)),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const UbAnimatedCheck(size: 52),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: QrImageView(
                      data: created.qrCode,
                      size: 160,
                      backgroundColor: UniBiteColors.surface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${created.total.toStringAsFixed(2)} ${context.l10n.currencyJod} • ${context.l10n.paymentMethodCashOnly}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              UbPrimaryButton(
                onPressed: () => Navigator.of(ctx).pop(),
                label: context.l10n.close,
              ),
            ],
          ),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mealsAsync = ref.watch(
      cafeteriaMealsStreamProvider(widget.cafeteriaId),
    );

    return mealsAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorStateView(message: e.toString()),
      data: (meals) {
        final availableMeals = meals.where((m) => m.isAvailable).toList();
        if (availableMeals.isEmpty) {
          return EmptyStateView(
            icon: LucideIcons.utensilsCrossed,
            title: l10n.noMealsInCategory,
          );
        }

        final total = availableMeals.fold<double>(
          0.0,
          (sum, meal) => sum + meal.price * (_quantities[meal.id] ?? 0),
        );
        final hasItems = _quantities.values.any((q) => q > 0);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.walkInTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.walkInSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: availableMeals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final meal = availableMeals[index];
                  final qty = _quantities[meal.id] ?? 0;
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: MealImageWidget(
                        imagePath: meal.imagePath,
                        width: 54,
                        height: 54,
                      ),
                      title: Text(
                        meal.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${meal.price.toStringAsFixed(2)} ${l10n.currencyJod} • ${l10n.localizedMealCategory(meal.category)}',
                      ),
                      trailing: UbQuantityStepper(
                        quantity: qty,
                        onChanged: (next) =>
                            setState(() => _quantities[meal.id] = next),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(UniBiteTokens.s16),
              decoration: const BoxDecoration(
                color: UniBiteColors.surface,
                border: Border(top: BorderSide(color: UniBiteColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.specialNoteLabel,
                      hintText: l10n.specialNoteHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.totalLabel}: ${total.toStringAsFixed(2)} ${l10n.currencyJod}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: UniBiteColors.secondaryText),
                        ),
                      ),
                      UbPrimaryButton(
                        onPressed: hasItems
                            ? () => _submitWalkIn(availableMeals)
                            : null,
                        isLoading: _submitting,
                        icon: LucideIcons.receipt,
                        label: l10n.createWalkInButton,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
