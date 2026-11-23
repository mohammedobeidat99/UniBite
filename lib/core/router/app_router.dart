import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/offline_banner.dart';
import 'package:unibite/features/auth/domain/entities/app_user.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/auth/presentation/intro_onboarding_screen.dart';
import 'package:unibite/features/auth/presentation/login_screen.dart';
import 'package:unibite/features/auth/presentation/onboarding_screen.dart';
import 'package:unibite/features/auth/presentation/register_screen.dart';
import 'package:unibite/features/auth/presentation/reset_password_screen.dart';
import 'package:unibite/features/auth/presentation/splash_screen.dart';
import 'package:unibite/features/cafeterias/presentation/cafeteria_admin_dashboard_screen.dart';
import 'package:unibite/features/cafeterias/presentation/cafeteria_menu_screen.dart';
import 'package:unibite/features/cafeterias/presentation/student_shell_screen.dart';
import 'package:unibite/features/orders/presentation/cafeteria_staff_dashboard_screen.dart';
import 'package:unibite/features/universities/presentation/system_admin_dashboard_screen.dart';

/// Change notifier bridging Riverpod auth updates into [GoRouter.refreshListenable].
class _AuthRouterRefreshNotifier extends ChangeNotifier {
  _AuthRouterRefreshNotifier(Ref ref) {
    ref.listen<AppUser?>(currentUserProvider, (_, _) => notifyListeners());
    ref.listen<AsyncValue<AppUser?>>(
      currentUserStreamProvider,
      (_, _) => notifyListeners(),
    );
  }
}

/// Role-based [GoRouter] enforcing authentication, onboarding, and route transitions.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = ref.read(localStorageServiceProvider).getSessionUser();
      final location = state.matchedLocation;

      if (location == '/splash') return null;

      const publicRoutes = {
        '/intro',
        '/login',
        '/register',
        '/reset-password',
      };

      if (user == null) {
        return publicRoutes.contains(location) ? null : '/login';
      }

      switch (user.role) {
        case UserRole.student:
          if (!user.hasCompletedOnboarding) {
            return location == '/onboarding' ? null : '/onboarding';
          }
          if (location == '/onboarding' || location.startsWith('/student')) {
            return null;
          }
          return '/student';
        case UserRole.cafeteriaAdmin:
          return location == '/cafeteria-admin' ? null : '/cafeteria-admin';
        case UserRole.cafeteriaStaff:
          return location == '/cafeteria-staff' ? null : '/cafeteria-staff';
        case UserRole.systemAdmin:
          return location == '/system-admin' ? null : '/system-admin';
      }
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => _AppShellChrome(child: child),
        routes: [
          GoRoute(
            path: '/splash',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const SplashScreen()),
          ),
          GoRoute(
            path: '/intro',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const IntroOnboardingScreen()),
          ),
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const LoginScreen()),
          ),
          GoRoute(
            path: '/register',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const RegisterScreen()),
          ),
          GoRoute(
            path: '/reset-password',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const ResetPasswordScreen()),
          ),
          GoRoute(
            path: '/onboarding',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const OnboardingScreen()),
          ),
          GoRoute(
            path: '/student',
            pageBuilder: (context, state) {
              final tab =
                  int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
              return _fadeThroughPage(
                state,
                StudentShellScreen(initialTab: tab),
              );
            },
            routes: [
              GoRoute(
                path: 'cafeteria/:id',
                pageBuilder: (context, state) => _fadeThroughPage(
                  state,
                  CafeteriaMenuScreen(cafeteriaId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/cafeteria-admin',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const CafeteriaAdminDashboardScreen()),
          ),
          GoRoute(
            path: '/cafeteria-staff',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const CafeteriaStaffDashboardScreen()),
          ),
          GoRoute(
            path: '/system-admin',
            pageBuilder: (context, state) =>
                _fadeThroughPage(state, const SystemAdminDashboardScreen()),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fadeThroughPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: UniBiteTokens.normal,
    reverseTransitionDuration: UniBiteTokens.fast,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (UniBiteTokens.reduceMotion(context)) {
        return FadeTransition(opacity: animation, child: child);
      }
      final curved = CurvedAnimation(
        parent: animation,
        curve: UniBiteTokens.easeOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppShellChrome extends ConsumerWidget {
  const _AppShellChrome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(simulatedOfflineProvider);

    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: isOffline,
            child: child,
          ),
        ),
      ],
    );
  }
}
