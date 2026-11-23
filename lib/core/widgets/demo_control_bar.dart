import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';
import 'package:unibite/features/auth/domain/entities/user_role.dart';
import 'package:unibite/features/cart/presentation/cart_notifier.dart';

/// Whether the debug/demo toolbar should be shown in this build.
const bool kIsDemoToolbarEnabled =
    kDebugMode || bool.fromEnvironment('DEMO_MODE', defaultValue: false);

/// Debug/demo control strip enabling 1-click role switching, AR/EN toggle,
/// simulated offline banner testing, immediate auto-reject sweep, and data reset.
class DemoControlBar extends ConsumerWidget {
  /// Creates a [DemoControlBar].
  const DemoControlBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsDemoToolbarEnabled) return const SizedBox.shrink();

    final l10n = context.l10n;
    final currentUser = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider);
    final isOffline = ref.watch(simulatedOfflineProvider);

    return Material(
      color: UniBiteColors.primary900,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(
                LucideIcons.zap,
                color: UniBiteColors.secondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.demoBarTitle,
                style: const TextStyle(
                  color: UniBiteColors.surface,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (currentUser != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: UniBiteColors.surface.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${l10n.roleLabel(currentUser.role)} • ${currentUser.name}',
                    style: const TextStyle(
                      color: UniBiteColors.surface,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              PopupMenuButton<UserRole>(
                tooltip: l10n.switchRoleLabel,
                onSelected: (role) async {
                  ref.read(cartProvider.notifier).clear();
                  await ref.read(authRepositoryProvider).debugSwitchRole(role);
                },
                itemBuilder: (ctx) => [
                  for (final role in UserRole.values)
                    PopupMenuItem<UserRole>(
                      value: role,
                      child: Row(
                        children: [
                          Icon(
                            currentUser?.role == role
                                ? LucideIcons.checkCircle2
                                : LucideIcons.user,
                            size: 18,
                            color: UniBiteColors.primary700,
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.roleLabel(role)),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: UniBiteColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.arrowLeftRight,
                        size: 15,
                        color: UniBiteColors.surface,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.switchRoleLabel,
                        style: const TextStyle(
                          color: UniBiteColors.surface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _DemoChipButton(
                icon: LucideIcons.languages,
                label: locale.languageCode == 'ar' ? 'EN' : 'AR',
                onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
              ),
              const SizedBox(width: 6),
              _DemoChipButton(
                icon: isOffline ? LucideIcons.wifiOff : LucideIcons.wifi,
                label: l10n.offlineToggleLabel,
                highlighted: isOffline,
                onTap: () {
                  ref.read(simulatedOfflineProvider.notifier).state =
                      !isOffline;
                },
              ),
              const SizedBox(width: 6),
              _DemoChipButton(
                icon: LucideIcons.timerOff,
                label: l10n.runAutoRejectNow,
                onTap: () async {
                  final count = await ref
                      .read(orderAutoRejectServiceProvider)
                      .runSweep();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.autoRejectCompletedCount(count)),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 6),
              _DemoChipButton(
                icon: LucideIcons.rotateCcw,
                label: l10n.resetDemoData,
                onTap: () => _confirmReset(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetDemoConfirmTitle),
        content: Text(l10n.resetDemoConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(cartProvider.notifier).clear();
      await ref.read(localStorageServiceProvider).resetAndReseed();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.demoDataResetSuccess)));
      }
    }
  }
}

class _DemoChipButton extends StatelessWidget {
  const _DemoChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: highlighted
              ? UniBiteColors.danger
              : UniBiteColors.surface.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: UniBiteColors.surface),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: UniBiteColors.surface,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
