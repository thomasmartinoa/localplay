import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/artist.dart';
import '../../widgets/album_card.dart';

/// Artist detail screen
class ArtistScreen extends ConsumerWidget {
  final String artistId;
  final Artist? artist;

  const ArtistScreen({
    super.key,
    required this.artistId,
    this.artist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayArtist = artist;

    if (displayArtist == null) {
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
          // App bar with artist image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                displayArtist.name,
                style: AppTextStyles.title2.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Artist image
                  if (displayArtist.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: displayArtist.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: AppColors.surfaceDark,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textSecondaryDark,
                        size: 100,
                      ),
                    ),
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

          // Artist info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Follower count and verified badge
                  Row(
                    children: [
                      if (displayArtist.isVerified) ...[
                        const Icon(
                          Icons.verified,
                          color: AppColors.accentBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        displayArtist.formattedFollowerCount,
                        style: AppTextStyles.subhead.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Play and follow buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
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
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Follow'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Albums section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Albums',
                style: AppTextStyles.title3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ),

          if (displayArtist.albums.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No albums available',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayArtist.albums.length,
                  itemBuilder: (context, index) {
                    final album = displayArtist.albums[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: AlbumCard(album: album),
                    );
                  },
                ),
              ),
            ),

          // Bio section
          if (displayArtist.bio != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: AppTextStyles.title3.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayArtist.bio!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
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
}
