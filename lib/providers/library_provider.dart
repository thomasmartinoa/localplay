import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';

/// Provider for favorite songs
final favoriteSongsProvider = StateNotifierProvider<FavoriteSongsNotifier, List<Song>>((ref) {
  return FavoriteSongsNotifier();
});

class FavoriteSongsNotifier extends StateNotifier<List<Song>> {
  FavoriteSongsNotifier() : super([]);

  void addToFavorites(Song song) {
    if (!state.any((s) => s.id == song.id)) {
      state = [...state, song.copyWith(isFavorite: true)];
    }
  }

  void removeFromFavorites(String songId) {
    state = state.where((s) => s.id != songId).toList();
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
final recentlyPlayedProvider = StateNotifierProvider<RecentlyPlayedNotifier, List<Song>>((ref) {
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
final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier();
});

class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  PlaylistsNotifier() : super([]);

  void createPlaylist(String name, {String? description}) {
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
  }

  void deletePlaylist(String playlistId) {
    state = state.where((p) => p.id != playlistId).toList();
  }

  void addSongToPlaylist(String playlistId, Song song) {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        if (!playlist.songs.any((s) => s.id == song.id)) {
          final songs = [...playlist.songs, song];
          return playlist.copyWith(
            songs: songs,
            songCount: songs.length,
            totalDuration: songs.fold<Duration>(Duration.zero, (total, s) => total + s.duration),
            updatedAt: DateTime.now(),
          );
        }
      }
      return playlist;
    }).toList();
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        final songs = playlist.songs.where((s) => s.id != songId).toList();
        return playlist.copyWith(
          songs: songs,
          songCount: songs.length,
          totalDuration: songs.fold<Duration>(Duration.zero, (total, s) => total + s.duration),
          updatedAt: DateTime.now(),
        );
      }
      return playlist;
    }).toList();
  }

  void updatePlaylist(String playlistId, {String? name, String? description}) {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        return playlist.copyWith(
          name: name ?? playlist.name,
          description: description ?? playlist.description,
          updatedAt: DateTime.now(),
        );
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
