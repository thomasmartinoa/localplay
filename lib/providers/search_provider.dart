import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';

/// Search state
class SearchState {
  final String query;
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Song>? songs,
    List<Album>? albums,
    List<Artist>? artists,
    List<Playlist>? playlists,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      songs: songs ?? this.songs,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasResults => 
    songs.isNotEmpty || albums.isNotEmpty || artists.isNotEmpty || playlists.isNotEmpty;
}

/// Search provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
    if (query.isEmpty) {
      clearResults();
    } else {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual search logic
      // For now, this is a placeholder that would connect to your data source
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        isLoading: false,
        // Results would be populated from your data source
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearResults() {
    state = const SearchState();
  }
}

/// Search history provider
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const int maxHistory = 20;

  SearchHistoryNotifier() : super([]);

  void addToHistory(String query) {
    if (query.isEmpty) return;
    
    final newState = state.where((q) => q != query).toList();
    newState.insert(0, query);
    
    if (newState.length > maxHistory) {
      newState.removeLast();
    }
    
    state = newState;
  }

  void removeFromHistory(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clearHistory() {
    state = [];
  }
}
