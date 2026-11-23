import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';
import 'package:unibite/features/universities/domain/repositories/university_repository.dart';

/// Hive-backed local implementation of [UniversityRepository].
class LocalUniversityRepository implements UniversityRepository {
  /// Creates a [LocalUniversityRepository] backed by [_storage].
  LocalUniversityRepository(this._storage);

  final LocalStorageService _storage;

  @override
  Stream<List<University>> watchUniversities({bool activeOnly = false}) {
    return _storage.watchUniversities().map(
      (items) => activeOnly ? items.where((u) => u.isActive).toList() : items,
    );
  }

  @override
  Future<List<University>> getUniversities({bool activeOnly = false}) async {
    final items = _storage.getUniversities();
    return activeOnly ? items.where((u) => u.isActive).toList() : items;
  }

  @override
  Future<University> saveUniversity(
    University university, {
    required AppUser actor,
  }) async {
    _requireSystemAdmin(actor);
    if (university.name.trim().isEmpty) {
      throw const ValidationException('University name cannot be empty.');
    }
    final sanitized = university.copyWith(name: university.name.trim());
    await _storage.putUniversity(sanitized);
    return sanitized;
  }

  @override
  Future<University> setUniversityActive({
    required String id,
    required bool isActive,
    required AppUser actor,
  }) async {
    _requireSystemAdmin(actor);
    final match = _storage.getUniversities().where((u) => u.id == id).toList();
    if (match.isEmpty) {
      throw const ValidationException('University not found.');
    }
    final updated = match.first.copyWith(isActive: isActive);
    await _storage.putUniversity(updated);
    return updated;
  }

  @override
  Stream<List<Campus>> watchCampuses({
    String? universityId,
    bool activeOnly = false,
  }) {
    return _storage.watchCampuses().map(
      (items) => _filterCampuses(
        items,
        universityId: universityId,
        activeOnly: activeOnly,
      ),
    );
  }

  @override
  Future<List<Campus>> getCampuses({
    String? universityId,
    bool activeOnly = false,
  }) async {
    return _filterCampuses(
      _storage.getCampuses(),
      universityId: universityId,
      activeOnly: activeOnly,
    );
  }

  @override
  Future<Campus> saveCampus(Campus campus, {required AppUser actor}) async {
    _requireSystemAdmin(actor);
    if (campus.name.trim().isEmpty || campus.location.trim().isEmpty) {
      throw const ValidationException('Campus name and location are required.');
    }
    final uniExists = _storage.getUniversities().any(
      (u) => u.id == campus.universityId,
    );
    if (!uniExists) {
      throw const ValidationException('Parent university does not exist.');
    }
    final sanitized = campus.copyWith(
      name: campus.name.trim(),
      location: campus.location.trim(),
    );
    await _storage.putCampus(sanitized);
    return sanitized;
  }

  @override
  Future<Campus> setCampusActive({
    required String id,
    required bool isActive,
    required AppUser actor,
  }) async {
    _requireSystemAdmin(actor);
    final match = _storage.getCampuses().where((c) => c.id == id).toList();
    if (match.isEmpty) {
      throw const ValidationException('Campus not found.');
    }
    final updated = match.first.copyWith(isActive: isActive);
    await _storage.putCampus(updated);
    return updated;
  }

  List<Campus> _filterCampuses(
    List<Campus> items, {
    String? universityId,
    required bool activeOnly,
  }) {
    return items.where((campus) {
      if (universityId != null && campus.universityId != universityId) {
        return false;
      }
      if (activeOnly && !campus.isActive) return false;
      return true;
    }).toList();
  }

  void _requireSystemAdmin(AppUser actor) {
    if (actor.role != UserRole.systemAdmin || !actor.isActive) {
      throw const UnauthorizedAccessException(
        'Only active System Admins can manage universities and campuses.',
      );
    }
  }
}
