import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/artist.dart';
import '../../../providers/local_music_provider.dart';

/// Enum for sorting artists
enum ArtistSortOption {
  name('Name'),
  albumCount('Album Count');

  final String label;
  const ArtistSortOption(this.label);
}

/// Provider for artist sort option
final artistSortOptionProvider = StateProvider<ArtistSortOption>(
  (ref) => ArtistSortOption.name,
);

/// Provider for sorted artists
final sortedArtistsProvider = Provider<List<Artist>>((ref) {
  final artists = ref.watch(localArtistsProvider);
  final sortOption = ref.watch(artistSortOptionProvider);

  final sortedArtists = List<Artist>.from(artists);
  switch (sortOption) {
    case ArtistSortOption.name:
      sortedArtists.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case ArtistSortOption.albumCount:
      sortedArtists.sort((a, b) => b.albumCount.compareTo(a.albumCount));
  }

  return sortedArtists;
});

/// Screen showing all local artists
class AllArtistsScreen extends ConsumerWidget {
  const AllArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(sortedArtistsProvider);
    final sortOption = ref.watch(artistSortOptionProvider);

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
                'Artists',
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

          // Artist count header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${artists.length} artists',
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

          // Artists list
          if (artists.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.user,
                      size: 64,
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No artists yet',
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
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final artist = artists[index];
                return _ArtistListItem(artist: artist);
              }, childCount: artists.length),
            ),

          // Bottom padding for mini player
          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(artistSortOptionProvider);

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
            ...ArtistSortOption.values.map(
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
                  ref.read(artistSortOptionProvider.notifier).state = option;
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

  IconData _getSortIcon(ArtistSortOption option) {
    switch (option) {
      case ArtistSortOption.name:
        return Iconsax.text;
      case ArtistSortOption.albumCount:
        return Iconsax.cd;
    }
  }
}

/// Artist list item widget
class _ArtistListItem extends StatelessWidget {
  final Artist artist;

  const _ArtistListItem({required this.artist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () => context.push('/artist/${artist.id}', extra: artist),
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipOval(child: _buildArtwork()),
      ),
      title: Text(
        artist.name,
        style: AppTextStyles.headline.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${artist.albumCount} ${artist.albumCount == 1 ? 'album' : 'albums'}',
        style: AppTextStyles.subhead.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondaryDark,
      ),
    );
  }

  Widget _buildArtwork() {
    // Check for local artwork first
    if (artist.imageUrl != null) {
      final file = File(artist.imageUrl!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primaryDark.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Icon(
        Iconsax.user,
        color: AppColors.textPrimaryDark.withValues(alpha: 0.7),
        size: 28,
      ),
    );
  }
}
