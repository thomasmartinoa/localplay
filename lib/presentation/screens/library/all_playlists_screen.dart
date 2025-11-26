import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/playlist.dart';
import '../../../providers/library_provider.dart';

/// Screen showing all user playlists with management options
class AllPlaylistsScreen extends ConsumerWidget {
  const AllPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

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
                'Playlists',
                style: AppTextStyles.title1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            actions: [
              // Create new playlist button
              IconButton(
                icon: const Icon(Iconsax.add, color: AppColors.primary),
                onPressed: () => _showCreatePlaylistDialog(context, ref),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Playlist count header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${playlists.length} ${playlists.length == 1 ? 'playlist' : 'playlists'}',
                style: AppTextStyles.subhead.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(color: AppColors.dividerDark, height: 1),
          ),

          // Playlists list
          if (playlists.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.music_playlist,
                      size: 64,
                      color: AppColors.textSecondaryDark.withOpacity(0.5),
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
                        color: AppColors.textSecondaryDark.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showCreatePlaylistDialog(context, ref),
                      icon: const Icon(Iconsax.add),
                      label: const Text('Create Playlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                  final playlist = playlists[index];
                  return _PlaylistListItem(
                    playlist: playlist,
                    onTap: () => context.push('/playlist/${playlist.id}', extra: playlist),
                    onEdit: () => _showEditPlaylistDialog(context, ref, playlist),
                    onDelete: () => _showDeleteConfirmation(context, ref, playlist),
                  );
                },
                childCount: playlists.length,
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

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dividerDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dividerDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(playlistsProvider.notifier).createPlaylist(
                  nameController.text,
                  description: descriptionController.text.isNotEmpty 
                      ? descriptionController.text 
                      : null,
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

  void _showEditPlaylistDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(text: playlist.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Edit Playlist',
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dividerDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: AppColors.textPrimaryDark),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dividerDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(playlistsProvider.notifier).updatePlaylist(
                  playlist.id,
                  name: nameController.text,
                  description: descriptionController.text.isNotEmpty 
                      ? descriptionController.text 
                      : null,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Delete Playlist',
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${playlist.name}"'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.glassDark,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Playlist list item widget
class _PlaylistListItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlaylistListItem({
    required this.playlist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      onLongPress: () => _showOptionsSheet(context),
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildArtwork(),
        ),
      ),
      title: Text(
        playlist.name,
        style: AppTextStyles.headline.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
        style: AppTextStyles.subhead.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: AppColors.textSecondaryDark),
        onPressed: () => _showOptionsSheet(context),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
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
                  // Playlist info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildArtwork(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.textPrimaryDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${playlist.songCount} songs',
                                style: AppTextStyles.subhead.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.dividerDark, height: 1),
                  // Options
                  ListTile(
                    leading: const Icon(Iconsax.edit, color: AppColors.textPrimaryDark),
                    title: Text(
                      'Edit Playlist',
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimaryDark),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.trash, color: Colors.red),
                    title: Text(
                      'Delete Playlist',
                      style: AppTextStyles.body.copyWith(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    // Check if playlist has songs with artwork
    if (playlist.songs.isNotEmpty) {
      final firstSong = playlist.songs.first;
      if (firstSong.localArtworkPath != null) {
        final file = File(firstSong.localArtworkPath!);
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
            AppColors.primary.withOpacity(0.3),
            AppColors.primaryDark.withOpacity(0.5),
          ],
        ),
      ),
      child: Icon(
        Iconsax.music_playlist,
        color: AppColors.textPrimaryDark.withOpacity(0.7),
        size: 28,
      ),
    );
  }
}
