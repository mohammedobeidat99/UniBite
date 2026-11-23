import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:unibite/core/design_system/brand_artwork.dart';
import 'package:unibite/core/design_system/colors.dart';

/// Renders a meal or cafeteria image from a bundled asset, base64 data URI,
/// or consistent UniBite vector food illustration.
class MealImageWidget extends StatelessWidget {
  /// Creates a [MealImageWidget] for [imagePath] with dimensions [width] and [height].
  const MealImageWidget({
    super.key,
    required this.imagePath,
    this.width = 72,
    this.height = 72,
    this.borderRadius = 14,
  });

  /// Asset path, base64 `data:image/...` string, or `preset:<category>` identifier.
  final String imagePath;

  /// Target display width.
  final double width;

  /// Target display height.
  final double height;

  /// Corner radius applied to the rendered frame.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (imagePath.startsWith('data:image')) {
      final commaIndex = imagePath.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(imagePath.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _presetCard('preset:hotmeal'),
          );
        } catch (_) {
          return _presetCard('preset:hotmeal');
        }
      }
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _presetCard('preset:hotmeal'),
      );
    }

    return _presetCard(imagePath);
  }

  Widget _presetCard(String key) {
    return ColoredBox(
      color: UniBiteColors.primary50,
      child: CustomPaint(
        size: Size(width, height),
        painter: AppetizingFoodPainter(presetKey: key),
      ),
    );
  }
}
