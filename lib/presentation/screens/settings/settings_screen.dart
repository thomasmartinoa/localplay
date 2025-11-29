import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/local_music_provider.dart';
import '../../../services/local_music/local_music_scanner.dart';
import '../../../data/adapters/hive_adapters.dart';

/// Settings screen for folder selection and music scanning
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanFolders = ref.watch(scanFoldersProvider);
    final libraryStats = ref.watch(libraryStatsProvider);
    final scanProgressAsync = ref.watch(scanProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Settings',
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Library Stats Card
          _buildStatsCard(libraryStats),
          
          const SizedBox(height: 24),
          
          // Scan Progress (if scanning)
          scanProgressAsync.when(
            data: (progress) => progress.isScanning
                ? _buildScanProgressCard(progress)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Music Folders Section
          Text(
            'Music Folders',
            style: AppTextStyles.title3.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select folders to scan for music files',
            style: AppTextStyles.subhead.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Add Folder Button
          _buildAddFolderButton(context, ref),
          
          const SizedBox(height: 16),
          
          // Folder List
          if (scanFolders.isEmpty)
            _buildEmptyFoldersMessage()
          else
            ...scanFolders.map((folder) => _buildFolderTile(context, ref, folder)),
          
          const SizedBox(height: 24),
          
          // Scan Buttons
          _buildScanButtons(context, ref, scanFolders.isNotEmpty),
          
          const SizedBox(height: 24),
          
          // Danger Zone
          _buildDangerZone(context, ref),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassDark.withOpacity(0.8),
            AppColors.glassLight.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Library',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.music_note, '${stats['songs'] ?? 0}', 'Songs'),
              _buildStatItem(Icons.album, '${stats['albums'] ?? 0}', 'Albums'),
              _buildStatItem(Icons.person, '${stats['artists'] ?? 0}', 'Artists'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildScanProgressCard(ScanProgress progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryDark.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Scanning Music...',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: AppColors.glassDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${progress.scannedFiles} / ${progress.totalFiles} files',
            style: AppTextStyles.subhead.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          if (progress.currentFile.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              progress.currentFile,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddFolderButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _pickFolder(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.folder_add, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Add Music Folder',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFoldersMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Iconsax.folder,
            size: 48,
            color: AppColors.textSecondaryDark.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No folders selected',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add folders to scan for music,\nor scan all device music',
            textAlign: TextAlign.center,
            style: AppTextStyles.subhead.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, WidgetRef ref, ScanFolder folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: folder.isEnabled 
                ? AppColors.primary.withOpacity(0.2) 
                : AppColors.glassDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Iconsax.folder,
            color: folder.isEnabled ? AppColors.primary : AppColors.textSecondaryDark,
          ),
        ),
        title: Text(
          folder.name,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        subtitle: Text(
          folder.path,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: folder.isEnabled,
              onChanged: (_) => ref.read(scanFoldersProvider.notifier).toggleFolder(folder.path),
              activeThumbColor: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.textSecondaryDark),
              onPressed: () => _showDeleteFolderDialog(context, ref, folder),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButtons(BuildContext context, WidgetRef ref, bool hasFolders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scan Selected Folders
        if (hasFolders)
          ElevatedButton.icon(
            onPressed: () => _startScan(ref, useSelectedFolders: true),
            icon: const Icon(Iconsax.folder_2),
            label: const Text('Scan Selected Folders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        
        if (hasFolders) const SizedBox(height: 12),
        
        // Scan All Music
        OutlinedButton.icon(
          onPressed: () => _startScan(ref, useSelectedFolders: false),
          icon: const Icon(Iconsax.music),
          label: const Text('Scan All Device Music'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showClearLibraryDialog(context, ref),
          icon: const Icon(Iconsax.trash),
          label: const Text('Clear Music Library'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    final pickFolder = ref.read(pickFolderProvider);
    final path = await pickFolder();
    
    if (path != null) {
      // Check if directory is accessible
      final dir = Directory(path);
      final exists = await dir.exists();
      
      // Even if the directory check fails, we'll add it and let the scanner try
      // The scanner has fallback logic for alternative paths
      if (!exists) {
        print('Directory not directly accessible, but will add anyway: $path');
      }
      
      final name = path.split(Platform.pathSeparator).last;
      final folder = ScanFolder(
        path: path,
        name: name,
        addedAt: DateTime.now(),
      );
      await ref.read(scanFoldersProvider.notifier).addFolder(folder);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added folder: $name'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'Scan Now',
              textColor: Colors.white,
              onPressed: () => _startScan(ref, useSelectedFolders: true),
            ),
          ),
        );
      }
    }
  }

  Future<void> _startScan(WidgetRef ref, {required bool useSelectedFolders}) async {
    final scanAction = ref.read(scanMusicActionProvider);
    await scanAction(useSelectedFolders: useSelectedFolders);
  }

  void _showDeleteFolderDialog(BuildContext context, WidgetRef ref, ScanFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Remove Folder',
          style: AppTextStyles.title3.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Remove "${folder.name}" from scan folders?',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scanFoldersProvider.notifier).removeFolder(folder.path);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearLibraryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Clear Library',
          style: AppTextStyles.title3.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'This will remove all scanned music from the library. Your actual music files will not be deleted.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(localSongsProvider.notifier).clearAll();
              await ref.read(localAlbumsProvider.notifier).clearAll();
              await ref.read(localArtistsProvider.notifier).clearAll();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
