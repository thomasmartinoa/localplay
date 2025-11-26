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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glass App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFE0E0E0)],
                    ).createShader(bounds),
                    child: const Text(
                      'Listen Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.glassDark.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.primaryGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

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
                        child: AlbumCard(
                          album: album,
                          size: 180,
                        ),
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
                      AppColors.glassDark.withOpacity(0.6),
                      AppColors.glassLight.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.glassBorder.withOpacity(0.2),
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
                            onTap: () => _playSong(context, ref, song, recentlyAdded),
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 180),
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
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primaryDark.withOpacity(0.2),
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
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _playSong(BuildContext context, WidgetRef ref, dynamic song, List<dynamic> queue) {
    final audioService = ref.read(audioPlayerServiceProvider);
    final songIndex = queue.indexOf(song);
    audioService.playQueue(queue.cast(), startIndex: songIndex);
  }
}
