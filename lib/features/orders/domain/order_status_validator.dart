import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';

/// Single domain authority validating legal order-status transitions and actor scopes.
class OrderStatusValidator {
  OrderStatusValidator._();

  static const Map<OrderStatus, Set<OrderStatus>> _allowedTransitions = {
    OrderStatus.pending: {
      OrderStatus.accepted,
      OrderStatus.rejected,
      OrderStatus.cancelled,
    },
    OrderStatus.accepted: {OrderStatus.preparing},
    OrderStatus.preparing: {OrderStatus.ready},
    OrderStatus.ready: {OrderStatus.completed},
    OrderStatus.completed: {},
    OrderStatus.rejected: {},
    OrderStatus.cancelled: {},
  };

  /// Returns the set of legal target statuses reachable from [current].
  static Set<OrderStatus> allowedNextStatuses(OrderStatus current) {
    return _allowedTransitions[current] ?? const {};
  }

  /// Whether transitioning directly from [from] to [to] is structurally legal.
  static bool canTransition(OrderStatus from, OrderStatus to) {
    return allowedNextStatuses(from).contains(to);
  }

  /// Validates that [actor] may move [order] to [targetStatus] with optional [rejectReason].
  ///
  /// Throws an [OrderStateException] for illegal state transitions or missing
  /// rejection reasons, and an [UnauthorizedAccessException] if [actor] lacks
  /// permission or belongs to another cafeteria or student account.
  static void validateTransition({
    required Order order,
    required OrderStatus targetStatus,
    required AppUser actor,
    String? rejectReason,
  }) {
    if (!canTransition(order.status, targetStatus)) {
      throw OrderStateException(
        'Cannot transition order ${order.orderNumber} from '
        '${order.status.storageKey} to ${targetStatus.storageKey}.',
        code: 'illegal_order_transition',
      );
    }

    if (targetStatus == OrderStatus.cancelled) {
      final isOwningStudent =
          actor.role == UserRole.student && order.studentId == actor.id;
      if (!isOwningStudent) {
        throw const UnauthorizedAccessException(
          'Only the student who placed this order can cancel it before acceptance.',
          code: 'unauthorized_cancel',
        );
      }
      return;
    }

    final isCafeteriaOperator =
        actor.role == UserRole.cafeteriaAdmin ||
        actor.role == UserRole.cafeteriaStaff;
    if (!isCafeteriaOperator || actor.cafeteriaId != order.cafeteriaId) {
      throw const UnauthorizedAccessException(
        'Only staff or admin assigned to this cafeteria can update order status.',
        code: 'unauthorized_order_update',
      );
    }

    if (targetStatus == OrderStatus.rejected &&
        (rejectReason == null || rejectReason.trim().isEmpty)) {
      throw const OrderStateException(
        'A rejection reason is required when rejecting an order.',
        code: 'missing_reject_reason',
      );
    }
  }
}
