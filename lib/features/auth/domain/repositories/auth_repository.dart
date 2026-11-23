/// @docImport 'package:unibite/core/errors/app_exceptions.dart';
library;

import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';

/// Contract for authentication, student registration, password reset, and session state.
///
/// Implementations may read from local Hive storage during GP1 or Firebase Auth
/// in GP2 without affecting presentation or domain layers.
abstract class AuthRepository {
  /// Watches the currently signed-in user, emitting `null` when signed out.
  Stream<AppUser?> watchCurrentUser();

  /// Returns the currently signed-in user, or `null` if no session exists.
  Future<AppUser?> getCurrentUser();

  /// Authenticates an active account matching [email] and [password].
  ///
  /// Throws an [AuthException] if credentials are invalid or the account is inactive.
  Future<AppUser> login({required String email, required String password});

  /// Registers a new student account after validating [verificationCode].
  ///
  /// Throws an [AuthException] if [email] is already registered or [verificationCode]
  /// is invalid.
  Future<AppUser> registerStudent({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String verificationCode,
  });

  /// Verifies the simulated email confirmation [code] for [email].
  ///
  /// Throws an [AuthException] if [code] does not match the expected demo code.
  Future<void> verifyEmailCode({required String email, required String code});

  /// Resets the password for [email] to [newPassword] using [verificationCode].
  ///
  /// Throws an [AuthException] if [email] is not found or [verificationCode] fails.
  Future<void> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  });

  /// Updates the university and campus branch selected by a student with [userId].
  ///
  /// Throws an [UnauthorizedAccessException] if the caller does not own [userId].
  Future<AppUser> updateStudentCampus({
    required String userId,
    required String universityId,
    required String campusId,
  });

  /// Signs out the current user and clears the active local session.
  Future<void> logout();

  /// Switches the active demo session directly to a seeded user matching [role].
  ///
  /// Intended exclusively for debug and GP1 single-device demonstration mode.
  Future<AppUser> debugSwitchRole(UserRole role, {String? cafeteriaId});
}
