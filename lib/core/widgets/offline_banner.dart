import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/providers/repository_providers.dart';

/// Banner displayed when local connection is lost or offline demo mode is active.
class OfflineBanner extends ConsumerWidget {
  /// Creates an [OfflineBanner].
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(simulatedOfflineProvider);
    if (!isOffline) return const SizedBox.shrink();

    return Material(
      color: UniBiteColors.danger,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                LucideIcons.wifiOff,
                color: UniBiteColors.surface,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.connectionLostBanner,
                  style: const TextStyle(
                    color: UniBiteColors.surface,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(simulatedOfflineProvider.notifier).state = false;
                },
                style: TextButton.styleFrom(
                  foregroundColor: UniBiteColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
