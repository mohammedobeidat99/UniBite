import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:unibite/core/design_system/colors.dart';
import 'package:unibite/core/l10n/l10n_extensions.dart';

/// Displays the UniBite brand emblem and optional localized tagline.
class UniBiteLogo extends StatelessWidget {
  /// Creates a [UniBiteLogo] sized to [size] with optional [showTagline].
  const UniBiteLogo({super.key, this.size = 72, this.showTagline = false});

  /// Square width and height of the logo image.
  final double size;

  /// Whether to render the localized UniBite tagline below the emblem.
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            'assets/images/logo.jpg',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: UniBiteColors.primary900,
                borderRadius: BorderRadius.circular(size * 0.22),
              ),
              child: Icon(
                LucideIcons.utensils,
                size: size * 0.55,
                color: UniBiteColors.secondary,
              ),
            ),
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.appTagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: UniBiteColors.primary700,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
