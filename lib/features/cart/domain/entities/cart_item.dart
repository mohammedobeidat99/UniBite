import 'package:equatable/equatable.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';

/// Single meal line item held in the student's local shopping cart.
class CartItem extends Equatable {
  /// Creates a [CartItem] for [meal] with [quantity] and optional [note].
  const CartItem({required this.meal, required this.quantity, this.note});

  /// Menu item referenced by this cart entry.
  final Meal meal;

  /// Selected quantity (always at least 1).
  final int quantity;

  /// Optional preparation instruction entered by the student.
  final String? note;

  /// Computed line subtotal equal to `meal.price * quantity`.
  double get subtotal => meal.price * quantity;

  /// Returns a copy of this cart entry with replaced values.
  CartItem copyWith({
    Meal? meal,
    int? quantity,
    String? note,
    bool clearNote = false,
  }) {
    return CartItem(
      meal: meal ?? this.meal,
      quantity: quantity ?? this.quantity,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  @override
  List<Object?> get props => [meal, quantity, note];
}
