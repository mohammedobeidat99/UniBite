import 'package:flutter/material.dart';

/// Professional design system color tokens for UniBite inspired by the brand emblem:
/// Deep Midnight Navy, Royal Campus Blue, and Vibrant Crimson Red.
///
/// 70% Canvas & Base:
///   - [green50]: Screen canvas background (#F8FAFC ice/slate tint).
///   - [surface]: Pure card, sheet, and input background (#FFFFFF).
///   - [outline]: Crisp 1px subtle border (#E2E8F0).
///   - [green900]: Deep Midnight Navy (#0B132B) for hero headers & sidebars.
///   - [green700]: Royal Campus Navy (#1A2F60) for sub-headers and focused icons.
///   - [green500]: Electric Royal Blue (#2563EB) for active indicators and badge accents.
///   - [green100]: Soft Ice/Periwinkle tint (#E0E7FF) for subtle pill backings.
///   - [ink], [inkSoft], [inkMuted]: Slate-navy text hierarchy.
///
/// 20% Secondary / Action:
///   - [orange]: Vibrant Brand Crimson Red (#EA2B38) from the "Bite" emblem and hoodie.
///   - [orangePressed]: Deepened Crimson (#C81E2A) on press.
///   - [orangeSoft]: Soft Coral/Rose tint (#FFF1F2) for badge backgrounds.
///   - [orangeText]: High-contrast Crimson (#BE123C) for price tags and status badges.
///
/// 10% Accent & Semantic:
///   - [yellow], [onYellow]: Amber Gold (#F59E0B) for ratings and prep-time tags.
///   - [danger], [dangerSoft], [dangerText]: Errors, cancellations, warnings.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // 70% Canvas & Base — Midnight Navy & Ice Surfaces
  // ---------------------------------------------------------------------------
  static const Color green900 = Color(0xFF0B132B); // Deep Midnight Navy (Logo canvas)
  static const Color green700 = Color(0xFF162544); // Midnight Blue sub-canvas
  static const Color green500 = Color(0xFF2563EB); // Royal Campus Blue (Cap motif)
  static const Color green100 = Color(0xFFE0E7FF); // Soft Ice Blue pill backing
  static const Color green50 = Color(0xFFF8FAFC);  // Crisp modern Slate canvas

  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE2E8F0);

  static const Color ink = Color(0xFF0F172A);      // Slate 900
  static const Color inkSoft = Color(0xFF334155);  // Slate 700
  static const Color inkMuted = Color(0xFF64748B); // Slate 500

  // ---------------------------------------------------------------------------
  // 20% Secondary / Action — Vibrant Brand Crimson Red ("Bite" Emblem)
  // ---------------------------------------------------------------------------
  static const Color orange = Color(0xFFEA2B38);        // Vibrant Crimson Red
  static const Color orangePressed = Color(0xFFC81E2A); // Crimson pressed
  static const Color orangeSoft = Color(0xFFFFF1F2);    // Rose/Coral soft background
  static const Color orangeText = Color(0xFFBE123C);    // High-contrast price crimson

  // ---------------------------------------------------------------------------
  // 10% Accent & Semantic
  // ---------------------------------------------------------------------------
  static const Color yellow = Color(0xFFF59E0B);
  static const Color onYellow = Color(0xFF451A03);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFB91C1C);

  // Muted secondary helpers
  static const Color completedMuted = Color(0xFF94A3B8);

  // Semantic aliases
  static const Color warning = yellow;
  static const Color success = Color(0xFF10B981);

  // Direct brand aliases for clear code expressiveness
  static const Color navy900 = green900;
  static const Color navy700 = green700;
  static const Color royalBlue = green500;
  static const Color royalBlueSoft = green100;
  static const Color crimson = orange;
  static const Color crimsonSoft = orangeSoft;
  static const Color crimsonText = orangeText;
}
