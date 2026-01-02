import 'package:equatable/equatable.dart';
import 'song.dart';

/// Album entity representing a music album
class Album extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? artworkUrl;
  final String? localArtworkPath;
  final bool isLocal;
  final int releaseYear;
  final String? genre;
  final List<Song> songs;
  final int songCount;
  final Duration totalDuration;
  final bool isExplicit;
  final String? copyright;
  final String? description;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.artworkUrl,
    this.localArtworkPath,
    this.isLocal = false,
    required this.releaseYear,
    this.genre,
    this.songs = const [],
    this.songCount = 0,
    this.totalDuration = Duration.zero,
    this.isExplicit = false,
    this.copyright,
    this.description,
  });

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? artworkUrl,
    String? localArtworkPath,
    bool? isLocal,
    int? releaseYear,
    String? genre,
    List<Song>? songs,
    int? songCount,
    Duration? totalDuration,
    bool? isExplicit,
    String? copyright,
    String? description,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      isLocal: isLocal ?? this.isLocal,
      releaseYear: releaseYear ?? this.releaseYear,
      genre: genre ?? this.genre,
      songs: songs ?? this.songs,
      songCount: songCount ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
      isExplicit: isExplicit ?? this.isExplicit,
      copyright: copyright ?? this.copyright,
      description: description ?? this.description,
    );
  }

  /// Get artwork source - local file path or network URL
  String? get artworkSource => localArtworkPath ?? artworkUrl;

  /// Format total duration as "X hr Y min" or "X min"
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    artistId,
    artworkUrl,
    localArtworkPath,
    isLocal,
    releaseYear,
    genre,
    songs,
    songCount,
    totalDuration,
    isExplicit,
    copyright,
    description,
  ];
}
