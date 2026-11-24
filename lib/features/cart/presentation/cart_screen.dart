import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/meal_image_widget.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/features/cart/presentation/cart_notifier.dart';

/// Student shopping cart and cash-at-pickup checkout view with swipe-to-remove
/// undo, pickup slot validation, and animated QR confirmation.
class CartScreen extends ConsumerStatefulWidget {
  /// Creates a [CartScreen] with optional [onOrderPlaced] callback.
  const CartScreen({super.key, this.onOrderPlaced});

  /// Callback invoked after a cash order is successfully submitted.
  final VoidCallback? onOrderPlaced;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isPreOrder = false;
  TimeOfDay? _preOrderTime;
  bool _submitting = false;
  String? _checkoutError;

  DateTime? _buildPickupDateTime() {
    if (!_isPreOrder || _preOrderTime == null) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      _preOrderTime!.hour,
      _preOrderTime!.minute,
    );
  }

  Future<void> _placeOrder() async {
    final l10n = context.l10n;
    final cart = ref.read(cartProvider);
    final actor = ref.read(currentUserProvider);
    if (cart.isEmpty || cart.cafeteriaId == null || actor == null) return;

    final pickupDateTime = _buildPickupDateTime();
    if (_isPreOrder && pickupDateTime == null) {
      setState(() => _checkoutError = l10n.choosePickupTime);
      return;
    }

    setState(() {
      _submitting = true;
      _checkoutError = null;
    });

    try {
      final order = await ref
          .read(orderRepositoryProvider)
          .placeStudentOrder(
            cafeteriaId: cart.cafeteriaId!,
            items: cart.toOrderItems(),
            pickupTime: pickupDateTime,
            actor: actor,
          );
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sheet),
            ),
            backgroundColor: AppColors.surface,
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const UbAnimatedCheck(size: 68),
                  const SizedBox(height: 16),
                  Text(
                    l10n.orderNumberLabel(order.orderNumber),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppColors.green900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.orderPlacedSuccess(order.orderNumber),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.outline),
                      boxShadow: AppShadow.soft,
                    ),
                    child: QrImageView(
                      data: order.qrCode,
                      size: 150,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
              UbPrimaryButton(
                label: l10n.close,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
        widget.onOrderPlaced?.call();
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _checkoutError = e.message);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return EmptyStateView(
        icon: LucideIcons.shoppingBag,
        title: l10n.emptyCartTitle,
        subtitle: l10n.emptyCartSubtitle,
      );
    }

    final cafeAsync = ref.watch(cafeteriaByIdStreamProvider(cart.cafeteriaId!));
    final cafeteria = cafeAsync.valueOrNull;
    final isOpenNow = cafeteria?.isOpenAt(DateTime.now()) ?? true;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg16),
            children: [
              UbCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.green100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.store,
                        color: AppColors.green700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cart.cafeteriaName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    UbGhostButton(
                      onPressed: () =>
                          ref.read(cartProvider.notifier).clear(),
                      label: l10n.clearCartButton,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md12),
              ...List.generate(cart.items.length, (index) {
                final item = cart.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey('${item.meal.id}_${item.note ?? ''}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: AppColors.dangerText,
                      ),
                    ),
                    onDismissed: (_) {
                      ref.read(cartProvider.notifier).removeAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.removedItemUndo(item.meal.name)),
                          action: SnackBarAction(
                            label: l10n.undoAction,
                            textColor: AppColors.yellow,
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(
                                    meal: item.meal,
                                    cafeteriaName: cart.cafeteriaName ?? '',
                                    quantity: item.quantity,
                                    note: item.note,
                                  );
                            },
                          ),
                        ),
                      );
                    },
                    child: UbCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          MealImageWidget(
                            imagePath: item.meal.imagePath,
                            width: 60,
                            height: 60,
                            borderRadius: 14,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.meal.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.meal.price.toStringAsFixed(2)} ${l10n.currencyJod}',
                                  style: const TextStyle(
                                    color: AppColors.orangeText,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                if (item.note != null &&
                                    item.note!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    item.note!,
                                    style: const TextStyle(
                                      color: AppColors.inkMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          UbQuantityStepper(
                            quantity: item.quantity,
                            onChanged: (q) => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(index, q),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              UbCard(
                padding: const EdgeInsets.all(AppSpacing.lg16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.pickupModeLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      UbSegmentedControl<bool>(
                        selectedValue: _isPreOrder,
                        options: [
                          (false, l10n.orderNowOption, LucideIcons.zap),
                          (true, l10n.preOrderOption, LucideIcons.clock),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _isPreOrder = val;
                            if (!_isPreOrder) _preOrderTime = null;
                            _checkoutError = null;
                          });
                        },
                      ),
                      if (_isPreOrder) ...[
                        const SizedBox(height: 12),
                        UbSecondaryButton(
                          onPressed: () async {
                            final now = TimeOfDay.now();
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _preOrderTime ?? now,
                            );
                            if (picked != null) {
                              setState(() {
                                _preOrderTime = picked;
                                _checkoutError = null;
                              });
                            }
                          },
                          icon: LucideIcons.calendarClock,
                          label: _preOrderTime == null
                              ? l10n.choosePickupTime
                              : l10n.selectedPickupTime(
                                  DateFormat.Hm().format(
                                    _buildPickupDateTime()!,
                                  ),
                                ),
                        ),
                      ],
                      const Divider(height: 24),
                      Text(
                        l10n.itemSubtotal,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...cart.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity}× ${item.meal.name}'),
                              Text(
                                '${item.subtotal.toStringAsFixed(2)} ${l10n.currencyJod}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.totalLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            '${cart.totalAmount.toStringAsFixed(2)} ${l10n.currencyJod}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.orangeText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.green100,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.paymentMethodCashOnly,
                              style: const TextStyle(
                                color: AppColors.green900,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.fulfillmentSelfPickupOnly,
                              style: const TextStyle(
                                color: AppColors.green700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isPreOrder && !isOpenNow) ...[
                        const SizedBox(height: 10),
                        Text(
                          l10n.cafeteriaClosedOrderBlocked,
                          style: const TextStyle(
                            color: AppColors.dangerText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (_checkoutError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _checkoutError!,
                          style: const TextStyle(
                            color: AppColors.dangerText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: AppColors.outline)),
            boxShadow: AppShadow.soft,
          ),
          child: UbPrimaryButton(
            onPressed: (!_isPreOrder && !isOpenNow) ? null : _placeOrder,
            isLoading: _submitting,
            icon: LucideIcons.checkCircle2,
            label:
                '${l10n.placeOrderButton} • ${cart.totalAmount.toStringAsFixed(2)} ${l10n.currencyJod}',
          ),
        ),
      ],
    );
  }
}
