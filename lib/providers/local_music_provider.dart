import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/entities.dart';
import '../../data/adapters/hive_adapters.dart';
import '../../services/local_music/local_music_scanner.dart';

/// Local music scanner provider
final localMusicScannerProvider = Provider<LocalMusicScanner>((ref) {
  final scanner = LocalMusicScanner();
  ref.onDispose(() => scanner.dispose());
  return scanner;
});

/// Scan progress stream provider
final scanProgressProvider = StreamProvider<ScanProgress>((ref) {
  final scanner = ref.watch(localMusicScannerProvider);
  return scanner.progressStream;
});

/// Local songs provider
final localSongsProvider = StateNotifierProvider<LocalSongsNotifier, List<Song>>((ref) {
  return LocalSongsNotifier();
});

class LocalSongsNotifier extends StateNotifier<List<Song>> {
  Box<Song>? _songsBox;

  LocalSongsNotifier() : super([]) {
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      _songsBox = await Hive.openBox<Song>(HiveBoxes.songs);
      state = _songsBox!.values.toList();
    } catch (e) {
      print('Error loading songs: $e');
    }
  }

  Future<void> setSongs(List<Song> songs) async {
    try {
      _songsBox ??= await Hive.openBox<Song>(HiveBoxes.songs);
      await _songsBox!.clear();
      
      final songsMap = {for (var s in songs) s.id: s};
      await _songsBox!.putAll(songsMap);
      
      state = songs;
    } catch (e) {
      print('Error saving songs: $e');
    }
  }

  Future<void> addSongs(List<Song> songs) async {
    try {
      _songsBox ??= await Hive.openBox<Song>(HiveBoxes.songs);
      
      final songsMap = {for (var s in songs) s.id: s};
      await _songsBox!.putAll(songsMap);
      
      state = [...state, ...songs];
    } catch (e) {
      print('Error adding songs: $e');
    }
  }

  Future<void> updateSong(Song song) async {
    try {
      _songsBox ??= await Hive.openBox<Song>(HiveBoxes.songs);
      await _songsBox!.put(song.id, song);
      
      state = state.map((s) => s.id == song.id ? song : s).toList();
    } catch (e) {
      print('Error updating song: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      _songsBox ??= await Hive.openBox<Song>(HiveBoxes.songs);
      await _songsBox!.clear();
      state = [];
    } catch (e) {
      print('Error clearing songs: $e');
    }
  }

  /// Remove all songs from a specific folder path
  Future<void> removeSongsFromFolder(String folderPath) async {
    try {
      _songsBox ??= await Hive.openBox<Song>(HiveBoxes.songs);
      
      // Normalize the folder path for comparison
      final normalizedFolder = folderPath.replaceAll('\\', '/');
      
      // Find songs that belong to this folder
      final songsToRemove = state.where((song) {
        if (song.filePath == null) return false;
        final normalizedSongPath = song.filePath!.replaceAll('\\', '/');
        return normalizedSongPath.startsWith(normalizedFolder);
      }).toList();
      
      print('Removing ${songsToRemove.length} songs from folder: $folderPath');
      
      // Remove from Hive
      for (final song in songsToRemove) {
        await _songsBox!.delete(song.id);
      }
      
      // Update state
      state = state.where((song) {
        if (song.filePath == null) return true;
        final normalizedSongPath = song.filePath!.replaceAll('\\', '/');
        return !normalizedSongPath.startsWith(normalizedFolder);
      }).toList();
    } catch (e) {
      print('Error removing songs from folder: $e');
    }
  }

  /// Get songs from specific folder paths only
  List<Song> getSongsFromFolders(List<String> folderPaths) {
    if (folderPaths.isEmpty) return [];
    
    return state.where((song) {
      if (song.filePath == null) return false;
      final normalizedSongPath = song.filePath!.replaceAll('\\', '/');
      return folderPaths.any((folderPath) {
        final normalizedFolder = folderPath.replaceAll('\\', '/');
        return normalizedSongPath.startsWith(normalizedFolder);
      });
    }).toList();
  }

  List<Song> searchSongs(String query) {
    if (query.isEmpty) return state;
    final lowerQuery = query.toLowerCase();
    return state.where((song) =>
      song.title.toLowerCase().contains(lowerQuery) ||
      song.artist.toLowerCase().contains(lowerQuery) ||
      song.album.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

/// Local albums provider
final localAlbumsProvider = StateNotifierProvider<LocalAlbumsNotifier, List<Album>>((ref) {
  return LocalAlbumsNotifier();
});

class LocalAlbumsNotifier extends StateNotifier<List<Album>> {
  Box<Album>? _albumsBox;

  LocalAlbumsNotifier() : super([]) {
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      _albumsBox = await Hive.openBox<Album>(HiveBoxes.albums);
      state = _albumsBox!.values.toList();
    } catch (e) {
      print('Error loading albums: $e');
    }
  }

  Future<void> setAlbums(List<Album> albums) async {
    try {
      _albumsBox ??= await Hive.openBox<Album>(HiveBoxes.albums);
      await _albumsBox!.clear();
      
      final albumsMap = {for (var a in albums) a.id: a};
      await _albumsBox!.putAll(albumsMap);
      
      state = albums;
    } catch (e) {
      print('Error saving albums: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      _albumsBox ??= await Hive.openBox<Album>(HiveBoxes.albums);
      await _albumsBox!.clear();
      state = [];
    } catch (e) {
      print('Error clearing albums: $e');
    }
  }
}

/// Local artists provider
final localArtistsProvider = StateNotifierProvider<LocalArtistsNotifier, List<Artist>>((ref) {
  return LocalArtistsNotifier();
});

class LocalArtistsNotifier extends StateNotifier<List<Artist>> {
  Box<Artist>? _artistsBox;

  LocalArtistsNotifier() : super([]) {
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    try {
      _artistsBox = await Hive.openBox<Artist>(HiveBoxes.artists);
      state = _artistsBox!.values.toList();
    } catch (e) {
      print('Error loading artists: $e');
    }
  }

  Future<void> setArtists(List<Artist> artists) async {
    try {
      _artistsBox ??= await Hive.openBox<Artist>(HiveBoxes.artists);
      await _artistsBox!.clear();
      
      final artistsMap = {for (var a in artists) a.id: a};
      await _artistsBox!.putAll(artistsMap);
      
      state = artists;
    } catch (e) {
      print('Error saving artists: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      _artistsBox ??= await Hive.openBox<Artist>(HiveBoxes.artists);
      await _artistsBox!.clear();
      state = [];
    } catch (e) {
      print('Error clearing artists: $e');
    }
  }
}

/// Scan folders provider
final scanFoldersProvider = StateNotifierProvider<ScanFoldersNotifier, List<ScanFolder>>((ref) {
  return ScanFoldersNotifier();
});

class ScanFoldersNotifier extends StateNotifier<List<ScanFolder>> {
  Box<ScanFolder>? _foldersBox;

  ScanFoldersNotifier() : super([]) {
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      _foldersBox = await Hive.openBox<ScanFolder>(HiveBoxes.scanFolders);
      state = _foldersBox!.values.toList();
    } catch (e) {
      print('Error loading folders: $e');
    }
  }

  Future<void> addFolder(ScanFolder folder) async {
    try {
      _foldersBox ??= await Hive.openBox<ScanFolder>(HiveBoxes.scanFolders);
      
      // Check if folder already exists
      if (state.any((f) => f.path == folder.path)) return;
      
      await _foldersBox!.put(folder.path, folder);
      state = [...state, folder];
    } catch (e) {
      print('Error adding folder: $e');
    }
  }

  Future<void> removeFolder(String path) async {
    try {
      _foldersBox ??= await Hive.openBox<ScanFolder>(HiveBoxes.scanFolders);
      await _foldersBox!.delete(path);
      state = state.where((f) => f.path != path).toList();
    } catch (e) {
      print('Error removing folder: $e');
    }
  }

  Future<void> toggleFolder(String path) async {
    try {
      _foldersBox ??= await Hive.openBox<ScanFolder>(HiveBoxes.scanFolders);
      final folder = state.firstWhere((f) => f.path == path);
      final updated = folder.copyWith(isEnabled: !folder.isEnabled);
      await _foldersBox!.put(path, updated);
      state = state.map((f) => f.path == path ? updated : f).toList();
    } catch (e) {
      print('Error toggling folder: $e');
    }
  }

  /// Check if folder is enabled
  bool isFolderEnabled(String path) {
    final folder = state.firstWhere((f) => f.path == path, orElse: () => ScanFolder(path: '', name: '', addedAt: DateTime.now(), isEnabled: false));
    return folder.isEnabled;
  }

  List<String> get enabledFolderPaths => 
      state.where((f) => f.isEnabled).map((f) => f.path).toList();
}

/// Normalize folder path for Android storage access
String _normalizeFolderPath(String path) {
  // Handle content:// URIs
  if (path.startsWith('content://')) {
    // Try to extract path from content URI
    // Format: content://com.android.externalstorage.documents/tree/primary:Music
    final match = RegExp(r'primary[:%](.+)$').firstMatch(path);
    if (match != null) {
      final relativePath = Uri.decodeComponent(match.group(1)!);
      return '/storage/emulated/0/$relativePath';
    }
  }
  
  // Handle /tree/ or /document/ paths
  if (path.contains('/tree/') || path.contains('/document/')) {
    final match = RegExp(r'primary[:%](.+)$').firstMatch(path);
    if (match != null) {
      final relativePath = Uri.decodeComponent(match.group(1)!);
      return '/storage/emulated/0/$relativePath';
    }
  }
  
  return path;
}

/// Pick folder action provider
final pickFolderProvider = Provider<Future<String?> Function()>((ref) {
  return () async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      print('Raw picked folder path: $result');
      
      if (result != null) {
        // Normalize the path for Android
        String normalizedPath = result;
        if (Platform.isAndroid) {
          normalizedPath = _normalizeFolderPath(result);
          print('Normalized path: $normalizedPath');
        }
        
        // Verify the directory exists
        final dir = Directory(normalizedPath);
        final exists = await dir.exists();
        print('Directory exists: $exists');
        
        if (!exists) {
          print('Warning: Selected directory does not exist or is not accessible');
          print('Trying to list files in: $normalizedPath');
          
          // Still return the normalized path - the scanner will try alternative paths
        }
        
        return normalizedPath;
      }
      
      return result;
    } catch (e) {
      print('Error picking folder: $e');
      return null;
    }
  };
});

/// Scan music action provider
final scanMusicActionProvider = Provider<Future<void> Function({bool useSelectedFolders})>((ref) {
  return ({bool useSelectedFolders = false}) async {
    final scanner = ref.read(localMusicScannerProvider);
    final folders = ref.read(scanFoldersProvider);
    
    ScanResult result;
    
    if (useSelectedFolders) {
      // Get only enabled folder paths
      final enabledPaths = folders
          .where((f) => f.isEnabled)
          .map((f) => f.path)
          .toList();
      
      print('Scanning selected folders: $enabledPaths');
      print('Total folders: ${folders.length}, Enabled: ${enabledPaths.length}');
      
      if (enabledPaths.isEmpty) {
        print('No enabled folders found, returning empty result');
        // Don't scan all music, just return empty if no folders selected
        result = const ScanResult(songs: [], albums: [], artists: []);
      } else {
        result = await scanner.scanFolders(enabledPaths);
      }
    } else {
      print('Scanning all music on device');
      result = await scanner.scanAllMusic();
    }
    
    print('Scan complete: ${result.songs.length} songs, ${result.albums.length} albums, ${result.artists.length} artists');
    
    // Save results
    await ref.read(localSongsProvider.notifier).setSongs(result.songs);
    await ref.read(localAlbumsProvider.notifier).setAlbums(result.albums);
    await ref.read(localArtistsProvider.notifier).setArtists(result.artists);
  };
});

/// Scan a single folder and add to existing library
final scanSingleFolderProvider = Provider<Future<void> Function(String folderPath)>((ref) {
  return (String folderPath) async {
    final scanner = ref.read(localMusicScannerProvider);
    
    print('Scanning single folder: $folderPath');
    
    final result = await scanner.scanFolders([folderPath]);
    
    print('Single folder scan complete: ${result.songs.length} songs');
    
    if (result.songs.isNotEmpty) {
      // Add songs to existing library (not replace)
      await ref.read(localSongsProvider.notifier).addSongs(result.songs);
      
      // For albums and artists, we need to merge with existing
      final existingAlbums = ref.read(localAlbumsProvider);
      final existingArtists = ref.read(localArtistsProvider);
      
      // Add new albums that don't exist
      final newAlbums = result.albums.where((a) => 
        !existingAlbums.any((ea) => ea.id == a.id)
      ).toList();
      
      // Add new artists that don't exist
      final newArtists = result.artists.where((a) => 
        !existingArtists.any((ea) => ea.id == a.id)
      ).toList();
      
      if (newAlbums.isNotEmpty) {
        await ref.read(localAlbumsProvider.notifier).setAlbums([...existingAlbums, ...newAlbums]);
      }
      if (newArtists.isNotEmpty) {
        await ref.read(localArtistsProvider.notifier).setArtists([...existingArtists, ...newArtists]);
      }
    }
  };
});

/// Remove songs from a folder when folder is deleted or disabled
final removeFolderSongsProvider = Provider<Future<void> Function(String folderPath)>((ref) {
  return (String folderPath) async {
    print('Removing songs from folder: $folderPath');
    await ref.read(localSongsProvider.notifier).removeSongsFromFolder(folderPath);
    
    // Rebuild albums and artists based on remaining songs
    final remainingSongs = ref.read(localSongsProvider);
    
    // Get unique album IDs from remaining songs
    final remainingAlbumIds = remainingSongs
        .where((s) => s.albumId != null)
        .map((s) => s.albumId!)
        .toSet();
    
    // Get unique artist IDs from remaining songs
    final remainingArtistIds = remainingSongs
        .where((s) => s.artistId != null)
        .map((s) => s.artistId!)
        .toSet();
    
    // Filter albums to only keep those with songs
    final currentAlbums = ref.read(localAlbumsProvider);
    final filteredAlbums = currentAlbums.where((a) => remainingAlbumIds.contains(a.id)).toList();
    await ref.read(localAlbumsProvider.notifier).setAlbums(filteredAlbums);
    
    // Filter artists to only keep those with songs
    final currentArtists = ref.read(localArtistsProvider);
    final filteredArtists = currentArtists.where((a) => remainingArtistIds.contains(a.id)).toList();
    await ref.read(localArtistsProvider.notifier).setArtists(filteredArtists);
    
    print('Cleanup complete. Remaining: ${remainingSongs.length} songs, ${filteredAlbums.length} albums, ${filteredArtists.length} artists');
  };
});

/// Recently added songs (last 50)
final recentlyAddedSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(localSongsProvider);
  final sorted = List<Song>.from(songs)
    ..sort((a, b) => (b.dateAdded ?? DateTime(1970)).compareTo(a.dateAdded ?? DateTime(1970)));
  return sorted.take(50).toList();
});

/// Songs by album provider
final songsByAlbumProvider = Provider.family<List<Song>, String>((ref, albumId) {
  final songs = ref.watch(localSongsProvider);
  return songs.where((s) => s.albumId == albumId).toList()
    ..sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
});

/// Songs by artist provider
final songsByArtistProvider = Provider.family<List<Song>, String>((ref, artistId) {
  final songs = ref.watch(localSongsProvider);
  return songs.where((s) => s.artistId == artistId).toList();
});

/// Albums by artist provider
final albumsByArtistProvider = Provider.family<List<Album>, String>((ref, artistId) {
  final albums = ref.watch(localAlbumsProvider);
  return albums.where((a) => a.artistId == artistId).toList();
});

/// Search songs provider
final searchLocalSongsProvider = Provider.family<List<Song>, String>((ref, query) {
  if (query.isEmpty) return [];
  final songs = ref.watch(localSongsProvider);
  final lowerQuery = query.toLowerCase();
  return songs.where((song) =>
    song.title.toLowerCase().contains(lowerQuery) ||
    song.artist.toLowerCase().contains(lowerQuery) ||
    song.album.toLowerCase().contains(lowerQuery)
  ).toList();
});

/// Music library stats provider
final libraryStatsProvider = Provider<Map<String, int>>((ref) {
  final songs = ref.watch(localSongsProvider);
  final albums = ref.watch(localAlbumsProvider);
  final artists = ref.watch(localArtistsProvider);
  
  return {
    'songs': songs.length,
    'albums': albums.length,
    'artists': artists.length,
  };
});
