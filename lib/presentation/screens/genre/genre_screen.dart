import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/song.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/local_music_provider.dart';
import '../../widgets/song_tile.dart';

/// Enum for sorting songs in genre
enum GenreSongSortOption {
  title('Title'),
  artist('Artist'),
  album('Album'),
  dateAdded('Date Added'),
  duration('Duration');

  final String label;
  const GenreSongSortOption(this.label);
}

/// Provider for genre song sort option
final genreSongSortOptionProvider = StateProvider<GenreSongSortOption>(
  (ref) => GenreSongSortOption.title,
);

/// Provider for sorted songs within a genre
final sortedGenreSongsProvider = Provider.family<List<Song>, String>((
  ref,
  genre,
) {
  final songs = ref.watch(songsByGenreProvider(genre));
  final sortOption = ref.watch(genreSongSortOptionProvider);

  final sortedSongs = List<Song>.from(songs);
  switch (sortOption) {
    case GenreSongSortOption.title:
      sortedSongs.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    case GenreSongSortOption.artist:
      sortedSongs.sort(
        (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
      );
    case GenreSongSortOption.album:
      sortedSongs.sort(
        (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
      );
    case GenreSongSortOption.dateAdded:
      sortedSongs.sort(
        (a, b) => (b.dateAdded ?? DateTime(1970)).compareTo(
          a.dateAdded ?? DateTime(1970),
        ),
      );
    case GenreSongSortOption.duration:
      sortedSongs.sort((a, b) => b.duration.compareTo(a.duration));
  }

  return sortedSongs;
});

/// Screen showing songs of a specific genre
class GenreScreen extends ConsumerWidget {
  final String genreName;
  final Color? genreColor;

  const GenreScreen({super.key, required this.genreName, this.genreColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(sortedGenreSongsProvider(genreName));
    final audioService = ref.watch(audioPlayerServiceProvider);
    final sortOption = ref.watch(genreSongSortOptionProvider);
    final color = genreColor ?? AppColors.accentBlue;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                genreName,
                style: AppTextStyles.title1.copyWith(
                  color: AppColors.textPrimaryDark,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.4),
                      AppColors.backgroundDark,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getGenreIcon(genreName),
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            actions: [
              // Sort button
              IconButton(
                icon: const Icon(Iconsax.sort, color: Colors.white),
                onPressed: () => _showSortOptions(context, ref),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Song count and play all header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                          style: AppTextStyles.subhead.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          'Sorted by ${sortOption.label}',
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondaryDark.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Shuffle all button
                  IconButton(
                    onPressed: songs.isNotEmpty
                        ? () {
                            audioService.setShuffle(true);
                            audioService.playQueue(songs);
                          }
                        : null,
                    icon: Icon(Iconsax.shuffle, color: color),
                    tooltip: 'Shuffle All',
                  ),
                  // Play all button
                  IconButton(
                    onPressed: songs.isNotEmpty
                        ? () => audioService.playQueue(songs)
                        : null,
                    icon: Icon(Iconsax.play_circle, color: color),
                    tooltip: 'Play All',
                  ),
                ],
              ),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(color: AppColors.dividerDark, height: 1),
          ),

          // Songs list
          if (songs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.music,
                      size: 64,
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No songs in this genre',
                      style: AppTextStyles.title3.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Songs will appear here when scanned',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondaryDark.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  onTap: () => audioService.playQueue(songs, startIndex: index),
                );
              }, childCount: songs.length),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.glassDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sort By',
                  style: AppTextStyles.title3.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
              const Divider(color: AppColors.dividerDark, height: 1),
              ...GenreSongSortOption.values.map((option) {
                final isSelected =
                    ref.read(genreSongSortOptionProvider) == option;
                return ListTile(
                  leading: Icon(
                    _getSortIcon(option),
                    color: isSelected
                        ? genreColor ?? AppColors.accentBlue
                        : AppColors.textSecondaryDark,
                  ),
                  title: Text(
                    option.label,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected
                          ? genreColor ?? AppColors.accentBlue
                          : AppColors.textPrimaryDark,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: genreColor ?? AppColors.accentBlue,
                        )
                      : null,
                  onTap: () {
                    ref.read(genreSongSortOptionProvider.notifier).state =
                        option;
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  IconData _getSortIcon(GenreSongSortOption option) {
    switch (option) {
      case GenreSongSortOption.title:
        return Iconsax.text;
      case GenreSongSortOption.artist:
        return Iconsax.user;
      case GenreSongSortOption.album:
        return Iconsax.music_dashboard;
      case GenreSongSortOption.dateAdded:
        return Iconsax.calendar;
      case GenreSongSortOption.duration:
        return Iconsax.timer;
    }
  }

  IconData _getGenreIcon(String genre) {
    final lowerGenre = genre.toLowerCase();

    if (lowerGenre.contains('rock') || lowerGenre.contains('metal')) {
      return Iconsax.music;
    } else if (lowerGenre.contains('pop')) {
      return Iconsax.star;
    } else if (lowerGenre.contains('hip') || lowerGenre.contains('rap')) {
      return Iconsax.microphone;
    } else if (lowerGenre.contains('jazz') || lowerGenre.contains('blues')) {
      return Iconsax.music_dashboard;
    } else if (lowerGenre.contains('classical') ||
        lowerGenre.contains('orchestra')) {
      return Iconsax.note;
    } else if (lowerGenre.contains('electronic') ||
        lowerGenre.contains('edm') ||
        lowerGenre.contains('house')) {
      return Iconsax.cpu;
    } else if (lowerGenre.contains('country') || lowerGenre.contains('folk')) {
      return Iconsax.tree;
    } else {
      return Iconsax.music_circle;
    }
  }
}
