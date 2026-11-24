import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:unibite/core/design_system/components.dart';
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
            AppSpacing.lg16,
            AppSpacing.lg16,
            AppSpacing.lg16,
            100,
          ),
          children: [
            if (activeOrders.isNotEmpty) ...[
              UbSectionHeader(
                title: l10n.activeOrdersSection,
                badgeText: '${activeOrders.length}',
              ),
              const SizedBox(height: 12),
              ...activeOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StudentOrderCard(
                    order: order,
                    cafeteriaName: cafeNames[order.cafeteriaId] ?? '',
                    student: student,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (pastOrders.isNotEmpty) ...[
              UbSectionHeader(title: l10n.pastOrdersSection),
              const SizedBox(height: 12),
              ...pastOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(l10n.cancelOrderButton),
        content: Text(l10n.cancelOrderConfirm),
        actions: [
          UbGhostButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: l10n.cancel,
          ),
          UbSecondaryButton(
            isDanger: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            label: l10n.confirm,
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
      OrderStatus.pending => (AppColors.yellow, AppColors.onYellow),
      OrderStatus.accepted || OrderStatus.preparing => (
        AppColors.orangeSoft,
        AppColors.orangeText,
      ),
      OrderStatus.ready => (AppColors.green100, AppColors.green700),
      OrderStatus.completed => (
        AppColors.green50,
        AppColors.inkMuted,
      ),
      OrderStatus.rejected || OrderStatus.cancelled => (
        AppColors.dangerSoft,
        AppColors.dangerText,
      ),
    };

    return UbCard(
      padding: const EdgeInsets.all(AppSpacing.lg16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.green900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$cafeteriaName • ${DateFormat.yMd().add_Hm().format(order.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              UbStatusBadge(
                label: l10n.orderStatusLabel(order.status),
                backgroundColor: badgeBg,
                textColor: badgeFg,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.orderStatusPlainLabel(order.status),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: badgeFg,
            ),
          ),
          if (order.status.isActive) ...[
            const SizedBox(height: 14),
            UbOrderStatusStepper(status: order.status),
          ],
          if (order.status == OrderStatus.rejected &&
              order.rejectReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
              ),
              child: Text(
                l10n.rejectReasonLabel(order.rejectReason!),
                style: const TextStyle(
                  color: AppColors.dangerText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.outline),
          ),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.qty}× ${item.name}${item.note != null ? ' (${item.note})' : ''}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${item.subtotal.toStringAsFixed(2)} ${l10n.currencyJod}',
                    style: const TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(2)} ${l10n.currencyJod}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.orangeText,
                ),
              ),
            ],
          ),
          if (order.status.isActive) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: AppColors.outline),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(color: AppColors.outline),
                    boxShadow: AppShadow.soft,
                  ),
                  child: QrImageView(
                    data: order.qrCode,
                    size: 80,
                    backgroundColor: AppColors.surface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pickupQrCodeTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.qrCode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                          fontFamily: 'monospace',
                        ),
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
    );
  }
}
