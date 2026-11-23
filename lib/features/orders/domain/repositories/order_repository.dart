/// @docImport 'package:unibite/core/errors/app_exceptions.dart';
library;

import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';

/// Contract for placing, tracking, fulfilling, cancelling, and auto-rejecting orders.
abstract class OrderRepository {
  /// Watches all orders belonging to [cafeteriaId] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not assigned to [cafeteriaId].
  Stream<List<Order>> watchOrdersForCafeteria(
    String cafeteriaId, {
    required AppUser actor,
  });

  /// Watches all orders placed by [studentId] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] does not match [studentId].
  Stream<List<Order>> watchOrdersForStudent(
    String studentId, {
    required AppUser actor,
  });

  /// Watches a single order identified by [orderId].
  Stream<Order?> watchOrderById(String orderId);

  /// Searches for an order within [cafeteriaId] matching an order number or QR [query].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not assigned to [cafeteriaId].
  Future<Order?> findOrderByCodeOrNumber({
    required String cafeteriaId,
    required String query,
    required AppUser actor,
  });

  /// Submits a cash-at-pickup student order for [cafeteriaId] with [items] and optional [pickupTime].
  ///
  /// Validates that [actor] is an active student, [cafeteriaId] is open, all meals
  /// belong to [cafeteriaId] and are available, and [pickupTime] (if given) falls
  /// within working hours.
  Future<Order> placeStudentOrder({
    required String cafeteriaId,
    required List<OrderItem> items,
    DateTime? pickupTime,
    required AppUser actor,
  });

  /// Creates an immediate walk-in counter order for [cafeteriaId] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not cafeteria staff or admin
  /// assigned to [cafeteriaId].
  Future<Order> createWalkInOrder({
    required String cafeteriaId,
    required List<OrderItem> items,
    String? customerNote,
    required AppUser actor,
  });

  /// Transitions [orderId] to [newStatus] after validating rules via `OrderStatusValidator`.
  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? rejectReason,
    required AppUser actor,
  });

  /// Cancels [orderId] on behalf of the owning student [actor] while still `pending`.
  Future<Order> cancelOrder({required String orderId, required AppUser actor});

  /// Rejects all `pending` orders older than their cafeteria's configured timeout.
  ///
  /// Uses [cafeteriaTimeoutsSeconds] keyed by cafeteria ID and evaluates age against [now].
  /// Returns the count of orders auto-rejected.
  Future<int> autoRejectTimedOutOrders({
    required Map<String, int> cafeteriaTimeoutsSeconds,
    DateTime? now,
  });
}
