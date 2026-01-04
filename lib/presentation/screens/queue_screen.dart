import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/song.dart';
import '../../providers/audio_provider.dart';
import '../../services/audio/audio_player_service.dart';
import '../../data/models/player_state.dart';

/// Queue management screen
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final audioService = ref.watch(audioPlayerServiceProvider);

    return playerState.when(
      data: (state) => _buildQueueView(context, ref, state, audioService),
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Queue',
            style: AppTextStyles.title2.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: _buildEmptyState(),
      ),
    );
  }

  Widget _buildQueueView(
    BuildContext context,
    WidgetRef ref,
    PlayerState state,
    AudioPlayerService audioService,
  ) {
    final queue = state.queue;
    final currentIndex = state.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Queue',
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        actions: [
          if (queue.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _showClearConfirmation(context, audioService);
              },
              icon: const Icon(Iconsax.trash, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
      body: queue.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Queue info
                _buildQueueInfo(queue, currentIndex, state.repeatMode),

                // Current song
                if (currentIndex < queue.length) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Now Playing',
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCurrentSongCard(queue[currentIndex], ref),
                ],

                // Upcoming songs
                if (currentIndex + 1 < queue.length) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Next in Queue (${queue.length - currentIndex - 1})',
                          style: AppTextStyles.caption1.copyWith(
                            color: AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Queue list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: queue.length - currentIndex - 1,
                    itemBuilder: (context, index) {
                      final queueIndex = currentIndex + 1 + index;
                      final song = queue[queueIndex];
                      final isPlaying = state.currentSong?.id == song.id;

                      return _buildQueueSongTile(
                        song: song,
                        queueIndex: queueIndex,
                        isPlaying: isPlaying,
                        audioService: audioService,
                        context: context,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQueueInfo(List<Song> queue, int currentIndex, RepeatMode repeatMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          _buildInfoItem(
            icon: Iconsax.music_playlist,
            label: 'Total',
            value: '${queue.length}',
          ),
          const SizedBox(width: 24),
          _buildInfoItem(
            icon: Iconsax.play_circle5,
            label: 'Position',
            value: '${currentIndex + 1}',
          ),
          const Spacer(),
          if (repeatMode != RepeatMode.off)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.repeate_one5,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Loop',
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryDark),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption2.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentSongCard(Song song, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          song.title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Iconsax.sound5,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildQueueSongTile({
    required Song song,
    required int queueIndex,
    required bool isPlaying,
    required AudioPlayerService audioService,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        audioService.skipToIndex(queueIndex);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardDark.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isPlaying)
              const Icon(
                Iconsax.sound5,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.music_playlist,
            size: 80,
            color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Queue is Empty',
            style: AppTextStyles.title2.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play a song to start your queue',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, AudioPlayerService audioService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear Queue?',
          style: AppTextStyles.title3.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'This will stop playback.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              audioService.stop();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: AppTextStyles.body.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
