// Mocks generated in Mockito 5 @GenerateNiceMocks format.
// ignore_for_file: no_leading_underscores_for_library_prefixes
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:unibite/features/auth/domain/entities/app_user.dart' as _i5;
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart'
    as _i3;
import 'package:unibite/features/cafeterias/domain/repositories/cafeteria_repository.dart'
    as _i9;
import 'package:unibite/features/orders/domain/entities/order.dart' as _i2;
import 'package:unibite/features/orders/domain/entities/order_item.dart' as _i7;
import 'package:unibite/features/orders/domain/entities/order_status.dart'
    as _i8;
import 'package:unibite/features/orders/domain/repositories/order_repository.dart'
    as _i6;

class _FakeOrder_0 extends _i1.SmartFake implements _i2.Order {
  _FakeOrder_0(super.parent, super.parentInvocation);
}

class _FakeCafeteria_1 extends _i1.SmartFake implements _i3.Cafeteria {
  _FakeCafeteria_1(super.parent, super.parentInvocation);
}

/// A class which mocks [OrderRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockOrderRepository extends _i1.Mock implements _i6.OrderRepository {
  @override
  _i4.Stream<List<_i2.Order>> watchOrdersForCafeteria(
    String? cafeteriaId, {
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #watchOrdersForCafeteria,
              [cafeteriaId],
              {#actor: actor},
            ),
            returnValue: _i4.Stream<List<_i2.Order>>.empty(),
            returnValueForMissingStub: _i4.Stream<List<_i2.Order>>.empty(),
          )
          as _i4.Stream<List<_i2.Order>>);

  @override
  _i4.Stream<List<_i2.Order>> watchOrdersForStudent(
    String? studentId, {
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #watchOrdersForStudent,
              [studentId],
              {#actor: actor},
            ),
            returnValue: _i4.Stream<List<_i2.Order>>.empty(),
            returnValueForMissingStub: _i4.Stream<List<_i2.Order>>.empty(),
          )
          as _i4.Stream<List<_i2.Order>>);

  @override
  _i4.Stream<_i2.Order?> watchOrderById(String? orderId) =>
      (super.noSuchMethod(
            Invocation.method(#watchOrderById, [orderId]),
            returnValue: _i4.Stream<_i2.Order?>.empty(),
            returnValueForMissingStub: _i4.Stream<_i2.Order?>.empty(),
          )
          as _i4.Stream<_i2.Order?>);

  @override
  _i4.Future<_i2.Order?> findOrderByCodeOrNumber({
    required String? cafeteriaId,
    required String? query,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#findOrderByCodeOrNumber, [], {
              #cafeteriaId: cafeteriaId,
              #query: query,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i2.Order?>.value(),
            returnValueForMissingStub: _i4.Future<_i2.Order?>.value(),
          )
          as _i4.Future<_i2.Order?>);

  @override
  _i4.Future<_i2.Order> placeStudentOrder({
    required String? cafeteriaId,
    required List<_i7.OrderItem>? items,
    DateTime? pickupTime,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#placeStudentOrder, [], {
              #cafeteriaId: cafeteriaId,
              #items: items,
              #pickupTime: pickupTime,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#placeStudentOrder, [], {
                  #cafeteriaId: cafeteriaId,
                  #items: items,
                  #pickupTime: pickupTime,
                  #actor: actor,
                }),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#placeStudentOrder, [], {
                  #cafeteriaId: cafeteriaId,
                  #items: items,
                  #pickupTime: pickupTime,
                  #actor: actor,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Order>);

  @override
  _i4.Future<_i2.Order> createWalkInOrder({
    required String? cafeteriaId,
    required List<_i7.OrderItem>? items,
    String? customerNote,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#createWalkInOrder, [], {
              #cafeteriaId: cafeteriaId,
              #items: items,
              #customerNote: customerNote,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#createWalkInOrder, [], {
                  #cafeteriaId: cafeteriaId,
                  #items: items,
                  #customerNote: customerNote,
                  #actor: actor,
                }),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#createWalkInOrder, [], {
                  #cafeteriaId: cafeteriaId,
                  #items: items,
                  #customerNote: customerNote,
                  #actor: actor,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Order>);

  @override
  _i4.Future<_i2.Order> updateOrderStatus({
    required String? orderId,
    required _i8.OrderStatus? newStatus,
    String? rejectReason,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#updateOrderStatus, [], {
              #orderId: orderId,
              #newStatus: newStatus,
              #rejectReason: rejectReason,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#updateOrderStatus, [], {
                  #orderId: orderId,
                  #newStatus: newStatus,
                  #rejectReason: rejectReason,
                  #actor: actor,
                }),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#updateOrderStatus, [], {
                  #orderId: orderId,
                  #newStatus: newStatus,
                  #rejectReason: rejectReason,
                  #actor: actor,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Order>);

  @override
  _i4.Future<_i2.Order> cancelOrder({
    required String? orderId,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#cancelOrder, [], {
              #orderId: orderId,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#cancelOrder, [], {
                  #orderId: orderId,
                  #actor: actor,
                }),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i2.Order>.value(
              _FakeOrder_0(
                this,
                Invocation.method(#cancelOrder, [], {
                  #orderId: orderId,
                  #actor: actor,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.Order>);

  @override
  _i4.Future<int> autoRejectTimedOutOrders({
    required Map<String, int>? cafeteriaTimeoutsSeconds,
    DateTime? now,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#autoRejectTimedOutOrders, [], {
              #cafeteriaTimeoutsSeconds: cafeteriaTimeoutsSeconds,
              #now: now,
            }),
            returnValue: _i4.Future<int>.value(0),
            returnValueForMissingStub: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);
}

/// A class which mocks [CafeteriaRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCafeteriaRepository extends _i1.Mock
    implements _i9.CafeteriaRepository {
  @override
  _i4.Stream<List<_i3.Cafeteria>> watchCafeterias({
    String? campusId,
    bool? activeOnly = false,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#watchCafeterias, [], {
              #campusId: campusId,
              #activeOnly: activeOnly,
            }),
            returnValue: _i4.Stream<List<_i3.Cafeteria>>.empty(),
            returnValueForMissingStub: _i4.Stream<List<_i3.Cafeteria>>.empty(),
          )
          as _i4.Stream<List<_i3.Cafeteria>>);

  @override
  _i4.Stream<_i3.Cafeteria?> watchCafeteriaById(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#watchCafeteriaById, [id]),
            returnValue: _i4.Stream<_i3.Cafeteria?>.empty(),
            returnValueForMissingStub: _i4.Stream<_i3.Cafeteria?>.empty(),
          )
          as _i4.Stream<_i3.Cafeteria?>);

  @override
  _i4.Future<_i3.Cafeteria?> getCafeteriaById(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getCafeteriaById, [id]),
            returnValue: _i4.Future<_i3.Cafeteria?>.value(),
            returnValueForMissingStub: _i4.Future<_i3.Cafeteria?>.value(),
          )
          as _i4.Future<_i3.Cafeteria?>);

  @override
  _i4.Future<_i3.Cafeteria> saveCafeteria(
    _i3.Cafeteria? cafeteria, {
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#saveCafeteria, [cafeteria], {#actor: actor}),
            returnValue: _i4.Future<_i3.Cafeteria>.value(
              _FakeCafeteria_1(
                this,
                Invocation.method(#saveCafeteria, [cafeteria], {#actor: actor}),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i3.Cafeteria>.value(
              _FakeCafeteria_1(
                this,
                Invocation.method(#saveCafeteria, [cafeteria], {#actor: actor}),
              ),
            ),
          )
          as _i4.Future<_i3.Cafeteria>);

  @override
  _i4.Future<_i3.Cafeteria> setCafeteriaActive({
    required String? id,
    required bool? isActive,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#setCafeteriaActive, [], {
              #id: id,
              #isActive: isActive,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i3.Cafeteria>.value(
              _FakeCafeteria_1(
                this,
                Invocation.method(#setCafeteriaActive, [], {
                  #id: id,
                  #isActive: isActive,
                  #actor: actor,
                }),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i3.Cafeteria>.value(
              _FakeCafeteria_1(
                this,
                Invocation.method(#setCafeteriaActive, [], {
                  #id: id,
                  #isActive: isActive,
                  #actor: actor,
                }),
              ),
            ),
          )
          as _i4.Future<_i3.Cafeteria>);

  @override
  _i4.Future<_i3.Cafeteria> updateWorkingHours({
    required String? cafeteriaId,
    required String? workingHours,
    int? prepTimeMinutes,
    int? orderTimeoutSeconds,
    required _i5.AppUser? actor,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#updateWorkingHours, [], {
              #cafeteriaId: cafeteriaId,
              #workingHours: workingHours,
              #prepTimeMinutes: prepTimeMinutes,
              #orderTimeoutSeconds: orderTimeoutSeconds,
              #actor: actor,
            }),
            returnValue: _i4.Future<_i3.Cafeteria>.value(
              _FakeCafeteria_1(
                this,
                Invocation.method(#updateWorkingHours, [], {
                  #cafeteriaId: cafeteriaId,
                  #workingHours: workingHours,
                  #prepTimeMinutes: prepTimeMinutes,
                  #orderTimeoutSeconds: orderTimeoutSeconds,
                  #actor: actor,
                }),
              ),
            ),
            returnValueForMissingStub: _i4.Future<_i3.Cafeteria>.value(
              _FakeCafeteria_1(
                this,
                Invocation.method(#updateWorkingHours, [], {
                  #cafeteriaId: cafeteriaId,
                  #workingHours: workingHours,
                  #prepTimeMinutes: prepTimeMinutes,
                  #orderTimeoutSeconds: orderTimeoutSeconds,
                  #actor: actor,
                }),
              ),
            ),
          )
          as _i4.Future<_i3.Cafeteria>);
}
