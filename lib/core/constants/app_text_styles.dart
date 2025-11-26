import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App typography styles inspired by Apple's SF Pro Display
class AppTextStyles {
  AppTextStyles._();

  // Font Family - using system default (will use Roboto on Android, SF Pro on iOS)
  static const String? fontFamily = null;

  // Large Title - 34pt Bold
  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.37,
  );

  // Title 1 - 28pt Bold
  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.36,
  );

  // Title 2 - 22pt Bold
  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.35,
  );

  // Title 3 - 20pt Semibold
  static const TextStyle title3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
  );

  // Headline - 17pt Semibold
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  // Body - 17pt Regular
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
  );

  // Callout - 16pt Regular
  static const TextStyle callout = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.32,
  );

  // Subhead - 15pt Regular
  static const TextStyle subhead = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.24,
  );

  // Footnote - 13pt Regular
  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
  );

  // Caption 1 - 12pt Regular
  static const TextStyle caption1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  // Caption 2 - 11pt Regular
  static const TextStyle caption2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.07,
  );

  // Song Title Style
  static const TextStyle songTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
  );

  // Artist Name Style
  static const TextStyle artistName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.15,
    color: AppColors.textSecondaryDark,
  );

  // Player Title Style
  static const TextStyle playerTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
  );

  // Player Artist Style
  static const TextStyle playerArtist = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.32,
    color: AppColors.textSecondaryDark,
  );

  // Button Text Style
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
  );

  // Tab Label Style
  static const TextStyle tabLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
  );
}
