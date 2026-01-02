import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/local_music_provider.dart';
import '../../../providers/audio_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/album_card.dart';
import '../../widgets/section_header.dart';

/// Home screen - "Listen Now" tab with glass theme
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSongs = ref.watch(localSongsProvider);
    final localAlbums = ref.watch(localAlbumsProvider);
    final recentlyAdded = ref.watch(recentlyAddedSongsProvider);

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Space for the floating header
              SliverToBoxAdapter(child: SizedBox(height: statusBarHeight + 60)),

              // Empty state if no music
              if (localSongs.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(context))
              else ...[
                // Albums section
                if (localAlbums.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SectionHeader(
                        title: 'Your Albums',
                        onSeeAll: () {},
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: localAlbums.take(10).length,
                        itemBuilder: (context, index) {
                          final album = localAlbums[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: AlbumCard(album: album, size: 180),
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // Recently Added section
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Recently Added',
                    onSeeAll: () {},
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.glassDark.withValues(alpha: 0.6),
                          AppColors.glassLight.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.glassBorder.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          children: List.generate(
                            recentlyAdded.take(5).length,
                            (index) {
                              final song = recentlyAdded[index];
                              return SongTile(
                                song: song,
                                onTap: () => _playSong(
                                  context,
                                  ref,
                                  song,
                                  recentlyAdded,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Bottom padding for mini player and nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 180)),
            ],
          ),

          // Floating header with smooth gradient fade
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: statusBarHeight + 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundGradientStart,
                      AppColors.backgroundGradientStart,
                      AppColors.backgroundGradientStart.withValues(alpha: 0.95),
                      AppColors.backgroundGradientStart.withValues(alpha: 0.7),
                      AppColors.backgroundGradientStart.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Title text on top of gradient
          Positioned(
            top: statusBarHeight + 8,
            left: 20,
            child: Text(
              'Listen Now',
              style: AppTextStyles.largeTitle.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primaryDark.withValues(alpha: 0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.music,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Your Music Awaits',
            style: AppTextStyles.title1.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan your device to discover\nand play your local music',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => context.go('/library'),
            icon: const Icon(Iconsax.scan),
            label: const Text('Get Started'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _playSong(
    BuildContext context,
    WidgetRef ref,
    dynamic song,
    List<dynamic> queue,
  ) {
    final audioService = ref.read(audioPlayerServiceProvider);
    final songIndex = queue.indexOf(song);
    audioService.playQueue(queue.cast(), startIndex: songIndex);
  }
}
