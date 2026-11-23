/// Channel through which a cafeteria order originated.
enum OrderType {
  /// Order placed by a student via the mobile application.
  app('app'),

  /// Manual walk-in order entered directly at the cafeteria counter.
  walkin('walkin');

  /// Creates an [OrderType] mapped to [storageKey].
  const OrderType(this.storageKey);

  /// Stable string key persisted in storage.
  final String storageKey;

  /// Parses [value] into a matching [OrderType].
  ///
  /// Throws an [ArgumentError] if [value] is not recognized.
  static OrderType fromStorageKey(String value) {
    return OrderType.values.firstWhere(
      (type) => type.storageKey == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown order type'),
    );
  }
}
