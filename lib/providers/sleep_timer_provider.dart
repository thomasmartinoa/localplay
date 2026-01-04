import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/utils/app_logger.dart';
import 'audio_provider.dart';

/// Sleep timer state
class SleepTimerState {
  final Duration? duration;
  final Duration? remaining;
  final bool isActive;
  final DateTime? startTime;

  const SleepTimerState({
    this.duration,
    this.remaining,
    this.isActive = false,
    this.startTime,
  });

  SleepTimerState copyWith({
    Duration? duration,
    Duration? remaining,
    bool? isActive,
    DateTime? startTime,
  }) {
    return SleepTimerState(
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Get progress from 0.0 to 1.0
  double get progress {
    if (duration == null || remaining == null) return 0.0;
    if (duration!.inSeconds == 0) return 0.0;
    return 1.0 - (remaining!.inSeconds / duration!.inSeconds);
  }

  /// Format remaining time as MM:SS
  String get formattedRemaining {
    if (remaining == null) return '00:00';
    final minutes = remaining!.inMinutes;
    final seconds = remaining!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Sleep timer provider
final sleepTimerProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  return SleepTimerNotifier(ref);
});

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  final Ref _ref;
  Timer? _timer;
  Box? _settingsBox;

  SleepTimerNotifier(this._ref) : super(const SleepTimerState()) {
    _loadSavedTimer();
  }

  /// Load saved timer from storage
  Future<void> _loadSavedTimer() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      final savedEndTime = _settingsBox?.get('sleep_timer_end_time');

      if (savedEndTime != null) {
        final endTime = DateTime.fromMillisecondsSinceEpoch(savedEndTime as int);
        final now = DateTime.now();

        if (endTime.isAfter(now)) {
          // Timer is still active
          final duration = endTime.difference(now);
          _startTimer(duration, resuming: true);
        } else {
          // Timer expired while app was closed
          await _clearSavedTimer();
        }
      }
    } catch (e) {
      AppLogger.error('Error loading sleep timer: $e');
    }
  }

  /// Save timer to storage
  Future<void> _saveTimer(DateTime endTime) async {
    try {
      _settingsBox ??= await Hive.openBox('settings');
      await _settingsBox!.put('sleep_timer_end_time', endTime.millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('Error saving sleep timer: $e');
    }
  }

  /// Clear saved timer
  Future<void> _clearSavedTimer() async {
    try {
      _settingsBox ??= await Hive.openBox('settings');
      await _settingsBox!.delete('sleep_timer_end_time');
    } catch (e) {
      AppLogger.error('Error clearing sleep timer: $e');
    }
  }

  /// Start sleep timer
  void startTimer(Duration duration) {
    _startTimer(duration, resuming: false);
  }

  void _startTimer(Duration duration, {required bool resuming}) {
    _timer?.cancel();

    final startTime = DateTime.now();
    final endTime = startTime.add(duration);

    if (!resuming) {
      _saveTimer(endTime);
    }

    state = SleepTimerState(
      duration: duration,
      remaining: duration,
      isActive: true,
      startTime: startTime,
    );

    AppLogger.info('Sleep timer started: ${duration.inMinutes} minutes');

    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = endTime.difference(now);

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        _onTimerComplete();
      } else {
        state = state.copyWith(
          remaining: remaining,
        );
      }
    });
  }

  /// Timer completed
  Future<void> _onTimerComplete() async {
    AppLogger.info('Sleep timer completed - pausing playback');

    _timer?.cancel();
    _timer = null;

    // Pause the audio
    final audioService = _ref.read(audioPlayerServiceProvider);
    await audioService.pause();

    // Clear state
    state = const SleepTimerState();

    // Clear saved timer
    await _clearSavedTimer();
  }

  /// Cancel timer
  Future<void> cancelTimer() async {
    AppLogger.info('Sleep timer cancelled');

    _timer?.cancel();
    _timer = null;

    state = const SleepTimerState();

    await _clearSavedTimer();
  }

  /// Add time to active timer
  void addTime(Duration duration) {
    if (!state.isActive || state.remaining == null) return;

    final newRemaining = state.remaining! + duration;
    final newDuration = state.duration! + duration;

    // Restart timer with new duration
    _startTimer(newRemaining, resuming: true);

    state = state.copyWith(
      duration: newDuration,
      remaining: newRemaining,
    );

    AppLogger.info('Added ${duration.inMinutes} minutes to sleep timer');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Common sleep timer durations
class SleepTimerDurations {
  static const Duration fiveMinutes = Duration(minutes: 5);
  static const Duration tenMinutes = Duration(minutes: 10);
  static const Duration fifteenMinutes = Duration(minutes: 15);
  static const Duration thirtyMinutes = Duration(minutes: 30);
  static const Duration fortyFiveMinutes = Duration(minutes: 45);
  static const Duration oneHour = Duration(hours: 1);
  static const Duration twoHours = Duration(hours: 2);

  static final List<Duration> presets = [
    fiveMinutes,
    tenMinutes,
    fifteenMinutes,
    thirtyMinutes,
    fortyFiveMinutes,
    oneHour,
    twoHours,
  ];

  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours hr $minutes min';
      }
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
  }
}
