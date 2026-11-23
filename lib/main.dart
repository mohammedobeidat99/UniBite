import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unibite/core/database/local_storage_service.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/router/app_router.dart';
import 'package:unibite/core/theme/app_theme.dart';
import 'package:unibite/l10n/app_localizations.dart';

/// Initializes Hive local persistence and launches the UniBite application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const UniBiteApp(),
    ),
  );
}

/// Root Material 3 widget configuring localization, role-based routing, and background services.
class UniBiteApp extends ConsumerWidget {
  /// Creates the root [UniBiteApp].
  const UniBiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    // Keeps the 30s auto-reject background service active while the app runs.
    ref.watch(orderAutoRejectServiceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)?.appTitle ?? 'UniBite',
      theme: AppTheme.lightTheme(languageCode: locale.languageCode),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
