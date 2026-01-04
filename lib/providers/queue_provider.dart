import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/song.dart';
import '../core/utils/app_logger.dart';

/// Queue state
class QueueState {
  final List<Song> songs;
  final int currentIndex;
  final bool isLooping;
  final bool isShuffled;

  const QueueState({
    this.songs = const [],
    this.currentIndex = 0,
    this.isLooping = false,
    this.isShuffled = false,
  });

  QueueState copyWith({
    List<Song>? songs,
    int? currentIndex,
    bool? isLooping,
    bool? isShuffled,
  }) {
    return QueueState(
      songs: songs ?? this.songs,
      currentIndex: currentIndex ?? this.currentIndex,
      isLooping: isLooping ?? this.isLooping,
      isShuffled: isShuffled ?? this.isShuffled,
    );
  }

  bool get isEmpty => songs.isEmpty;
  bool get hasNext => currentIndex < songs.length - 1;
  bool get hasPrevious => currentIndex > 0;
  Song? get currentSong => songs.isEmpty ? null : songs[currentIndex];
  int get totalSongs => songs.length;
}

/// Queue provider - manages playback queue
class QueueNotifier extends StateNotifier<QueueState> {
  QueueNotifier() : super(const QueueState());

  /// Set the entire queue
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    if (songs.isEmpty) {
      AppLogger.warning('Attempted to set empty queue');
      return;
    }

    if (startIndex < 0 || startIndex >= songs.length) {
      AppLogger.warning('Invalid start index: $startIndex, using 0');
      startIndex = 0;
    }

    state = state.copyWith(
      songs: List.from(songs),
      currentIndex: startIndex,
    );

    AppLogger.info('Queue set with ${songs.length} songs, starting at index $startIndex');
  }

  /// Add a song to the end of the queue
  void addToQueue(Song song) {
    final updatedSongs = [...state.songs, song];
    state = state.copyWith(songs: updatedSongs);
    AppLogger.info('Added song to queue: ${song.title}');
  }

  /// Add multiple songs to the end of the queue
  void addMultipleToQueue(List<Song> songs) {
    if (songs.isEmpty) return;

    final updatedSongs = [...state.songs, ...songs];
    state = state.copyWith(songs: updatedSongs);
    AppLogger.info('Added ${songs.length} songs to queue');
  }

  /// Insert a song after the current song (play next)
  void playNext(Song song) {
    if (state.isEmpty) {
      setQueue([song]);
      return;
    }

    final updatedSongs = [...state.songs];
    updatedSongs.insert(state.currentIndex + 1, song);
    state = state.copyWith(songs: updatedSongs);
    AppLogger.info('Inserted song to play next: ${song.title}');
  }

  /// Remove a song from the queue
  void removeSong(int index) {
    if (index < 0 || index >= state.songs.length) {
      AppLogger.warning('Invalid remove index: $index');
      return;
    }

    final updatedSongs = [...state.songs];
    final removedSong = updatedSongs.removeAt(index);

    // Adjust current index if needed
    int newIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newIndex = state.currentIndex - 1;
    } else if (index == state.currentIndex) {
      // If removing current song, keep index the same (will play next song at same position)
      newIndex = state.currentIndex.clamp(0, updatedSongs.length - 1);
    }

    state = state.copyWith(
      songs: updatedSongs,
      currentIndex: newIndex,
    );

    AppLogger.info('Removed song from queue: ${removedSong.title}');
  }

  /// Reorder songs in the queue (drag and drop)
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    // Adjust newIndex if it's after oldIndex (due to removal)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedSongs = [...state.songs];
    final song = updatedSongs.removeAt(oldIndex);
    updatedSongs.insert(newIndex, song);

    // Adjust current index based on the move
    int newCurrentIndex = state.currentIndex;
    if (oldIndex == state.currentIndex) {
      newCurrentIndex = newIndex;
    } else if (oldIndex < state.currentIndex && newIndex >= state.currentIndex) {
      newCurrentIndex = state.currentIndex - 1;
    } else if (oldIndex > state.currentIndex && newIndex <= state.currentIndex) {
      newCurrentIndex = state.currentIndex + 1;
    }

    state = state.copyWith(
      songs: updatedSongs,
      currentIndex: newCurrentIndex,
    );

    AppLogger.debug('Reordered queue: moved index $oldIndex to $newIndex');
  }

  /// Clear the queue
  void clearQueue() {
    state = const QueueState();
    AppLogger.info('Queue cleared');
  }

  /// Jump to a specific song in the queue
  void jumpToIndex(int index) {
    if (index < 0 || index >= state.songs.length) {
      AppLogger.warning('Invalid jump index: $index');
      return;
    }

    state = state.copyWith(currentIndex: index);
    AppLogger.info('Jumped to queue index: $index');
  }

  /// Move to next song
  bool moveToNext() {
    if (state.hasNext) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      AppLogger.debug('Moved to next song in queue');
      return true;
    } else if (state.isLooping && state.songs.isNotEmpty) {
      state = state.copyWith(currentIndex: 0);
      AppLogger.debug('Looped back to start of queue');
      return true;
    }
    return false;
  }

  /// Move to previous song
  bool moveToPrevious() {
    if (state.hasPrevious) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
      AppLogger.debug('Moved to previous song in queue');
      return true;
    } else if (state.isLooping && state.songs.isNotEmpty) {
      state = state.copyWith(currentIndex: state.songs.length - 1);
      AppLogger.debug('Looped to end of queue');
      return true;
    }
    return false;
  }

  /// Toggle loop mode
  void toggleLoop() {
    state = state.copyWith(isLooping: !state.isLooping);
    AppLogger.info('Loop mode: ${state.isLooping}');
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    state = state.copyWith(isShuffled: !state.isShuffled);
    AppLogger.info('Shuffle mode: ${state.isShuffled}');
  }

  /// Get songs from a specific index onwards
  List<Song> getUpcomingSongs({int limit = 10}) {
    if (state.currentIndex + 1 >= state.songs.length) {
      return [];
    }

    final startIndex = state.currentIndex + 1;
    final endIndex = (startIndex + limit).clamp(0, state.songs.length);
    return state.songs.sublist(startIndex, endIndex);
  }

  /// Get songs before current song
  List<Song> getPreviousSongs({int limit = 10}) {
    if (state.currentIndex == 0) {
      return [];
    }

    final endIndex = state.currentIndex;
    final startIndex = (endIndex - limit).clamp(0, endIndex);
    return state.songs.sublist(startIndex, endIndex);
  }
}

/// Queue provider instance
final queueManagerProvider = StateNotifierProvider<QueueNotifier, QueueState>((ref) {
  return QueueNotifier();
});
