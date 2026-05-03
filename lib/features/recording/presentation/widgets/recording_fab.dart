import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../dot_input_sheet.dart';
import '../recording_provider.dart';
import 'first_dot_banner.dart';

class RecordingFab extends ConsumerWidget {
  const RecordingFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(activeRecordingProvider).isLoading;

    return FloatingActionButton(
      heroTag: 'record_fab',
      onPressed: isLoading ? null : () => _openDotInput(context, ref),
      backgroundColor:
          isLoading ? DottieColors.surfaceVariant : DottieColors.primary,
      elevation: 4,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(Icons.add_location_alt_rounded,
              color: Colors.white, size: 28),
    );
  }

  Future<void> _openDotInput(BuildContext context, WidgetRef ref) async {
    final isFirstDot = await DotInputSheet.show(context);
    if (isFirstDot && context.mounted) {
      await showFirstDotFlow(context, ref);
    }
  }
}
