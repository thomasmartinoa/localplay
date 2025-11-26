import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/audio_provider.dart';
import '../../widgets/song_tile.dart';

/// Glass-styled search screen for discovering music
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchHistory = ref.watch(searchHistoryProvider);

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
                      'Search',
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
          ),

          // Glass Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.glassDark.withOpacity(0.7),
                      AppColors.glassLight.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.glassBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Artists, Songs, Lyrics, and More',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondaryDark.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Iconsax.search_normal_1,
                          color: AppColors.textSecondaryDark.withOpacity(0.7),
                          size: 22,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchProvider.notifier).clearResults();
                                  setState(() {});
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondaryDark.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.textPrimaryDark,
                                    size: 14,
                                  ),
                                ),
                              )
                            : null,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (value) {
                        ref.read(searchProvider.notifier).setQuery(value);
                        setState(() {});
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          ref.read(searchHistoryProvider.notifier).addToHistory(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content based on search state
          if (searchState.query.isEmpty) ...[
            // Search history
            if (searchHistory.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(searchHistoryProvider.notifier).clearHistory();
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final query = searchHistory[index];
                    return ListTile(
                      leading: Icon(
                        Iconsax.clock,
                        color: AppColors.textSecondaryDark.withOpacity(0.6),
                        size: 20,
                      ),
                      title: Text(
                        query,
                        style: const TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          ref.read(searchHistoryProvider.notifier).removeFromHistory(query);
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondaryDark.withOpacity(0.5),
                          size: 18,
                        ),
                      ),
                      onTap: () {
                        _searchController.text = query;
                        ref.read(searchProvider.notifier).setQuery(query);
                        setState(() {});
                      },
                    );
                  },
                  childCount: searchHistory.length,
                ),
              ),
            ],

            // Browse categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: const Text(
                  'Browse Categories',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final categories = [
                      {'name': 'Pop', 'color': AppColors.accentPink, 'icon': Iconsax.music},
                      {'name': 'Hip-Hop', 'color': AppColors.accentOrange, 'icon': Iconsax.microphone},
                      {'name': 'Rock', 'color': AppColors.accentPurple, 'icon': Iconsax.music_square},
                      {'name': 'Electronic', 'color': AppColors.accentBlue, 'icon': Iconsax.sound},
                      {'name': 'R&B', 'color': AppColors.accentGreen, 'icon': Iconsax.heart},
                      {'name': 'Jazz', 'color': AppColors.accentTeal, 'icon': Iconsax.music_filter},
                      {'name': 'Classical', 'color': AppColors.accentIndigo, 'icon': Iconsax.note},
                      {'name': 'Country', 'color': AppColors.accentOrange, 'icon': Iconsax.music_play},
                    ];
                    final category = categories[index];
                    return _buildCategoryCard(
                      category['name'] as String,
                      category['color'] as Color,
                      category['icon'] as IconData,
                    );
                  },
                  childCount: 8,
                ),
              ),
            ),
          ] else ...[
            // Search results
            if (searchState.isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.glassDark.withOpacity(0.6),
                            AppColors.glassLight.withOpacity(0.4),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              )
            else if (!searchState.hasResults)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.glassDark.withOpacity(0.6),
                                AppColors.glassLight.withOpacity(0.4),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.glassBorder.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Iconsax.search_status,
                            size: 48,
                            color: AppColors.textSecondaryDark.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No results found',
                          style: TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for something else',
                          style: TextStyle(
                            color: AppColors.textSecondaryDark.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Display search results in glass container
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Songs section
                          if (searchState.songs.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Songs',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...searchState.songs.take(5).map((song) => SongTile(
                              song: song,
                              onTap: () {
                                ref.read(audioPlayerServiceProvider).playQueue(
                                  searchState.songs,
                                  startIndex: searchState.songs.indexOf(song),
                                );
                              },
                            )),
                          ],
                          // Albums section
                          if (searchState.albums.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Albums',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...searchState.albums.take(3).map((album) => ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildAlbumArtwork(album),
                              ),
                              title: Text(
                                album.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${album.artist} • ${album.songCount} songs',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () {
                                // Navigate to album
                              },
                            )),
                          ],
                          // Artists section
                          if (searchState.artists.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Artists',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ...searchState.artists.take(3).map((artist) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.glassDark,
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                              title: Text(
                                artist.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${artist.albumCount} albums',
                                style: TextStyle(
                                  color: AppColors.textSecondaryDark.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () {
                                // Navigate to artist
                              },
                            )),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 180),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String name, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to category
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArtwork(dynamic album) {
    if (album.isLocal && album.localArtworkPath != null) {
      return Image.file(
        File(album.localArtworkPath!),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAlbumPlaceholder(),
      );
    } else if (album.artworkUrl != null) {
      return CachedNetworkImage(
        imageUrl: album.artworkUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildAlbumPlaceholder(),
        errorWidget: (context, url, error) => _buildAlbumPlaceholder(),
      );
    }
    return _buildAlbumPlaceholder();
  }

  Widget _buildAlbumPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.album,
        color: AppColors.textSecondaryDark,
        size: 24,
      ),
    );
  }
}
