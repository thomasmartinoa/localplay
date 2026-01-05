# Swipe to Favorite Feature 💝

## Overview
Added an intuitive swipe gesture to favorite/unfavorite songs directly from any song list.

## How It Works

### Swipe Right or Left
- **Swipe Right** → Toggle favorite status
- **Swipe Left** → Toggle favorite status
- Both directions work the same way for ease of use

### Visual Feedback

#### When Song is NOT Favorite:
- **Gradient**: Primary color (pink/red) gradient
- **Icon**: ❤️ Solid heart icon
- **Action**: Adds song to favorites

#### When Song IS Favorite:
- **Gradient**: Red gradient
- **Icon**: 💔 Broken heart icon
- **Action**: Removes song from favorites

### User Experience
1. User swipes any song tile left or right
2. Beautiful gradient background appears showing the action
3. Heart icon indicates the action (add/remove favorite)
4. Song stays in place (doesn't dismiss)
5. Favorite status updates instantly
6. Works across all song lists:
   - All Songs screen
   - Album details
   - Artist details
   - Search results
   - Playlists
   - Genre screens

## Technical Implementation

### Changes Made
**File**: `lib/presentation/widgets/song_tile.dart`

1. **Wrapped in Dismissible Widget**
   - Enabled horizontal swipe
   - `confirmDismiss` returns `false` to prevent actual dismissal
   - Toggles favorite state on swipe

2. **Added Swipe Background**
   - Gradient background (primary or red based on state)
   - Heart/broken heart icon
   - Aligned left or right based on swipe direction

3. **State Management**
   - Watches `favoriteSongsProvider` for current state
   - Calls `toggleFavorite()` on swipe
   - Instant UI update

## Design Details

### Colors
- **Add to Favorites**: Primary color gradient (AppColors.primary)
- **Remove from Favorites**: Red gradient (Colors.red)
- **Icon Color**: White for contrast

### Animation
- Smooth gradient reveal during swipe
- No jittery animations
- Maintains song tile's tap and scale animations

### Icon Size
- Heart icons: 28px
- White color for visibility against gradient

## User Benefits

✅ **Faster**: No need to open context menu
✅ **Intuitive**: Natural swipe gesture
✅ **Visual**: Clear indication of action
✅ **Consistent**: Works everywhere in the app
✅ **Reversible**: Swipe again to undo
✅ **Non-destructive**: Song stays in place

## Testing

### Manual Testing Checklist
- [ ] Swipe right on non-favorite song → adds to favorites
- [ ] Swipe left on non-favorite song → adds to favorites
- [ ] Swipe right on favorite song → removes from favorites
- [ ] Swipe left on favorite song → removes from favorites
- [ ] Song tile doesn't dismiss after swipe
- [ ] Gradient appears smoothly during swipe
- [ ] Correct icon shows (heart vs broken heart)
- [ ] Works in All Songs screen
- [ ] Works in Album screen
- [ ] Works in Artist screen
- [ ] Works in Search results
- [ ] Works in Playlist screen
- [ ] Favorite state persists after app restart
- [ ] Tap still plays the song (doesn't interfere)

## Example Usage

### Screen: All Songs
```
┌─────────────────────────────────────┐
│  🎵 Song Title                      │  ← Swipe right
│     Artist Name               3:45  │  
└─────────────────────────────────────┘
         ↓ Swipe reveals ↓
┌─────────────────────────────────────┐
│ ❤️ [Pink gradient]     Song Title   │
│                        Artist    3:45│
└─────────────────────────────────────┘
```

### After Favorite Added
```
┌─────────────────────────────────────┐
│  🎵 Song Title                      │  ← Swipe left  
│     Artist Name               3:45  │  (Already favorite)
└─────────────────────────────────────┘
         ↓ Swipe reveals ↓
┌─────────────────────────────────────┐
│     Song Title   💔 [Red gradient]  │
│     Artist 3:45                      │
└─────────────────────────────────────┘
```

## Code Quality

✅ No new dependencies
✅ Uses existing favorite provider
✅ Follows app's design language
✅ Type-safe implementation
✅ No performance impact
✅ Maintains existing functionality

## Future Enhancements

Potential improvements:
- [ ] Haptic feedback on swipe
- [ ] Custom swipe threshold
- [ ] Toast notification "Added to favorites"
- [ ] Undo snackbar
- [ ] Swipe to add to playlist (different direction)
- [ ] Customizable swipe actions in settings

## Conclusion

The swipe-to-favorite feature provides a quick, intuitive way to manage favorite songs without interrupting the music browsing experience. It's implemented cleanly with minimal code changes and follows iOS/Apple Music UX patterns.
