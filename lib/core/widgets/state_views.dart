import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/components.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';

/// Centered progress spinner for loading states.
class LoadingView extends StatelessWidget {
  /// Creates a [LoadingView].
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: AppLoader.regular(),
      ),
    );
  }
}

/// Animated empty state panel featuring UniBite's looping steam-bowl art.
class EmptyStateView extends StatelessWidget {
  /// Creates an [EmptyStateView] with [icon], [title], and optional [subtitle].
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  /// Lucide icon retained for API compatibility alongside the illustration.
  final IconData icon;

  /// Primary message describing why the view is empty.
  final String title;

  /// Optional supporting hint text.
  final String? subtitle;

  /// Optional call-to-action button displayed below the text.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SteamEmptyIllustration(size: 108),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: UniBiteColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: UniBiteColors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Standard error state view with recovery action.
class ErrorStateView extends StatelessWidget {
  /// Creates an [ErrorStateView] showing [message] and optional [onRetry].
  const ErrorStateView({super.key, required this.message, this.onRetry});

  /// Error text shown to the user.
  final String message;

  /// Optional retry action invoked when the user taps Retry.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: UniBiteColors.dangerSoft,
            borderRadius: BorderRadius.circular(UniBiteTokens.r20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: UniBiteColors.dangerText,
                size: 38,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: UniBiteColors.dangerText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                UbPrimaryButton(
                  onPressed: onRetry,
                  icon: LucideIcons.refreshCw,
                  label: context.l10n.retry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact pill badge displaying colored status text.
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge] with [label], [backgroundColor], and [textColor].
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Localized text shown inside the badge.
  final String label;

  /// Pill fill color.
  final Color backgroundColor;

  /// Foreground text color.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
