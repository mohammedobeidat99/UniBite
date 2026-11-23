/// Base exception for all domain and data errors in UniBite.
abstract class AppException implements Exception {
  /// Creates an application exception with a user-readable [message] and optional [code].
  const AppException(this.message, {this.code});

  /// Human-readable description of the failure.
  final String message;

  /// Optional machine-readable error code for localization mapping.
  final String? code;

  @override
  String toString() => code == null ? message : '$code: $message';
}

/// Exception thrown when an actor lacks permission for an operation or scope.
class UnauthorizedAccessException extends AppException {
  /// Creates an unauthorized access exception with [message] and optional [code].
  const UnauthorizedAccessException(super.message, {super.code});
}

/// Exception thrown when input data or domain invariants fail validation.
class ValidationException extends AppException {
  /// Creates a validation exception with [message] and optional [code].
  const ValidationException(super.message, {super.code});
}

/// Exception thrown when authentication, registration, or password reset fails.
class AuthException extends AppException {
  /// Creates an authentication exception with [message] and optional [code].
  const AuthException(super.message, {super.code});
}

/// Exception thrown when an illegal order status transition is requested.
class OrderStateException extends AppException {
  /// Creates an order state exception with [message] and optional [code].
  const OrderStateException(super.message, {super.code});
}
