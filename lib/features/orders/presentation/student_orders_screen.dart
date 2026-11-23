import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

/// Displays the student's live active orders with animated stepper and QR codes
/// plus past order history.
class StudentOrdersScreen extends ConsumerWidget {
  /// Creates a [StudentOrdersScreen] for [student].
  const StudentOrdersScreen({super.key, required this.student});

  /// Currently signed-in student.
  final AppUser student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ordersAsync = ref.watch(studentOrdersStreamProvider(student.id));
    final cafeterias =
        ref
            .watch(
              cafeteriasStreamProvider((campusId: null, activeOnly: false)),
            )
            .valueOrNull ??
        [];
    final cafeNames = {for (final c in cafeterias) c.id: c.name};

    return ordersAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorStateView(message: e.toString()),
      data: (orders) {
        if (orders.isEmpty) {
          return EmptyStateView(
            icon: LucideIcons.receipt,
            title: l10n.noOrdersYet,
          );
        }

        final activeOrders = orders.where((o) => o.status.isActive).toList();
        final pastOrders = orders.where((o) => o.status.isTerminal).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            UniBiteTokens.screenPadding,
            UniBiteTokens.s16,
            UniBiteTokens.screenPadding,
            100,
          ),
          children: [
            if (activeOrders.isNotEmpty) ...[
              Text(
                l10n.activeOrdersSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ...activeOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentOrderCard(
                    order: order,
                    cafeteriaName: cafeNames[order.cafeteriaId] ?? '',
                    student: student,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (pastOrders.isNotEmpty) ...[
              Text(
                l10n.pastOrdersSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ...pastOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentOrderCard(
                    order: order,
                    cafeteriaName: cafeNames[order.cafeteriaId] ?? '',
                    student: student,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StudentOrderCard extends ConsumerWidget {
  const _StudentOrderCard({
    required this.order,
    required this.cafeteriaName,
    required this.student,
  });

  final Order order;
  final String cafeteriaName;
  final AppUser student;

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelOrderButton),
        content: Text(l10n.cancelOrderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UniBiteColors.danger,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(orderRepositoryProvider)
          .cancelOrder(orderId: order.id, actor: student);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (Color badgeBg, Color badgeFg) = switch (order.status) {
      OrderStatus.pending => (UniBiteColors.accentSoft, UniBiteColors.onAccent),
      OrderStatus.accepted || OrderStatus.preparing => (
        UniBiteColors.secondarySoft,
        UniBiteColors.secondaryText,
      ),
      OrderStatus.ready => (UniBiteColors.primary100, UniBiteColors.primary700),
      OrderStatus.completed => (
        UniBiteColors.primary50,
        UniBiteColors.completedMuted,
      ),
      OrderStatus.rejected || OrderStatus.cancelled => (
        UniBiteColors.dangerSoft,
        UniBiteColors.dangerText,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UniBiteTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderNumberLabel(order.orderNumber),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: UniBiteColors.primary700),
                      ),
                      Text(
                        '$cafeteriaName • ${DateFormat.yMd().add_Hm().format(order.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: l10n.orderStatusLabel(order.status),
                  backgroundColor: badgeBg,
                  textColor: badgeFg,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.orderStatusPlainLabel(order.status),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: badgeFg,
              ),
            ),
            if (order.status.isActive) ...[
              const SizedBox(height: 12),
              UbOrderStatusStepper(status: order.status),
            ],
            if (order.status == OrderStatus.rejected &&
                order.rejectReason != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: UniBiteColors.dangerSoft,
                  borderRadius: BorderRadius.circular(UniBiteTokens.r12),
                ),
                child: Text(
                  l10n.rejectReasonLabel(order.rejectReason!),
                  style: const TextStyle(
                    color: UniBiteColors.dangerText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Divider(height: 20),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.qty}× ${item.name}${item.note != null ? ' (${item.note})' : ''}',
                      ),
                    ),
                    Text(
                      '${item.subtotal.toStringAsFixed(2)} ${l10n.currencyJod}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${order.total.toStringAsFixed(2)} ${l10n.currencyJod}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: UniBiteColors.secondaryText,
                  ),
                ),
              ],
            ),
            if (order.status.isActive) ...[
              const Divider(height: 24),
              Row(
                children: [
                  QrImageView(
                    data: order.qrCode,
                    size: 92,
                    backgroundColor: UniBiteColors.surface,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pickupQrCodeTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.qrCode,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (order.status == OrderStatus.pending) ...[
                          const SizedBox(height: 10),
                          UbSecondaryButton(
                            isDanger: true,
                            onPressed: () => _cancelOrder(context, ref),
                            icon: LucideIcons.xCircle,
                            label: l10n.cancelOrderButton,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
