import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/entities.dart';
import '../../providers/library_provider.dart';

/// Bottom sheet for adding a song to a playlist
class AddToPlaylistSheet extends ConsumerStatefulWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  ConsumerState<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<AddToPlaylistSheet> {
  final _nameController = TextEditingController();
  bool _showCreateNew = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.glassDark.withValues(alpha: 0.95),
                  AppColors.surfaceDark.withValues(alpha: 0.98),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.glassHighlight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassHighlight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add to Playlist',
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showCreateNew = !_showCreateNew),
                        icon: Icon(
                          _showCreateNew ? Icons.close : Iconsax.add,
                          size: 18,
                        ),
                        label: Text(_showCreateNew ? 'Cancel' : 'New'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Create new playlist input
                if (_showCreateNew)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.glassDark.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.glassBorder.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: AppColors.textPrimaryDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Playlist name',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondaryDark.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              autofocus: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            if (_nameController.text.isNotEmpty) {
                              ref
                                  .read(playlistsProvider.notifier)
                                  .createPlaylist(_nameController.text);
                              _nameController.clear();
                              setState(() => _showCreateNew = false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_showCreateNew) const SizedBox(height: 16),

                // Playlists list
                Expanded(
                  child: playlists.isEmpty && !_showCreateNew
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.music_playlist,
                                size: 48,
                                color: AppColors.textSecondaryDark.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No playlists yet',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "New" to create one',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];
                            final isInPlaylist = playlist.songs.any(
                              (s) => s.id == widget.song.id,
                            );

                            return ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.3),
                                      AppColors.primaryDark.withValues(
                                        alpha: 0.2,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Iconsax.music_playlist,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                playlist.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${playlist.songCount} songs',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: isInPlaylist
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    )
                                  : Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.textSecondaryDark
                                          .withValues(alpha: 0.5),
                                    ),
                              onTap: () {
                                if (isInPlaylist) {
                                  ref
                                      .read(playlistsProvider.notifier)
                                      .removeSongFromPlaylist(
                                        playlist.id,
                                        widget.song.id,
                                      );
                                } else {
                                  ref
                                      .read(playlistsProvider.notifier)
                                      .addSongToPlaylist(
                                        playlist.id,
                                        widget.song,
                                      );
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isInPlaylist
                                          ? 'Removed from ${playlist.name}'
                                          : 'Added to ${playlist.name}',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.glassDark,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
