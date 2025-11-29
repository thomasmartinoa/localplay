import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/entities.dart';
import 'artwork_extractor.dart';

/// Scan progress state
class ScanProgress {
  final int totalFiles;
  final int scannedFiles;
  final String currentFile;
  final bool isScanning;
  final bool isComplete;
  final String? error;

  const ScanProgress({
    this.totalFiles = 0,
    this.scannedFiles = 0,
    this.currentFile = '',
    this.isScanning = false,
    this.isComplete = false,
    this.error,
  });

  double get progress => totalFiles > 0 ? scannedFiles / totalFiles : 0;
  
  ScanProgress copyWith({
    int? totalFiles,
    int? scannedFiles,
    String? currentFile,
    bool? isScanning,
    bool? isComplete,
    String? error,
  }) {
    return ScanProgress(
      totalFiles: totalFiles ?? this.totalFiles,
      scannedFiles: scannedFiles ?? this.scannedFiles,
      currentFile: currentFile ?? this.currentFile,
      isScanning: isScanning ?? this.isScanning,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

/// Scan result containing songs, albums, and artists
class ScanResult {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  const ScanResult({
    required this.songs,
    required this.albums,
    required this.artists,
  });
}

/// Service for scanning local music files
class LocalMusicScanner {
  final BehaviorSubject<ScanProgress> _progressSubject = 
      BehaviorSubject<ScanProgress>.seeded(const ScanProgress());
  
  final ArtworkExtractor _artworkExtractor = ArtworkExtractor();

  /// Supported audio file extensions
  static const List<String> _supportedExtensions = [
    '.mp3', '.m4a', '.aac', '.flac', '.wav', '.ogg', '.opus', '.wma', '.aiff'
  ];

  /// Stream of scan progress
  Stream<ScanProgress> get progressStream => _progressSubject.stream;

  /// Current scan progress
  ScanProgress get currentProgress => _progressSubject.value;

  /// Request storage permissions
  Future<bool> requestPermissions() async {
    // For Android
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use audio permission
      final audioPermission = await Permission.audio.request();
      if (audioPermission.isGranted) {
        print('Audio permission granted');
        return true;
      }
      
      // For Android 11+ (API 30+), may need manage external storage
      final managePermission = await Permission.manageExternalStorage.request();
      if (managePermission.isGranted) {
        print('Manage external storage permission granted');
        return true;
      }
      
      // Fallback to storage permission for older Android versions
      final storagePermission = await Permission.storage.request();
      if (storagePermission.isGranted) {
        print('Storage permission granted');
        return true;
      }
      
      print('No storage permissions granted');
      return false;
    }
    
    // For iOS
    if (Platform.isIOS) {
      final permission = await Permission.mediaLibrary.request();
      return permission.isGranted;
    }
    
    return true;
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      final audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;
      
      final storageStatus = await Permission.storage.status;
      return storageStatus.isGranted;
    }
    
    if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.status;
      return status.isGranted;
    }
    
    return true;
  }

  /// Generate a unique ID from file path
  String _generateId(String path) {
    final bytes = utf8.encode(path);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Check if file is a supported audio file
  bool _isAudioFile(String path) {
    final ext = path.toLowerCase();
    return _supportedExtensions.any((e) => ext.endsWith(e));
  }

  /// Normalize a folder path (handle various Android path formats)
  String _normalizePath(String path) {
    // Handle content:// URIs by extracting the actual path
    if (path.startsWith('content://')) {
      // Try to extract path from common content URI formats
      // content://com.android.externalstorage.documents/tree/primary:Music
      final match = RegExp(r'primary[:%](.+)$').firstMatch(path);
      if (match != null) {
        final relativePath = Uri.decodeComponent(match.group(1)!);
        return '/storage/emulated/0/$relativePath';
      }
      print('Could not parse content URI: $path');
      return path;
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

  /// Get all audio files from a directory recursively
  Future<List<File>> _getAudioFiles(List<String> folderPaths) async {
    final audioFiles = <File>[];
    
    for (final originalPath in folderPaths) {
      final folderPath = _normalizePath(originalPath);
      print('Scanning folder: $folderPath (original: $originalPath)');
      
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        print('Folder does not exist: $folderPath');
        
        // Try alternative path formats
        final alternativePaths = _getAlternativePaths(originalPath);
        bool found = false;
        for (final altPath in alternativePaths) {
          final altFolder = Directory(altPath);
          if (await altFolder.exists()) {
            print('Found alternative path: $altPath');
            await _scanDirectory(altFolder, audioFiles);
            found = true;
            break;
          }
        }
        if (!found) {
          print('Could not find accessible path for: $originalPath');
        }
        continue;
      }
      
      await _scanDirectory(folder, audioFiles);
    }
    
    print('Total audio files found: ${audioFiles.length}');
    
    return audioFiles;
  }

  /// Get alternative path formats to try
  List<String> _getAlternativePaths(String path) {
    final alternatives = <String>[];
    
    // Extract folder name from path
    final segments = path.split(RegExp(r'[/\\]'));
    final folderName = segments.isNotEmpty ? segments.last : '';
    
    if (folderName.isNotEmpty) {
      // Try common Android storage locations
      alternatives.addAll([
        '/storage/emulated/0/$folderName',
        '/storage/emulated/0/Music/$folderName',
        '/storage/emulated/0/Download/$folderName',
        '/sdcard/$folderName',
        '/sdcard/Music/$folderName',
      ]);
    }
    
    return alternatives;
  }

  /// Scan a directory for audio files
  Future<void> _scanDirectory(Directory folder, List<File> audioFiles) async {
    try {
      await for (final entity in folder.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          audioFiles.add(entity);
          print('Found audio file: ${entity.path}');
        }
      }
    } catch (e) {
      print('Error scanning folder ${folder.path}: $e');
    }
  }

  /// Get common music directories on the device
  Future<List<String>> getDefaultMusicFolders() async {
    final folders = <String>[];
    
    if (Platform.isAndroid) {
      // Common Android music directories
      final paths = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
      ];
      
      for (final path in paths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          folders.add(path);
        }
      }
      
      // Try to get external storage directories
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final musicDir = Directory('${externalDir.parent.parent.parent.parent.path}/Music');
          if (await musicDir.exists() && !folders.contains(musicDir.path)) {
            folders.add(musicDir.path);
          }
        }
      } catch (e) {
        // Ignore errors
      }
    } else if (Platform.isIOS) {
      final docDir = await getApplicationDocumentsDirectory();
      folders.add(docDir.path);
    }
    
    return folders.toSet().toList(); // Remove duplicates
  }

  /// Extract metadata from filename (basic implementation without external package)
  /// Format: "Artist - Title.mp3" or just "Title.mp3"
  Map<String, String?> _parseFilename(String filename) {
    // Remove extension
    final nameWithoutExt = filename.replaceAll(RegExp(r'\.[^.]+$'), '');
    
    // Try to parse "Artist - Title" format
    final parts = nameWithoutExt.split(' - ');
    if (parts.length >= 2) {
      return {
        'artist': parts[0].trim(),
        'title': parts.sublist(1).join(' - ').trim(),
      };
    }
    
    // Fall back to just using filename as title
    return {
      'artist': null,
      'title': nameWithoutExt.trim(),
    };
  }

  /// Scan all audio files from default music directories
  Future<ScanResult> scanAllMusic() async {
    final defaultFolders = await getDefaultMusicFolders();
    if (defaultFolders.isEmpty) {
      // If no default folders found, scan common paths
      return scanFolders(['/storage/emulated/0/Music']);
    }
    return scanFolders(defaultFolders);
  }

  /// Scan specific folders for music
  Future<ScanResult> scanFolders(List<String> folderPaths) async {
    _progressSubject.add(const ScanProgress(isScanning: true));

    try {
      // Check permissions
      final hasPermission = await hasPermissions();
      if (!hasPermission) {
        final granted = await requestPermissions();
        if (!granted) {
          _progressSubject.add(const ScanProgress(
            isScanning: false,
            error: 'Storage permission denied',
          ));
          return const ScanResult(songs: [], albums: [], artists: []);
        }
      }

      // Get all audio files
      final audioFiles = await _getAudioFiles(folderPaths);

      if (audioFiles.isEmpty) {
        _progressSubject.add(const ScanProgress(
          isScanning: false,
          isComplete: true,
        ));
        return const ScanResult(songs: [], albums: [], artists: []);
      }

      _progressSubject.add(ScanProgress(
        totalFiles: audioFiles.length,
        scannedFiles: 0,
        isScanning: true,
      ));

      final songs = <Song>[];
      final albumsMap = <String, Album>{};
      final artistsMap = <String, Artist>{};

      for (int i = 0; i < audioFiles.length; i++) {
        final file = audioFiles[i];
        final fileName = file.path.split('/').last;
        
        _progressSubject.add(_progressSubject.value.copyWith(
          scannedFiles: i + 1,
          currentFile: fileName,
        ));

        // Try to extract metadata from the file using native code
        final metadata = await _artworkExtractor.extractMetadata(file.path);
        
        // Parse filename as fallback
        final parsed = _parseFilename(fileName);
        
        // Use metadata if available, fallback to filename parsing
        String title = metadata?['title'] as String? ?? 
                       parsed['title'] ?? 
                       fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
        String artistName = metadata?['artist'] as String? ?? 
                           metadata?['albumArtist'] as String? ??
                           parsed['artist'] ?? 
                           'Unknown Artist';
        String albumName = metadata?['album'] as String? ?? 'Unknown Album';
        int? year = metadata?['year'] as int?;
        int? trackNumber = metadata?['trackNumber'] as int?;
        
        // Get duration from metadata (in milliseconds)
        Duration duration = Duration.zero;
        if (metadata?['duration'] != null) {
          duration = Duration(milliseconds: (metadata!['duration'] as int));
        }
        
        // Generate IDs
        final fileId = _generateId(file.path);
        final artistId = _generateId(artistName.toLowerCase());
        final albumId = _generateId('${artistName.toLowerCase()}_${albumName.toLowerCase()}');

        // Get file modification date
        DateTime dateAdded;
        try {
          dateAdded = (await file.stat()).modified;
        } catch (e) {
          dateAdded = DateTime.now();
        }

        // Extract and cache artwork
        String? artworkPath;
        if (metadata?['hasArtwork'] == true) {
          artworkPath = await _artworkExtractor.extractAndCacheArtwork(file.path);
        }

        final song = Song(
          id: fileId,
          title: title,
          artist: artistName,
          album: albumName,
          albumId: albumId,
          artistId: artistId,
          filePath: file.path,
          localArtworkPath: artworkPath,
          isLocal: true,
          duration: duration,
          trackNumber: trackNumber,
          dateAdded: dateAdded,
        );

        songs.add(song);

        // Build album
        if (!albumsMap.containsKey(albumId)) {
          albumsMap[albumId] = Album(
            id: albumId,
            title: albumName,
            artist: artistName,
            artistId: artistId,
            localArtworkPath: artworkPath,
            isLocal: true,
            releaseYear: year ?? 0,
            songCount: 1,
            totalDuration: duration,
          );
        } else {
          final existingAlbum = albumsMap[albumId]!;
          // Update artwork if this song has one and album doesn't
          final updatedArtworkPath = existingAlbum.localArtworkPath ?? artworkPath;
          albumsMap[albumId] = existingAlbum.copyWith(
            songCount: existingAlbum.songCount + 1,
            totalDuration: existingAlbum.totalDuration + song.duration,
            localArtworkPath: updatedArtworkPath,
          );
        }

        // Build artist
        if (!artistsMap.containsKey(artistId)) {
          artistsMap[artistId] = Artist(
            id: artistId,
            name: artistName,
            imageUrl: null,
            albumCount: 1,
          );
        } else {
          final existingArtist = artistsMap[artistId]!;
          // Count unique albums for this artist
          final artistAlbums = albumsMap.values
              .where((a) => a.artistId == artistId)
              .length;
          artistsMap[artistId] = existingArtist.copyWith(
            albumCount: artistAlbums,
          );
        }
      }

      _progressSubject.add(ScanProgress(
        totalFiles: audioFiles.length,
        scannedFiles: audioFiles.length,
        isScanning: false,
        isComplete: true,
      ));

      return ScanResult(
        songs: songs,
        albums: albumsMap.values.toList(),
        artists: artistsMap.values.toList(),
      );
    } catch (e) {
      _progressSubject.add(ScanProgress(
        isScanning: false,
        error: 'Error scanning folders: $e',
      ));
      return const ScanResult(songs: [], albums: [], artists: []);
    }
  }

  /// Reset progress
  void resetProgress() {
    _progressSubject.add(const ScanProgress());
  }

  /// Dispose resources
  void dispose() {
    _progressSubject.close();
  }
}
