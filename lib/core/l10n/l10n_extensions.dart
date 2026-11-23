import 'package:flutter/widgets.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';
import 'package:unibite/features/orders/domain/entities/order_type.dart';
import 'package:unibite/l10n/app_localizations.dart';

/// Convenience localization helpers built on [BuildContext] and domain enums.
extension AppLocalizationsContextX on BuildContext {
  /// Active [AppLocalizations] instance for the widget tree.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Localized display helpers for [OrderStatus], [UserRole], [OrderType], and categories.
extension DomainLocalizationX on AppLocalizations {
  /// Returns the localized label for [role].
  String roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return roleStudent;
      case UserRole.cafeteriaAdmin:
        return roleCafeteriaAdmin;
      case UserRole.cafeteriaStaff:
        return roleCafeteriaStaff;
      case UserRole.systemAdmin:
        return roleSystemAdmin;
    }
  }

  /// Returns the localized label for [status].
  String orderStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return statusPending;
      case OrderStatus.accepted:
        return statusAccepted;
      case OrderStatus.preparing:
        return statusPreparing;
      case OrderStatus.ready:
        return statusReady;
      case OrderStatus.completed:
        return statusCompleted;
      case OrderStatus.rejected:
        return statusRejected;
      case OrderStatus.cancelled:
        return statusCancelled;
    }
  }

  /// Returns the plain-language student status sentence for [status].
  String orderStatusPlainLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return statusPlainPending;
      case OrderStatus.accepted:
        return statusPlainAccepted;
      case OrderStatus.preparing:
        return statusPlainPreparing;
      case OrderStatus.ready:
        return statusPlainReady;
      case OrderStatus.completed:
        return statusPlainCompleted;
      case OrderStatus.rejected:
        return statusPlainRejected;
      case OrderStatus.cancelled:
        return statusPlainCancelled;
    }
  }

  /// Returns the localized label for [type].
  String orderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.app:
        return orderTypeApp;
      case OrderType.walkin:
        return orderTypeWalkin;
    }
  }

  /// Returns the localized label for a canonical meal [category] key.
  String localizedMealCategory(String category) {
    switch (category) {
      case 'Sandwiches':
        return categorySandwiches;
      case 'Hot Meals':
        return categoryHotMeals;
      case 'Salads':
        return categorySalads;
      case 'Beverages':
        return categoryBeverages;
      case 'Desserts':
        return categoryDesserts;
      default:
        return category;
    }
  }
}
