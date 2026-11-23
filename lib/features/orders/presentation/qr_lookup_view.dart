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
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';

/// Pickup counter lookup view verifying order numbers or scanned QR payloads.
class QrLookupView extends ConsumerStatefulWidget {
  /// Creates a [QrLookupView] scoped to [cafeteriaId] and [actor].
  const QrLookupView({
    super.key,
    required this.cafeteriaId,
    required this.actor,
  });

  /// Fulfilling cafeteria identifier.
  final String cafeteriaId;

  /// Authenticated Cafeteria Staff or Admin actor.
  final AppUser actor;

  @override
  ConsumerState<QrLookupView> createState() => _QrLookupViewState();
}

class _QrLookupViewState extends ConsumerState<QrLookupView> {
  final _queryCtrl = TextEditingController();
  Order? _foundOrder;
  String? _error;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup([String? overrideQuery]) async {
    final query = overrideQuery ?? _queryCtrl.text;
    if (overrideQuery != null) {
      _queryCtrl.text = overrideQuery;
    }
    setState(() {
      _error = null;
      _foundOrder = null;
    });

    try {
      final result = await ref
          .read(orderRepositoryProvider)
          .findOrderByCodeOrNumber(
            cafeteriaId: widget.cafeteriaId,
            query: query,
            actor: widget.actor,
          );
      if (mounted) {
        setState(() {
          _foundOrder = result;
          if (result == null) {
            _error = context.l10n.orderNotFound;
          }
        });
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _completeOrder(Order order) async {
    try {
      final updated = await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(
            orderId: order.id,
            newStatus: OrderStatus.completed,
            actor: widget.actor,
          );
      if (mounted) setState(() => _foundOrder = updated);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders =
        ref
            .watch(cafeteriaOrdersStreamProvider(widget.cafeteriaId))
            .valueOrNull ??
        [];
    final readyOrders = orders
        .where((o) => o.status == OrderStatus.ready)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UniBiteTokens.screenPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.qrLookupTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.qrLookupHint,
                        prefixIcon: const Icon(LucideIcons.qrCode),
                      ),
                      onSubmitted: (_) => _lookup(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  UbPrimaryButton(onPressed: _lookup, label: l10n.lookupButton),
                ],
              ),
              if (readyOrders.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.quickReadyOrdersLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: UniBiteColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: readyOrders
                      .map(
                        (order) => ActionChip(
                          avatar: const Icon(LucideIcons.qrCode, size: 16),
                          label: Text(order.orderNumber),
                          onPressed: () => _lookup(order.qrCode),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: UniBiteColors.dangerText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_foundOrder != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.orderNumberLabel(_foundOrder!.orderNumber),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: UniBiteColors.primary700),
                            ),
                            const Spacer(),
                            StatusBadge(
                              label: l10n.orderStatusLabel(_foundOrder!.status),
                              backgroundColor: UniBiteColors.primary100,
                              textColor: UniBiteColors.primary700,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: QrImageView(
                            data: _foundOrder!.qrCode,
                            size: 130,
                            backgroundColor: UniBiteColors.surface,
                          ),
                        ),
                        const Divider(height: 24),
                        ..._foundOrder!.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item.qty}× ${item.name}'),
                                ),
                                Text(
                                  '${item.subtotal.toStringAsFixed(2)} ${l10n.currencyJod}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.totalLabel,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${_foundOrder!.total.toStringAsFixed(2)} ${l10n.currencyJod}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: UniBiteColors.secondaryText,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.paymentMethodCashOnly,
                          style: const TextStyle(color: UniBiteColors.inkMuted),
                        ),
                        if (_foundOrder!.status == OrderStatus.ready) ...[
                          const SizedBox(height: 16),
                          UbPrimaryButton(
                            onPressed: () => _completeOrder(_foundOrder!),
                            backgroundColor: UniBiteColors.primary500,
                            icon: LucideIcons.checkCircle2,
                            label: l10n.completePickupButton,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
