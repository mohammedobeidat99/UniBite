import 'package:equatable/equatable.dart';

/// Campus cafeteria vendor belonging to exactly one university and campus branch.
class Cafeteria extends Equatable {
  /// Creates an immutable [Cafeteria] record.
  const Cafeteria({
    required this.id,
    required this.universityId,
    required this.campusId,
    required this.name,
    required this.logo,
    required this.workingHours,
    required this.isActive,
    required this.ownerId,
    this.prepTimeMinutes = 15,
    this.orderTimeoutSeconds = 180,
  });

  /// Unique identifier for the cafeteria.
  final String id;

  /// Parent university identifier.
  final String universityId;

  /// Exact campus branch identifier where this cafeteria operates.
  final String campusId;

  /// Display name of the cafeteria.
  final String name;

  /// Asset path, URL, or encoded image string for the cafeteria logo.
  final String logo;

  /// Daily operating window in `HH:mm-HH:mm` 24-hour format (e.g., `08:00-18:00`).
  final String workingHours;

  /// Whether the cafeteria is approved and active on the platform.
  final bool isActive;

  /// Identifier of the Cafeteria Admin user who owns this cafeteria.
  final String ownerId;

  /// Estimated order preparation duration in minutes.
  final int prepTimeMinutes;

  /// Seconds before an unanswered pending order is automatically rejected.
  final int orderTimeoutSeconds;

  /// Whether this cafeteria is open at the given [time] based on [isActive] and [workingHours].
  ///
  /// Returns `false` if [isActive] is `false` or [workingHours] cannot be parsed.
  bool isOpenAt(DateTime time) {
    if (!isActive) return false;
    final parsed = parseWorkingHours(workingHours);
    if (parsed == null) return false;

    final currentMinutes = time.hour * 60 + time.minute;
    final startMinutes = parsed.$1;
    final endMinutes = parsed.$2;

    if (endMinutes >= startMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }
    // Handles overnight schedules (e.g., 20:00-02:00).
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  }

  /// Parses a `HH:mm-HH:mm` string into start and end minutes since midnight.
  ///
  /// Returns `null` when [hours] does not follow the expected format.
  static (int, int)? parseWorkingHours(String hours) {
    final parts = hours.trim().split('-');
    if (parts.length != 2) return null;

    final start = _parseTimeToMinutes(parts[0].trim());
    final end = _parseTimeToMinutes(parts[1].trim());
    if (start == null || end == null) return null;
    return (start, end);
  }

  static int? _parseTimeToMinutes(String hhMm) {
    final segments = hhMm.split(':');
    if (segments.length != 2) return null;
    final hour = int.tryParse(segments[0]);
    final minute = int.tryParse(segments[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  /// Returns a copy of this cafeteria with updated fields.
  Cafeteria copyWith({
    String? id,
    String? universityId,
    String? campusId,
    String? name,
    String? logo,
    String? workingHours,
    bool? isActive,
    String? ownerId,
    int? prepTimeMinutes,
    int? orderTimeoutSeconds,
  }) {
    return Cafeteria(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      campusId: campusId ?? this.campusId,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      orderTimeoutSeconds: orderTimeoutSeconds ?? this.orderTimeoutSeconds,
    );
  }

  /// Serializes this cafeteria into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'universityId': universityId,
      'campusId': campusId,
      'name': name,
      'logo': logo,
      'workingHours': workingHours,
      'isActive': isActive,
      'ownerId': ownerId,
      'prepTimeMinutes': prepTimeMinutes,
      'orderTimeoutSeconds': orderTimeoutSeconds,
    };
  }

  /// Reconstructs a [Cafeteria] from a JSON map.
  factory Cafeteria.fromJson(Map<String, dynamic> json) {
    return Cafeteria(
      id: json['id'] as String,
      universityId: json['universityId'] as String,
      campusId: json['campusId'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String? ?? 'assets/images/logo.jpg',
      workingHours: json['workingHours'] as String? ?? '08:00-18:00',
      isActive: json['isActive'] as bool? ?? true,
      ownerId: json['ownerId'] as String,
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      orderTimeoutSeconds:
          (json['orderTimeoutSeconds'] as num?)?.toInt() ?? 180,
    );
  }

  @override
  List<Object?> get props => [
    id,
    universityId,
    campusId,
    name,
    logo,
    workingHours,
    isActive,
    ownerId,
    prepTimeMinutes,
    orderTimeoutSeconds,
  ];
}
