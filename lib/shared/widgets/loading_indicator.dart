import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          color: color ?? DottieColors.primary,
          strokeWidth: 2.5,
          strokeCap: StrokeCap.round,
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
