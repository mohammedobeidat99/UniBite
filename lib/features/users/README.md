# Users Feature

Handles System Admin user listing/activation across roles and Cafeteria Admin creation/management of Cafeteria Staff accounts.

## Structure
- `domain/repositories/`: `UserRepository`
- `data/local/`: `LocalUserRepository` (strictly scopes staff creation/toggling to the owning `cafeteriaId`)

## GP2 Firebase Migration
Implement `FirestoreUserRepository implements UserRepository` paired with Firebase Admin / Cloud Functions for account provisioning.
