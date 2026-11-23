import 'package:equatable/equatable.dart';

/// Physical branch belonging to a single [University].
class Campus extends Equatable {
  /// Creates an immutable [Campus] record.
  const Campus({
    required this.id,
    required this.universityId,
    required this.name,
    required this.location,
    required this.isActive,
  });

  /// Unique identifier for the campus branch.
  final String id;

  /// Parent university identifier.
  final String universityId;

  /// Display name of the campus branch.
  final String name;

  /// City or street description of the campus location.
  final String location;

  /// Whether this campus branch is open for student onboarding and ordering.
  final bool isActive;

  /// Returns a copy of this campus with updated fields.
  Campus copyWith({
    String? id,
    String? universityId,
    String? name,
    String? location,
    bool? isActive,
  }) {
    return Campus(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      name: name ?? this.name,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Serializes this campus to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'universityId': universityId,
      'name': name,
      'location': location,
      'isActive': isActive,
    };
  }

  /// Reconstructs a [Campus] from a JSON map.
  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'] as String,
      universityId: json['universityId'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, universityId, name, location, isActive];
}
