import 'package:equatable/equatable.dart';

/// Food or beverage menu item offered by a specific cafeteria.
class Meal extends Equatable {
  /// Creates an immutable [Meal] record.
  const Meal({
    required this.id,
    required this.cafeteriaId,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.isAvailable,
  });

  /// Unique identifier for the meal.
  final String id;

  /// Identifier of the cafeteria that serves this meal.
  final String cafeteriaId;

  /// Display name of the meal.
  final String name;

  /// Short description of ingredients and portion details.
  final String description;

  /// Unit price in the local campus currency (JOD).
  final double price;

  /// Asset path, local file path, or base64 data URI for the meal photo.
  final String imagePath;

  /// Menu category label (e.g., `Sandwiches`, `Hot Meals`, `Beverages`).
  final String category;

  /// Whether the meal is currently in stock and can be ordered.
  final bool isAvailable;

  /// Returns a copy of this meal with updated properties.
  Meal copyWith({
    String? id,
    String? cafeteriaId,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    String? category,
    bool? isAvailable,
  }) {
    return Meal(
      id: id ?? this.id,
      cafeteriaId: cafeteriaId ?? this.cafeteriaId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  /// Serializes this meal into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cafeteriaId': cafeteriaId,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  /// Reconstructs a [Meal] from a JSON map.
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      cafeteriaId: json['cafeteriaId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imagePath: json['imagePath'] as String? ?? 'preset:sandwich',
      category: json['category'] as String? ?? 'Hot Meals',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cafeteriaId,
    name,
    description,
    price,
    imagePath,
    category,
    isAvailable,
  ];
}
