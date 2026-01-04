import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/sleep_timer_provider.dart';
import '../../../data/models/player_state.dart';
import '../../widgets/sleep_timer_sheet.dart';

/// Full-screen glass-styled now playing screen
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);
    final favoriteSongs = ref.watch(favoriteSongsProvider);

    return playerState.when(
      data: (state) {
        if (state.currentSong == null) {
          return _buildEmptyState(context);
        }

        final song = state.currentSong!;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background with album art blur
              Positioned.fill(child: _buildBackgroundImage(song)),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Frosted glass effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Header with close button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGlassIconButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            onPressed: () => context.pop(),
                            size: 44,
                          ),
                          Column(
                            children: [
                              Text(
                                'PLAYING FROM',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.album,
                                style: const TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          _buildGlassIconButton(
                            icon: Icons.more_horiz,
                            onPressed: () => _showOptions(context),
                            size: 44,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Album artwork with glow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 60,
                                spreadRadius: -10,
                                offset: const Offset(0, 20),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: -5,
                                offset: const Offset(0, 25),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildArtworkImage(song),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Song info and controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          // Song title and artist
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimaryDark,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      song.artist,
                                      style: TextStyle(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Favorite button with glow
                              _buildGlassIconButton(
                                icon: favoriteSongs.any((s) => s.id == song.id)
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                onPressed: () {
                                  ref
                                      .read(favoriteSongsProvider.notifier)
                                      .toggleFavorite(song);
                                },
                                size: 48,
                                isActive: favoriteSongs.any(
                                  (s) => s.id == song.id,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Progress bar
                          _buildProgressSlider(state, audioService),

                          const SizedBox(height: 24),

                          // Playback controls
                          _buildPlaybackControls(state, audioService),

                          const SizedBox(height: 28),

                          // Volume slider
                          _buildVolumeSlider(state, audioService),

                          const SizedBox(height: 24),

                          // Bottom actions
                          _buildBottomActions(context, ref),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 44,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primaryDark.withValues(alpha: 0.2),
                  ]
                : [AppColors.glassOverlay, AppColors.glassOverlayLight],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.glassHighlight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textPrimaryDark,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildProgressSlider(PlayerState state, dynamic audioService) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.textPrimaryDark,
            inactiveTrackColor: AppColors.sliderInactive.withValues(alpha: 0.4),
            thumbColor: AppColors.textPrimaryDark,
            overlayColor: AppColors.textPrimaryDark.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: state.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              audioService.seekToPercent(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.formattedPosition,
                style: TextStyle(
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                state.formattedRemaining,
                style: TextStyle(
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(PlayerState state, dynamic audioService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle button
        _buildGlassIconButton(
          icon: Iconsax.shuffle,
          onPressed: () => audioService.toggleShuffle(),
          size: 44,
          isActive: state.shuffleEnabled,
        ),
        // Previous button
        GestureDetector(
          onTap: state.hasPrevious ? () => audioService.previous() : null,
          child: Icon(
            Icons.skip_previous_rounded,
            color: state.hasPrevious
                ? AppColors.textPrimaryDark
                : AppColors.textSecondaryDark.withValues(alpha: 0.4),
            size: 42,
          ),
        ),
        // Play/Pause button with glow
        GestureDetector(
          onTap: () => audioService.togglePlayPause(),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFE8E8E8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.backgroundDark,
              size: 44,
            ),
          ),
        ),
        // Next button
        GestureDetector(
          onTap: state.hasNext ? () => audioService.next() : null,
          child: Icon(
            Icons.skip_next_rounded,
            color: state.hasNext
                ? AppColors.textPrimaryDark
                : AppColors.textSecondaryDark.withValues(alpha: 0.4),
            size: 42,
          ),
        ),
        // Repeat button
        _buildGlassIconButton(
          icon: state.repeatMode == RepeatMode.one
              ? Iconsax.repeate_one
              : Iconsax.repeat,
          onPressed: () => audioService.toggleRepeat(),
          size: 44,
          isActive: state.repeatMode != RepeatMode.off,
        ),
      ],
    );
  }

  Widget _buildVolumeSlider(PlayerState state, dynamic audioService) {
    return Row(
      children: [
        Icon(
          Icons.volume_down_rounded,
          color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
          size: 22,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.textSecondaryDark.withValues(
                alpha: 0.6,
              ),
              inactiveTrackColor: AppColors.sliderInactive.withValues(
                alpha: 0.3,
              ),
              thumbColor: AppColors.textSecondaryDark.withValues(alpha: 0.8),
              overlayColor: AppColors.textSecondaryDark.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: state.volume,
              onChanged: (value) => audioService.setVolume(value),
            ),
          ),
        ),
        Icon(
          Icons.volume_up_rounded,
          color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
          size: 22,
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(sleepTimerProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Sleep Timer Button
        Stack(
          children: [
            _buildGlassIconButton(
              icon: Iconsax.timer_1,
              onPressed: () => _showSleepTimer(context),
              size: 44,
              isActive: timerState.isActive,
            ),
            if (timerState.isActive)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 6, height: 6),
                ),
              ),
          ],
        ),
        _buildGlassIconButton(icon: Iconsax.driver, onPressed: () {}, size: 44),
        _buildGlassIconButton(
          icon: Iconsax.music_playlist,
          onPressed: () => context.push('/queue'),
          size: 44,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimaryDark,
              size: 32,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.glassDark.withValues(alpha: 0.6),
                      AppColors.glassLight.withValues(alpha: 0.4),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.music_off_rounded,
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No song playing',
                style: TextStyle(
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(dynamic song) {
    if (song.isLocal && song.localArtworkPath != null) {
      return Image.file(
        File(song.localArtworkPath!),
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.5),
        colorBlendMode: BlendMode.darken,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: AppColors.backgroundDark),
      );
    } else if (song.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: song.artworkUrl!,
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.5),
        colorBlendMode: BlendMode.darken,
        errorWidget: (context, url, error) =>
            Container(color: AppColors.backgroundDark),
      );
    }
    return Container(color: AppColors.backgroundDark);
  }

  Widget _buildArtworkImage(dynamic song) {
    if (song.isLocal && song.localArtworkPath != null) {
      return Image.file(
        File(song.localArtworkPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildArtworkPlaceholder(),
      );
    } else if (song.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: song.artworkUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildArtworkPlaceholder(),
        errorWidget: (context, url, error) => _buildArtworkPlaceholder(),
      );
    }
    return _buildArtworkPlaceholder();
  }

  Widget _buildArtworkPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassDark, AppColors.glassLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.textSecondaryDark.withValues(alpha: 0.4),
          size: 80,
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            ),
            child: const Text(
              'Options',
              style: TextStyle(color: AppColors.textPrimaryDark),
            ),
          ),
        ),
      ),
    );
  }

  void _showSleepTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SleepTimerSheet(),
    );
  }
}
