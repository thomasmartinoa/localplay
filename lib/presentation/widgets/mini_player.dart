import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../providers/audio_provider.dart';

/// Floating glass mini player widget - Apple Music style
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);

    // Pure glass effect - fully transparent with strong blur
    // Like looking through thick clear glass
    const textColor = Colors.white;
    final secondaryTextColor = Colors.white.withValues(alpha: 0.6);

    return playerState.when(
      data: (state) {
        if (state.currentSong == null) {
          return const SizedBox.shrink();
        }

        final song = state.currentSong!;

        return LiquidGlass.withOwnLayer(
          settings: const LiquidGlassSettings(
            thickness: 20,
            blur: 7,
            glassColor: Color.fromARGB(61, 11, 7, 214),
            lightIntensity: 0.25,
            saturation: 1.0,
          ),
          shape: LiquidRoundedSuperellipse(borderRadius: 18),
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(
                children: [
                  // Tappable area (Album art + Song info) - Opens now playing screen
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/now-playing');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          // Album art
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _buildArtwork(song),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Song info
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Control buttons (NOT tappable for navigation)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Play/Pause button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(audioPlayerServiceProvider)
                              .togglePlayPause();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: textColor,
                            size: 32,
                          ),
                        ),
                      ),
                      // Next button
                      GestureDetector(
                        onTap: state.hasNext
                            ? () {
                                HapticFeedback.lightImpact();
                                ref.read(audioPlayerServiceProvider).next();
                              }
                            : null,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.fast_forward_rounded,
                            color: state.hasNext
                                ? textColor
                                : textColor.withValues(alpha: 0.3),
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withValues(alpha: 0.5),
        size: 18,
      ),
    );
  }

  Widget _buildArtwork(dynamic song) {
    if (song.isLocal && song.localArtworkPath != null) {
      return Image.file(
        File(song.localArtworkPath!),
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (song.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: song.artworkUrl!,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }
}
