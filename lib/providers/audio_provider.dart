import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio/audio_player_service.dart';
import '../../data/models/player_state.dart';
import '../../domain/entities/song.dart';

/// Provider for the audio player service
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the current player state
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.stateStream;
});

/// Provider for the current song
final currentSongProvider = Provider<Song?>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.currentSong;
});

/// Provider for whether music is playing
final isPlayingProvider = Provider<bool>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.isPlaying ?? false;
});

/// Provider for the current queue
final queueProvider = Provider<List<Song>>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.queue ?? [];
});

/// Provider for shuffle state
final shuffleEnabledProvider = Provider<bool>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.shuffleEnabled ?? false;
});

/// Provider for repeat mode
final repeatModeProvider = Provider<RepeatMode>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.repeatMode ?? RepeatMode.off;
});

/// Provider for playback position
final positionProvider = Provider<Duration>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.position ?? Duration.zero;
});

/// Provider for playback duration
final durationProvider = Provider<Duration>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.duration ?? Duration.zero;
});

/// Provider for progress percentage
final progressProvider = Provider<double>((ref) {
  final state = ref.watch(playerStateProvider);
  return state.valueOrNull?.progress ?? 0.0;
});
