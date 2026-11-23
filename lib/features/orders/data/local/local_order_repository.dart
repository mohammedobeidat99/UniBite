import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';
import 'package:unibite/features/orders/domain/order_status_validator.dart';
import 'package:unibite/features/orders/domain/repositories/order_repository.dart';
import 'package:uuid/uuid.dart';

/// Hive-backed local implementation of [OrderRepository].
class LocalOrderRepository implements OrderRepository {
  /// Creates a [LocalOrderRepository] backed by [_storage].
  LocalOrderRepository(this._storage, {Uuid? uuid, DateTime Function()? clock})
    : _uuid = uuid ?? const Uuid(),
      _clock = clock ?? DateTime.now;

  final LocalStorageService _storage;
  final Uuid _uuid;
  final DateTime Function() _clock;

  @override
  Stream<List<Order>> watchOrdersForCafeteria(
    String cafeteriaId, {
    required AppUser actor,
  }) {
    _requireCafeteriaScope(actor, cafeteriaId);
    return _storage.watchOrders().map(
      (orders) => orders.where((o) => o.cafeteriaId == cafeteriaId).toList(),
    );
  }

  @override
  Stream<List<Order>> watchOrdersForStudent(
    String studentId, {
    required AppUser actor,
  }) {
    final isSelf = actor.role == UserRole.student && actor.id == studentId;
    if (!actor.isActive || (!isSelf && actor.role != UserRole.systemAdmin)) {
      throw const UnauthorizedAccessException(
        'Students may only view their own orders.',
      );
    }
    return _storage.watchOrders().map(
      (orders) => orders.where((o) => o.studentId == studentId).toList(),
    );
  }

  @override
  Stream<Order?> watchOrderById(String orderId) {
    return _storage.watchOrders().map((orders) {
      for (final order in orders) {
        if (order.id == orderId) return order;
      }
      return null;
    });
  }

  @override
  Future<Order?> findOrderByCodeOrNumber({
    required String cafeteriaId,
    required String query,
    required AppUser actor,
  }) async {
    _requireCafeteriaScope(actor, cafeteriaId);
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final order in _storage.getOrders()) {
      if (order.cafeteriaId != cafeteriaId) continue;
      if (order.orderNumber.toLowerCase() == normalized ||
          order.qrCode.toLowerCase() == normalized ||
          order.id.toLowerCase() == normalized) {
        return order;
      }
    }
    return null;
  }

  @override
  Future<Order> placeStudentOrder({
    required String cafeteriaId,
    required List<OrderItem> items,
    DateTime? pickupTime,
    required AppUser actor,
  }) async {
    if (!actor.isActive || actor.role != UserRole.student) {
      throw const UnauthorizedAccessException(
        'Only active student accounts can place app orders.',
      );
    }
    if (items.isEmpty) {
      throw const ValidationException('Cannot place an empty order.');
    }

    final cafeteria = _findCafeteria(cafeteriaId);
    if (!cafeteria.isActive) {
      throw const ValidationException(
        'This cafeteria is suspended and cannot accept orders.',
      );
    }

    final now = _clock();
    if (pickupTime == null) {
      if (!cafeteria.isOpenAt(now)) {
        throw const ValidationException(
          'This cafeteria is currently closed for immediate orders.',
        );
      }
    } else {
      if (pickupTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
        throw const ValidationException(
          'Scheduled pickup time cannot be in the past.',
        );
      }
      if (!cafeteria.isOpenAt(pickupTime)) {
        throw ValidationException(
          'Selected pickup time must be within working hours (${cafeteria.workingHours}).',
        );
      }
    }

    final validatedItems = _validateAndSnapshotItems(
      cafeteriaId: cafeteriaId,
      items: items,
    );
    final total = validatedItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    final id = 'order_${_uuid.v4()}';
    final orderNumber = _nextOrderNumber();
    final order = Order(
      id: id,
      orderNumber: orderNumber,
      studentId: actor.id,
      cafeteriaId: cafeteriaId,
      items: validatedItems,
      total: double.parse(total.toStringAsFixed(2)),
      status: OrderStatus.pending,
      type: OrderType.app,
      pickupTime: pickupTime,
      qrCode: 'UNIBITE|$id|$orderNumber|$cafeteriaId',
      paymentMethod: 'cash',
      createdAt: now,
      updatedAt: now,
    );

    await _storage.putOrder(order);
    return order;
  }

  @override
  Future<Order> createWalkInOrder({
    required String cafeteriaId,
    required List<OrderItem> items,
    String? customerNote,
    required AppUser actor,
  }) async {
    _requireCafeteriaScope(actor, cafeteriaId);
    if (items.isEmpty) {
      throw const ValidationException(
        'Select at least one meal for a walk-in order.',
      );
    }

    final cafeteria = _findCafeteria(cafeteriaId);
    if (!cafeteria.isActive) {
      throw const ValidationException('Cafeteria is suspended.');
    }

    final validatedItems = _validateAndSnapshotItems(
      cafeteriaId: cafeteriaId,
      items: items,
      fallbackNote: customerNote,
    );
    final total = validatedItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    final now = _clock();
    final id = 'order_${_uuid.v4()}';
    final orderNumber = _nextOrderNumber();
    final order = Order(
      id: id,
      orderNumber: orderNumber,
      cafeteriaId: cafeteriaId,
      items: validatedItems,
      total: double.parse(total.toStringAsFixed(2)),
      status: OrderStatus.accepted,
      type: OrderType.walkin,
      qrCode: 'UNIBITE|$id|$orderNumber|$cafeteriaId',
      paymentMethod: 'cash',
      createdAt: now,
      updatedAt: now,
    );

    await _storage.putOrder(order);
    return order;
  }

  @override
  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? rejectReason,
    required AppUser actor,
  }) async {
    final existing = _findOrder(orderId);
    OrderStatusValidator.validateTransition(
      order: existing,
      targetStatus: newStatus,
      actor: actor,
      rejectReason: rejectReason,
    );

    final updated = existing.copyWith(
      status: newStatus,
      rejectReason: newStatus == OrderStatus.rejected
          ? rejectReason?.trim()
          : existing.rejectReason,
      updatedAt: _clock(),
    );
    await _storage.putOrder(updated);
    return updated;
  }

  @override
  Future<Order> cancelOrder({required String orderId, required AppUser actor}) {
    return updateOrderStatus(
      orderId: orderId,
      newStatus: OrderStatus.cancelled,
      actor: actor,
    );
  }

  @override
  Future<int> autoRejectTimedOutOrders({
    required Map<String, int> cafeteriaTimeoutsSeconds,
    DateTime? now,
  }) async {
    final evalTime = now ?? _clock();
    final orders = _storage.getOrders();
    var rejectedCount = 0;

    for (final order in orders) {
      if (order.status != OrderStatus.pending) continue;
      final timeoutSeconds = cafeteriaTimeoutsSeconds[order.cafeteriaId] ?? 180;
      final elapsedSeconds = evalTime.difference(order.createdAt).inSeconds;
      if (elapsedSeconds >= timeoutSeconds) {
        final updated = order.copyWith(
          status: OrderStatus.rejected,
          rejectReason: 'No response',
          updatedAt: evalTime,
        );
        await _storage.putOrder(updated);
        rejectedCount++;
      }
    }
    return rejectedCount;
  }

  Cafeteria _findCafeteria(String cafeteriaId) {
    for (final cafe in _storage.getCafeterias()) {
      if (cafe.id == cafeteriaId) return cafe;
    }
    throw const ValidationException('Selected cafeteria was not found.');
  }

  Order _findOrder(String orderId) {
    for (final order in _storage.getOrders()) {
      if (order.id == orderId) return order;
    }
    throw const ValidationException('Order not found.');
  }

  List<OrderItem> _validateAndSnapshotItems({
    required String cafeteriaId,
    required List<OrderItem> items,
    String? fallbackNote,
  }) {
    final mealsById = <String, Meal>{
      for (final m in _storage.getMeals()) m.id: m,
    };

    final result = <OrderItem>[];
    for (final item in items) {
      if (item.qty <= 0) {
        throw const ValidationException('Item quantity must be at least 1.');
      }
      final meal = mealsById[item.mealId];
      if (meal == null) {
        throw ValidationException('Meal "${item.name}" no longer exists.');
      }
      if (meal.cafeteriaId != cafeteriaId) {
        throw const ValidationException(
          'All items in an order must belong to the same cafeteria.',
        );
      }
      if (!meal.isAvailable) {
        throw ValidationException(
          'Meal "${meal.name}" is currently unavailable.',
        );
      }
      result.add(
        OrderItem(
          mealId: meal.id,
          name: meal.name,
          price: meal.price,
          qty: item.qty,
          note: (item.note != null && item.note!.trim().isNotEmpty)
              ? item.note!.trim()
              : (fallbackNote?.trim().isNotEmpty == true
                    ? fallbackNote!.trim()
                    : null),
        ),
      );
    }
    return result;
  }

  String _nextOrderNumber() {
    final existing = _storage.getOrders();
    var maxNum = 1000;
    for (final order in existing) {
      final stripped = order.orderNumber.replaceFirst('UB-', '');
      final parsed = int.tryParse(stripped);
      if (parsed != null && parsed > maxNum) {
        maxNum = parsed;
      }
    }
    return 'UB-${maxNum + 1}';
  }

  void _requireCafeteriaScope(AppUser actor, String cafeteriaId) {
    final isSystemAdmin = actor.role == UserRole.systemAdmin;
    final isAssignedOperator =
        (actor.role == UserRole.cafeteriaAdmin ||
            actor.role == UserRole.cafeteriaStaff) &&
        actor.cafeteriaId == cafeteriaId;
    if (!actor.isActive || (!isSystemAdmin && !isAssignedOperator)) {
      throw const UnauthorizedAccessException(
        'Access denied: you may only view or handle orders for your assigned cafeteria.',
      );
    }
  }
}
