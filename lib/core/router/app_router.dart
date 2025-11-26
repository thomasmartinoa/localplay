import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/library/library_screen.dart';
import '../../presentation/screens/library/all_songs_screen.dart';
import '../../presentation/screens/library/all_albums_screen.dart';
import '../../presentation/screens/library/all_artists_screen.dart';
import '../../presentation/screens/library/all_playlists_screen.dart';
import '../../presentation/screens/library/favorites_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/player/now_playing_screen.dart';
import '../../presentation/screens/album/album_screen.dart';
import '../../presentation/screens/playlist/playlist_screen.dart';
import '../../presentation/screens/artist/artist_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../domain/entities/entities.dart';

/// App router configuration using GoRouter
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Main shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // Home tab
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        // Browse/Search tab
        GoRoute(
          path: '/search',
          name: 'search',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        // Library tab
        GoRoute(
          path: '/library',
          name: 'library',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
      ],
    ),
    // Full screen player
    GoRoute(
      path: '/now-playing',
      name: 'nowPlaying',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    ),
    // Album detail
    GoRoute(
      path: '/album/:id',
      name: 'album',
      builder: (context, state) {
        final album = state.extra as Album?;
        return AlbumScreen(
          albumId: state.pathParameters['id']!,
          album: album,
        );
      },
    ),
    // Playlist detail
    GoRoute(
      path: '/playlist/:id',
      name: 'playlist',
      builder: (context, state) {
        final playlist = state.extra as Playlist?;
        return PlaylistScreen(
          playlistId: state.pathParameters['id']!,
          playlist: playlist,
        );
      },
    ),
    // Artist detail
    GoRoute(
      path: '/artist/:id',
      name: 'artist',
      builder: (context, state) {
        final artist = state.extra as Artist?;
        return ArtistScreen(
          artistId: state.pathParameters['id']!,
          artist: artist,
        );
      },
    ),
    // Settings
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // All Songs
    GoRoute(
      path: '/all-songs',
      name: 'allSongs',
      builder: (context, state) => const AllSongsScreen(),
    ),
    // All Albums
    GoRoute(
      path: '/all-albums',
      name: 'allAlbums',
      builder: (context, state) => const AllAlbumsScreen(),
    ),
    // All Artists
    GoRoute(
      path: '/all-artists',
      name: 'allArtists',
      builder: (context, state) => const AllArtistsScreen(),
    ),
    // All Playlists
    GoRoute(
      path: '/all-playlists',
      name: 'allPlaylists',
      builder: (context, state) => const AllPlaylistsScreen(),
    ),
    // Favorites
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
  ],
);
