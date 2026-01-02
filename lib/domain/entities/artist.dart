import 'package:equatable/equatable.dart';
import 'album.dart';

/// Artist entity representing a music artist
class Artist extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bio;
  final List<String> genres;
  final List<Album> albums;
  final int albumCount;
  final int followerCount;
  final bool isVerified;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    this.genres = const [],
    this.albums = const [],
    this.albumCount = 0,
    this.followerCount = 0,
    this.isVerified = false,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? bio,
    List<String>? genres,
    List<Album>? albums,
    int? albumCount,
    int? followerCount,
    bool? isVerified,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      genres: genres ?? this.genres,
      albums: albums ?? this.albums,
      albumCount: albumCount ?? this.albumCount,
      followerCount: followerCount ?? this.followerCount,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Format follower count with abbreviations
  String get formattedFollowerCount {
    if (followerCount >= 1000000) {
      return '${(followerCount / 1000000).toStringAsFixed(1)}M followers';
    } else if (followerCount >= 1000) {
      return '${(followerCount / 1000).toStringAsFixed(1)}K followers';
    }
    return '$followerCount followers';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    bio,
    genres,
    albums,
    albumCount,
    followerCount,
    isVerified,
  ];
}
