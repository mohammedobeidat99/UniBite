import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/core/utils/password_hasher.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

/// Hive-backed local implementation of [AuthRepository] for GP1.
///
/// Passwords are stored exclusively as salted SHA-256 hashes, and email
/// verification / password resets accept the simulated GP1 code `123456`.
class LocalAuthRepository implements AuthRepository {
  /// Creates a [LocalAuthRepository] backed by [_storage].
  LocalAuthRepository(this._storage, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LocalStorageService _storage;
  final Uuid _uuid;

  @override
  Stream<AppUser?> watchCurrentUser() => _storage.watchSessionUser();

  @override
  Future<AppUser?> getCurrentUser() async => _storage.getSessionUser();

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const AuthException(
        'Email and password are required.',
        code: 'missing_credentials',
      );
    }

    final matching = _storage
        .getUsers()
        .where((u) => u.email.toLowerCase() == normalizedEmail)
        .toList();

    if (matching.isEmpty) {
      throw const AuthException(
        'Invalid email or password.',
        code: 'invalid_credentials',
      );
    }

    final user = matching.first;
    if (!PasswordHasher.verifyPassword(password, user.passwordHash)) {
      throw const AuthException(
        'Invalid email or password.',
        code: 'invalid_credentials',
      );
    }

    if (!user.isActive) {
      throw const AuthException(
        'This account is deactivated. Please contact your administrator.',
        code: 'account_inactive',
      );
    }

    await _storage.setSessionUserId(user.id);
    return user;
  }

  @override
  Future<AppUser> registerStudent({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String verificationCode,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw const ValidationException('Full name is required.');
    }
    if (!normalizedEmail.contains('@')) {
      throw const ValidationException('Enter a valid university email.');
    }
    if (password.length < 6) {
      throw const ValidationException(
        'Password must be at least 6 characters long.',
      );
    }

    await verifyEmailCode(email: normalizedEmail, code: verificationCode);

    final exists = _storage.getUsers().any(
      (u) => u.email.toLowerCase() == normalizedEmail,
    );
    if (exists) {
      throw const AuthException(
        'An account with this email already exists.',
        code: 'email_already_exists',
      );
    }

    final newUser = AppUser(
      id: 'user_${_uuid.v4()}',
      name: trimmedName,
      email: normalizedEmail,
      passwordHash: PasswordHasher.hashPassword(password),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      role: UserRole.student,
      isActive: true,
    );

    await _storage.putUser(newUser);
    await _storage.setSessionUserId(newUser.id);
    return newUser;
  }

  @override
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    if (code.trim() != SeedData.demoVerificationCode) {
      throw const AuthException(
        'Invalid verification code. Use demo code 123456.',
        code: 'invalid_verification_code',
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    await verifyEmailCode(email: normalizedEmail, code: verificationCode);

    if (newPassword.length < 6) {
      throw const ValidationException(
        'New password must be at least 6 characters long.',
      );
    }

    final matching = _storage
        .getUsers()
        .where((u) => u.email.toLowerCase() == normalizedEmail)
        .toList();

    if (matching.isEmpty) {
      throw const AuthException(
        'No account found for this email address.',
        code: 'user_not_found',
      );
    }

    final updated = matching.first.copyWith(
      passwordHash: PasswordHasher.hashPassword(newPassword),
    );
    await _storage.putUser(updated);
  }

  @override
  Future<AppUser> updateStudentCampus({
    required String userId,
    required String universityId,
    required String campusId,
  }) async {
    final sessionUser = _storage.getSessionUser();
    if (sessionUser == null ||
        (sessionUser.id != userId &&
            sessionUser.role != UserRole.systemAdmin)) {
      throw const UnauthorizedAccessException(
        'You can only update your own campus selection.',
      );
    }

    final targetList = _storage
        .getUsers()
        .where((u) => u.id == userId)
        .toList();
    if (targetList.isEmpty) {
      throw const AuthException('User account not found.');
    }

    final target = targetList.first;
    if (target.role != UserRole.student) {
      throw const UnauthorizedAccessException(
        'Only student accounts select a campus during onboarding.',
      );
    }

    final campuses = _storage.getCampuses().where(
      (c) => c.id == campusId && c.universityId == universityId && c.isActive,
    );
    if (campuses.isEmpty) {
      throw const ValidationException(
        'Selected campus is inactive or does not belong to the selected university.',
      );
    }

    final updated = target.copyWith(
      universityId: universityId,
      campusId: campusId,
    );
    await _storage.putUser(updated);
    return updated;
  }

  @override
  Future<void> logout() async {
    await _storage.setSessionUserId(null);
  }

  @override
  Future<AppUser> debugSwitchRole(UserRole role, {String? cafeteriaId}) async {
    final users =
        _storage
            .getUsers()
            .where(
              (u) =>
                  u.role == role &&
                  u.isActive &&
                  (cafeteriaId == null || u.cafeteriaId == cafeteriaId),
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    if (users.isEmpty) {
      throw AuthException('No active demo user found for role ${role.name}.');
    }
    final chosen = users.first;
    await _storage.setSessionUserId(chosen.id);
    return chosen;
  }
}
