import 'package:equatable/equatable.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';

/// Authenticated user profile stored locally or in a remote identity provider.
class AppUser extends Equatable {
  /// Creates an immutable [AppUser] record.
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.phone,
    required this.role,
    this.universityId,
    this.campusId,
    this.cafeteriaId,
    required this.isActive,
  });

  /// Unique identifier for the user.
  final String id;

  /// Full display name of the user.
  final String name;

  /// University or organizational email address used for login.
  final String email;

  /// Salted cryptographic hash of the user's password.
  final String passwordHash;

  /// Optional mobile contact number.
  final String? phone;

  /// Single role assigned to this user.
  final UserRole role;

  /// Selected university identifier for students or scoped admins.
  final String? universityId;

  /// Selected campus branch identifier for students or scoped admins.
  final String? campusId;

  /// Assigned cafeteria identifier when [role] is admin or staff.
  final String? cafeteriaId;

  /// Whether the account is enabled and permitted to sign in.
  final bool isActive;

  /// Whether the student has selected both a university and a campus branch.
  bool get hasCompletedOnboarding =>
      role != UserRole.student || (universityId != null && campusId != null);

  /// Returns a copy of this user with the provided fields replaced.
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    bool clearPhone = false,
    UserRole? role,
    String? universityId,
    bool clearUniversityId = false,
    String? campusId,
    bool clearCampusId = false,
    String? cafeteriaId,
    bool clearCafeteriaId = false,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: clearPhone ? null : (phone ?? this.phone),
      role: role ?? this.role,
      universityId: clearUniversityId
          ? null
          : (universityId ?? this.universityId),
      campusId: clearCampusId ? null : (campusId ?? this.campusId),
      cafeteriaId: clearCafeteriaId ? null : (cafeteriaId ?? this.cafeteriaId),
      isActive: isActive ?? this.isActive,
    );
  }

  /// Serializes this user into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'phone': phone,
      'role': role.storageKey,
      'universityId': universityId,
      'campusId': campusId,
      'cafeteriaId': cafeteriaId,
      'isActive': isActive,
    };
  }

  /// Reconstructs an [AppUser] from a JSON map.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromStorageKey(json['role'] as String),
      universityId: json['universityId'] as String?,
      campusId: json['campusId'] as String?,
      cafeteriaId: json['cafeteriaId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    passwordHash,
    phone,
    role,
    universityId,
    campusId,
    cafeteriaId,
    isActive,
  ];
}
