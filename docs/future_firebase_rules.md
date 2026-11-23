# Future Firestore Security Rules (GP2 Migration Blueprint)

This document defines the equivalent Firebase Firestore Security Rules corresponding to the local GP1 access-control enforcement implemented inside `lib/features/*/data/local/` and `lib/core/router/app_router.dart`.

## Custom Claims / User Document Lookup

Every authenticated Firebase user maps 1-to-1 to `/users/{uid}` storing:

- `role`: `'student' | 'cafeteriaAdmin' | 'cafeteriaStaff' | 'systemAdmin'`
- `isActive`: `bool`
- `universityId`: `string?`
- `campusId`: `string?`
- `cafeteriaId`: `string?`

## Firestore Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function currentUser() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function isActiveUser() {
      return isSignedIn() && currentUser().isActive == true;
    }

    function hasRole(role) {
      return isActiveUser() && currentUser().role == role;
    }

    function isSystemAdmin() {
      return hasRole('systemAdmin');
    }

    function isCafeteriaAdminFor(cafeteriaId) {
      return hasRole('cafeteriaAdmin') && currentUser().cafeteriaId == cafeteriaId;
    }

    function isCafeteriaOperatorFor(cafeteriaId) {
      return (hasRole('cafeteriaAdmin') || hasRole('cafeteriaStaff'))
        && currentUser().cafeteriaId == cafeteriaId;
    }

    // -------------------------------------------------------------------------
    // Universities & Campuses (FR-5, FR-6, NFR-3)
    // -------------------------------------------------------------------------
    match /universities/{universityId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isSystemAdmin();
    }

    match /campuses/{campusId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isSystemAdmin();
    }

    // -------------------------------------------------------------------------
    // Cafeterias (FR-5, FR-12, FR-52)
    // -------------------------------------------------------------------------
    match /cafeterias/{cafeteriaId} {
      allow read: if isSignedIn();
      allow create, delete: if isSystemAdmin();

      // System Admin can approve/suspend/reassign any cafeteria.
      // Cafeteria Admin can only update operating hours, prepTimeMinutes, and orderTimeoutSeconds
      // on their own cafeteriaId; Cafeteria Staff cannot edit cafeteria settings.
      allow update: if isSystemAdmin()
        || (isCafeteriaAdminFor(cafeteriaId)
            && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['workingHours', 'prepTimeMinutes', 'orderTimeoutSeconds']));

      // Meals subcollection or top-level /meals/{mealId} (FR-10, FR-11, FR-13)
      match /meals/{mealId} {
        allow read: if isSignedIn();
        allow create, update, delete: if isSystemAdmin() || isCafeteriaAdminFor(cafeteriaId);
      }
    }

    // Top-level meals collection (matches GP1 flat entity layout)
    match /meals/{mealId} {
      allow read: if isSignedIn();
      allow create: if isSystemAdmin()
        || isCafeteriaAdminFor(request.resource.data.cafeteriaId);
      allow update, delete: if isSystemAdmin()
        || isCafeteriaAdminFor(resource.data.cafeteriaId);
    }

    // -------------------------------------------------------------------------
    // Users (FR-3, FR-4, FR-13, FR-51)
    // -------------------------------------------------------------------------
    match /users/{userId} {
      allow read: if isSystemAdmin()
        || (isSignedIn() && request.auth.uid == userId)
        || (hasRole('cafeteriaAdmin')
            && resource.data.role == 'cafeteriaStaff'
            && resource.data.cafeteriaId == currentUser().cafeteriaId);

      // Self-registration only creates inactive-restricted student role.
      // Only System Admin creates Cafeteria Admins; Cafeteria Admin creates Staff for own cafeteria.
      allow create: if isSystemAdmin()
        || (isSignedIn()
            && request.auth.uid == userId
            && request.resource.data.role == 'student'
            && request.resource.data.isActive == true)
        || (hasRole('cafeteriaAdmin')
            && request.resource.data.role == 'cafeteriaStaff'
            && request.resource.data.cafeteriaId == currentUser().cafeteriaId);

      // Students can only update their own universityId/campusId onboarding selection.
      // Cafeteria Admins can only toggle isActive for staff in their own cafeteria.
      allow update: if isSystemAdmin()
        || (hasRole('student')
            && request.auth.uid == userId
            && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['universityId', 'campusId']))
        || (hasRole('cafeteriaAdmin')
            && resource.data.role == 'cafeteriaStaff'
            && resource.data.cafeteriaId == currentUser().cafeteriaId
            && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['isActive']));

      allow delete: if isSystemAdmin();
    }

    // -------------------------------------------------------------------------
    // Orders (FR-14 to FR-24)
    // -------------------------------------------------------------------------
    match /orders/{orderId} {
      allow read: if isSystemAdmin()
        || (hasRole('student') && resource.data.studentId == request.auth.uid)
        || isCafeteriaOperatorFor(resource.data.cafeteriaId);

      // Student orders always start as 'pending' with paymentMethod == 'cash'.
      // Walk-in orders are created by assigned cafeteria operators with type == 'walkin'.
      allow create: if (hasRole('student')
            && request.resource.data.studentId == request.auth.uid
            && request.resource.data.type == 'app'
            && request.resource.data.status == 'pending'
            && request.resource.data.paymentMethod == 'cash')
        || (isCafeteriaOperatorFor(request.resource.data.cafeteriaId)
            && request.resource.data.type == 'walkin'
            && request.resource.data.paymentMethod == 'cash');

      // Students can only cancel their own order while status == 'pending'.
      // Cafeteria operators enforce legal transitions via Cloud Functions / Rules.
      allow update: if isSystemAdmin()
        || (hasRole('student')
            && resource.data.studentId == request.auth.uid
            && resource.data.status == 'pending'
            && request.resource.data.status == 'cancelled'
            && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['status', 'updatedAt']))
        || (isCafeteriaOperatorFor(resource.data.cafeteriaId)
            && (
              (resource.data.status == 'pending' && request.resource.data.status in ['accepted', 'rejected']) ||
              (resource.data.status == 'accepted' && request.resource.data.status == 'preparing') ||
              (resource.data.status == 'preparing' && request.resource.data.status == 'ready') ||
              (resource.data.status == 'ready' && request.resource.data.status == 'completed')
            ));

      allow delete: if false;
    }
  }
}
```

## Cloud Function for Auto-Reject (GP2)

In GP2, `OrderAutoRejectService` (`lib/features/orders/domain/services/order_auto_reject_service.dart`) moves to a scheduled Cloud Function (`onSchedule("every 1 minutes")`) that queries `orders` where `status == "pending"` and `createdAt <= now - cafeteria.orderTimeoutSeconds`, setting `status = "rejected"` and `rejectReason = "No response"`.
