import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/album.dart';

/// Glass-styled album card widget for displaying albums
class AlbumCard extends StatefulWidget {
  final Album album;
  final double size;
  final bool showArtist;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.album,
    this.size = 160,
    this.showArtist = true,
    this.onTap,
  });

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap ?? () => context.push('/album/${widget.album.id}', extra: widget.album),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.size,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Album artwork with shadow and rounded corners
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowDark.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildArtwork(),
                ),
              ),
              const SizedBox(height: 10),
              // Album title
              Text(
                widget.album.title,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Artist name
              if (widget.showArtist)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    widget.album.artist,
                    style: TextStyle(
                      color: AppColors.textSecondaryDark.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    // Check for local artwork first
    if (widget.album.isLocal && widget.album.localArtworkPath != null) {
      final file = File(widget.album.localArtworkPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _buildPlaceholder(),
        );
      }
    }
    
    // Fall back to network image
    if (widget.album.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.album.artworkUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassDark,
            AppColors.glassLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.album_rounded,
        color: AppColors.textSecondaryDark.withOpacity(0.5),
        size: widget.size * 0.35,
      ),
    );
  }
}
