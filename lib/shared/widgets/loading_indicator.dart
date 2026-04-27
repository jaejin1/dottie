import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? DottieColors.primary,
        strokeWidth: 3,
      ),
    );
  }
}
