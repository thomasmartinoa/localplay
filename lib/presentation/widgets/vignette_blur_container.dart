import 'dart:ui';
import 'package:flutter/material.dart';

/// A container with vignette blur effect - more blur at edges, clearer in center
class VignetteBlurContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final double borderRadius;
  final double edgeBlur;
  final double centerBlur;
  final Color backgroundColor;
  final Color borderColor;

  const VignetteBlurContainer({
    super.key,
    required this.child,
    required this.height,
    this.width,
    this.borderRadius = 18,
    this.edgeBlur = 5,
    this.centerBlur = 1,
    this.backgroundColor = const Color(0x05FFFFFF),
    this.borderColor = const Color(0x1AFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            // Base heavy blur layer (edges)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: edgeBlur, sigmaY: edgeBlur),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Center clearer area with gradient mask
            Positioned.fill(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: edgeBlur - centerBlur,
                        sigmaY: edgeBlur - centerBlur,
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            ),
            // Glass container with border
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simpler approach - layered blur with horizontal gradient
class EdgeBlurContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final double borderRadius;
  final double blur;
  final Color backgroundColor;
  final Color borderColor;

  const EdgeBlurContainer({
    super.key,
    required this.child,
    required this.height,
    this.width,
    this.borderRadius = 18,
    this.blur = 8,
    this.backgroundColor = const Color(0x05FFFFFF),
    this.borderColor = const Color(0x1AFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            // Main blur layer - uniform glass effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    // Subtle gradient overlay for depth
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ),
            // Content layer
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                // Very subtle inner shadow effect using gradient border
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
