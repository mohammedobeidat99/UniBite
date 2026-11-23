import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/app_colors.dart';
import 'package:unibite/core/design_system/app_loader.dart';
import 'package:unibite/core/design_system/app_spacing.dart';
import 'package:unibite/core/design_system/app_text.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';
import 'package:unibite/core/widgets/meal_image_widget.dart';
import 'package:unibite/features/cafeterias/domain/entities/cafeteria.dart';
import 'package:unibite/features/meals/domain/entities/meal.dart';
import 'package:unibite/features/orders/domain/entities/order.dart';
import 'package:unibite/features/orders/domain/entities/order_status.dart';

export 'app_colors.dart';
export 'app_loader.dart';
export 'app_spacing.dart';
export 'app_text.dart';

// =============================================================================
// 1. AppScaffold & AppTopBar
// =============================================================================

/// Page scaffold enforcing [AppColors.green50] background, safe areas, and optional width constraint.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.maxWidth = 1440,
    this.backgroundColor = AppColors.green50,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final double maxWidth;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: body,
        ),
      ),
    );
  }
}

/// Custom top bar adhering strictly to design tokens.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = AppColors.surface,
    this.showBackButton = false,
    this.onBackPressed,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.green700),
                  onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
                )
              : null),
      title: Text(
        title,
        style: AppText.h2(context),
      ),
      actions: actions,
    );
  }
}

// =============================================================================
// 2. SectionHeader & SectionDivider
// =============================================================================

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.padding = const EdgeInsets.only(bottom: AppSpacing.s12),
  });

  final String title;
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
            child: Text(
              title,
              style: AppText.h2(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

// =============================================================================
// 3. AppCard
// =============================================================================

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
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
          HapticFeedback.lightImpact();
          onTap!();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      ),
    );
  }
}

// =============================================================================
// 4. AppButton (Primary, Secondary, Ghost, Danger)
// =============================================================================

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.height = 52,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.height = 52,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.height = 48,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.height = 48,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.height = 48,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final reduceMotion = AppMotion.reduceMotion(context);

    // Styling properties based on variant
    final isPrimary = widget.variant == AppButtonVariant.primary;
    final isSecondary = widget.variant == AppButtonVariant.secondary;
    final isGhost = widget.variant == AppButtonVariant.ghost;
    final isDanger = widget.variant == AppButtonVariant.danger;

    final radius = BorderRadius.circular(AppRadius.button);

    Color textColor;
    if (!enabled) {
      textColor = AppColors.inkMuted;
    } else if (isPrimary) {
      textColor = AppColors.ink;
    } else if (isSecondary) {
      textColor = AppColors.green700;
    } else if (isDanger) {
      textColor = AppColors.danger;
    } else {
      textColor = AppColors.ink;
    }

    BoxDecoration decoration;
    if (!enabled) {
      decoration = BoxDecoration(
        color: isGhost ? Colors.transparent : AppColors.green100,
        borderRadius: radius,
      );
    } else if (isPrimary) {
      decoration = BoxDecoration(
        gradient: _pressed
            ? const LinearGradient(colors: [AppColors.orangePressed, AppColors.orangePressed])
            : AppColors.ctaGradient,
        borderRadius: radius,
        boxShadow: _pressed ? null : AppShadow.soft,
      );
    } else if (isSecondary) {
      decoration = BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.green700),
      );
    } else if (isDanger) {
      decoration = BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: radius,
        border: Border.all(color: AppColors.danger),
      );
    } else {
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: radius,
      );
    }

    Widget content = SizedBox(
      height: widget.height,
      width: widget.fullWidth ? double.infinity : null,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            child: widget.isLoading
                ? SizedBox(
                    key: const ValueKey('loader'),
                    width: 22,
                    height: 22,
                    child: AppLoader.button(color: textColor),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: textColor),
                        AppSpacing.h8,
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: (_pressed && !reduceMotion) ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed?.call();
                  }
                : null,
            borderRadius: radius,
            child: Ink(
              decoration: decoration,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 5. AppIconButton
// =============================================================================

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.iconSize = 20,
    this.color = AppColors.green700,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        iconSize: iconSize,
        icon: Icon(icon, color: color),
        onPressed: onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

// =============================================================================
// 6. AppTextField & SearchField
// =============================================================================

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppText.caption(context, color: AppColors.inkSoft).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.v8,
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: AppText.bodyL(context),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppText.bodyM(context, color: AppColors.inkMuted),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.green500, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
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
        boxShadow: AppShadow.raised,
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
            builder: (context, val, _) {
              if (val.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(LucideIcons.x, size: 18, color: AppColors.inkMuted),
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
            horizontal: AppSpacing.s16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 7. CategoryChip & StatusPill
// =============================================================================

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green700 : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: isSelected ? AppColors.green700 : AppColors.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: isSelected ? AppColors.surface : AppColors.ink),
                AppSpacing.h8,
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.surface : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.status,
    this.dotColor,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final OrderStatus? status;
  final Color? dotColor;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color dot;

    if (status != null) {
      bg = switch (status!) {
        OrderStatus.pending => AppColors.yellow.withValues(alpha: 0.16),
        OrderStatus.accepted || OrderStatus.preparing => AppColors.orangeSoft,
        OrderStatus.ready => AppColors.green100,
        OrderStatus.completed => AppColors.green50,
        OrderStatus.rejected || OrderStatus.cancelled => AppColors.dangerSoft,
      };
      fg = switch (status!) {
        OrderStatus.pending => AppColors.onYellow,
        OrderStatus.accepted || OrderStatus.preparing => AppColors.orangeText,
        OrderStatus.ready => AppColors.green700,
        OrderStatus.completed => AppColors.inkMuted,
        OrderStatus.rejected || OrderStatus.cancelled => AppColors.dangerText,
      };
      dot = switch (status!) {
        OrderStatus.pending => AppColors.yellow,
        OrderStatus.accepted || OrderStatus.preparing => AppColors.orange,
        OrderStatus.ready => AppColors.green500,
        OrderStatus.completed => AppColors.inkMuted,
        OrderStatus.rejected || OrderStatus.cancelled => AppColors.danger,
      };
    } else {
      bg = backgroundColor ?? AppColors.green100;
      fg = textColor ?? AppColors.green700;
      dot = dotColor ?? AppColors.yellow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
          AppSpacing.h8,
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 8. PriceText & QuantityStepper
// =============================================================================

class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    this.currency = 'JOD',
    this.color,
  });

  final double amount;
  final String currency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${amount.toStringAsFixed(2)} $currency',
      style: AppText.price(context, color: color),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minValue = 0,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int minValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outline),
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
              size: 16,
              color: quantity > minValue ? AppColors.green700 : AppColors.inkMuted,
            ),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.ink,
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
            icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.orangeText),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 9. CafeteriaCard, MealCard, OrderCard
// =============================================================================

class CafeteriaCard extends StatelessWidget {
  const CafeteriaCard({
    super.key,
    required this.cafeteria,
    required this.onTap,
  });

  final Cafeteria cafeteria;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOpen = cafeteria.isOpenAt(DateTime.now());

    return Opacity(
      opacity: isOpen ? 1.0 : 0.6,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                      child: CustomPaint(painter: SwooshHeroPainter()),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.s12,
                    right: AppSpacing.s12,
                    child: StatusPill(
                      label: isOpen ? l10n.open : l10n.closed,
                      dotColor: isOpen ? AppColors.yellow : AppColors.danger,
                      backgroundColor: isOpen ? AppColors.green100 : AppColors.dangerSoft,
                      textColor: isOpen ? AppColors.green700 : AppColors.dangerText,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.s16,
                    bottom: -20,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadow.soft,
                      ),
                      child: MealImageWidget(
                        imagePath: cafeteria.logo,
                        width: 48,
                        height: 48,
                        borderRadius: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 26, AppSpacing.s16, AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cafeteria.name,
                    style: AppText.h2(context),
                  ),
                  AppSpacing.v4,
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 14, color: AppColors.inkSoft),
                      AppSpacing.h8,
                      Expanded(
                        child: Text(
                          '${l10n.workingHoursFormat(cafeteria.workingHours)} · ${l10n.prepTimeFormat(cafeteria.prepTimeMinutes)}',
                          style: AppText.caption(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.onAdd,
  });

  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyL(context, weight: FontWeight.w700),
                ),
                AppSpacing.v4,
                Text(
                  meal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyM(context, color: AppColors.inkSoft),
                ),
                AppSpacing.v8,
                PriceText(amount: meal.price),
              ],
            ),
          ),
          AppSpacing.h12,
          Stack(
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: 'meal_${meal.id}',
                child: MealImageWidget(
                  imagePath: meal.imagePath,
                  width: 96,
                  height: 96,
                  borderRadius: 16,
                ),
              ),
              if (!meal.isAvailable)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.green900.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      l10n.unavailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (onAdd != null)
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onAdd!();
                      },
                      icon: const Icon(LucideIcons.plus, size: 18, color: AppColors.ink),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.cafeteriaName,
    required this.onTap,
  });

  final Order order;
  final String cafeteriaName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cafeteriaName,
                style: AppText.h2(context),
              ),
              StatusPill(
                label: l10n.orderStatusLabel(order.status),
                status: order.status,
              ),
            ],
          ),
          AppSpacing.v8,
          Text(
            order.items.map((i) => '${i.qty}× ${i.name}').join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyM(context),
          ),
          AppSpacing.v12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}',
                style: AppText.caption(context),
              ),
              PriceText(amount: order.total),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 10. FloatingNavBar & CartBar
// =============================================================================

class FloatingNavBarDestination {
  const FloatingNavBarDestination({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final int badgeCount;
}

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<FloatingNavBarDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 4, AppSpacing.s16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.green900,
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            boxShadow: AppShadow.raised,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (i) {
              final item = destinations[i];
              final isSelected = i == selectedIndex;
              final itemWidget = InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(i);
                },
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 12 : 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orange : Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Badge(
                        isLabelVisible: item.badgeCount > 0,
                        backgroundColor: AppColors.yellow,
                        textColor: AppColors.onYellow,
                        label: Text('${item.badgeCount}'),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: isSelected ? AppColors.ink : AppColors.surface,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );

              return isSelected ? Flexible(child: itemWidget) : itemWidget;
            }),
          ),
        ),
      ),
    );
  }
}

class CartBar extends StatelessWidget {
  const CartBar({
    super.key,
    required this.itemCount,
    required this.cafeteriaName,
    required this.totalAmount,
    required this.onTap,
  });

  final int itemCount;
  final String cafeteriaName;
  final double totalAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.green700,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadow.raised,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$itemCount',
                  style: const TextStyle(
                    color: AppColors.onYellow,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.navCart,
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      cafeteriaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.green100,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${totalAmount.toStringAsFixed(2)} ${l10n.currencyJod}',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 11. EmptyState & ErrorState
// =============================================================================

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon = LucideIcons.utensilsCrossed,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.green100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.green700),
            ),
            AppSpacing.v16,
            Text(
              title,
              style: AppText.h2(context),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.v8,
              Text(
                subtitle!,
                style: AppText.bodyM(context, color: AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.v24,
              AppButton.primary(
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

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertCircle, size: 36, color: AppColors.danger),
            ),
            AppSpacing.v16,
            Text(
              title,
              style: AppText.h2(context, color: AppColors.dangerText),
              textAlign: TextAlign.center,
            ),
            AppSpacing.v8,
            Text(
              message,
              style: AppText.bodyM(context, color: AppColors.inkSoft),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.v24,
              AppButton.secondary(
                label: retryLabel,
                icon: LucideIcons.rotateCcw,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.danger,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(LucideIcons.wifiOff, size: 18, color: AppColors.surface),
            AppSpacing.h12,
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 12. SkeletonBox & AppDialog
// =============================================================================

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.input,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.green100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// =============================================================================
// Backward-compatible widget aliases
// =============================================================================

typedef UbCard = AppCard;
typedef UbSectionHeader = SectionHeader;
typedef UbSearchField = SearchField;
typedef UbEmptyState = EmptyState;
typedef UbErrorState = ErrorState;
class UbOpenClosedPill extends StatelessWidget {
  const UbOpenClosedPill({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StatusPill(
      label: isOpen ? l10n.open : l10n.closed,
      dotColor: isOpen ? AppColors.yellow : AppColors.danger,
      backgroundColor: isOpen ? AppColors.green100 : AppColors.dangerSoft,
      textColor: isOpen ? AppColors.green700 : AppColors.dangerText,
    );
  }
}
typedef UbQuantityStepper = QuantityStepper;
typedef UbStickyCartBar = CartBar;
typedef UbNavDestination = FloatingNavBarDestination;
typedef UbFloatingPillNav = FloatingNavBar;

class UbPrimaryButton extends StatelessWidget {
  const UbPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor = AppColors.orange,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

class UbSecondaryButton extends StatelessWidget {
  const UbSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    if (isDanger) {
      return AppButton.danger(
        label: label,
        onPressed: onPressed,
        icon: icon,
      );
    }
    return AppButton.secondary(
      label: label,
      onPressed: onPressed,
      icon: icon,
    );
  }
}

class UbGhostButton extends StatelessWidget {
  const UbGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.underlinedOrange = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool underlinedOrange;

  @override
  Widget build(BuildContext context) {
    return AppButton.ghost(
      label: label,
      onPressed: onPressed,
    );
  }
}

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
                        color: isSelected ? AppColors.green700 : AppColors.inkMuted,
                      ),
                      AppSpacing.h8,
                    ],
                    Flexible(
                      child: Text(
                        opt.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppColors.green700 : AppColors.inkMuted,
                        ),
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

class UbOrderStatusStepper extends StatelessWidget {
  const UbOrderStatusStepper({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = AppMotion.reduceMotion(context);
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

    final activeColor = switch (status) {
      OrderStatus.pending => AppColors.yellow,
      OrderStatus.accepted || OrderStatus.preparing => AppColors.orange,
      OrderStatus.ready => AppColors.green500,
      OrderStatus.completed => AppColors.inkMuted,
      OrderStatus.rejected || OrderStatus.cancelled => AppColors.danger,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(steps.length, (i) {
            final reached = i <= activeIdx;
            final isCurrent = i == activeIdx;
            final nodeColor = reached ? activeColor : AppColors.outline;

            Widget node = Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: reached ? nodeColor : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: nodeColor, width: 2),
              ),
              child: Icon(
                steps[i].$3,
                size: 14,
                color: reached
                    ? (status == OrderStatus.pending && isCurrent
                          ? AppColors.onYellow
                          : AppColors.surface)
                    : AppColors.inkMuted,
              ),
            );

            if (isCurrent &&
                !reduceMotion &&
                !AppMotion.isTestEnvironment &&
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
                        duration: AppMotion.normal,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i < activeIdx ? activeColor : AppColors.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        AppSpacing.v8,
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
                      fontWeight: s.$1 == status ? FontWeight.w700 : FontWeight.w500,
                      color: s.$1 == status ? AppColors.ink : AppColors.inkMuted,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class UbAnimatedCheck extends StatelessWidget {
  const UbAnimatedCheck({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.green500,
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.check,
        color: AppColors.surface,
        size: size * 0.52,
      ),
    );
  }
}
