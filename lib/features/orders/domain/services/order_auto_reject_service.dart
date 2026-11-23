import 'dart:async';

import 'package:unibite/features/cafeterias/domain/repositories/cafeteria_repository.dart';
import 'package:unibite/features/orders/domain/repositories/order_repository.dart';

/// Periodic background service that auto-rejects unanswered pending orders.
///
/// Designed as a self-contained domain service so GP2 can migrate the logic
/// directly into a scheduled Cloud Function without changing repository APIs.
class OrderAutoRejectService {
  /// Creates an [OrderAutoRejectService] backed by [_orderRepository] and [_cafeteriaRepository].
  OrderAutoRejectService(
    this._orderRepository,
    this._cafeteriaRepository, {
    Duration interval = const Duration(seconds: 30),
    DateTime Function()? clock,
  }) : _interval = interval,
       _clock = clock ?? DateTime.now;

  final OrderRepository _orderRepository;
  final CafeteriaRepository _cafeteriaRepository;
  final Duration _interval;
  final DateTime Function() _clock;

  Timer? _timer;

  /// Whether the periodic auto-reject timer is currently active.
  bool get isRunning => _timer?.isActive ?? false;

  /// Starts the periodic check every [_interval] while the app remains open.
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(_interval, (_) {
      runSweep();
    });
  }

  /// Stops the periodic auto-reject timer if active.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Executes a single sweep across cafeterias and rejects timed-out pending orders.
  ///
  /// Returns the number of orders transitioned to `rejected` with reason `"No response"`.
  Future<int> runSweep() async {
    final cafeterias = await _cafeteriaRepository
        .watchCafeterias(activeOnly: false)
        .first;
    final timeouts = <String, int>{
      for (final cafe in cafeterias) cafe.id: cafe.orderTimeoutSeconds,
    };
    return _orderRepository.autoRejectTimedOutOrders(
      cafeteriaTimeoutsSeconds: timeouts,
      now: _clock(),
    );
  }
}
