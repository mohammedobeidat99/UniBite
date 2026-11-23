import 'package:flutter_test/flutter_test.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';
import 'package:unibite/features/orders/domain/order_status_validator.dart';

void main() {
  const student = AppUser(
    id: 'student_1',
    name: 'Student One',
    email: 's1@just.edu.jo',
    passwordHash: 'salt\$hash',
    role: UserRole.student,
    universityId: 'uni_1',
    campusId: 'camp_1',
    isActive: true,
  );

  const otherStudent = AppUser(
    id: 'student_2',
    name: 'Student Two',
    email: 's2@just.edu.jo',
    passwordHash: 'salt\$hash',
    role: UserRole.student,
    universityId: 'uni_1',
    campusId: 'camp_1',
    isActive: true,
  );

  const cafeStaff = AppUser(
    id: 'staff_1',
    name: 'Kitchen Staff',
    email: 'staff@just.edu.jo',
    passwordHash: 'salt\$hash',
    role: UserRole.cafeteriaStaff,
    cafeteriaId: 'cafe_1',
    isActive: true,
  );

  const otherCafeAdmin = AppUser(
    id: 'admin_2',
    name: 'Other Admin',
    email: 'admin2@just.edu.jo',
    passwordHash: 'salt\$hash',
    role: UserRole.cafeteriaAdmin,
    cafeteriaId: 'cafe_2',
    isActive: true,
  );

  Order makeOrder(OrderStatus status) {
    final now = DateTime(2026, 11, 22, 12, 0);
    return Order(
      id: 'ord_1',
      orderNumber: 'UB-1001',
      studentId: student.id,
      cafeteriaId: 'cafe_1',
      items: const [OrderItem(mealId: 'm1', name: 'Wrap', price: 2.5, qty: 1)],
      total: 2.5,
      status: status,
      type: OrderType.app,
      qrCode: 'UNIBITE|ord_1|UB-1001|cafe_1',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('OrderStatusValidator', () {
    test(
      'permits legal forward transitions by assigned cafeteria operator',
      () {
        expect(
          () => OrderStatusValidator.validateTransition(
            order: makeOrder(OrderStatus.pending),
            targetStatus: OrderStatus.accepted,
            actor: cafeStaff,
          ),
          returnsNormally,
        );
        expect(
          () => OrderStatusValidator.validateTransition(
            order: makeOrder(OrderStatus.accepted),
            targetStatus: OrderStatus.preparing,
            actor: cafeStaff,
          ),
          returnsNormally,
        );
        expect(
          () => OrderStatusValidator.validateTransition(
            order: makeOrder(OrderStatus.preparing),
            targetStatus: OrderStatus.ready,
            actor: cafeStaff,
          ),
          returnsNormally,
        );
        expect(
          () => OrderStatusValidator.validateTransition(
            order: makeOrder(OrderStatus.ready),
            targetStatus: OrderStatus.completed,
            actor: cafeStaff,
          ),
          returnsNormally,
        );
      },
    );

    test('permits rejection with non-empty reason', () {
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.rejected,
          rejectReason: 'Out of ingredients',
          actor: cafeStaff,
        ),
        returnsNormally,
      );
    });

    test('throws OrderStateException when rejection reason is empty', () {
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.rejected,
          rejectReason: '   ',
          actor: cafeStaff,
        ),
        throwsA(isA<OrderStateException>()),
      );
    });

    test('permits owning student to cancel pending order only', () {
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.cancelled,
          actor: student,
        ),
        returnsNormally,
      );

      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.accepted),
          targetStatus: OrderStatus.cancelled,
          actor: student,
        ),
        throwsA(isA<OrderStateException>()),
      );
    });

    test('rejects cancellation by another student or cafeteria staff', () {
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.cancelled,
          actor: otherStudent,
        ),
        throwsA(isA<UnauthorizedAccessException>()),
      );
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.cancelled,
          actor: cafeStaff,
        ),
        throwsA(isA<UnauthorizedAccessException>()),
      );
    });

    test('rejects illegal transitions and cross-cafeteria operators', () {
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.ready,
          actor: cafeStaff,
        ),
        throwsA(isA<OrderStateException>()),
      );
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.completed),
          targetStatus: OrderStatus.preparing,
          actor: cafeStaff,
        ),
        throwsA(isA<OrderStateException>()),
      );
      expect(
        () => OrderStatusValidator.validateTransition(
          order: makeOrder(OrderStatus.pending),
          targetStatus: OrderStatus.accepted,
          actor: otherCafeAdmin,
        ),
        throwsA(isA<UnauthorizedAccessException>()),
      );
    });
  });
}
