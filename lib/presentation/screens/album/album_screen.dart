import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/album.dart';
import '../../../providers/audio_provider.dart';
import '../../widgets/song_tile.dart';

/// Album detail screen
class AlbumScreen extends ConsumerWidget {
  final String albumId;
  final Album? album;

  const AlbumScreen({super.key, required this.albumId, this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioPlayerServiceProvider);
    final displayAlbum = album;

    if (displayAlbum == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Collapsing app bar with album art
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Album artwork
                  if (displayAlbum.artworkUrl != null)
                    CachedNetworkImage(
                      imageUrl: displayAlbum.artworkUrl!,
                      fit: BoxFit.cover,
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.backgroundDark.withValues(alpha: 0.8),
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Album info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayAlbum.title,
                    style: AppTextStyles.title1.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayAlbum.artist,
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${displayAlbum.genre ?? 'Album'} • ${displayAlbum.releaseYear}',
                    style: AppTextStyles.subhead.copyWith(
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
                            if (displayAlbum.songs.isNotEmpty) {
                              audioService.playQueue(displayAlbum.songs);
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
                            if (displayAlbum.songs.isNotEmpty) {
                              audioService.setShuffle(true);
                              audioService.playQueue(displayAlbum.songs);
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
          if (displayAlbum.songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No songs available',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = displayAlbum.songs[index];
                return SongTile(
                  song: song,
                  showAlbumArt: false,
                  showTrackNumber: true,
                  onTap: () {
                    audioService.playQueue(
                      displayAlbum.songs,
                      startIndex: index,
                    );
                  },
                );
              }, childCount: displayAlbum.songs.length),
            ),

          // Album info footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.dividerDark),
                  const SizedBox(height: 8),
                  Text(
                    '${displayAlbum.songCount} songs, ${displayAlbum.formattedDuration}',
                    style: AppTextStyles.footnote.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  if (displayAlbum.copyright != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      displayAlbum.copyright!,
                      style: AppTextStyles.footnote.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
