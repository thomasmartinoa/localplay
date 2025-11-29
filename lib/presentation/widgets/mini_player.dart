import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/audio_provider.dart';
import 'vignette_blur_container.dart';

/// Floating glass mini player widget - Apple Music style
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    
    // Pure glass effect - fully transparent with strong blur
    // Like looking through thick clear glass
    const textColor = Colors.white;
    final secondaryTextColor = Colors.white.withOpacity(0.6);

    return playerState.when(
      data: (state) {
        if (state.currentSong == null) {
          return const SizedBox.shrink();
        }

        final song = state.currentSong!;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/now-playing');
          },
          child: EdgeBlurContainer(
            height: 64,
            borderRadius: 22,
            blur: 25,
            backgroundColor: Colors.white.withOpacity(0.06),
            child: Stack(
              children: [
                // Progress indicator at bottom
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 6,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: state.progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 8, 12),
                  child: Row(
                    children: [
                      // Album art
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildArtwork(song),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Song info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Control buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Play/Pause button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(audioPlayerServiceProvider).togglePlayPause();
                            },
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
                                    : textColor.withOpacity(0.3),
                                size: 32,
                              ),
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
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withOpacity(0.5),
        size: 22,
      ),
    );
  }

  Widget _buildArtwork(dynamic song) {
    if (song.isLocal && song.localArtworkPath != null) {
      return Image.file(
        File(song.localArtworkPath!),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (song.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: song.artworkUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }
}
