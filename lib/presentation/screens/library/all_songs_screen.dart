import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/song.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/local_music_provider.dart';
import '../../widgets/song_tile.dart';

/// Enum for sorting songs
enum SongSortOption {
  title('Title'),
  artist('Artist'),
  album('Album'),
  dateAdded('Date Added'),
  duration('Duration');

  final String label;
  const SongSortOption(this.label);
}

/// Provider for song sort option
final songSortOptionProvider = StateProvider<SongSortOption>((ref) => SongSortOption.title);

/// Provider for sorted songs
final sortedSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(localSongsProvider);
  final sortOption = ref.watch(songSortOptionProvider);
  
  final sortedSongs = List<Song>.from(songs);
  switch (sortOption) {
    case SongSortOption.title:
      sortedSongs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    case SongSortOption.artist:
      sortedSongs.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
    case SongSortOption.album:
      sortedSongs.sort((a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()));
    case SongSortOption.dateAdded:
      sortedSongs.sort((a, b) => (b.dateAdded ?? DateTime(1970)).compareTo(a.dateAdded ?? DateTime(1970)));
    case SongSortOption.duration:
      sortedSongs.sort((a, b) => b.duration.compareTo(a.duration));
  }
  
  return sortedSongs;
});

/// Screen showing all local songs
class AllSongsScreen extends ConsumerWidget {
  const AllSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(sortedSongsProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);
    final sortOption = ref.watch(songSortOptionProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                'Songs',
                style: AppTextStyles.title1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            actions: [
              // Sort button
              IconButton(
                icon: const Icon(Iconsax.sort, color: AppColors.primary),
                onPressed: () => _showSortOptions(context, ref),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Song count and play all header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${songs.length} songs',
                          style: AppTextStyles.subhead.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          'Sorted by ${sortOption.label}',
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondaryDark.withOpacity(0.7),
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
                    icon: const Icon(Iconsax.shuffle, color: AppColors.primary),
                    tooltip: 'Shuffle All',
                  ),
                  // Play all button
                  IconButton(
                    onPressed: songs.isNotEmpty
                        ? () => audioService.playQueue(songs)
                        : null,
                    icon: const Icon(Iconsax.play_circle, color: AppColors.primary),
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
                      color: AppColors.textSecondaryDark.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No songs yet',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan your device to find music',
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.textSecondaryDark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    onTap: () => audioService.playQueue(songs, startIndex: index),
                  );
                },
                childCount: songs.length,
              ),
            ),

          // Bottom padding for mini player
          const SliverToBoxAdapter(
            child: SizedBox(height: 160),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(songSortOptionProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassHighlight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sort By',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 16),
            ...SongSortOption.values.map((option) => ListTile(
              leading: Icon(
                _getSortIcon(option),
                color: currentSort == option ? AppColors.primary : AppColors.textSecondaryDark,
              ),
              title: Text(
                option.label,
                style: TextStyle(
                  color: currentSort == option ? AppColors.primary : AppColors.textPrimaryDark,
                  fontWeight: currentSort == option ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: currentSort == option
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(songSortOptionProvider.notifier).state = option;
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(SongSortOption option) {
    switch (option) {
      case SongSortOption.title:
        return Iconsax.text;
      case SongSortOption.artist:
        return Iconsax.user;
      case SongSortOption.album:
        return Iconsax.cd;
      case SongSortOption.dateAdded:
        return Iconsax.calendar;
      case SongSortOption.duration:
        return Iconsax.clock;
    }
  }
}
