import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/utils/app_logger.dart';

/// Service to extract embedded artwork from audio files using platform channels
class ArtworkExtractor {
  static const MethodChannel _channel = MethodChannel(
    'com.example.localplay/artwork',
  );

  Directory? _artworkCacheDir;

  /// Get the artwork cache directory
  Future<Directory> _getArtworkCacheDir() async {
    if (_artworkCacheDir != null) return _artworkCacheDir!;

    final appDir = await getApplicationDocumentsDirectory();
    _artworkCacheDir = Directory('${appDir.path}/artwork_cache');

    if (!await _artworkCacheDir!.exists()) {
      await _artworkCacheDir!.create(recursive: true);
    }

    return _artworkCacheDir!;
  }

  /// Generate a unique ID from file path
  String _generateId(String path) {
    final bytes = utf8.encode(path);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Extract artwork from an audio file and cache it
  /// Returns the path to the cached artwork file, or null if no artwork found
  Future<String?> extractAndCacheArtwork(String audioFilePath) async {
    try {
      // Generate a unique ID for this file
      final fileId = _generateId(audioFilePath);
      final cacheDir = await _getArtworkCacheDir();
      final artworkPath = '${cacheDir.path}/$fileId.jpg';

      // Check if artwork is already cached
      final cachedFile = File(artworkPath);
      if (await cachedFile.exists()) {
        return artworkPath;
      }

      // Extract artwork using platform channel
      final Uint8List? artworkData = await _channel.invokeMethod<Uint8List>(
        'extractArtwork',
        {'filePath': audioFilePath},
      );

      if (artworkData == null || artworkData.isEmpty) {
        return null;
      }

      // Save to cache
      await cachedFile.writeAsBytes(artworkData);
      return artworkPath;
    } catch (e) {
      AppLogger.error('extracting artwork from $audioFilePath: $e');
      return null;
    }
  }

  /// Extract artwork bytes from an audio file without caching
  Future<Uint8List?> extractArtworkBytes(String audioFilePath) async {
    try {
      final Uint8List? artworkData = await _channel.invokeMethod<Uint8List>(
        'extractArtwork',
        {'filePath': audioFilePath},
      );
      return artworkData;
    } catch (e) {
      AppLogger.error('extracting artwork bytes: $e');
      return null;
    }
  }

  /// Extract metadata from an audio file
  /// Returns a map with title, artist, album, duration, etc.
  Future<Map<String, dynamic>?> extractMetadata(String audioFilePath) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'extractMetadata',
        {'filePath': audioFilePath},
      );

      if (result == null) return null;

      return Map<String, dynamic>.from(result);
    } catch (e) {
      AppLogger.error('extracting metadata from $audioFilePath: $e');
      return null;
    }
  }

  /// Clear the artwork cache
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getArtworkCacheDir();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
      _artworkCacheDir = null;
    } catch (e) {
      AppLogger.error('clearing artwork cache: $e');
    }
  }

  /// Get the size of the artwork cache in bytes
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getArtworkCacheDir();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
