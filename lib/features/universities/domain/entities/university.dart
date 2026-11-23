import 'package:equatable/equatable.dart';

/// Higher-education institution configured in UniBite.
class University extends Equatable {
  /// Creates an immutable [University] record.
  const University({
    required this.id,
    required this.name,
    required this.logo,
    required this.isActive,
  });

  /// Unique identifier for the university.
  final String id;

  /// Official display name of the university.
  final String name;

  /// Asset path, URL, or base64 data URI for the university emblem.
  final String logo;

  /// Whether students can select this university and browse its campuses.
  final bool isActive;

  /// Returns a copy of this university with updated properties.
  University copyWith({
    String? id,
    String? name,
    String? logo,
    bool? isActive,
  }) {
    return University(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Serializes this university to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'logo': logo, 'isActive': isActive};
  }

  /// Reconstructs a [University] from a JSON map.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String? ?? 'assets/images/logo.jpg',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, logo, isActive];
}
