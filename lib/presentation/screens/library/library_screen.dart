import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/library_provider.dart';
import '../../widgets/playlist_tile.dart';

/// Library screen - user's music library
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final favorites = ref.watch(favoriteSongsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Library',
                style: AppTextStyles.largeTitle.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showCreatePlaylistDialog(context, ref),
                icon: const Icon(
                  Iconsax.add,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Library sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildLibraryItem(
                  context,
                  icon: Iconsax.music_playlist,
                  title: 'Playlists',
                  subtitle: '${playlists.length} playlists',
                  onTap: () {},
                ),
                _buildLibraryItem(
                  context,
                  icon: Iconsax.music,
                  title: 'Artists',
                  subtitle: 'Your favorite artists',
                  onTap: () {},
                ),
                _buildLibraryItem(
                  context,
                  icon: Iconsax.cd,
                  title: 'Albums',
                  subtitle: 'Your saved albums',
                  onTap: () {},
                ),
                _buildLibraryItem(
                  context,
                  icon: Iconsax.music_square,
                  title: 'Songs',
                  subtitle: '${favorites.length} songs',
                  onTap: () {},
                ),
                _buildLibraryItem(
                  context,
                  icon: Iconsax.arrow_down_2,
                  title: 'Downloaded',
                  subtitle: 'Music available offline',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(
              color: AppColors.dividerDark,
              height: 32,
              indent: 16,
              endIndent: 16,
            ),
          ),

          // Recently Added section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Added',
                    style: AppTextStyles.title3.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlists list
          if (playlists.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Iconsax.music_playlist,
                        size: 64,
                        color: AppColors.textSecondaryDark,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No playlists yet',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a playlist to organize your music',
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
                  final playlist = playlists[index];
                  return PlaylistTile(
                    playlist: playlist,
                    onTap: () {
                      // Navigate to playlist
                    },
                  );
                },
                childCount: playlists.length,
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

  Widget _buildLibraryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.headline.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.subhead.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondaryDark,
      ),
      onTap: onTap,
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'New Playlist',
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(playlistsProvider.notifier).createPlaylist(
                      controller.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
