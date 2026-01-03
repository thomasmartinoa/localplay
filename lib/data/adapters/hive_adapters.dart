import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/entities.dart';

/// Hive Type IDs
class HiveTypeIds {
  static const int song = 0;
  static const int album = 1;
  static const int artist = 2;
  static const int playlist = 3;
  static const int scanFolder = 4;
  static const int playlistType = 5;
}

/// Song adapter for Hive
class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = HiveTypeIds.song;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      albumId: fields[4] as String?,
      artistId: fields[5] as String?,
      artworkUrl: fields[6] as String?,
      audioUrl: fields[7] as String?,
      filePath: fields[8] as String?,
      localArtworkPath: fields[9] as String?,
      isLocal: fields[10] as bool? ?? false,
      duration: Duration(milliseconds: fields[11] as int? ?? 0),
      trackNumber: fields[12] as int?,
      discNumber: fields[13] as int?,
      genre: fields[14] as String?,
      releaseYear: fields[15] as int?,
      isExplicit: fields[16] as bool? ?? false,
      isFavorite: fields[17] as bool? ?? false,
      lastPlayed: fields[18] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[18] as int)
          : null,
      playCount: fields[19] as int? ?? 0,
      dateAdded: fields[20] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[20] as int)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.albumId)
      ..writeByte(5)
      ..write(obj.artistId)
      ..writeByte(6)
      ..write(obj.artworkUrl)
      ..writeByte(7)
      ..write(obj.audioUrl)
      ..writeByte(8)
      ..write(obj.filePath)
      ..writeByte(9)
      ..write(obj.localArtworkPath)
      ..writeByte(10)
      ..write(obj.isLocal)
      ..writeByte(11)
      ..write(obj.duration.inMilliseconds)
      ..writeByte(12)
      ..write(obj.trackNumber)
      ..writeByte(13)
      ..write(obj.discNumber)
      ..writeByte(14)
      ..write(obj.genre)
      ..writeByte(15)
      ..write(obj.releaseYear)
      ..writeByte(16)
      ..write(obj.isExplicit)
      ..writeByte(17)
      ..write(obj.isFavorite)
      ..writeByte(18)
      ..write(obj.lastPlayed?.millisecondsSinceEpoch)
      ..writeByte(19)
      ..write(obj.playCount)
      ..writeByte(20)
      ..write(obj.dateAdded?.millisecondsSinceEpoch);
  }
}

/// Album adapter for Hive
class AlbumAdapter extends TypeAdapter<Album> {
  @override
  final int typeId = HiveTypeIds.album;

  @override
  Album read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Album(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      artistId: fields[3] as String?,
      artworkUrl: fields[4] as String?,
      localArtworkPath: fields[5] as String?,
      isLocal: fields[6] as bool? ?? false,
      releaseYear: fields[7] as int? ?? 0,
      genre: fields[8] as String?,
      songCount: fields[9] as int? ?? 0,
      totalDuration: Duration(milliseconds: fields[10] as int? ?? 0),
      isExplicit: fields[11] as bool? ?? false,
      copyright: fields[12] as String?,
      description: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Album obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.artistId)
      ..writeByte(4)
      ..write(obj.artworkUrl)
      ..writeByte(5)
      ..write(obj.localArtworkPath)
      ..writeByte(6)
      ..write(obj.isLocal)
      ..writeByte(7)
      ..write(obj.releaseYear)
      ..writeByte(8)
      ..write(obj.genre)
      ..writeByte(9)
      ..write(obj.songCount)
      ..writeByte(10)
      ..write(obj.totalDuration.inMilliseconds)
      ..writeByte(11)
      ..write(obj.isExplicit)
      ..writeByte(12)
      ..write(obj.copyright)
      ..writeByte(13)
      ..write(obj.description);
  }
}

/// Artist adapter for Hive
class ArtistAdapter extends TypeAdapter<Artist> {
  @override
  final int typeId = HiveTypeIds.artist;

  @override
  Artist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artist(
      id: fields[0] as String,
      name: fields[1] as String,
      imageUrl: fields[2] as String?,
      bio: fields[3] as String?,
      genres: (fields[4] as List?)?.cast<String>() ?? [],
      albumCount: fields[5] as int? ?? 0,
      followerCount: fields[6] as int? ?? 0,
      isVerified: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Artist obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.albumCount)
      ..writeByte(6)
      ..write(obj.followerCount)
      ..writeByte(7)
      ..write(obj.isVerified);
  }
}

/// Scan folder model for storing user-selected folders
class ScanFolder {
  final String path;
  final String name;
  final DateTime addedAt;
  final bool isEnabled;

  const ScanFolder({
    required this.path,
    required this.name,
    required this.addedAt,
    this.isEnabled = true,
  });

  ScanFolder copyWith({
    String? path,
    String? name,
    DateTime? addedAt,
    bool? isEnabled,
  }) {
    return ScanFolder(
      path: path ?? this.path,
      name: name ?? this.name,
      addedAt: addedAt ?? this.addedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// ScanFolder adapter for Hive
class ScanFolderAdapter extends TypeAdapter<ScanFolder> {
  @override
  final int typeId = HiveTypeIds.scanFolder;

  @override
  ScanFolder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanFolder(
      path: fields[0] as String,
      name: fields[1] as String,
      addedAt: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      isEnabled: fields[3] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, ScanFolder obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.addedAt.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.isEnabled);
  }
}

/// Playlist adapter for Hive
class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = HiveTypeIds.playlist;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      artworkUrl: fields[3] as String?,
      creatorId: fields[4] as String?,
      creatorName: fields[5] as String?,
      songs: (fields[6] as List?)?.cast<Song>() ?? [],
      songCount: fields[7] as int? ?? 0,
      totalDuration: Duration(milliseconds: fields[8] as int? ?? 0),
      isPublic: fields[9] as bool? ?? false,
      isEditable: fields[10] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[11] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[12] as int),
      type: PlaylistType.values[fields[13] as int? ?? 0],
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.artworkUrl)
      ..writeByte(4)
      ..write(obj.creatorId)
      ..writeByte(5)
      ..write(obj.creatorName)
      ..writeByte(6)
      ..write(obj.songs)
      ..writeByte(7)
      ..write(obj.songCount)
      ..writeByte(8)
      ..write(obj.totalDuration.inMilliseconds)
      ..writeByte(9)
      ..write(obj.isPublic)
      ..writeByte(10)
      ..write(obj.isEditable)
      ..writeByte(11)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(12)
      ..write(obj.updatedAt.millisecondsSinceEpoch)
      ..writeByte(13)
      ..write(obj.type.index);
  }
}

/// PlaylistType adapter for Hive
class PlaylistTypeAdapter extends TypeAdapter<PlaylistType> {
  @override
  final int typeId = HiveTypeIds.playlistType;

  @override
  PlaylistType read(BinaryReader reader) {
    return PlaylistType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, PlaylistType obj) {
    writer.writeByte(obj.index);
  }
}

/// Initialize Hive adapters
Future<void> registerHiveAdapters() async {
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(AlbumAdapter());
  Hive.registerAdapter(ArtistAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(PlaylistTypeAdapter());
  Hive.registerAdapter(ScanFolderAdapter());
}

/// Hive box names
class HiveBoxes {
  static const String songs = 'songs';
  static const String albums = 'albums';
  static const String artists = 'artists';
  static const String playlists = 'playlists';
  static const String favorites = 'favorites';
  static const String recentlyPlayed = 'recently_played';
  static const String scanFolders = 'scan_folders';
  static const String settings = 'settings';
}
