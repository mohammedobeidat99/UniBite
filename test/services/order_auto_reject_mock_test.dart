import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/cafeterias/domain/repositories/cafeteria_repository.dart';
import 'package:unibite/features/orders/domain/repositories/order_repository.dart';
import 'package:unibite/features/orders/domain/services/order_auto_reject_service.dart';

@GenerateNiceMocks([
  MockSpec<OrderRepository>(),
  MockSpec<CafeteriaRepository>(),
])
import 'order_auto_reject_mock_test.mocks.dart';

void main() {
  group('OrderAutoRejectService (Mockito)', () {
    late MockOrderRepository mockOrderRepository;
    late MockCafeteriaRepository mockCafeteriaRepository;
    late OrderAutoRejectService service;
    final fixedNow = DateTime(2026, 11, 22, 14, 0, 0);

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockCafeteriaRepository = MockCafeteriaRepository();
      service = OrderAutoRejectService(
        mockOrderRepository,
        mockCafeteriaRepository,
        clock: () => fixedNow,
      );
    });

    test(
      'maps cafeteria timeouts and delegates sweep to OrderRepository',
      () async {
        const cafeterias = [
          Cafeteria(
            id: 'cafe_1',
            universityId: 'uni_1',
            campusId: 'camp_1',
            name: 'Cafe One',
            logo: 'assets/images/logo.jpg',
            workingHours: '08:00-22:00',
            isActive: true,
            ownerId: 'owner_1',
            orderTimeoutSeconds: 180,
          ),
          Cafeteria(
            id: 'cafe_2',
            universityId: 'uni_1',
            campusId: 'camp_1',
            name: 'Cafe Two',
            logo: 'assets/images/logo.jpg',
            workingHours: '08:00-22:00',
            isActive: true,
            ownerId: 'owner_2',
            orderTimeoutSeconds: 240,
          ),
        ];

        when(
          mockCafeteriaRepository.watchCafeterias(activeOnly: false),
        ).thenAnswer((_) => Stream.value(cafeterias));
        when(
          mockOrderRepository.autoRejectTimedOutOrders(
            cafeteriaTimeoutsSeconds: anyNamed('cafeteriaTimeoutsSeconds'),
            now: anyNamed('now'),
          ),
        ).thenAnswer((_) async => 2);

        final rejectedCount = await service.runSweep();

        expect(rejectedCount, 2);
        verify(
          mockCafeteriaRepository.watchCafeterias(activeOnly: false),
        ).called(1);
        verify(
          mockOrderRepository.autoRejectTimedOutOrders(
            cafeteriaTimeoutsSeconds: {'cafe_1': 180, 'cafe_2': 240},
            now: fixedNow,
          ),
        ).called(1);
      },
    );
  });
}
