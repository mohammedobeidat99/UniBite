import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unibite/features/cart/domain/entities/cart_item.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order_item.dart';

/// Immutable snapshot of the student's active shopping cart.
class CartState extends Equatable {
  /// Creates a [CartState] with [cafeteriaId], [cafeteriaName], and [items].
  const CartState({
    this.cafeteriaId,
    this.cafeteriaName,
    this.items = const [],
  });

  /// Identifier of the single cafeteria currently associated with the cart.
  final String? cafeteriaId;

  /// Display name of the cafeteria currently associated with the cart.
  final String? cafeteriaName;

  /// Ordered list of items currently in the cart.
  final List<CartItem> items;

  /// Whether the cart currently contains zero items.
  bool get isEmpty => items.isEmpty;

  /// Total count of individual meal portions across all cart entries.
  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Sum of all item subtotals in JOD.
  double get totalAmount => double.parse(
    items.fold(0.0, (sum, item) => sum + item.subtotal).toStringAsFixed(2),
  );

  /// Converts cart entries into domain [OrderItem] payloads for submission.
  List<OrderItem> toOrderItems() {
    return items
        .map(
          (item) => OrderItem(
            mealId: item.meal.id,
            name: item.meal.name,
            price: item.meal.price,
            qty: item.quantity,
            note: item.note,
          ),
        )
        .toList();
  }

  @override
  List<Object?> get props => [cafeteriaId, cafeteriaName, items];
}

/// Outcome returned when attempting to add a meal into the cart.
enum CartAddResult {
  /// Meal was added or merged successfully.
  added,

  /// Meal was rejected because it belongs to a different cafeteria than active items.
  differentCafeteriaConflict,

  /// Meal was rejected because it is currently marked unavailable.
  unavailableMeal,
}

/// State notifier managing single-cafeteria cart operations for students.
class CartNotifier extends StateNotifier<CartState> {
  /// Creates an empty [CartNotifier].
  CartNotifier() : super(const CartState());

  /// Attempts to add [meal] from [cafeteriaName] with [quantity] and optional [note].
  ///
  /// When [replaceIfDifferentCafeteria] is `true`, any existing items from another
  /// cafeteria are cleared before adding [meal].
  CartAddResult addItem({
    required Meal meal,
    required String cafeteriaName,
    int quantity = 1,
    String? note,
    bool replaceIfDifferentCafeteria = false,
  }) {
    if (!meal.isAvailable || quantity <= 0) {
      return CartAddResult.unavailableMeal;
    }

    if (state.cafeteriaId != null &&
        state.cafeteriaId != meal.cafeteriaId &&
        state.items.isNotEmpty) {
      if (!replaceIfDifferentCafeteria) {
        return CartAddResult.differentCafeteriaConflict;
      }
      state = const CartState();
    }

    final normalizedNote = note?.trim().isEmpty == true ? null : note?.trim();
    final updatedItems = List<CartItem>.from(state.items);
    final existingIndex = updatedItems.indexWhere(
      (item) =>
          item.meal.id == meal.id &&
          (item.note ?? '') == (normalizedNote ?? ''),
    );

    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      updatedItems.add(
        CartItem(meal: meal, quantity: quantity, note: normalizedNote),
      );
    }

    state = CartState(
      cafeteriaId: meal.cafeteriaId,
      cafeteriaName: cafeteriaName,
      items: updatedItems,
    );
    return CartAddResult.added;
  }

  /// Updates the quantity of the cart entry at [index], removing it if `<= 0`.
  void updateQuantity(int index, int newQuantity) {
    if (index < 0 || index >= state.items.length) return;
    if (newQuantity <= 0) {
      removeAt(index);
      return;
    }
    final updated = List<CartItem>.from(state.items);
    updated[index] = updated[index].copyWith(quantity: newQuantity);
    state = CartState(
      cafeteriaId: state.cafeteriaId,
      cafeteriaName: state.cafeteriaName,
      items: updated,
    );
  }

  /// Updates the preparation [note] on the cart entry at [index].
  void updateNote(int index, String? note) {
    if (index < 0 || index >= state.items.length) return;
    final updated = List<CartItem>.from(state.items);
    final normalized = note?.trim().isEmpty == true ? null : note?.trim();
    updated[index] = updated[index].copyWith(
      note: normalized,
      clearNote: normalized == null,
    );
    state = CartState(
      cafeteriaId: state.cafeteriaId,
      cafeteriaName: state.cafeteriaName,
      items: updated,
    );
  }

  /// Removes the item at [index] and clears the cafeteria lock when empty.
  void removeAt(int index) {
    if (index < 0 || index >= state.items.length) return;
    final updated = List<CartItem>.from(state.items)..removeAt(index);
    if (updated.isEmpty) {
      clear();
    } else {
      state = CartState(
        cafeteriaId: state.cafeteriaId,
        cafeteriaName: state.cafeteriaName,
        items: updated,
      );
    }
  }

  /// Empties the cart and resets the active cafeteria lock.
  void clear() {
    state = const CartState();
  }
}

/// Global Riverpod provider holding the student's active cart state.
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
