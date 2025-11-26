import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/local_music_provider.dart';
import '../../../services/local_music/local_music_scanner.dart';
import '../../widgets/playlist_tile.dart';
import '../../widgets/song_tile.dart';

/// Library screen - user's music library
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);
    final favorites = ref.watch(favoriteSongsProvider);
    final localSongs = ref.watch(localSongsProvider);
    final localAlbums = ref.watch(localAlbumsProvider);
    final localArtists = ref.watch(localArtistsProvider);
    final recentlyAdded = ref.watch(recentlyAddedSongsProvider);
    final scanProgressAsync = ref.watch(scanProgressProvider);

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
                onPressed: () => context.push('/settings'),
                icon: const Icon(
                  Iconsax.setting_2,
                  color: AppColors.primary,
                ),
              ),
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

          // Scan Progress Card
          scanProgressAsync.when(
            data: (progress) => progress.isScanning
                ? SliverToBoxAdapter(child: _buildScanProgressCard(progress))
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Empty State or Library Content
          if (localSongs.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState(context, ref))
          else ...[
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
                    subtitle: '${localArtists.length} artists',
                    onTap: () {},
                  ),
                  _buildLibraryItem(
                    context,
                    icon: Iconsax.cd,
                    title: 'Albums',
                    subtitle: '${localAlbums.length} albums',
                    onTap: () {},
                  ),
                  _buildLibraryItem(
                    context,
                    icon: Iconsax.music_square,
                    title: 'Songs',
                    subtitle: '${localSongs.length} songs',
                    onTap: () {},
                  ),
                  _buildLibraryItem(
                    context,
                    icon: Iconsax.heart,
                    title: 'Favorites',
                    subtitle: '${favorites.length} songs',
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

            // Recently Added Songs
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = recentlyAdded[index];
                  return SongTile(
                    song: song,
                    onTap: () => _playSong(ref, song, recentlyAdded),
                  );
                },
                childCount: recentlyAdded.take(10).length,
              ),
            ),

            // Playlists section
            if (playlists.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Divider(
                  color: AppColors.dividerDark,
                  height: 32,
                  indent: 16,
                  endIndent: 16,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Playlists',
                    style: AppTextStyles.title3.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final playlist = playlists[index];
                    return PlaylistTile(
                      playlist: playlist,
                      onTap: () => context.push('/playlist/${playlist.id}', extra: playlist),
                    );
                  },
                  childCount: playlists.length,
                ),
              ),
            ],
          ],

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 160),
          ),
        ],
      ),
    );
  }

  Widget _buildScanProgressCard(ScanProgress progress) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Scanning: ${progress.scannedFiles}/${progress.totalFiles}',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: AppColors.glassDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          if (progress.currentFile.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              progress.currentFile,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.music,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Music Yet',
            style: AppTextStyles.title2.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan your device to find and play\nyour local music collection',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _startQuickScan(ref),
            icon: const Icon(Iconsax.scan),
            label: const Text('Scan All Music'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Iconsax.folder_add),
            label: const Text('Select Folders'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
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

  Future<void> _startQuickScan(WidgetRef ref) async {
    final scanAction = ref.read(scanMusicActionProvider);
    await scanAction(useSelectedFolders: false);
  }

  void _playSong(WidgetRef ref, dynamic song, List<dynamic> queue) {
    // Will be connected to audio provider
  }
}
