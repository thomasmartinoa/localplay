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
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.3),
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
                      child: Container(
                        color: Colors.transparent,
                      ),
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
                border: Border.all(
                  color: borderColor,
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
            // Main blur layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Extra blur on left edge
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  bottomLeft: Radius.circular(borderRadius),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur * 1.5, sigmaY: blur * 1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Extra blur on right edge
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blur * 1.5, sigmaY: blur * 1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.white.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
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
                border: Border.all(
                  color: borderColor,
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
