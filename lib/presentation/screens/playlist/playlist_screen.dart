import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/playlist.dart';
import '../../../domain/entities/song.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/local_music_provider.dart';
import '../../widgets/song_tile.dart';

/// Playlist detail screen with edit capabilities
class PlaylistScreen extends ConsumerStatefulWidget {
  final String playlistId;
  final Playlist? playlist;

  const PlaylistScreen({
    super.key,
    required this.playlistId,
    this.playlist,
  });

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioPlayerServiceProvider);
    // Watch the playlist from provider to get real-time updates
    final updatedPlaylist = ref.watch(playlistProvider(widget.playlistId));
    final displayPlaylist = updatedPlaylist ?? widget.playlist;

    if (displayPlaylist == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            actions: [
              // Edit button
              IconButton(
                icon: Icon(
                  _isEditing ? Iconsax.tick_circle : Iconsax.edit,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
              // More options button
              IconButton(
                icon: const Icon(Icons.more_horiz, color: AppColors.primary),
                onPressed: () => _showPlaylistOptions(context, displayPlaylist),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Playlist artwork from first song
                  _buildPlaylistArtwork(displayPlaylist),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.backgroundDark.withOpacity(0.8),
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlist info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayPlaylist.name,
                    style: AppTextStyles.title1.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  if (displayPlaylist.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      displayPlaylist.description!,
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${displayPlaylist.songCount} songs • ${displayPlaylist.formattedDuration}',
                    style: AppTextStyles.footnote.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Play and shuffle buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: displayPlaylist.songs.isNotEmpty
                              ? () => audioService.playQueue(displayPlaylist.songs)
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
                          onPressed: displayPlaylist.songs.isNotEmpty
                              ? () {
                                  audioService.setShuffle(true);
                                  audioService.playQueue(displayPlaylist.songs);
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
                  const SizedBox(height: 12),
                  // Add songs button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddSongsSheet(context, displayPlaylist),
                      icon: const Icon(Iconsax.add),
                      label: const Text('Add Songs'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondaryDark,
                        side: BorderSide(color: AppColors.dividerDark),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Songs list
          if (displayPlaylist.songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.textSecondaryDark,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This playlist is empty',
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add Songs" to get started',
                        style: AppTextStyles.subhead.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_isEditing)
            // Editable song list with reorder and delete
            SliverReorderableList(
              itemCount: displayPlaylist.songs.length,
              onReorder: (oldIndex, newIndex) {
                _reorderSongs(displayPlaylist, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final song = displayPlaylist.songs[index];
                return ReorderableDelayedDragStartListener(
                  key: Key('edit_${song.id}'),
                  index: index,
                  child: _buildEditableSongTile(
                    song,
                    displayPlaylist,
                    index,
                  ),
                );
              },
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = displayPlaylist.songs[index];
                  return SongTile(
                    song: song,
                    onTap: () {
                      audioService.playQueue(displayPlaylist.songs, startIndex: index);
                    },
                  );
                },
                childCount: displayPlaylist.songs.length,
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

  Widget _buildPlaylistArtwork(Playlist playlist) {
    // Try to get artwork from first song
    if (playlist.songs.isNotEmpty) {
      final firstSong = playlist.songs.first;
      if (firstSong.localArtworkPath != null) {
        final file = File(firstSong.localArtworkPath!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => _buildArtworkPlaceholder(),
          );
        }
      }
    }
    return _buildArtworkPlaceholder();
  }

  Widget _buildArtworkPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildEditableSongTile(Song song, Playlist playlist, int index) {
    return Container(
      color: AppColors.backgroundDark,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const Icon(
              Icons.drag_handle,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(width: 12),
            // Song artwork
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildSongArtwork(song),
              ),
            ),
          ],
        ),
        title: Text(
          song.title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: AppTextStyles.subhead.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.red,
          ),
          onPressed: () => _removeSongFromPlaylist(playlist, song),
        ),
      ),
    );
  }

  Widget _buildSongArtwork(Song song) {
    if (song.localArtworkPath != null) {
      final file = File(song.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stack) => _buildSongPlaceholder(),
        );
      }
    }
    return _buildSongPlaceholder();
  }

  Widget _buildSongPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassDark,
            AppColors.glassLight,
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.textSecondaryDark.withOpacity(0.5),
        size: 20,
      ),
    );
  }

  void _reorderSongs(Playlist playlist, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final songs = List<Song>.from(playlist.songs);
    final song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);
    
    // Update the playlist with reordered songs
    ref.read(playlistsProvider.notifier).updatePlaylistSongs(
      playlist.id,
      songs,
    );
  }

  void _removeSongFromPlaylist(Playlist playlist, Song song) {
    ref.read(playlistsProvider.notifier).removeSongFromPlaylist(
      playlist.id,
      song.id,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${song.title}" from playlist'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.glassDark,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            ref.read(playlistsProvider.notifier).addSongToPlaylist(
              playlist.id,
              song,
            );
          },
        ),
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, Playlist playlist) {
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
                  ListTile(
                    leading: const Icon(Iconsax.edit, color: AppColors.textPrimaryDark),
                    title: Text(
                      'Edit Playlist Name',
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimaryDark),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditPlaylistDialog(context, playlist);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.add, color: AppColors.textPrimaryDark),
                    title: Text(
                      'Add Songs',
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimaryDark),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddSongsSheet(context, playlist);
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
                      _showDeleteConfirmation(context, playlist);
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

  void _showEditPlaylistDialog(BuildContext context, Playlist playlist) {
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

  void _showDeleteConfirmation(BuildContext context, Playlist playlist) {
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
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from playlist screen
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

  void _showAddSongsSheet(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddSongsSheet(
        playlist: playlist,
        onAddSong: (song) {
          ref.read(playlistsProvider.notifier).addSongToPlaylist(
            playlist.id,
            song,
          );
        },
      ),
    );
  }
}

/// Sheet for adding songs to a playlist
class _AddSongsSheet extends ConsumerStatefulWidget {
  final Playlist playlist;
  final Function(Song) onAddSong;

  const _AddSongsSheet({
    required this.playlist,
    required this.onAddSong,
  });

  @override
  ConsumerState<_AddSongsSheet> createState() => _AddSongsSheetState();
}

class _AddSongsSheetState extends ConsumerState<_AddSongsSheet> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSongs = ref.watch(localSongsProvider);
    final playlistSongIds = widget.playlist.songs.map((s) => s.id).toSet();
    
    // Filter out songs already in playlist and apply search
    final availableSongs = allSongs.where((song) {
      if (playlistSongIds.contains(song.id)) return false;
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return song.title.toLowerCase().contains(query) ||
             song.artist.toLowerCase().contains(query) ||
             song.album.toLowerCase().contains(query);
    }).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Songs',
                        style: AppTextStyles.title2.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimaryDark),
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    hintStyle: TextStyle(color: AppColors.textSecondaryDark.withOpacity(0.5)),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textSecondaryDark),
                    filled: true,
                    fillColor: AppColors.glassDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${availableSongs.length} songs available',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: availableSongs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.music,
                              size: 48,
                              color: AppColors.textSecondaryDark.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'All songs added to playlist' 
                                  : 'No songs found',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: availableSongs.length,
                        itemBuilder: (context, index) {
                          final song = availableSongs[index];
                          return _AddSongTile(
                            song: song,
                            onAdd: () {
                              widget.onAddSong(song);
                              setState(() {}); // Refresh to remove added song
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "${song.title}"'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.glassDark,
                                  duration: const Duration(seconds: 1),
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
    );
  }
}

/// Tile for adding a song to playlist
class _AddSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onAdd;

  const _AddSongTile({
    required this.song,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildArtwork(),
        ),
      ),
      title: Text(
        song.title,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: AppTextStyles.subhead.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.primary,
        ),
        onPressed: onAdd,
      ),
    );
  }

  Widget _buildArtwork() {
    if (song.localArtworkPath != null) {
      final file = File(song.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassDark,
            AppColors.glassLight,
          ],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.textSecondaryDark.withOpacity(0.5),
        size: 20,
      ),
    );
  }
}
