import 'package:equatable/equatable.dart';
import '../../domain/entities/song.dart';

/// Represents the current state of the audio player
class PlayerState extends Equatable {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;
  final double volume;
  final double speed;
  final RepeatMode repeatMode;
  final bool shuffleEnabled;
  final bool hasNext;
  final bool hasPrevious;

  const PlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isCompleted = false,
    this.volume = 1.0,
    this.speed = 1.0,
    this.repeatMode = RepeatMode.off,
    this.shuffleEnabled = false,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  /// Initial empty state
  factory PlayerState.initial() => const PlayerState();

  PlayerState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    bool? isCompleted,
    double? volume,
    double? speed,
    RepeatMode? repeatMode,
    bool? shuffleEnabled,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isCompleted: isCompleted ?? this.isCompleted,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  /// Get progress as percentage (0.0 to 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Get buffered progress as percentage (0.0 to 1.0)
  double get bufferedProgress {
    if (duration.inMilliseconds == 0) return 0.0;
    return bufferedPosition.inMilliseconds / duration.inMilliseconds;
  }

  /// Format position as mm:ss
  String get formattedPosition {
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration as mm:ss
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format remaining time as -mm:ss
  String get formattedRemaining {
    final remaining = duration - position;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '-$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    currentSong,
    queue,
    currentIndex,
    position,
    bufferedPosition,
    duration,
    isPlaying,
    isBuffering,
    isCompleted,
    volume,
    speed,
    repeatMode,
    shuffleEnabled,
    hasNext,
    hasPrevious,
  ];
}

/// Repeat mode options
enum RepeatMode { off, all, one }
