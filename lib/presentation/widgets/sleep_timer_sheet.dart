import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/sleep_timer_provider.dart';

/// Sleep timer bottom sheet
class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(sleepTimerProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondaryDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Iconsax.timer_1, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Sleep Timer',
                    style: AppTextStyles.title2.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const Spacer(),
                  if (timerState.isActive)
                    TextButton.icon(
                      onPressed: () {
                        ref.read(sleepTimerProvider.notifier).cancelTimer();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            // Active Timer Display
            if (timerState.isActive) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      timerState.formattedRemaining,
                      style: AppTextStyles.largeTitle.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Music will stop',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: timerState.progress,
                        backgroundColor: AppColors.textSecondaryDark.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add time buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAddTimeButton('+5 min', const Duration(minutes: 5)),
                        _buildAddTimeButton('+10 min', const Duration(minutes: 10)),
                        _buildAddTimeButton('+15 min', const Duration(minutes: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              // Preset durations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Set',
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SleepTimerDurations.presets.map((duration) {
                        return _buildPresetChip(duration);
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Custom duration
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Duration',
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeInput(
                            controller: _hoursController,
                            label: 'Hours',
                            maxValue: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeInput(
                            controller: _minutesController,
                            label: 'Minutes',
                            maxValue: 59,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStartButton(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(Duration duration) {
    return InkWell(
      onTap: () {
        ref.read(sleepTimerProvider.notifier).startTimer(duration);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderDark,
          ),
        ),
        child: Text(
          SleepTimerDurations.formatDuration(duration),
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput({
    required TextEditingController controller,
    required String label,
    required int maxValue,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimaryDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption1.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          final intValue = int.tryParse(value) ?? 0;
          if (intValue > maxValue) {
            controller.text = maxValue.toString();
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
        }
      },
    );
  }

  Widget _buildStartButton() {
    return IconButton(
      onPressed: () {
        final hours = int.tryParse(_hoursController.text) ?? 0;
        final minutes = int.tryParse(_minutesController.text) ?? 0;

        if (hours > 0 || minutes > 0) {
          final duration = Duration(hours: hours, minutes: minutes);
          ref.read(sleepTimerProvider.notifier).startTimer(duration);
          Navigator.pop(context);
        }
      },
      icon: const Icon(Iconsax.play_circle5),
      color: AppColors.primary,
      iconSize: 40,
    );
  }

  Widget _buildAddTimeButton(String label, Duration duration) {
    return OutlinedButton(
      onPressed: () {
        ref.read(sleepTimerProvider.notifier).addTime(duration);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}
