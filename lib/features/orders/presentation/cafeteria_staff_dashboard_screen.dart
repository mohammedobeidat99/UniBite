import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/core/widgets/unibite_logo.dart';
import 'package:unibite/features/orders/presentation/live_order_board_widget.dart';
import 'package:unibite/features/orders/presentation/qr_lookup_view.dart';
import 'package:unibite/features/orders/presentation/walk_in_order_view.dart';

/// Web-responsive dashboard for Cafeteria Staff restricted strictly to order workflows.
class CafeteriaStaffDashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [CafeteriaStaffDashboardScreen].
  const CafeteriaStaffDashboardScreen({super.key});

  @override
  ConsumerState<CafeteriaStaffDashboardScreen> createState() =>
      _CafeteriaStaffDashboardScreenState();
}

class _CafeteriaStaffDashboardScreenState
    extends ConsumerState<CafeteriaStaffDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actor = ref.watch(currentUserProvider);
    if (actor == null || actor.cafeteriaId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final cafeteriaId = actor.cafeteriaId!;
    final cafe = ref
        .watch(cafeteriaByIdStreamProvider(cafeteriaId))
        .valueOrNull;
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    final body = IndexedStack(
      index: _selectedTab,
      children: [
        LiveOrderBoardWidget(
          cafeteriaId: cafeteriaId,
          actor: actor,
          onCreateWalkIn: () => setState(() => _selectedTab = 1),
        ),
        WalkInOrderView(cafeteriaId: cafeteriaId, actor: actor),
        QrLookupView(cafeteriaId: cafeteriaId, actor: actor),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const UniBiteLogo(size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${cafe?.name ?? l10n.appTitle} — ${l10n.roleCafeteriaStaff}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isWide) ...[
            UbStatusBadge(
              label: l10n.liveConnectedBadge,
              backgroundColor: AppColors.green100,
              textColor: AppColors.green700,
            ),
            const SizedBox(width: 8),
            UbStatusBadge(
              label: l10n.screenAwakeBadge,
              backgroundColor: AppColors.green50,
              textColor: AppColors.inkMuted,
            ),
            const SizedBox(width: 6),
          ],
          IconButton(
            tooltip: l10n.languageLabel,
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            icon: const Icon(LucideIcons.languages),
          ),
          IconButton(
            tooltip: l10n.logoutButton,
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(LucideIcons.logOut),
          ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedTab,
                  extended: MediaQuery.sizeOf(context).width >= 1120,
                  backgroundColor: AppColors.green900,
                  indicatorColor: AppColors.orange,
                  selectedIconTheme: const IconThemeData(
                    color: AppColors.ink,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: AppColors.green100,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.green100,
                    fontWeight: FontWeight.w500,
                  ),
                  onDestinationSelected: (idx) =>
                      setState(() => _selectedTab = idx),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(LucideIcons.layoutDashboard),
                      label: Text(l10n.tabLiveBoard),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(LucideIcons.receipt),
                      label: Text(l10n.tabWalkInOrder),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(LucideIcons.qrCode),
                      label: Text(l10n.tabQrLookup),
                    ),
                  ],
                ),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (idx) =>
                  setState(() => _selectedTab = idx),
              destinations: [
                NavigationDestination(
                  icon: const Icon(LucideIcons.layoutDashboard),
                  label: l10n.tabLiveBoard,
                ),
                NavigationDestination(
                  icon: const Icon(LucideIcons.receipt),
                  label: l10n.tabWalkInOrder,
                ),
                NavigationDestination(
                  icon: const Icon(LucideIcons.qrCode),
                  label: l10n.tabQrLookup,
                ),
              ],
            ),
    );
  }
}
