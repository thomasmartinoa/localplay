import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/song.dart';
import '../../providers/audio_provider.dart';
import '../../providers/library_provider.dart';
import 'add_to_playlist_sheet.dart';

/// Glass-styled song tile widget for displaying a song in a list
class SongTile extends ConsumerStatefulWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;
  final bool showAlbumArt;
  final bool showTrackNumber;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMorePressed,
    this.showAlbumArt = true,
    this.showTrackNumber = false,
    this.isPlaying = false,
  });

  @override
  ConsumerState<SongTile> createState() => _SongTileState();
}

class _SongTileState extends ConsumerState<SongTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = ref.watch(favoriteSongsProvider);
    final isFavorite = favoriteSongs.any((s) => s.id == widget.song.id);

    return Dismissible(
      key: ValueKey('dismissible_${widget.song.id}'),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      movementDuration: const Duration(milliseconds: 200),
      resizeDuration: const Duration(milliseconds: 200),
      confirmDismiss: (direction) async {
        if (_isDismissing) return false;
        _isDismissing = true;
        
        // Toggle favorite instead of dismissing
        ref.read(favoriteSongsProvider.notifier).toggleFavorite(widget.song);
        
        // Reset flag after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _isDismissing = false);
          }
        });
        
        return false; // Don't actually dismiss
      },
      background: _buildSwipeBackground(isLeft: true, isFavorite: isFavorite),
      secondaryBackground: _buildSwipeBackground(isLeft: false, isFavorite: isFavorite),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (!_isDismissing) _controller.forward();
        },
        onTapUp: (_) {
          if (!_isDismissing) _controller.reverse();
        },
        onTapCancel: () {
          if (!_isDismissing) _controller.reverse();
        },
        onTap: () {
          if (!_isDismissing && widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
            children: [
              // Leading: Album art or track number
              if (widget.showAlbumArt)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowDark.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildArtwork(),
                  ),
                )
              else if (widget.showTrackNumber)
                SizedBox(
                  width: 32,
                  child: Center(
                    child: widget.isPlaying
                        ? _buildPlayingIndicator()
                        : Text(
                            '${widget.song.trackNumber ?? 0}',
                            style: TextStyle(
                              color: AppColors.textSecondaryDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              const SizedBox(width: 14),
              // Song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      style: TextStyle(
                        color: widget.isPlaying
                            ? AppColors.primary
                            : AppColors.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (widget.song.isExplicit) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondaryDark.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'E',
                              style: TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            widget.song.artist,
                            style: TextStyle(
                              color: AppColors.textSecondaryDark.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trailing: Duration and more button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.song.formattedDuration,
                    style: TextStyle(
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildMoreButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPlayingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.equalizer_rounded, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }

  Widget _buildArtwork() {
    // Check for local artwork first
    if (widget.song.isLocal && widget.song.localArtworkPath != null) {
      final file = File(widget.song.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }
    }

    // Fall back to network image
    if (widget.song.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.song.artworkUrl!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: widget.onMorePressed ?? () => _showSongOptions(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_horiz,
          color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassDark, AppColors.glassLight],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
        size: 24,
      ),
    );
  }

  Widget _buildSheetArtwork() {
    // Check for local artwork first
    if (widget.song.isLocal && widget.song.localArtworkPath != null) {
      final file = File(widget.song.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildSheetPlaceholder(),
        );
      }
    }

    // Fall back to network image
    if (widget.song.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.song.artworkUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildSheetPlaceholder(),
        errorWidget: (context, url, error) => _buildSheetPlaceholder(),
      );
    }

    return _buildSheetPlaceholder();
  }

  Widget _buildSheetPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassDark, AppColors.glassLight],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }

  void _showSongOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildOptionsSheet(context),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    return ClipRRect(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: AppColors.glassHighlight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassHighlight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Song info header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowDark.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildSheetArtwork(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.song.title,
                              style: const TextStyle(
                                color: AppColors.textPrimaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.song.artist,
                              style: TextStyle(
                                color: AppColors.textSecondaryDark.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(
                  color: AppColors.dividerDark.withValues(alpha: 0.5),
                  height: 1,
                ),
                // Options
                _buildOptionTile(
                  context: context,
                  icon: Icons.play_circle_outline_rounded,
                  title: 'Play Next',
                  onTap: () {
                    ref.read(audioPlayerServiceProvider).playNext(widget.song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.song.title} will play next'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.glassDark,
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  context: context,
                  icon: Icons.queue_music_rounded,
                  title: 'Add to Queue',
                  onTap: () {
                    ref
                        .read(audioPlayerServiceProvider)
                        .addToQueue(widget.song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${widget.song.title} to queue'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.glassDark,
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  context: context,
                  icon: Icons.playlist_add_rounded,
                  title: 'Add to Playlist',
                  onTap: () {
                    Navigator.pop(context);
                    AddToPlaylistSheet.show(context, widget.song);
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final isFavorite = ref.watch(
                      isSongFavoriteProvider(widget.song.id),
                    );
                    return _buildOptionTile(
                      context: context,
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      title: isFavorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                      iconColor: isFavorite ? AppColors.accentPink : null,
                      onTap: () {
                        ref
                            .read(favoriteSongsProvider.notifier)
                            .toggleFavorite(widget.song);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite
                                  ? 'Removed from Favorites'
                                  : 'Added to Favorites',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.glassDark,
                          ),
                        );
                      },
                    );
                  },
                ),
                _buildOptionTile(
                  context: context,
                  icon: Icons.album_rounded,
                  title: 'Go to Album',
                  onTap: () => Navigator.pop(context),
                ),
                _buildOptionTile(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'Go to Artist',
                  onTap: () => Navigator.pop(context),
                ),
                _buildOptionTile(
                  context: context,
                  icon: Icons.share_rounded,
                  title: 'Share Song',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? AppColors.textPrimaryDark,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft, required bool isFavorite}) {
    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.only(
        left: isLeft ? 28 : 0,
        right: isLeft ? 0 : 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: isFavorite
              ? [
                  Colors.red.withValues(alpha: 0.8),
                  Colors.red.withValues(alpha: 0.0),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
        ),
      ),
      child: Icon(
        isFavorite ? Icons.heart_broken_rounded : Icons.favorite_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
