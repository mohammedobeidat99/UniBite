import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/state_views.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';

/// Live three-column Kanban board for managing New, Preparing, and Ready orders
/// with counter-readable typography, inline QR lookup, pulsing rings, and sound alerts.
class LiveOrderBoardWidget extends ConsumerStatefulWidget {
  /// Creates a [LiveOrderBoardWidget] scoped to [cafeteriaId] and [actor].
  const LiveOrderBoardWidget({
    super.key,
    required this.cafeteriaId,
    required this.actor,
    this.onCreateWalkIn,
  });

  /// Cafeteria identifier whose orders are monitored.
  final String cafeteriaId;

  /// Authenticated Cafeteria Admin or Staff actor performing actions.
  final AppUser actor;

  /// Optional callback invoked when the operator taps the Walk-In quick button.
  final VoidCallback? onCreateWalkIn;

  @override
  ConsumerState<LiveOrderBoardWidget> createState() =>
      _LiveOrderBoardWidgetState();
}

class _LiveOrderBoardWidgetState extends ConsumerState<LiveOrderBoardWidget>
    with SingleTickerProviderStateMixin {
  Timer? _alertTimer;
  Timer? _countdownTicker;
  late final AnimationController _pulseController;
  final TextEditingController _inlineLookupCtrl = TextEditingController();
  bool _isMuted = false;
  bool _hasPending = false;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    if (!UniBiteTokens.isTestEnvironment) {
      _countdownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    _countdownTicker?.cancel();
    _pulseController.dispose();
    _inlineLookupCtrl.dispose();
    super.dispose();
  }

  void _syncAlertLoop(bool hasPending) {
    if (_hasPending == hasPending) return;
    _hasPending = hasPending;

    if (hasPending) {
      if (!UniBiteTokens.isTestEnvironment) {
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
        _triggerBeep();
        _alertTimer ??= Timer.periodic(const Duration(seconds: 4), (_) {
          _triggerBeep();
        });
      }
    } else {
      _alertTimer?.cancel();
      _alertTimer = null;
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _triggerBeep() {
    if (UniBiteTokens.isTestEnvironment) return;
    if (!_isMuted && _hasPending) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _transition(
    Order order,
    OrderStatus target, {
    String? rejectReason,
  }) async {
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(
            orderId: order.id,
            newStatus: target,
            rejectReason: rejectReason,
            actor: widget.actor,
          );
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _inlineLookupOrder() async {
    final l10n = context.l10n;
    final query = _inlineLookupCtrl.text.trim();
    if (query.isEmpty) return;

    final found = await ref
        .read(orderRepositoryProvider)
        .findOrderByCodeOrNumber(
          cafeteriaId: widget.cafeteriaId,
          query: query,
          actor: widget.actor,
        );
    if (!mounted) return;
    if (found == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.orderNotFound)));
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.orderNumberLabel(found.orderNumber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.orderStatusLabel(found.status)} • ${found.total.toStringAsFixed(2)} ${l10n.currencyJod}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...found.items.map((it) => Text('${it.qty}× ${it.name}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
          if (found.status == OrderStatus.ready)
            UbPrimaryButton(
              label: l10n.completePickupButton,
              onPressed: () async {
                await _transition(found, OrderStatus.completed);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openRejectDialog(Order order) async {
    final l10n = context.l10n;
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.rejectOrderDialogTitle} • ${order.orderNumber}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: Text(l10n.rejectQuickOut),
                    onPressed: () => reasonCtrl.text = l10n.rejectQuickOut,
                  ),
                  ActionChip(
                    label: Text(l10n.rejectQuickBusy),
                    onPressed: () => reasonCtrl.text = l10n.rejectQuickBusy,
                  ),
                  ActionChip(
                    label: Text(l10n.rejectQuickClosing),
                    onPressed: () => reasonCtrl.text = l10n.rejectQuickClosing,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonCtrl,
                decoration: InputDecoration(
                  labelText: l10n.rejectReasonInputLabel,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(reasonCtrl.text.trim());
              }
            },
            child: Text(l10n.rejectOrderButton),
          ),
        ],
      ),
    );
    reasonCtrl.dispose();

    if (reason != null) {
      await _transition(order, OrderStatus.rejected, rejectReason: reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ordersAsync = ref.watch(
      cafeteriaOrdersStreamProvider(widget.cafeteriaId),
    );
    final cafeAsync = ref.watch(
      cafeteriaByIdStreamProvider(widget.cafeteriaId),
    );
    final timeoutSeconds = cafeAsync.valueOrNull?.orderTimeoutSeconds ?? 180;

    return ordersAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorStateView(message: e.toString()),
      data: (orders) {
        final pendingOrders = orders
            .where((o) => o.status == OrderStatus.pending)
            .toList();
        final preparingOrders = orders
            .where(
              (o) =>
                  o.status == OrderStatus.accepted ||
                  o.status == OrderStatus.preparing,
            )
            .toList();
        final readyOrders = orders
            .where((o) => o.status == OrderStatus.ready)
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncAlertLoop(pendingOrders.isNotEmpty);
        });

        final isWide = MediaQuery.sizeOf(context).width >= 900;

        return Column(
          children: [
            // Persistent counter action strip: QR lookup, Walk-In CTA, Mute toggle.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isWide ? 310 : double.infinity,
                    child: TextField(
                      controller: _inlineLookupCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.qrLookupHint,
                        prefixIcon: const Icon(LucideIcons.qrCode),
                        isDense: true,
                        suffixIcon: IconButton(
                          tooltip: l10n.lookupButton,
                          onPressed: _inlineLookupOrder,
                          icon: const Icon(LucideIcons.search),
                        ),
                      ),
                      onSubmitted: (_) => _inlineLookupOrder(),
                    ),
                  ),
                  if (widget.onCreateWalkIn != null)
                    UbPrimaryButton(
                      label: l10n.tabWalkInOrder,
                      icon: LucideIcons.plusCircle,
                      onPressed: widget.onCreateWalkIn,
                    ),
                  UbSecondaryButton(
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                    icon: _isMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                    label: _isMuted ? l10n.soundAlertMuted : l10n.soundAlertOn,
                  ),
                ],
              ),
            ),
            if (pendingOrders.isNotEmpty)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final color = Color.lerp(
                    AppColors.orange,
                    AppColors.danger,
                    _pulseController.value,
                  )!;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.bellRing,
                          color: AppColors.ink,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.pendingAlertBanner(pendingOrders.length),
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            Expanded(
              child: isWide
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _BoardColumn(
                              title: l10n.columnNew,
                              count: pendingOrders.length,
                              accentColor: AppColors.orange,
                              headerTextColor: AppColors.ink,
                              orders: pendingOrders,
                              timeoutSeconds: timeoutSeconds,
                              now: _now,
                              pulseValue: _pulseController.value,
                              onAccept: (o) =>
                                  _transition(o, OrderStatus.accepted),
                              onReject: _openRejectDialog,
                              onStartPreparing: (o) =>
                                  _transition(o, OrderStatus.preparing),
                              onMarkReady: (o) =>
                                  _transition(o, OrderStatus.ready),
                              onComplete: (o) =>
                                  _transition(o, OrderStatus.completed),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _BoardColumn(
                              title: l10n.columnPreparing,
                              count: preparingOrders.length,
                              accentColor: AppColors.yellow,
                              headerTextColor: AppColors.onYellow,
                              orders: preparingOrders,
                              timeoutSeconds: timeoutSeconds,
                              now: _now,
                              pulseValue: 0,
                              onAccept: (o) =>
                                  _transition(o, OrderStatus.accepted),
                              onReject: _openRejectDialog,
                              onStartPreparing: (o) =>
                                  _transition(o, OrderStatus.preparing),
                              onMarkReady: (o) =>
                                  _transition(o, OrderStatus.ready),
                              onComplete: (o) =>
                                  _transition(o, OrderStatus.completed),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _BoardColumn(
                              title: l10n.columnReady,
                              count: readyOrders.length,
                              accentColor: AppColors.green500,
                              headerTextColor: AppColors.surface,
                              orders: readyOrders,
                              timeoutSeconds: timeoutSeconds,
                              now: _now,
                              pulseValue: 0,
                              onAccept: (o) =>
                                  _transition(o, OrderStatus.accepted),
                              onReject: _openRejectDialog,
                              onStartPreparing: (o) =>
                                  _transition(o, OrderStatus.preparing),
                              onMarkReady: (o) =>
                                  _transition(o, OrderStatus.ready),
                              onComplete: (o) =>
                                  _transition(o, OrderStatus.completed),
                            ),
                          ),
                        ],
                      ),
                    )
                  : DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppColors.green700,
                            indicatorColor: AppColors.orange,
                            tabs: [
                              Tab(
                                text:
                                    '${l10n.columnNew} (${pendingOrders.length})',
                              ),
                              Tab(
                                text:
                                    '${l10n.columnPreparing} (${preparingOrders.length})',
                              ),
                              Tab(
                                text:
                                    '${l10n.columnReady} (${readyOrders.length})',
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _BoardColumn(
                                  title: l10n.columnNew,
                                  count: pendingOrders.length,
                                  accentColor: AppColors.orange,
                                  headerTextColor: AppColors.ink,
                                  orders: pendingOrders,
                                  timeoutSeconds: timeoutSeconds,
                                  now: _now,
                                  pulseValue: _pulseController.value,
                                  onAccept: (o) =>
                                      _transition(o, OrderStatus.accepted),
                                  onReject: _openRejectDialog,
                                  onStartPreparing: (o) =>
                                      _transition(o, OrderStatus.preparing),
                                  onMarkReady: (o) =>
                                      _transition(o, OrderStatus.ready),
                                  onComplete: (o) =>
                                      _transition(o, OrderStatus.completed),
                                ),
                                _BoardColumn(
                                  title: l10n.columnPreparing,
                                  count: preparingOrders.length,
                                  accentColor: AppColors.yellow,
                                  headerTextColor: AppColors.onYellow,
                                  orders: preparingOrders,
                                  timeoutSeconds: timeoutSeconds,
                                  now: _now,
                                  pulseValue: 0,
                                  onAccept: (o) =>
                                      _transition(o, OrderStatus.accepted),
                                  onReject: _openRejectDialog,
                                  onStartPreparing: (o) =>
                                      _transition(o, OrderStatus.preparing),
                                  onMarkReady: (o) =>
                                      _transition(o, OrderStatus.ready),
                                  onComplete: (o) =>
                                      _transition(o, OrderStatus.completed),
                                ),
                                _BoardColumn(
                                  title: l10n.columnReady,
                                  count: readyOrders.length,
                                  accentColor: AppColors.green500,
                                  headerTextColor: AppColors.surface,
                                  orders: readyOrders,
                                  timeoutSeconds: timeoutSeconds,
                                  now: _now,
                                  pulseValue: 0,
                                  onAccept: (o) =>
                                      _transition(o, OrderStatus.accepted),
                                  onReject: _openRejectDialog,
                                  onStartPreparing: (o) =>
                                      _transition(o, OrderStatus.preparing),
                                  onMarkReady: (o) =>
                                      _transition(o, OrderStatus.ready),
                                  onComplete: (o) =>
                                      _transition(o, OrderStatus.completed),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.title,
    required this.count,
    required this.accentColor,
    required this.headerTextColor,
    required this.orders,
    required this.timeoutSeconds,
    required this.now,
    required this.pulseValue,
    required this.onAccept,
    required this.onReject,
    required this.onStartPreparing,
    required this.onMarkReady,
    required this.onComplete,
  });

  final String title;
  final int count;
  final Color accentColor;
  final Color headerTextColor;
  final List<Order> orders;
  final int timeoutSeconds;
  final DateTime now;
  final double pulseValue;
  final ValueChanged<Order> onAccept;
  final ValueChanged<Order> onReject;
  final ValueChanged<Order> onStartPreparing;
  final ValueChanged<Order> onMarkReady;
  final ValueChanged<Order> onComplete;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadow.soft,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 6, backgroundColor: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.green900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: headerTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      '—',
                      style: TextStyle(
                        color: AppColors.inkMuted,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      Widget card = _OrderTicketCard(
                        order: orders[index],
                        timeoutSeconds: timeoutSeconds,
                        now: now,
                        pulseValue: pulseValue,
                        onAccept: () => onAccept(orders[index]),
                        onReject: () => onReject(orders[index]),
                        onStartPreparing: () => onStartPreparing(orders[index]),
                        onMarkReady: () => onMarkReady(orders[index]),
                        onComplete: () => onComplete(orders[index]),
                      );
                      if (!reduceMotion) {
                        card = card
                            .animate(key: ValueKey(orders[index].id))
                            .fadeIn(duration: UniBiteTokens.fast)
                            .slideY(begin: 0.05, end: 0);
                      }
                      return card;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderTicketCard extends StatelessWidget {
  const _OrderTicketCard({
    required this.order,
    required this.timeoutSeconds,
    required this.now,
    required this.pulseValue,
    required this.onAccept,
    required this.onReject,
    required this.onStartPreparing,
    required this.onMarkReady,
    required this.onComplete,
  });

  final Order order;
  final int timeoutSeconds;
  final DateTime now;
  final double pulseValue;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onStartPreparing;
  final VoidCallback onMarkReady;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final elapsedMinutes = now
        .difference(order.createdAt)
        .inMinutes
        .clamp(0, 999);
    final remainingSeconds =
        (timeoutSeconds - now.difference(order.createdAt).inSeconds).clamp(
          0,
          timeoutSeconds,
        );
    final isUrgent = order.status == OrderStatus.pending;
    final timerColor = remainingSeconds <= 30 || elapsedMinutes >= 10
        ? AppColors.dangerText
        : AppColors.inkMuted;

    final statusAccentColor = switch (order.status) {
      OrderStatus.pending => AppColors.orange,
      OrderStatus.accepted || OrderStatus.preparing => AppColors.yellow,
      OrderStatus.ready => AppColors.green500,
      _ => AppColors.outline,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isUrgent ? AppColors.orange : AppColors.outline,
          width: isUrgent ? 1.5 : 1.0,
        ),
        boxShadow: AppShadow.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              color: statusAccentColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.orderNumberLabel(order.orderNumber),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.green900,
                ),
              ),
              const Spacer(),
              UbStatusBadge(
                label: l10n.orderTypeLabel(order.type),
                backgroundColor: order.type == OrderType.walkin
                    ? AppColors.orangeSoft
                    : AppColors.green100,
                textColor: order.type == OrderType.walkin
                    ? AppColors.orangeText
                    : AppColors.green700,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormat.Hm().format(order.createdAt)} • ${order.total.toStringAsFixed(2)} ${l10n.currencyJod}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                l10n.elapsedMinutesLabel(elapsedMinutes),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: timerColor,
                ),
              ),
            ],
          ),
          if (order.pickupTime != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Text(
                l10n.selectedPickupTime(
                  DateFormat.Hm().format(order.pickupTime!),
                ),
                style: const TextStyle(
                  color: AppColors.onYellow,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const Divider(height: 16),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.qty}× ${item.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (item.note != null && item.note!.isNotEmpty)
                    Text(
                      '  • ${item.note}',
                      style: const TextStyle(
                        color: AppColors.orangeText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (order.status == OrderStatus.pending) ...[
            Row(
              children: [
                AppCountdownRing(
                  progress: timeoutSeconds > 0
                      ? remainingSeconds / timeoutSeconds
                      : 0.0,
                  remainingText:
                      '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                  isUrgent: remainingSeconds <= 45,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.autoRejectInSeconds(remainingSeconds),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: timerColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: UbSecondaryButton(
                    isDanger: true,
                    onPressed: onReject,
                    label: l10n.rejectOrderButton,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: UbPrimaryButton(
                    onPressed: onAccept,
                    label: l10n.acceptOrderButton,
                  ),
                ),
              ],
            ),
          ] else if (order.status == OrderStatus.accepted) ...[
            UbPrimaryButton(
              onPressed: onStartPreparing,
              label: l10n.startPreparingButton,
            ),
          ] else if (order.status == OrderStatus.preparing) ...[
            UbPrimaryButton(
              onPressed: onMarkReady,
              backgroundColor: AppColors.green500,
              label: l10n.markReadyButton,
            ),
          ] else if (order.status == OrderStatus.ready) ...[
            UbPrimaryButton(
              onPressed: onComplete,
              backgroundColor: AppColors.green700,
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
);
  }
}
