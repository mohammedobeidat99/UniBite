import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/utils/password_hasher.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/users/domain/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

/// Hive-backed local implementation of [UserRepository].
class LocalUserRepository implements UserRepository {
  /// Creates a [LocalUserRepository] backed by [_storage].
  LocalUserRepository(this._storage, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LocalStorageService _storage;
  final Uuid _uuid;

  @override
  Stream<List<AppUser>> watchUsers({UserRole? role, String? cafeteriaId}) {
    return _storage.watchUsers().map(
      (users) => _filter(users, role: role, cafeteriaId: cafeteriaId),
    );
  }

  @override
  Future<List<AppUser>> getUsers({UserRole? role, String? cafeteriaId}) async {
    return _filter(_storage.getUsers(), role: role, cafeteriaId: cafeteriaId);
  }

  @override
  Future<AppUser> createCafeteriaAdmin({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String universityId,
    required String campusId,
    String? cafeteriaId,
    required AppUser actor,
  }) async {
    if (!actor.isActive || actor.role != UserRole.systemAdmin) {
      throw const UnauthorizedAccessException(
        'Only System Admins can create and approve Cafeteria Admin accounts.',
      );
    }
    return _createUser(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: UserRole.cafeteriaAdmin,
      universityId: universityId,
      campusId: campusId,
      cafeteriaId: cafeteriaId,
    );
  }

  @override
  Future<AppUser> createCafeteriaStaff({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String cafeteriaId,
    required AppUser actor,
  }) async {
    final isSystemAdmin = actor.role == UserRole.systemAdmin;
    final isOwningAdmin =
        actor.role == UserRole.cafeteriaAdmin &&
        actor.cafeteriaId == cafeteriaId;
    if (!actor.isActive || (!isSystemAdmin && !isOwningAdmin)) {
      throw const UnauthorizedAccessException(
        'Only the Cafeteria Admin of this cafeteria can create staff accounts.',
      );
    }

    final cafeMatches = _storage
        .getCafeterias()
        .where((c) => c.id == cafeteriaId)
        .toList();
    if (cafeMatches.isEmpty) {
      throw const ValidationException('Cafeteria not found.');
    }
    final cafe = cafeMatches.first;

    return _createUser(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: UserRole.cafeteriaStaff,
      universityId: cafe.universityId,
      campusId: cafe.campusId,
      cafeteriaId: cafeteriaId,
    );
  }

  @override
  Future<AppUser> setUserActive({
    required String userId,
    required bool isActive,
    required AppUser actor,
  }) async {
    final matching = _storage.getUsers().where((u) => u.id == userId).toList();
    if (matching.isEmpty) {
      throw const ValidationException('User not found.');
    }
    final target = matching.first;

    final isSystemAdmin = actor.role == UserRole.systemAdmin;
    final isOwningAdminForStaff =
        actor.role == UserRole.cafeteriaAdmin &&
        target.role == UserRole.cafeteriaStaff &&
        target.cafeteriaId == actor.cafeteriaId;

    if (!actor.isActive || (!isSystemAdmin && !isOwningAdminForStaff)) {
      throw const UnauthorizedAccessException(
        'You do not have permission to change this user status.',
      );
    }

    if (target.id == actor.id && !isActive) {
      throw const ValidationException(
        'You cannot deactivate your own active administrator session.',
      );
    }

    final updated = target.copyWith(isActive: isActive);
    await _storage.putUser(updated);
    return updated;
  }

  @override
  Future<AppUser> assignCafeteriaToOwner({
    required String userId,
    required String cafeteriaId,
    required AppUser actor,
  }) async {
    if (!actor.isActive || actor.role != UserRole.systemAdmin) {
      throw const UnauthorizedAccessException(
        'Only System Admins can assign cafeteria ownership.',
      );
    }
    final matching = _storage.getUsers().where((u) => u.id == userId).toList();
    if (matching.isEmpty) {
      throw const ValidationException('Owner account not found.');
    }
    final updated = matching.first.copyWith(cafeteriaId: cafeteriaId);
    await _storage.putUser(updated);
    return updated;
  }

  Future<AppUser> _createUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    required UserRole role,
    String? universityId,
    String? campusId,
    String? cafeteriaId,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw const ValidationException('Full name is required.');
    }
    if (!normalizedEmail.contains('@')) {
      throw const ValidationException('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw const ValidationException(
        'Password must be at least 6 characters long.',
      );
    }

    final exists = _storage.getUsers().any(
      (u) => u.email.toLowerCase() == normalizedEmail,
    );
    if (exists) {
      throw const ValidationException('A user with this email already exists.');
    }

    final created = AppUser(
      id: 'user_${_uuid.v4()}',
      name: trimmedName,
      email: normalizedEmail,
      passwordHash: PasswordHasher.hashPassword(password),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      role: role,
      universityId: universityId,
      campusId: campusId,
      cafeteriaId: cafeteriaId,
      isActive: true,
    );
    await _storage.putUser(created);
    return created;
  }

  List<AppUser> _filter(
    List<AppUser> users, {
    UserRole? role,
    String? cafeteriaId,
  }) {
    return users.where((user) {
      if (role != null && user.role != role) return false;
      if (cafeteriaId != null && user.cafeteriaId != cafeteriaId) return false;
      return true;
    }).toList();
  }
}
