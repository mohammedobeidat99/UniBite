/// @docImport 'package:unibite/core/errors/app_exceptions.dart';
library;

import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';

/// Contract for reading and administering universities and campus branches.
abstract class UniversityRepository {
  /// Watches all universities, optionally filtering to active ones when [activeOnly] is `true`.
  Stream<List<University>> watchUniversities({bool activeOnly = false});

  /// Fetches all universities, optionally filtering to active ones when [activeOnly] is `true`.
  Future<List<University>> getUniversities({bool activeOnly = false});

  /// Creates or updates a [university] record on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<University> saveUniversity(
    University university, {
    required AppUser actor,
  });

  /// Updates the active status of a university identified by [id] to [isActive].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<University> setUniversityActive({
    required String id,
    required bool isActive,
    required AppUser actor,
  });

  /// Watches campus branches, optionally filtered by [universityId] and [activeOnly].
  Stream<List<Campus>> watchCampuses({
    String? universityId,
    bool activeOnly = false,
  });

  /// Fetches campus branches, optionally filtered by [universityId] and [activeOnly].
  Future<List<Campus>> getCampuses({
    String? universityId,
    bool activeOnly = false,
  });

  /// Creates or updates a [campus] branch on behalf of [actor].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<Campus> saveCampus(Campus campus, {required AppUser actor});

  /// Updates the active status of a campus identified by [id] to [isActive].
  ///
  /// Throws an [UnauthorizedAccessException] if [actor] is not a System Admin.
  Future<Campus> setCampusActive({
    required String id,
    required bool isActive,
    required AppUser actor,
  });
}
