import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/app_colors.dart';
import 'package:unibite/core/design_system/app_loader.dart';
import 'package:unibite/core/design_system/app_spacing.dart';
import 'package:unibite/core/design_system/app_text.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/design_system/tokens.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';

export 'app_colors.dart';
export 'app_loader.dart';
export 'app_spacing.dart';
export 'app_text.dart';

/// Energy-orange pill primary CTA with press scale (`0.97`), haptic feedback,
/// and smooth loading morph into a progress spinner.
class UbPrimaryButton extends StatefulWidget {
  /// Creates a [UbPrimaryButton] with [label] and optional [onPressed].
  const UbPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor = UniBiteColors.secondary,
  });

  /// Bold uppercase-friendly button text (15 sp bold for WCAG AA compliance).
  final String label;

  /// Tap handler; when `null`, renders the disabled state.
  final VoidCallback? onPressed;

  /// Whether the button shows an inline loading spinner and locks input.
  final bool isLoading;

  /// Optional leading Lucide icon.
  final IconData? icon;

  /// Button fill color, defaulting to [UniBiteColors.secondary].
  final Color backgroundColor;

  @override
  State<UbPrimaryButton> createState() => _UbPrimaryButtonState();
}

class _UbPrimaryButtonState extends State<UbPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final reduceMotion = UniBiteTokens.reduceMotion(context);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: (_pressed && !reduceMotion) ? 0.97 : 1.0,
        duration: UniBiteTokens.fast,
        curve: UniBiteTokens.easeOut,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed?.call();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pressed
                  ? UniBiteColors.secondaryPressed
                  : widget.backgroundColor,
              disabledBackgroundColor: UniBiteColors.primary100,
              disabledForegroundColor: UniBiteColors.inkMuted,
              foregroundColor: AppColors.surface,
              shape: const StadiumBorder(),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22),
            ),
            child: AnimatedSwitcher(
              duration: UniBiteTokens.fast,
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: AppLoader.button(color: AppColors.surface),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: AppColors.surface),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary campus-green outlined pill button.
class UbSecondaryButton extends StatelessWidget {
  /// Creates a [UbSecondaryButton].
  const UbSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDanger = false,
  });

  /// Button text.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to style the outline using [UniBiteColors.dangerText].
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final fg = isDanger ? UniBiteColors.dangerText : UniBiteColors.primary700;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: fg.withValues(alpha: 0.7)),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ghost text button with contrast-safe dark orange accent underline option.
class UbGhostButton extends StatelessWidget {
  /// Creates a [UbGhostButton].
  const UbGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.underlinedOrange = false,
  });

  /// Button text.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Whether to highlight with [AppColors.orangeText].
  final bool underlinedOrange;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: underlinedOrange
            ? AppColors.orangeText
            : AppColors.green700,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: underlinedOrange ? AppColors.orangeText : AppColors.green700,
        ),
      ),
    );
  }
}

/// Compact pill showing Open (with sunny-yellow dot) or Closed status.
class UbOpenClosedPill extends StatelessWidget {
  /// Creates a [UbOpenClosedPill] displaying [isOpen] state.
  const UbOpenClosedPill({super.key, required this.isOpen});

  /// Whether the cafeteria is currently open.
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      label: isOpen ? l10n.open : l10n.closed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isOpen ? UniBiteColors.primary100 : UniBiteColors.dangerSoft,
          borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
          border: Border.all(
            color: (isOpen ? AppColors.green700 : AppColors.danger).withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOpen ? UniBiteColors.accent : UniBiteColors.danger,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOpen ? l10n.open : l10n.closed,
              style: TextStyle(
                color: isOpen
                    ? UniBiteColors.primary700
                    : UniBiteColors.dangerText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enterprise pill status badge with crisp outline, rounded geometry, and optional icon.
class UbStatusBadge extends StatelessWidget {
  /// Creates a [UbStatusBadge].
  const UbStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.dotColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? dotColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: textColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward-compatible alias for [UbStatusBadge].
typedef StatusBadge = UbStatusBadge;

/// Tactile quantity stepper with rolling animated counter and 48 dp touch targets.
class UbQuantityStepper extends StatelessWidget {
  /// Creates a [UbQuantityStepper].
  const UbQuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minValue = 0,
  });

  /// Current numeric quantity.
  final int quantity;

  /// Callback invoked with the updated quantity.
  final ValueChanged<int> onChanged;

  /// Minimum permitted quantity (defaults to `0`).
  final int minValue;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    return Container(
      decoration: BoxDecoration(
        color: UniBiteColors.primary50,
        borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
        border: Border.all(color: UniBiteColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: quantity > minValue
                ? () {
                    HapticFeedback.selectionClick();
                    onChanged(quantity - 1);
                  }
                : null,
            icon: Icon(
              LucideIcons.minus,
              size: 18,
              color: quantity > minValue
                  ? UniBiteColors.primary700
                  : UniBiteColors.completedMuted,
            ),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : UniBiteTokens.fast,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  '$quantity',
                  key: ValueKey(quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: UniBiteColors.ink,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () {
              HapticFeedback.selectionClick();
              onChanged(quantity + 1);
            },
            icon: const Icon(
              LucideIcons.plus,
              size: 18,
              color: UniBiteColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom cart bar sliding into view whenever the student cart has items.
class UbStickyCartBar extends StatelessWidget {
  /// Creates a [UbStickyCartBar].
  const UbStickyCartBar({
    super.key,
    required this.itemCount,
    required this.cafeteriaName,
    required this.totalAmount,
    required this.onTap,
  });

  /// Total quantity of meals currently in the cart.
  final int itemCount;

  /// Locked cafeteria name for the active cart.
  final String cafeteriaName;

  /// Total JOD price of the cart.
  final double totalAmount;

  /// Callback opening the Cart tab/view.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    if (itemCount <= 0) return const SizedBox.shrink();

    final bar = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: UniBiteColors.primary900,
            borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
            boxShadow: UniBiteTokens.shadow2,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : UniBiteTokens.fast,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey(itemCount),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: UniBiteColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: UniBiteColors.onAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.navCart,
                      style: const TextStyle(
                        color: UniBiteColors.surface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      cafeteriaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: UniBiteColors.primary100,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: UniBiteColors.secondary,
                  borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
                ),
                child: Text(
                  '${totalAmount.toStringAsFixed(2)} ${l10n.currencyJod}',
                  style: const TextStyle(
                    color: UniBiteColors.surface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (reduceMotion) return bar;
    return bar
        .animate()
        .slideY(begin: 0.35, end: 0, duration: UniBiteTokens.normal)
        .fadeIn(duration: UniBiteTokens.fast);
  }
}

/// Destination descriptor for [UbFloatingPillNav].
class UbNavDestination {
  /// Creates a [UbNavDestination].
  const UbNavDestination({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });

  /// Lucide icon rendered for this tab.
  final IconData icon;

  /// Localized tab label.
  final String label;

  /// Optional integer badge count shown when `> 0`.
  final int badgeCount;
}

/// Floating pill-shaped mobile navigation bar with accessible 48 dp touch targets.
class UbFloatingPillNav extends StatelessWidget {
  /// Creates a [UbFloatingPillNav].
  const UbFloatingPillNav({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  /// Active destination index.
  final int selectedIndex;

  /// Ordered navigation destinations.
  final List<UbNavDestination> destinations;

  /// Selection callback invoked with tapped tab index.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: UniBiteColors.surface,
            borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
            border: Border.all(color: UniBiteColors.border),
            boxShadow: UniBiteTokens.shadow2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (i) {
              final item = destinations[i];
              final selected = i == selectedIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onSelected(i),
                    borderRadius: BorderRadius.circular(UniBiteTokens.rPill),
                    child: AnimatedContainer(
                      duration: UniBiteTokens.fast,
                      curve: UniBiteTokens.easeOut,
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? UniBiteColors.primary100
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          UniBiteTokens.rPill,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Badge(
                            isLabelVisible: item.badgeCount > 0,
                            backgroundColor: UniBiteColors.secondary,
                            label: Text('${item.badgeCount}'),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: selected
                                  ? UniBiteColors.primary700
                                  : UniBiteColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? UniBiteColors.primary700
                                  : UniBiteColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Animated live order status stepper with pulsing active stage and Ready confetti.
class UbOrderStatusStepper extends StatelessWidget {
  /// Creates a [UbOrderStatusStepper] for [status].
  const UbOrderStatusStepper({super.key, required this.status});

  /// Current [OrderStatus] of the tracked order.
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final steps = [
      (OrderStatus.pending, l10n.statusPending, LucideIcons.clock),
      (OrderStatus.accepted, l10n.statusAccepted, LucideIcons.check),
      (OrderStatus.preparing, l10n.statusPreparing, LucideIcons.flame),
      (OrderStatus.ready, l10n.statusReady, LucideIcons.packageCheck),
    ];

    final activeIdx = switch (status) {
      OrderStatus.pending => 0,
      OrderStatus.accepted => 1,
      OrderStatus.preparing => 2,
      OrderStatus.ready || OrderStatus.completed => 3,
      OrderStatus.rejected || OrderStatus.cancelled => -1,
    };

    if (activeIdx < 0) return const SizedBox.shrink();

    final isReady = status == OrderStatus.ready;
    final activeColor = switch (status) {
      OrderStatus.pending => UniBiteColors.accent,
      OrderStatus.accepted || OrderStatus.preparing => UniBiteColors.secondary,
      OrderStatus.ready => UniBiteColors.primary500,
      OrderStatus.completed => UniBiteColors.completedMuted,
      OrderStatus.rejected || OrderStatus.cancelled => UniBiteColors.danger,
    };

    return Stack(
      children: [
        if (isReady)
          const Positioned.fill(
            child: IgnorePointer(child: YellowConfettiOverlay()),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: List.generate(steps.length, (i) {
                final reached = i <= activeIdx;
                final isCurrent = i == activeIdx;
                final nodeColor = reached ? activeColor : UniBiteColors.border;

                Widget node = Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: reached ? nodeColor : UniBiteColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: nodeColor, width: 2),
                  ),
                  child: Icon(
                    steps[i].$3,
                    size: 14,
                    color: reached
                        ? (status == OrderStatus.pending && isCurrent
                              ? UniBiteColors.onAccent
                              : UniBiteColors.surface)
                        : UniBiteColors.inkMuted,
                  ),
                );

                if (isCurrent &&
                    !reduceMotion &&
                    !UniBiteTokens.isTestEnvironment &&
                    status != OrderStatus.completed) {
                  node = node
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 1.0,
                        end: 1.12,
                        duration: const Duration(milliseconds: 700),
                      );
                }

                return Expanded(
                  child: Row(
                    children: [
                      node,
                      if (i < steps.length - 1)
                        Expanded(
                          child: AnimatedContainer(
                            duration: UniBiteTokens.normal,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: i < activeIdx
                                  ? activeColor
                                  : UniBiteColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: steps
                  .map(
                    (s) => Expanded(
                      child: Text(
                        s.$2,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: s.$1 == status
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: s.$1 == status
                              ? UniBiteColors.ink
                              : UniBiteColors.inkMuted,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Green-tinted skeleton shimmer loader replacing blank loading states.
class UbSkeletonShimmer extends StatelessWidget {
  /// Creates a [UbSkeletonShimmer] list placeholder.
  const UbSkeletonShimmer({super.key, this.itemCount = 3});

  /// Number of skeleton rows to display.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    return ListView.separated(
      padding: const EdgeInsets.all(UniBiteTokens.screenPadding),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, _) {
        final box = Container(
          height: 92,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UniBiteColors.surface,
            borderRadius: BorderRadius.circular(UniBiteTokens.r20),
            border: Border.all(color: UniBiteColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: UniBiteColors.primary100,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 14,
                      width: 160,
                      decoration: BoxDecoration(
                        color: UniBiteColors.primary100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 110,
                      decoration: BoxDecoration(
                        color: UniBiteColors.primary50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (reduceMotion) return box;
        return box
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: const Duration(milliseconds: 1100),
              color: UniBiteColors.primary50,
            );
      },
    );
  }
}

/// Animated success check-draw emblem shown when an order is placed.
class UbAnimatedCheck extends StatelessWidget {
  /// Creates a [UbAnimatedCheck].
  const UbAnimatedCheck({super.key, this.size = 64});

  /// Diameter of the success check circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = UniBiteTokens.reduceMotion(context);
    final circle = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: UniBiteColors.primary500,
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.check,
        color: UniBiteColors.surface,
        size: size * 0.52,
      ),
    );
    if (reduceMotion) return circle;
    return circle
        .animate()
        .scale(begin: const Offset(0.4, 0.4), duration: UniBiteTokens.normal)
        .fadeIn(duration: UniBiteTokens.fast);
  }
}

/// Standardized elevated surface card with 20dp radius, 1px subtle outline, and soft shadow.
class UbCard extends StatelessWidget {
  const UbCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg16),
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.outline,
    this.borderRadius = AppRadius.card,
    this.shadow,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? shadow;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: shadow ?? AppShadow.soft,
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      ),
    );
  }
}

/// Standardized section header with H2 typography and optional trailing action.
class UbSectionHeader extends StatelessWidget {
  const UbSectionHeader({
    super.key,
    required this.title,
    this.badgeText,
    this.actionText,
    this.onActionTap,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.md12),
  });

  final String title;
  final String? badgeText;
  final String? actionText;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppText.h2(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: AppColors.orangeText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: AppText.bodyM(context, color: AppColors.orangeText)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

/// Floating rounded search input field with instant search and clear actions.
class UbSearchField extends StatelessWidget {
  const UbSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadow.soft,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppText.bodyM(context),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppText.bodyM(context, color: AppColors.inkMuted),
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 20,
            color: AppColors.green700,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 18,
                  color: AppColors.inkMuted,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                  onClear?.call();
                },
              );
            },
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Standard empty state container with circular icon, friendly title, and optional CTA.
class UbEmptyState extends StatelessWidget {
  const UbEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.green100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: AppColors.green700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg16),
            Text(
              title,
              style: AppText.h2(context),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm8),
              Text(
                subtitle!,
                style: AppText.bodyM(context, color: AppColors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl24),
              UbPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standard error state container with circular warning icon and retry CTA.
class UbErrorState extends StatelessWidget {
  const UbErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertCircle,
                size: 36,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.lg16),
            Text(
              title,
              style: AppText.h2(context, color: AppColors.dangerText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm8),
            Text(
              message,
              style: AppText.bodyM(context, color: AppColors.inkSoft),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl24),
              UbSecondaryButton(
                label: retryLabel ?? 'Retry',
                onPressed: onRetry,
                icon: LucideIcons.rotateCcw,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Segmented tab pill controller for Cart Pickup vs. Pre-order.
class UbSegmentedControl<T> extends StatelessWidget {
  const UbSegmentedControl({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  final T selectedValue;
  final List<(T, String, IconData?)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.green100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt.$1 == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(opt.$1);
              },
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: isSelected ? AppShadow.soft : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (opt.$3 != null) ...[
                      Icon(
                        opt.$3,
                        size: 16,
                        color: isSelected
                            ? AppColors.green700
                            : AppColors.inkMuted,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      opt.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.green700
                            : AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Modern enterprise statistic & metric card for dashboard analytics.
class UbStatCard extends StatelessWidget {
  const UbStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor = AppColors.green700,
    this.iconBackground = AppColors.green100,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UbCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.green100,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor ?? AppColors.green700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md12),
          Text(
            value,
            style: AppText.display(context).copyWith(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppText.bodyM(context, color: AppColors.inkMuted).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppText.caption(context, color: AppColors.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}
