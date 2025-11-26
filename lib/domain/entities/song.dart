import 'package:equatable/equatable.dart';

/// Song entity representing a music track
class Song extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumId;
  final String? artistId;
  final String? artworkUrl;
  final String audioUrl;
  final Duration duration;
  final int? trackNumber;
  final int? discNumber;
  final String? genre;
  final int? releaseYear;
  final bool isExplicit;
  final bool isFavorite;
  final DateTime? lastPlayed;
  final int playCount;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumId,
    this.artistId,
    this.artworkUrl,
    required this.audioUrl,
    required this.duration,
    this.trackNumber,
    this.discNumber,
    this.genre,
    this.releaseYear,
    this.isExplicit = false,
    this.isFavorite = false,
    this.lastPlayed,
    this.playCount = 0,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumId,
    String? artistId,
    String? artworkUrl,
    String? audioUrl,
    Duration? duration,
    int? trackNumber,
    int? discNumber,
    String? genre,
    int? releaseYear,
    bool? isExplicit,
    bool? isFavorite,
    DateTime? lastPlayed,
    int? playCount,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      genre: genre ?? this.genre,
      releaseYear: releaseYear ?? this.releaseYear,
      isExplicit: isExplicit ?? this.isExplicit,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      playCount: playCount ?? this.playCount,
    );
  }

  /// Format duration as mm:ss
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        albumId,
        artistId,
        artworkUrl,
        audioUrl,
        duration,
        trackNumber,
        discNumber,
        genre,
        releaseYear,
        isExplicit,
        isFavorite,
        lastPlayed,
        playCount,
      ];
}
