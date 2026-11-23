# Orders Feature

Manages the complete order lifecycle: student cash orders, pre-orders, walk-in orders, QR code generation & lookup, live Kanban board alerts, status validation, and periodic auto-rejection.

## Structure
- `domain/entities/`: `OrderStatus`, `OrderType`, `OrderItem`, `Order`
- `domain/`: `OrderStatusValidator` (single source of truth for legal status transitions)
- `domain/repositories/`: `OrderRepository`
- `domain/services/`: `OrderAutoRejectService`
- `data/local/`: `LocalOrderRepository`
- `presentation/`: `LiveOrderBoardWidget`, `WalkInOrderView`, `QrLookupView`, `CafeteriaStaffDashboardScreen`, `StudentOrdersScreen`

## GP2 Firebase Migration
Implement `FirestoreOrderRepository implements OrderRepository` and deploy `OrderAutoRejectService.runSweep()` as a scheduled Cloud Function.
