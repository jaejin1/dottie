import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message = '오류가 발생했어요',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: DottieColors.textHint),
            const SizedBox(height: Dimensions.md),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 15, color: DottieColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Dimensions.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('다시 시도'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DottieColors.primary,
                  side: const BorderSide(color: DottieColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
