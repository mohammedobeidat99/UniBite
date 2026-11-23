/// @docImport 'package:unibite/core/errors/app_exceptions.dart';
library;

import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';

/// Contract for administrative user management across System Admin and Cafeteria Admin scopes.
abstract class UserRepository {
  /// Watches users, optionally filtered by [role] and/or [cafeteriaId].
  Stream<List<AppUser>> watchUsers({UserRole? role, String? cafeteriaId});

  /// Fetches users, optionally filtered by [role] and/or [cafeteriaId].
  Future<List<AppUser>> getUsers({UserRole? role, String? cafeteriaId});

  /// Creates an approved Cafeteria Admin account on behalf of System Admin [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<AppUser> createCafeteriaAdmin({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String universityId,
    required String campusId,
    String? cafeteriaId,
    required AppUser actor,
  });

  /// Creates a Cafeteria Staff account scoped to [cafeteriaId] on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not the Cafeteria Admin
  /// for [cafeteriaId] (or a System Admin).
  Future<AppUser> createCafeteriaStaff({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String cafeteriaId,
    required AppUser actor,
  });

  /// Activates or deactivates [userId] on behalf of [actor].
  ///
  /// System Admins may toggle any account; Cafeteria Admins may only toggle staff
  /// accounts belonging to their own cafeteria.
  Future<AppUser> setUserActive({
    required String userId,
    required bool isActive,
    required AppUser actor,
  });

  /// Assigns [cafeteriaId] to owner [userId] on behalf of System Admin [actor].
  Future<AppUser> assignCafeteriaToOwner({
    required String userId,
    required String cafeteriaId,
    required AppUser actor,
  });
}
