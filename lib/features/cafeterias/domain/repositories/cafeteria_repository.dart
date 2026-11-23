/// @docImport 'package:unibite/core/errors/app_exceptions.dart';
library;

import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';

/// Contract for querying and managing campus cafeterias and their operating hours.
abstract class CafeteriaRepository {
  /// Watches cafeterias, optionally filtered by [campusId] and [activeOnly].
  Stream<List<Cafeteria>> watchCafeterias({
    String? campusId,
    bool activeOnly = false,
  });

  /// Watches a single cafeteria identified by [id], emitting `null` if absent.
  Stream<Cafeteria?> watchCafeteriaById(String id);

  /// Fetches a single cafeteria by [id], or `null` if not found.
  Future<Cafeteria?> getCafeteriaById(String id);

  /// Creates or updates a [cafeteria] record on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<Cafeteria> saveCafeteria(
    Cafeteria cafeteria, {
    required AppUser actor,
  });

  /// Sets the active/approval flag of cafeteria [id] to [isActive].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<Cafeteria> setCafeteriaActive({
    required String id,
    required bool isActive,
    required AppUser actor,
  });

  /// Updates [workingHours], optional [prepTimeMinutes], and optional [orderTimeoutSeconds]
  /// for [cafeteriaId].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not the Cafeteria Admin
  /// assigned to [cafeteriaId] (or a System Admin).
  Future<Cafeteria> updateWorkingHours({
    required String cafeteriaId,
    required String workingHours,
    int? prepTimeMinutes,
    int? orderTimeoutSeconds,
    required AppUser actor,
  });
}
