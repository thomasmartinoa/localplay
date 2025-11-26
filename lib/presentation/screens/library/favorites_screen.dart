import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/library_provider.dart';
import '../../widgets/song_tile.dart';

/// Screen showing favorite songs
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteSongsProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                'Favorites',
                style: AppTextStyles.title1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accentPink.withOpacity(0.4),
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.only(top: 40),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 80,
                      color: AppColors.accentPink.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Song count and play all header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${favorites.length} ${favorites.length == 1 ? 'song' : 'songs'}',
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                  // Shuffle all button
                  IconButton(
                    onPressed: favorites.isNotEmpty
                        ? () {
                            audioService.setShuffle(true);
                            audioService.playQueue(favorites);
                          }
                        : null,
                    icon: const Icon(Iconsax.shuffle, color: AppColors.primary),
                    tooltip: 'Shuffle All',
                  ),
                  // Play all button
                  IconButton(
                    onPressed: favorites.isNotEmpty
                        ? () => audioService.playQueue(favorites)
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

          // Favorites list
          if (favorites.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: AppColors.textSecondaryDark.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Songs you like will appear here',
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
                  final song = favorites[index];
                  return Dismissible(
                    key: Key('favorite_${song.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: AppColors.accentPink.withOpacity(0.3),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.heart_broken_rounded,
                        color: AppColors.accentPink,
                      ),
                    ),
                    onDismissed: (_) {
                      ref.read(favoriteSongsProvider.notifier).removeFromFavorites(song.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed ${song.title} from favorites'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.glassDark,
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: AppColors.primary,
                            onPressed: () {
                              ref.read(favoriteSongsProvider.notifier).addToFavorites(song);
                            },
                          ),
                        ),
                      );
                    },
                    child: SongTile(
                      song: song,
                      onTap: () => audioService.playQueue(favorites, startIndex: index),
                    ),
                  );
                },
                childCount: favorites.length,
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
}
