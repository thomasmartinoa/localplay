import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/playlist.dart';
import '../../../providers/audio_provider.dart';
import '../../widgets/song_tile.dart';

/// Playlist detail screen
class PlaylistScreen extends ConsumerWidget {
  final String playlistId;
  final Playlist? playlist;

  const PlaylistScreen({
    super.key,
    required this.playlistId,
    this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioPlayerServiceProvider);
    final displayPlaylist = playlist;

    if (displayPlaylist == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Playlist artwork
                  if (displayPlaylist.displayArtwork != null)
                    CachedNetworkImage(
                      imageUrl: displayPlaylist.displayArtwork!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.backgroundDark.withOpacity(0.8),
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlist info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayPlaylist.name,
                    style: AppTextStyles.title1.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  if (displayPlaylist.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      displayPlaylist.description!,
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${displayPlaylist.songCount} songs • ${displayPlaylist.formattedDuration}',
                    style: AppTextStyles.footnote.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Play button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (displayPlaylist.songs.isNotEmpty) {
                              audioService.playQueue(displayPlaylist.songs);
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (displayPlaylist.songs.isNotEmpty) {
                              audioService.setShuffle(true);
                              audioService.playQueue(displayPlaylist.songs);
                            }
                          },
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text('Shuffle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Songs list
          if (displayPlaylist.songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.textSecondaryDark,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This playlist is empty',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add songs to get started',
                        style: AppTextStyles.subhead.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = displayPlaylist.songs[index];
                  return SongTile(
                    song: song,
                    onTap: () {
                      audioService.playQueue(displayPlaylist.songs, startIndex: index);
                    },
                  );
                },
                childCount: displayPlaylist.songs.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 160),
          ),
        ],
      ),
    );
  }
}
