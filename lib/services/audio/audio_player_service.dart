import 'dart:async';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';
import '../../domain/entities/song.dart';
import '../../data/models/player_state.dart';
import '../../core/utils/app_logger.dart';

/// Audio player service using just_audio for playback
class AudioPlayerService {
  final AudioPlayer _player;
  final BehaviorSubject<PlayerState> _stateSubject;

  List<Song> _queue = [];
  int _currentIndex = 0;
  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int>? _shuffleIndices;

  AudioPlayerService()
    : _player = AudioPlayer(),
      _stateSubject = BehaviorSubject<PlayerState>.seeded(
        PlayerState.initial(),
      ) {
    _init();
  }

  /// Stream of player state
  Stream<PlayerState> get stateStream => _stateSubject.stream;

  /// Current player state
  PlayerState get state => _stateSubject.value;

  /// Current song being played
  Song? get currentSong => _queue.isNotEmpty && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  /// The audio player instance
  AudioPlayer get player => _player;

  /// Initialize the audio player
  Future<void> _init() async {
    // Configure audio session for music playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state changes
    _player.playerStateStream.listen((playerState) {
      _updateState();
    });

    // Listen to position changes
    _player.positionStream.listen((position) {
      _updateState();
    });

    // Listen to buffered position changes
    _player.bufferedPositionStream.listen((bufferedPosition) {
      _updateState();
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      _updateState();
    });

    // Listen for completion
    _player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
      _updateState();
    });
  }

  /// Update the state stream
  void _updateState() {
    final processingState = _player.processingState;

    _stateSubject.add(
      PlayerState(
        currentSong: currentSong,
        queue: _queue,
        currentIndex: _currentIndex,
        position: _player.position,
        bufferedPosition: _player.bufferedPosition,
        duration: _player.duration ?? Duration.zero,
        isPlaying: _player.playing,
        isBuffering:
            processingState == ProcessingState.buffering ||
            processingState == ProcessingState.loading,
        isCompleted: processingState == ProcessingState.completed,
        volume: _player.volume,
        speed: _player.speed,
        repeatMode: _repeatMode,
        shuffleEnabled: _shuffleEnabled,
        hasNext: _hasNext(),
        hasPrevious: _hasPrevious(),
      ),
    );
  }

  /// Handle song completion
  Future<void> _onSongCompleted() async {
    switch (_repeatMode) {
      case RepeatMode.one:
        await seekTo(Duration.zero);
        await play();
        break;
      case RepeatMode.all:
        if (_hasNext()) {
          await next();
        } else {
          // Go back to the first song
          _currentIndex = 0;
          await _loadCurrentSong();
          await play();
        }
        break;
      case RepeatMode.off:
        if (_hasNext()) {
          await next();
        }
        break;
    }
  }

  /// Check if there's a next song
  bool _hasNext() {
    if (_queue.isEmpty) return false;
    if (_repeatMode == RepeatMode.all) return true;
    return _currentIndex < _queue.length - 1;
  }

  /// Check if there's a previous song
  bool _hasPrevious() {
    if (_queue.isEmpty) return false;
    return _currentIndex > 0 || _player.position > const Duration(seconds: 3);
  }

  /// Play a single song
  Future<void> playSong(Song song) async {
    await playQueue([song], startIndex: 0);
  }

  /// Play a queue of songs
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);

    if (_shuffleEnabled) {
      _generateShuffleIndices();
    }

    await _loadCurrentSong();
    await play();
  }

  /// Load the current song
  Future<void> _loadCurrentSong() async {
    final song = currentSong;
    if (song == null) return;

    try {
      // Load from local file or URL
      if (song.isLocal && song.filePath != null) {
        await _player.setFilePath(song.filePath!);
      } else if (song.audioUrl != null) {
        await _player.setUrl(song.audioUrl!);
      } else {
        AppLogger.warning('No audio source available for song: ${song.title}');
        // Auto-skip to next song if current song has no source
        if (_hasNext()) {
          AppLogger.info('Auto-skipping to next song');
          await next();
        }
        return;
      }
      _updateState();
    } catch (e) {
      // Handle error - maybe the file or URL is invalid
      AppLogger.error('Error loading song ${song.title}: $e');
      
      // Auto-skip to next song on error
      if (_hasNext()) {
        AppLogger.info('Auto-skipping to next song due to load error');
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay before skipping
        await next();
      } else {
        // No more songs, just stop
        AppLogger.warning('No more songs in queue, stopping playback');
        await stop();
      }
    }
  }

  /// Play
  Future<void> play() async {
    await _player.play();
  }

  /// Pause
  Future<void> pause() async {
    await _player.pause();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// Stop
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Seek to percentage (0.0 to 1.0)
  Future<void> seekToPercent(double percent) async {
    final duration = _player.duration ?? Duration.zero;
    final position = Duration(
      milliseconds: (duration.inMilliseconds * percent).round(),
    );
    await seekTo(position);
  }

  /// Skip forward by duration
  Future<void> seekForward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    final currentPosition = _player.position;
    final maxDuration = _player.duration ?? Duration.zero;
    final newPosition = currentPosition + duration;
    await seekTo(newPosition > maxDuration ? maxDuration : newPosition);
  }

  /// Skip backward by duration
  Future<void> seekBackward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    final currentPosition = _player.position;
    final newPosition = currentPosition - duration;
    await seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  /// Go to next song
  Future<void> next() async {
    if (!_hasNext()) return;

    if (_shuffleEnabled && _shuffleIndices != null) {
      final currentShuffleIndex = _shuffleIndices!.indexOf(_currentIndex);
      if (currentShuffleIndex < _shuffleIndices!.length - 1) {
        _currentIndex = _shuffleIndices![currentShuffleIndex + 1];
      }
    } else {
      _currentIndex++;
    }

    await _loadCurrentSong();
    await play();
  }

  /// Go to previous song
  Future<void> previous() async {
    // If more than 3 seconds into the song, restart it
    if (_player.position > const Duration(seconds: 3)) {
      await seekTo(Duration.zero);
      return;
    }

    if (!_hasPrevious()) return;

    if (_shuffleEnabled && _shuffleIndices != null) {
      final currentShuffleIndex = _shuffleIndices!.indexOf(_currentIndex);
      if (currentShuffleIndex > 0) {
        _currentIndex = _shuffleIndices![currentShuffleIndex - 1];
      }
    } else {
      _currentIndex--;
    }

    await _loadCurrentSong();
    await play();
  }

  /// Skip to specific index in queue
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await _loadCurrentSong();
    await play();
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    if (_shuffleEnabled) {
      _generateShuffleIndices();
    } else {
      _shuffleIndices = null;
    }
    _updateState();
  }

  /// Set shuffle mode
  void setShuffle(bool enabled) {
    _shuffleEnabled = enabled;
    if (enabled) {
      _generateShuffleIndices();
    } else {
      _shuffleIndices = null;
    }
    _updateState();
  }

  /// Generate shuffle indices
  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_queue.length, (i) => i)..shuffle();
    // Put current index at the beginning
    if (_shuffleIndices != null) {
      _shuffleIndices!.remove(_currentIndex);
      _shuffleIndices!.insert(0, _currentIndex);
    }
  }

  /// Toggle repeat mode
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _updateState();
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    _updateState();
  }

  /// Add song to queue
  void addToQueue(Song song) {
    _queue.add(song);
    if (_shuffleEnabled) {
      _shuffleIndices?.add(_queue.length - 1);
    }
    _updateState();
  }

  /// Add song to play next
  void playNext(Song song) {
    _queue.insert(_currentIndex + 1, song);
    if (_shuffleEnabled) {
      final currentShuffleIndex = _shuffleIndices?.indexOf(_currentIndex) ?? 0;
      _shuffleIndices?.insert(currentShuffleIndex + 1, _currentIndex + 1);
    }
    _updateState();
  }

  /// Remove song from queue
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;

    _queue.removeAt(index);
    if (_shuffleEnabled) {
      _shuffleIndices?.remove(index);
    }

    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _queue.isNotEmpty) {
      _loadCurrentSong();
    }

    _updateState();
  }

  /// Clear the queue
  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    _shuffleIndices = null;
    stop();
    _updateState();
  }

  /// Reorder queue
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;

    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Update current index if needed
    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }

    _updateState();
  }

  /// Get queue
  List<Song> get queue => List.unmodifiable(_queue);

  /// Get current index
  int get currentIndex => _currentIndex;

  /// Dispose the player
  Future<void> dispose() async {
    await _player.dispose();
    await _stateSubject.close();
  }
}
