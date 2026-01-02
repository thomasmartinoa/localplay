import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/album.dart';
import '../../../providers/local_music_provider.dart';

/// Enum for sorting albums
enum AlbumSortOption {
  title('Title'),
  artist('Artist'),
  year('Year'),
  songCount('Song Count');

  final String label;
  const AlbumSortOption(this.label);
}

/// Provider for album sort option
final albumSortOptionProvider = StateProvider<AlbumSortOption>(
  (ref) => AlbumSortOption.title,
);

/// Provider for sorted albums
final sortedAlbumsProvider = Provider<List<Album>>((ref) {
  final albums = ref.watch(localAlbumsProvider);
  final sortOption = ref.watch(albumSortOptionProvider);

  final sortedAlbums = List<Album>.from(albums);
  switch (sortOption) {
    case AlbumSortOption.title:
      sortedAlbums.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    case AlbumSortOption.artist:
      sortedAlbums.sort(
        (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
      );
    case AlbumSortOption.year:
      sortedAlbums.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
    case AlbumSortOption.songCount:
      sortedAlbums.sort((a, b) => b.songCount.compareTo(a.songCount));
  }

  return sortedAlbums;
});

/// Screen showing all local albums
class AllAlbumsScreen extends ConsumerWidget {
  const AllAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(sortedAlbumsProvider);
    final sortOption = ref.watch(albumSortOptionProvider);

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
                'Albums',
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

          // Album count header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${albums.length} albums',
                    style: AppTextStyles.subhead.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sorted by ${sortOption.label}',
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(color: AppColors.dividerDark, height: 1),
          ),

          // Albums grid
          if (albums.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.cd,
                      size: 64,
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No albums yet',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan your device to find music',
                      style: AppTextStyles.subhead.copyWith(
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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final album = albums[index];
                  return _AlbumGridItem(album: album);
                }, childCount: albums.length),
              ),
            ),

          // Bottom padding for mini player
          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(albumSortOptionProvider);

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
                color: AppColors.glassHighlight.withValues(alpha: 0.5),
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
            ...AlbumSortOption.values.map(
              (option) => ListTile(
                leading: Icon(
                  _getSortIcon(option),
                  color: currentSort == option
                      ? AppColors.primary
                      : AppColors.textSecondaryDark,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    color: currentSort == option
                        ? AppColors.primary
                        : AppColors.textPrimaryDark,
                    fontWeight: currentSort == option
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: currentSort == option
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(albumSortOptionProvider.notifier).state = option;
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(AlbumSortOption option) {
    switch (option) {
      case AlbumSortOption.title:
        return Iconsax.text;
      case AlbumSortOption.artist:
        return Iconsax.user;
      case AlbumSortOption.year:
        return Iconsax.calendar;
      case AlbumSortOption.songCount:
        return Iconsax.music_square;
    }
  }
}

/// Album grid item widget
class _AlbumGridItem extends StatelessWidget {
  final Album album;

  const _AlbumGridItem({required this.album});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/album/${album.id}', extra: album),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album artwork
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildArtwork(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Album title
          Text(
            album.title,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Artist name
          Text(
            album.artist,
            style: AppTextStyles.subhead.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork() {
    // Check for local artwork first
    if (album.localArtworkPath != null) {
      final file = File(album.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
