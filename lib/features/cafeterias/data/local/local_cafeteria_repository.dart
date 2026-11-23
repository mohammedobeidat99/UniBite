import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/errors/app_exceptions.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/cafeterias/domain/repositories/cafeteria_repository.dart';

/// Hive-backed local implementation of [CafeteriaRepository].
class LocalCafeteriaRepository implements CafeteriaRepository {
  /// Creates a [LocalCafeteriaRepository] backed by [_storage].
  LocalCafeteriaRepository(this._storage);

  final LocalStorageService _storage;

  @override
  Stream<List<Cafeteria>> watchCafeterias({
    String? campusId,
    bool activeOnly = false,
  }) {
    return _storage.watchCafeterias().map(
      (items) => items.where((cafeteria) {
        if (campusId != null && cafeteria.campusId != campusId) {
          return false;
        }
        if (activeOnly && !cafeteria.isActive) return false;
        return true;
      }).toList(),
    );
  }

  @override
  Stream<Cafeteria?> watchCafeteriaById(String id) {
    return _storage.watchCafeterias().map((items) {
      for (final item in items) {
        if (item.id == id) return item;
      }
      return null;
    });
  }

  @override
  Future<Cafeteria?> getCafeteriaById(String id) async {
    for (final item in _storage.getCafeterias()) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Cafeteria> saveCafeteria(
    Cafeteria cafeteria, {
    required AppUser actor,
  }) async {
    if (actor.role != UserRole.systemAdmin || !actor.isActive) {
      throw const UnauthorizedAccessException(
        'Only active System Admins can create or reassign cafeterias.',
      );
    }
    if (cafeteria.name.trim().isEmpty) {
      throw const ValidationException('Cafeteria name cannot be empty.');
    }
    if (Cafeteria.parseWorkingHours(cafeteria.workingHours) == null) {
      throw const ValidationException(
        'Working hours must follow HH:mm-HH:mm format.',
      );
    }
    final campusMatches = _storage.getCampuses().where(
      (c) =>
          c.id == cafeteria.campusId &&
          c.universityId == cafeteria.universityId,
    );
    if (campusMatches.isEmpty) {
      throw const ValidationException(
        'Each cafeteria must belong to exactly one valid campus branch.',
      );
    }

    final sanitized = cafeteria.copyWith(name: cafeteria.name.trim());
    await _storage.putCafeteria(sanitized);
    return sanitized;
  }

  @override
  Future<Cafeteria> setCafeteriaActive({
    required String id,
    required bool isActive,
    required AppUser actor,
  }) async {
    if (actor.role != UserRole.systemAdmin || !actor.isActive) {
      throw const UnauthorizedAccessException(
        'Only active System Admins can approve or suspend cafeterias.',
      );
    }
    final existing = await getCafeteriaById(id);
    if (existing == null) {
      throw const ValidationException('Cafeteria not found.');
    }
    final updated = existing.copyWith(isActive: isActive);
    await _storage.putCafeteria(updated);
    return updated;
  }

  @override
  Future<Cafeteria> updateWorkingHours({
    required String cafeteriaId,
    required String workingHours,
    int? prepTimeMinutes,
    int? orderTimeoutSeconds,
    required AppUser actor,
  }) async {
    final isSystemAdmin = actor.role == UserRole.systemAdmin;
    final isOwningAdmin =
        actor.role == UserRole.cafeteriaAdmin &&
        actor.cafeteriaId == cafeteriaId;
    if (!actor.isActive || (!isSystemAdmin && !isOwningAdmin)) {
      throw const UnauthorizedAccessException(
        'Only the Cafeteria Admin of this cafeteria can update operating hours.',
      );
    }

    if (Cafeteria.parseWorkingHours(workingHours) == null) {
      throw const ValidationException(
        'Working hours must follow HH:mm-HH:mm format.',
      );
    }
    if (prepTimeMinutes != null && prepTimeMinutes <= 0) {
      throw const ValidationException('Prep time must be positive.');
    }
    if (orderTimeoutSeconds != null && orderTimeoutSeconds < 30) {
      throw const ValidationException(
        'Auto-reject timeout must be at least 30 seconds.',
      );
    }

    final existing = await getCafeteriaById(cafeteriaId);
    if (existing == null) {
      throw const ValidationException('Cafeteria not found.');
    }

    final updated = existing.copyWith(
      workingHours: workingHours.trim(),
      prepTimeMinutes: prepTimeMinutes ?? existing.prepTimeMinutes,
      orderTimeoutSeconds: orderTimeoutSeconds ?? existing.orderTimeoutSeconds,
    );
    await _storage.putCafeteria(updated);
    return updated;
  }
}
