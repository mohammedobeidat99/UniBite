import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:unibite/core/database/seed_data.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/universities/domain/entities/campus.dart';
import 'package:unibite/features/universities/domain/entities/university.dart';

/// Local Hive persistence manager emitting reactive collection streams.
///
/// Mirrors real-time Firestore collection listeners so local repositories behave
/// identically to a reactive backend during GP1.
class LocalStorageService {
  /// Creates a [LocalStorageService] backed by already opened or lazily opened Hive boxes.
  LocalStorageService();

  static const String _usersBoxName = 'unibite_users';
  static const String _universitiesBoxName = 'unibite_universities';
  static const String _campusesBoxName = 'unibite_campuses';
  static const String _cafeteriasBoxName = 'unibite_cafeterias';
  static const String _mealsBoxName = 'unibite_meals';
  static const String _ordersBoxName = 'unibite_orders';
  static const String _metaBoxName = 'unibite_meta';

  static const String _sessionUserIdKey = 'session_user_id';
  static const String _localeCodeKey = 'locale_code';
  static const String _seededFlagKey = 'is_seeded';
  static const String _introSeenKey = 'intro_seen';

  late final Box<dynamic> _usersBox;
  late final Box<dynamic> _universitiesBox;
  late final Box<dynamic> _campusesBox;
  late final Box<dynamic> _cafeteriasBox;
  late final Box<dynamic> _mealsBox;
  late final Box<dynamic> _ordersBox;
  late final Box<dynamic> _metaBox;

  final StreamController<List<AppUser>> _usersController =
      StreamController<List<AppUser>>.broadcast();
  final StreamController<List<University>> _universitiesController =
      StreamController<List<University>>.broadcast();
  final StreamController<List<Campus>> _campusesController =
      StreamController<List<Campus>>.broadcast();
  final StreamController<List<Cafeteria>> _cafeteriasController =
      StreamController<List<Cafeteria>>.broadcast();
  final StreamController<List<Meal>> _mealsController =
      StreamController<List<Meal>>.broadcast();
  final StreamController<List<Order>> _ordersController =
      StreamController<List<Order>>.broadcast();
  final StreamController<AppUser?> _sessionController =
      StreamController<AppUser?>.broadcast();

  bool _initialized = false;

  /// Initializes Hive, opens all boxes, and seeds initial GP1 data if empty.
  ///
  /// When [testDirectoryPath] is provided (for unit tests), Hive uses that folder
  /// instead of `Hive.initFlutter()`.
  Future<void> init({String? testDirectoryPath}) async {
    if (_initialized) return;

    if (testDirectoryPath != null) {
      Hive.init(testDirectoryPath);
    } else {
      await Hive.initFlutter();
    }

    _usersBox = Hive.isBoxOpen(_usersBoxName)
        ? Hive.box<dynamic>(_usersBoxName)
        : await Hive.openBox<dynamic>(_usersBoxName);
    _universitiesBox = Hive.isBoxOpen(_universitiesBoxName)
        ? Hive.box<dynamic>(_universitiesBoxName)
        : await Hive.openBox<dynamic>(_universitiesBoxName);
    _campusesBox = Hive.isBoxOpen(_campusesBoxName)
        ? Hive.box<dynamic>(_campusesBoxName)
        : await Hive.openBox<dynamic>(_campusesBoxName);
    _cafeteriasBox = Hive.isBoxOpen(_cafeteriasBoxName)
        ? Hive.box<dynamic>(_cafeteriasBoxName)
        : await Hive.openBox<dynamic>(_cafeteriasBoxName);
    _mealsBox = Hive.isBoxOpen(_mealsBoxName)
        ? Hive.box<dynamic>(_mealsBoxName)
        : await Hive.openBox<dynamic>(_mealsBoxName);
    _ordersBox = Hive.isBoxOpen(_ordersBoxName)
        ? Hive.box<dynamic>(_ordersBoxName)
        : await Hive.openBox<dynamic>(_ordersBoxName);
    _metaBox = Hive.isBoxOpen(_metaBoxName)
        ? Hive.box<dynamic>(_metaBoxName)
        : await Hive.openBox<dynamic>(_metaBoxName);

    _initialized = true;

    final alreadySeeded = _metaBox.get(_seededFlagKey) == true;
    if (!alreadySeeded || _usersBox.isEmpty) {
      await resetAndReseed();
    } else {
      _emitAll();
    }
  }

  /// Clears all Hive boxes and restores deterministic GP1 seed data.
  Future<void> resetAndReseed() async {
    await Future.wait([
      _usersBox.clear(),
      _universitiesBox.clear(),
      _campusesBox.clear(),
      _cafeteriasBox.clear(),
      _mealsBox.clear(),
      _ordersBox.clear(),
    ]);

    for (final university in SeedData.universities()) {
      await _universitiesBox.put(university.id, university.toJson());
    }
    for (final campus in SeedData.campuses()) {
      await _campusesBox.put(campus.id, campus.toJson());
    }
    for (final cafeteria in SeedData.cafeterias()) {
      await _cafeteriasBox.put(cafeteria.id, cafeteria.toJson());
    }
    for (final meal in SeedData.meals()) {
      await _mealsBox.put(meal.id, meal.toJson());
    }
    for (final user in SeedData.users()) {
      await _usersBox.put(user.id, user.toJson());
    }
    for (final order in SeedData.orders()) {
      await _ordersBox.put(order.id, order.toJson());
    }

    await _metaBox.delete(_sessionUserIdKey);
    await _metaBox.put(_seededFlagKey, true);
    _emitAll();
  }

  /// Releases all stream controllers and closes opened Hive boxes.
  Future<void> dispose() async {
    unawaited(_usersController.close());
    unawaited(_universitiesController.close());
    unawaited(_campusesController.close());
    unawaited(_cafeteriasController.close());
    unawaited(_mealsController.close());
    unawaited(_ordersController.close());
    unawaited(_sessionController.close());
    try {
      await Hive.close().timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {},
      );
    } catch (_) {}
    _initialized = false;
  }

  // ---------------------------------------------------------------------------
  // Locale & Session Metadata
  // ---------------------------------------------------------------------------

  /// Currently stored locale code (`'en'` or `'ar'`).
  String getLocaleCode() => (_metaBox.get(_localeCodeKey) as String?) ?? 'en';

  /// Persists the preferred [localeCode] (`'en'` or `'ar'`).
  Future<void> setLocaleCode(String localeCode) async {
    await _metaBox.put(_localeCodeKey, localeCode);
  }

  /// Whether the first-launch 3-slide intro onboarding has been completed or skipped.
  bool getIntroSeen() => _metaBox.get(_introSeenKey) == true;

  /// Marks the 3-slide intro onboarding as [seen].
  Future<void> setIntroSeen(bool seen) async {
    await _metaBox.put(_introSeenKey, seen);
  }

  /// Returns the currently signed-in [AppUser], or `null` when signed out.
  AppUser? getSessionUser() {
    final userId = _metaBox.get(_sessionUserIdKey) as String?;
    if (userId == null) return null;
    final raw = _usersBox.get(userId);
    if (raw == null) return null;
    return AppUser.fromJson(_toJsonMap(raw));
  }

  /// Watches the active [AppUser] session, immediately emitting current state.
  Stream<AppUser?> watchSessionUser() async* {
    yield getSessionUser();
    yield* _sessionController.stream;
  }

  /// Sets the active session to [userId], or clears it when `null`.
  Future<void> setSessionUserId(String? userId) async {
    if (userId == null) {
      await _metaBox.delete(_sessionUserIdKey);
    } else {
      await _metaBox.put(_sessionUserIdKey, userId);
    }
    _sessionController.add(getSessionUser());
  }

  // ---------------------------------------------------------------------------
  // Collection Getters, Watchers & Writers
  // ---------------------------------------------------------------------------

  /// Returns all stored [AppUser] records.
  List<AppUser> getUsers() =>
      _usersBox.values.map((raw) => AppUser.fromJson(_toJsonMap(raw))).toList();

  /// Watches all [AppUser] records with an initial synchronous emission.
  Stream<List<AppUser>> watchUsers() async* {
    yield getUsers();
    yield* _usersController.stream;
  }

  /// Inserts or updates [user] and notifies user and session streams.
  Future<void> putUser(AppUser user) async {
    await _usersBox.put(user.id, user.toJson());
    _usersController.add(getUsers());
    if (_metaBox.get(_sessionUserIdKey) == user.id) {
      _sessionController.add(user.isActive ? user : null);
      if (!user.isActive) {
        await _metaBox.delete(_sessionUserIdKey);
      }
    }
  }

  /// Returns all stored [University] records.
  List<University> getUniversities() => _universitiesBox.values
      .map((raw) => University.fromJson(_toJsonMap(raw)))
      .toList();

  /// Watches all [University] records with an initial emission.
  Stream<List<University>> watchUniversities() async* {
    yield getUniversities();
    yield* _universitiesController.stream;
  }

  /// Inserts or updates [university] and emits updated universities.
  Future<void> putUniversity(University university) async {
    await _universitiesBox.put(university.id, university.toJson());
    _universitiesController.add(getUniversities());
  }

  /// Returns all stored [Campus] records.
  List<Campus> getCampuses() => _campusesBox.values
      .map((raw) => Campus.fromJson(_toJsonMap(raw)))
      .toList();

  /// Watches all [Campus] records with an initial emission.
  Stream<List<Campus>> watchCampuses() async* {
    yield getCampuses();
    yield* _campusesController.stream;
  }

  /// Inserts or updates [campus] and emits updated campuses.
  Future<void> putCampus(Campus campus) async {
    await _campusesBox.put(campus.id, campus.toJson());
    _campusesController.add(getCampuses());
  }

  /// Returns all stored [Cafeteria] records.
  List<Cafeteria> getCafeterias() => _cafeteriasBox.values
      .map((raw) => Cafeteria.fromJson(_toJsonMap(raw)))
      .toList();

  /// Watches all [Cafeteria] records with an initial emission.
  Stream<List<Cafeteria>> watchCafeterias() async* {
    yield getCafeterias();
    yield* _cafeteriasController.stream;
  }

  /// Inserts or updates [cafeteria] and emits updated cafeterias.
  Future<void> putCafeteria(Cafeteria cafeteria) async {
    await _cafeteriasBox.put(cafeteria.id, cafeteria.toJson());
    _cafeteriasController.add(getCafeterias());
  }

  /// Returns all stored [Meal] records.
  List<Meal> getMeals() =>
      _mealsBox.values.map((raw) => Meal.fromJson(_toJsonMap(raw))).toList();

  /// Watches all [Meal] records with an initial emission.
  Stream<List<Meal>> watchMeals() async* {
    yield getMeals();
    yield* _mealsController.stream;
  }

  /// Inserts or updates [meal] and emits updated meals.
  Future<void> putMeal(Meal meal) async {
    await _mealsBox.put(meal.id, meal.toJson());
    _mealsController.add(getMeals());
  }

  /// Removes the meal identified by [mealId] and emits updated meals.
  Future<void> deleteMeal(String mealId) async {
    await _mealsBox.delete(mealId);
    _mealsController.add(getMeals());
  }

  /// Returns all stored [Order] records sorted newest first.
  List<Order> getOrders() {
    final orders = _ordersBox.values
        .map((raw) => Order.fromJson(_toJsonMap(raw)))
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// Watches all [Order] records sorted newest first.
  Stream<List<Order>> watchOrders() async* {
    yield getOrders();
    yield* _ordersController.stream;
  }

  /// Inserts or updates [order] and emits updated orders.
  Future<void> putOrder(Order order) async {
    await _ordersBox.put(order.id, order.toJson());
    _ordersController.add(getOrders());
  }

  void _emitAll() {
    _universitiesController.add(getUniversities());
    _campusesController.add(getCampuses());
    _cafeteriasController.add(getCafeterias());
    _mealsController.add(getMeals());
    _usersController.add(getUsers());
    _ordersController.add(getOrders());
    _sessionController.add(getSessionUser());
  }

  Map<String, dynamic> _toJsonMap(dynamic raw) {
    final map = Map<dynamic, dynamic>.from(raw as Map);
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _toJsonMap(value));
      }
      if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e is Map ? _toJsonMap(e) : e).toList(),
        );
      }
      return MapEntry(key.toString(), value);
    });
  }
}
