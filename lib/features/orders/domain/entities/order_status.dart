/// Lifecycle states shared across student, cafeteria, and auto-reject workflows.
enum OrderStatus {
  /// Newly placed order awaiting cafeteria acceptance or rejection.
  pending('pending'),

  /// Order accepted by cafeteria staff and queued for preparation.
  accepted('accepted'),

  /// Order actively being cooked or assembled in the kitchen.
  preparing('preparing'),

  /// Order packed and waiting at the counter for student pickup.
  ready('ready'),

  /// Order handed over to the student and paid in cash.
  completed('completed'),

  /// Order declined by the cafeteria or automatically rejected after timeout.
  rejected('rejected'),

  /// Order cancelled by the student prior to cafeteria acceptance.
  cancelled('cancelled');

  /// Creates an [OrderStatus] value mapped to [storageKey].
  const OrderStatus(this.storageKey);

  /// Stable string key persisted in storage.
  final String storageKey;

  /// Whether this status represents a final state that cannot transition further.
  bool get isTerminal =>
      this == OrderStatus.completed ||
      this == OrderStatus.rejected ||
      this == OrderStatus.cancelled;

  /// Whether this status belongs to an active in-progress order.
  bool get isActive => !isTerminal;

  /// Parses [value] into an [OrderStatus].
  ///
  /// Throws an [ArgumentError] if [value] does not match any status.
  static OrderStatus fromStorageKey(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.storageKey == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown order status'),
    );
  }
}
