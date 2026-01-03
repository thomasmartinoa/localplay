import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/entities.dart';
import '../../data/adapters/hive_adapters.dart';
import '../../core/utils/app_logger.dart';
import 'local_music_provider.dart';

/// Provider for favorite songs
final favoriteSongsProvider =
    StateNotifierProvider<FavoriteSongsNotifier, List<Song>>((ref) {
      return FavoriteSongsNotifier(ref);
    });

class FavoriteSongsNotifier extends StateNotifier<List<Song>> {
  final Ref _ref;
  Box<Song>? _favoritesBox;

  FavoriteSongsNotifier(this._ref) : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      _favoritesBox = await Hive.openBox<Song>(HiveBoxes.favorites);
      state = _favoritesBox!.values.toList();
      AppLogger.info('Loaded ${state.length} favorites from storage');
    } catch (e) {
      AppLogger.error('Error loading favorites: $e');
    }
  }

  Future<void> addToFavorites(Song song) async {
    if (!state.any((s) => s.id == song.id)) {
      final favoriteSong = song.copyWith(isFavorite: true);
      state = [...state, favoriteSong];
      
      try {
        _favoritesBox ??= await Hive.openBox<Song>(HiveBoxes.favorites);
        await _favoritesBox!.put(song.id, favoriteSong);
        
        // Sync with local songs provider
        _ref.read(localSongsProvider.notifier).updateSong(favoriteSong);
      } catch (e) {
        AppLogger.error('Error saving favorite: $e');
      }
    }
  }

  Future<void> removeFromFavorites(String songId) async {
    state = state.where((s) => s.id != songId).toList();
    
    try {
      _favoritesBox ??= await Hive.openBox<Song>(HiveBoxes.favorites);
      await _favoritesBox!.delete(songId);
      
      // Sync with local songs provider
      final localSongs = _ref.read(localSongsProvider);
      final song = localSongs.firstWhere((s) => s.id == songId, orElse: () => localSongs.first);
      if (localSongs.any((s) => s.id == songId)) {
        _ref.read(localSongsProvider.notifier).updateSong(song.copyWith(isFavorite: false));
      }
    } catch (e) {
      AppLogger.error('Error removing favorite: $e');
    }
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song.id)) {
      removeFromFavorites(song.id);
    } else {
      addToFavorites(song);
    }
  }

  bool isFavorite(String songId) {
    return state.any((s) => s.id == songId);
  }
}

/// Provider for checking if a song is favorite
final isSongFavoriteProvider = Provider.family<bool, String>((ref, songId) {
  final favorites = ref.watch(favoriteSongsProvider);
  return favorites.any((s) => s.id == songId);
});

/// Provider for recently played songs
final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<Song>>((ref) {
      return RecentlyPlayedNotifier();
    });

class RecentlyPlayedNotifier extends StateNotifier<List<Song>> {
  static const int maxRecent = 50;

  RecentlyPlayedNotifier() : super([]);

  void addToRecentlyPlayed(Song song) {
    // Remove if already exists
    final newState = state.where((s) => s.id != song.id).toList();
    // Add to beginning
    newState.insert(0, song.copyWith(lastPlayed: DateTime.now()));
    // Limit size
    if (newState.length > maxRecent) {
      newState.removeLast();
    }
    state = newState;
  }
}

/// Provider for user playlists
final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
      return PlaylistsNotifier();
    });

class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  Box<Playlist>? _playlistsBox;

  PlaylistsNotifier() : super([]) {
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      _playlistsBox = await Hive.openBox<Playlist>(HiveBoxes.playlists);
      state = _playlistsBox!.values.toList();
      AppLogger.info('Loaded ${state.length} playlists from storage');
    } catch (e) {
      AppLogger.error('Error loading playlists: $e');
    }
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final now = DateTime.now();
    final playlist = Playlist(
      id: 'playlist_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      type: PlaylistType.userCreated,
    );
    state = [...state, playlist];
    
    try {
      _playlistsBox ??= await Hive.openBox<Playlist>(HiveBoxes.playlists);
      await _playlistsBox!.put(playlist.id, playlist);
    } catch (e) {
      AppLogger.error('Error saving playlist: $e');
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    state = state.where((p) => p.id != playlistId).toList();
    
    try {
      _playlistsBox ??= await Hive.openBox<Playlist>(HiveBoxes.playlists);
      await _playlistsBox!.delete(playlistId);
    } catch (e) {
      AppLogger.error('Error deleting playlist: $e');
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        if (!playlist.songs.any((s) => s.id == song.id)) {
          final songs = [...playlist.songs, song];
          final updated = playlist.copyWith(
            songs: songs,
            songCount: songs.length,
            totalDuration: songs.fold<Duration>(
              Duration.zero,
              (total, s) => total + s.duration,
            ),
            updatedAt: DateTime.now(),
          );
          
          // Save to Hive
          _savePlaylist(updated);
          
          return updated;
        }
      }
      return playlist;
    }).toList();
  }

  Future<void> _savePlaylist(Playlist playlist) async {
    try {
      _playlistsBox ??= await Hive.openBox<Playlist>(HiveBoxes.playlists);
      await _playlistsBox!.put(playlist.id, playlist);
    } catch (e) {
      AppLogger.error('Error saving playlist: $e');
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        final songs = playlist.songs.where((s) => s.id != songId).toList();
        final updated = playlist.copyWith(
          songs: songs,
          songCount: songs.length,
          totalDuration: songs.fold<Duration>(
            Duration.zero,
            (total, s) => total + s.duration,
          ),
          updatedAt: DateTime.now(),
        );
        _savePlaylist(updated);
        return updated;
      }
      return playlist;
    }).toList();
  }

  Future<void> updatePlaylist(String playlistId, {String? name, String? description}) async {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        final updated = playlist.copyWith(
          name: name ?? playlist.name,
          description: description ?? playlist.description,
          updatedAt: DateTime.now(),
        );
        _savePlaylist(updated);
        return updated;
      }
      return playlist;
    }).toList();
  }

  Future<void> updatePlaylistSongs(String playlistId, List<Song> songs) async {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        final updated = playlist.copyWith(
          songs: songs,
          songCount: songs.length,
          totalDuration: songs.fold<Duration>(
            Duration.zero,
            (total, s) => total + s.duration,
          ),
          updatedAt: DateTime.now(),
        );
        _savePlaylist(updated);
        return updated;
      }
      return playlist;
    }).toList();
  }
}

/// Provider for a specific playlist
final playlistProvider = Provider.family<Playlist?, String>((ref, playlistId) {
  final playlists = ref.watch(playlistsProvider);
  try {
    return playlists.firstWhere((p) => p.id == playlistId);
  } catch (_) {
    return null;
  }
});
