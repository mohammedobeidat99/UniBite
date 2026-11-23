import 'package:equatable/equatable.dart';

/// Single line item inside a placed [Order].
class OrderItem extends Equatable {
  /// Creates an immutable [OrderItem].
  const OrderItem({
    required this.mealId,
    required this.name,
    required this.price,
    required this.qty,
    this.note,
  });

  /// Identifier of the referenced meal.
  final String mealId;

  /// Snapshot of the meal name at the time of ordering.
  final String name;

  /// Unit price snapshot at the time of ordering.
  final double price;

  /// Number of portions ordered.
  final int qty;

  /// Optional preparation note requested by the customer.
  final String? note;

  /// Computed line total equal to [price] multiplied by [qty].
  double get subtotal => price * qty;

  /// Returns a copy of this line item with replaced values.
  OrderItem copyWith({
    String? mealId,
    String? name,
    double? price,
    int? qty,
    String? note,
    bool clearNote = false,
  }) {
    return OrderItem(
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  /// Serializes this line item to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'mealId': mealId,
      'name': name,
      'price': price,
      'qty': qty,
      'note': note,
    };
  }

  /// Reconstructs an [OrderItem] from a JSON map.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      mealId: json['mealId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num).toInt(),
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [mealId, name, price, qty, note];
}
