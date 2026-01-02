import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/audio_provider.dart';
import '../widgets/mini_player.dart';

/// Main shell widget with floating glass navigation bar - Apple Music style
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final hasCurrentSong = playerState.maybeWhen(
      data: (state) => state.currentSong != null,
      orElse: () => false,
    );

    // Get safe area bottom padding
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Nav bar height + bottom padding + margin
    final navBarTotalHeight = 58 + bottomPadding + 16;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Main content - extends behind nav bar for glass effect
              Positioned.fill(child: widget.child),
              // Floating Mini Player (positioned correctly above nav bar)
              if (hasCurrentSong)
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: navBarTotalHeight + 8, // 8px gap above nav bar
                  child: const MiniPlayer(),
                ),
              // Floating Glass Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFloatingNavBar(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context) {
    const iconColor = Colors.white;
    final inactiveIconColor = Colors.white.withValues(alpha: 0.5);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
        child: LiquidGlassLayer(
          settings: const LiquidGlassSettings(
            thickness: 20,
            blur: 7,
            glassColor: Color.fromARGB(61, 11, 7, 214),
            lightIntensity: 0.25,
            saturation: 1.0,
          ),
          child: LiquidGlassBlendGroup(
            blend: 15.0,
            child: Row(
              children: [
                // Main navigation pill (Home, Library)
                Expanded(
                  child: LiquidGlass.grouped(
                    shape: LiquidRoundedSuperellipse(borderRadius: 18),
                    child: SizedBox(
                      height: 58,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            index: 0,
                            route: '/',
                            iconColor: iconColor,
                            inactiveColor: inactiveIconColor,
                          ),
                          _buildNavItem(
                            icon: Icons.library_music_rounded,
                            label: 'Library',
                            index: 1,
                            route: '/library',
                            iconColor: iconColor,
                            inactiveColor: inactiveIconColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Search button (circular pill)
                _buildSearchButton(context, iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context, Color iconColor) {
    final isActive = _currentIndex == 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = 2);
        context.go('/search');
      },
      child: LiquidGlass.grouped(
        shape: LiquidRoundedSuperellipse(borderRadius: 18),
        child: SizedBox(
          height: 58,
          width: 58,
          child: Center(
            child: Icon(
              Icons.search_rounded,
              color: isActive ? AppColors.primary : iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required String route,
    required Color iconColor,
    required Color inactiveColor,
    bool isDisabled = false,
  }) {
    final isActive = _currentIndex == index && !isDisabled;

    // Active background color - subtle highlight
    final activeBackgroundColor = Colors.white.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              setState(() => _currentIndex = index);
              context.go(route);
            },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with background highlight for active state
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? activeBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDisabled
                    ? inactiveColor.withValues(alpha: 0.3)
                    : isActive
                    ? AppColors.primary
                    : iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isDisabled
                    ? inactiveColor.withValues(alpha: 0.3)
                    : isActive
                    ? AppColors.primary
                    : iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
