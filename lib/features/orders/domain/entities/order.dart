import 'package:equatable/equatable.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';

/// Food order placed via the student app or entered as a cafeteria walk-in order.
class Order extends Equatable {
  /// Creates an immutable [Order] record.
  const Order({
    required this.id,
    required this.orderNumber,
    this.studentId,
    required this.cafeteriaId,
    required this.items,
    required this.total,
    required this.status,
    this.rejectReason,
    required this.type,
    this.pickupTime,
    required this.qrCode,
    this.paymentMethod = 'cash',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique internal identifier for the order.
  final String id;

  /// Human-friendly ticket number displayed to students and kitchen staff (e.g., `UB-1042`).
  final String orderNumber;

  /// Ordering student's identifier, or `null` for walk-in orders.
  final String? studentId;

  /// Fulfilling cafeteria identifier.
  final String cafeteriaId;

  /// Line items included in this order.
  final List<OrderItem> items;

  /// Total cash payable upon self-pickup.
  final double total;

  /// Current lifecycle status of the order.
  final OrderStatus status;

  /// Optional explanation when [status] is [OrderStatus.rejected].
  final String? rejectReason;

  /// Channel indicating whether the order is an app order or walk-in order.
  final OrderType type;

  /// Scheduled pre-order pickup timestamp, or `null` for immediate pickup.
  final DateTime? pickupTime;

  /// Encoded QR code token verified at the cafeteria pickup counter.
  final String qrCode;

  /// Payment method, fixed to `'cash'` in GP1.
  final String paymentMethod;

  /// Timestamp when the order was created.
  final DateTime createdAt;

  /// Timestamp of the latest status change.
  final DateTime updatedAt;

  /// Returns a copy of this order with replaced fields.
  Order copyWith({
    String? id,
    String? orderNumber,
    String? studentId,
    String? cafeteriaId,
    List<OrderItem>? items,
    double? total,
    OrderStatus? status,
    String? rejectReason,
    bool clearRejectReason = false,
    OrderType? type,
    DateTime? pickupTime,
    String? qrCode,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      studentId: studentId ?? this.studentId,
      cafeteriaId: cafeteriaId ?? this.cafeteriaId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      rejectReason: clearRejectReason
          ? null
          : (rejectReason ?? this.rejectReason),
      type: type ?? this.type,
      pickupTime: pickupTime ?? this.pickupTime,
      qrCode: qrCode ?? this.qrCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this order into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'studentId': studentId,
      'cafeteriaId': cafeteriaId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status.storageKey,
      'rejectReason': rejectReason,
      'type': type.storageKey,
      'pickupTime': pickupTime?.toIso8601String(),
      'qrCode': qrCode,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Reconstructs an [Order] from a JSON map.
  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? [])
        .map(
          (item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      studentId: json['studentId'] as String?,
      cafeteriaId: json['cafeteriaId'] as String,
      items: rawItems,
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.fromStorageKey(json['status'] as String),
      rejectReason: json['rejectReason'] as String?,
      type: OrderType.fromStorageKey(json['type'] as String? ?? 'app'),
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'] as String)
          : null,
      qrCode: json['qrCode'] as String,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    studentId,
    cafeteriaId,
    items,
    total,
    status,
    rejectReason,
    type,
    pickupTime,
    qrCode,
    paymentMethod,
    createdAt,
    updatedAt,
  ];
}
