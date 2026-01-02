import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/artist.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/local_music_provider.dart';
import '../../widgets/song_tile.dart';

/// Artist detail screen showing local artist info and songs
class ArtistScreen extends ConsumerWidget {
  final String artistId;
  final Artist? artist;

  const ArtistScreen({super.key, required this.artistId, this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayArtist = artist;
    final audioService = ref.watch(audioPlayerServiceProvider);
    final artistSongs = ref.watch(songsByArtistProvider(artistId));
    final artistAlbums = ref.watch(albumsByArtistProvider(artistId));

    if (displayArtist == null) {
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
          // App bar with artist image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                displayArtist.name,
                style: AppTextStyles.title2.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Artist image from first album or placeholder
                  _buildArtistImage(displayArtist, artistAlbums),
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

          // Artist info and controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Song/Album count
                  Text(
                    '${artistSongs.length} ${artistSongs.length == 1 ? 'song' : 'songs'} • ${artistAlbums.length} ${artistAlbums.length == 1 ? 'album' : 'albums'}',
                    style: AppTextStyles.subhead.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Play and shuffle buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: artistSongs.isNotEmpty
                              ? () => audioService.playQueue(artistSongs)
                              : null,
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
                          onPressed: artistSongs.isNotEmpty
                              ? () {
                                  audioService.setShuffle(true);
                                  audioService.playQueue(artistSongs);
                                }
                              : null,
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

          // Albums section
          if (artistAlbums.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Albums',
                  style: AppTextStyles.title3.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: artistAlbums.length,
                  itemBuilder: (context, index) {
                    final album = artistAlbums[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () =>
                            context.push('/album/${album.id}', extra: album),
                        child: SizedBox(
                          width: 130,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowDark.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildAlbumArtwork(album),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                album.title,
                                style: AppTextStyles.subhead.copyWith(
                                  color: AppColors.textPrimaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (album.releaseYear > 0)
                                Text(
                                  album.releaseYear.toString(),
                                  style: AppTextStyles.caption1.copyWith(
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Songs section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Songs',
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ),

          if (artistSongs.isEmpty)
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
                final song = artistSongs[index];
                return SongTile(
                  song: song,
                  onTap: () =>
                      audioService.playQueue(artistSongs, startIndex: index),
                );
              }, childCount: artistSongs.length),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }

  Widget _buildArtistImage(Artist artist, List<dynamic> albums) {
    // Try to use first album artwork
    if (albums.isNotEmpty) {
      final firstAlbum = albums.first;
      if (firstAlbum.localArtworkPath != null) {
        final file = File(firstAlbum.localArtworkPath!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => _buildArtistPlaceholder(),
          );
        }
      }
    }

    // Check artist image
    if (artist.imageUrl != null) {
      final file = File(artist.imageUrl!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildArtistPlaceholder(),
        );
      }
    }

    return _buildArtistPlaceholder();
  }

  Widget _buildArtistPlaceholder() {
    return Container(
      color: AppColors.surfaceDark,
      child: Center(
        child: Icon(
          Iconsax.user,
          color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          size: 80,
        ),
      ),
    );
  }

  Widget _buildAlbumArtwork(dynamic album) {
    if (album.localArtworkPath != null) {
      final file = File(album.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 130,
          height: 130,
          errorBuilder: (context, error, stack) => _buildAlbumPlaceholder(),
        );
      }
    }
    return _buildAlbumPlaceholder();
  }

  Widget _buildAlbumPlaceholder() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassDark, AppColors.glassLight],
        ),
      ),
      child: Icon(
        Iconsax.cd,
        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
        size: 48,
      ),
    );
  }
}
