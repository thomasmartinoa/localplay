import 'package:equatable/equatable.dart';
import 'song.dart';

/// Playlist entity representing a user-created or curated playlist
class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? artworkUrl;
  final String? creatorId;
  final String? creatorName;
  final List<Song> songs;
  final int songCount;
  final Duration totalDuration;
  final bool isPublic;
  final bool isEditable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PlaylistType type;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.artworkUrl,
    this.creatorId,
    this.creatorName,
    this.songs = const [],
    this.songCount = 0,
    this.totalDuration = Duration.zero,
    this.isPublic = false,
    this.isEditable = true,
    required this.createdAt,
    required this.updatedAt,
    this.type = PlaylistType.userCreated,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? artworkUrl,
    String? creatorId,
    String? creatorName,
    List<Song>? songs,
    int? songCount,
    Duration? totalDuration,
    bool? isPublic,
    bool? isEditable,
    DateTime? createdAt,
    DateTime? updatedAt,
    PlaylistType? type,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      songs: songs ?? this.songs,
      songCount: songCount ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
      isPublic: isPublic ?? this.isPublic,
      isEditable: isEditable ?? this.isEditable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  /// Format total duration as "X hr Y min" or "X min"
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  /// Get artwork URL or first song's artwork
  String? get displayArtwork {
    if (artworkUrl != null) return artworkUrl;
    if (songs.isNotEmpty) return songs.first.artworkUrl;
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        artworkUrl,
        creatorId,
        creatorName,
        songs,
        songCount,
        totalDuration,
        isPublic,
        isEditable,
        createdAt,
        updatedAt,
        type,
      ];
}

/// Type of playlist
enum PlaylistType {
  userCreated,
  favorites,
  recentlyPlayed,
  curated,
  radio,
}
