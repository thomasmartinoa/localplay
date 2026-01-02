import 'package:flutter/material.dart';

/// Glass theme color palette inspired by Apple Music
class AppColors {
  AppColors._();

  // Primary Accent Colors
  static const Color primary = Color(0xFFFF2D55);
  static const Color primaryLight = Color(0xFFFF6B8A);
  static const Color primaryDark = Color(0xFFD91E42);
  static const Color accent = Color(0xFFFF2D55);

  // Glass Background Colors
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundGradientStart = Color(0xFF0F0F1A);
  static const Color backgroundGradientEnd = Color(0xFF050508);
  static const Color backgroundLight = Color(0xFFF2F2F7);

  // Glass Surface Colors (for frosted glass effect)
  static const Color glassDark = Color(0xFF1A1A2E);
  static const Color glassLight = Color(0xFF16162A);
  static const Color glassBorder = Color(0xFF2A2A4A);
  static const Color glassHighlight = Color(0xFF3A3A5A);

  // Frosted Glass Overlays
  static const Color glassOverlay = Color(0x1AFFFFFF);
  static const Color glassOverlayLight = Color(0x0DFFFFFF);
  static const Color glassOverlayDark = Color(0x33000000);

  // Card & Surface Colors
  static const Color cardDark = Color(0xFF1C1C2E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF12121F);
  static const Color surfaceLight = Color(0xFFF8F8FA);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryDark = Color(0xFF9898B0);
  static const Color textSecondaryLight = Color(0xFF6C6C80);
  static const Color textTertiary = Color(0xFF5A5A70);

  // Accent Colors for variety
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentPurple = Color(0xFFBF5AF2);
  static const Color accentPink = Color(0xFFFF375F);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentGreen = Color(0xFF30D158);
  static const Color accentTeal = Color(0xFF64D2FF);
  static const Color accentIndigo = Color(0xFF5E5CE6);

  // Gradient Colors for glass effects
  static const List<Color> glassGradient = [
    Color(0x1A6366F1),
    Color(0x0AEC4899),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFFFF2D55),
    Color(0xFFFF6B8A),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1C1C1E),
    Color(0xFF000000),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF0F0F1A),
    Color(0xFF0A0A0F),
    Color(0xFF050508),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF1E1E32),
    Color(0xFF151525),
  ];

  // Divider & Border Colors
  static const Color dividerDark = Color(0xFF2A2A40);
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color borderDark = Color(0xFF3A3A50);
  static const Color borderLight = Color(0xFFD1D1D6);

  // Overlay Colors
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayMedium = Color(0x66000000);
  static const Color overlayLight = Color(0x33000000);

  // Player Colors
  static const Color playerBackground = Color(0xFF0F0F18);
  static const Color sliderActive = Color(0xFFFFFFFF);
  static const Color sliderInactive = Color(0xFF3A3A50);
  static const Color sliderGlow = Color(0x40FFFFFF);

  // Tab Bar Colors
  static const Color tabBarActiveDark = primary;
  static const Color tabBarActiveLight = primary;
  static const Color tabBarInactiveDark = Color(0xFF6A6A80);
  static const Color tabBarInactiveLight = Color(0xFF8E8E93);

  // Shadow Colors
  static const Color shadowDark = Color(0x40000000);
  static const Color shadowPrimary = Color(0x40FF2D55);
  static const Color shadowGlow = Color(0x20FFFFFF);
}
