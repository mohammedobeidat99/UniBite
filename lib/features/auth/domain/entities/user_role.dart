/// Role assigned to each authenticated user in UniBite.
///
/// Each account holds exactly one role stored in `AppUser.role`.
enum UserRole {
  /// University student ordering food via the mobile interface.
  student('student'),

  /// Cafeteria owner managing menu, working hours, staff, and live orders.
  cafeteriaAdmin('cafeteriaAdmin'),

  /// Cashier or kitchen operator handling orders and QR pickup verification.
  cafeteriaStaff('cafeteriaStaff'),

  /// Platform administrator managing universities, campuses, cafeterias, and users.
  systemAdmin('systemAdmin');

  /// Creates a role enum value with its serialized [storageKey].
  const UserRole(this.storageKey);

  /// Stable string identifier persisted in local or remote storage.
  final String storageKey;

  /// Parses a persisted [value] into a matching [UserRole].
  ///
  /// Throws an [ArgumentError] if [value] does not match any known role.
  static UserRole fromStorageKey(String value) {
    return UserRole.values.firstWhere(
      (role) => role.storageKey == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown user role'),
    );
  }
}
