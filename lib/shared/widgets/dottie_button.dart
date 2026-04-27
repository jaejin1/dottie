import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class DottieButton extends StatelessWidget {
  const DottieButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.variant = DottieButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final DottieButtonVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == DottieButtonVariant.primary;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? DottieColors.primary : DottieColors.surfaceVariant,
          foregroundColor:
              isPrimary ? Colors.white : DottieColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum DottieButtonVariant { primary, secondary }
