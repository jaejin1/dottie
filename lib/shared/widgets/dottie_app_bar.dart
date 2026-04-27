import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class DottieAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DottieAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: DottieColors.surface,
      foregroundColor: DottieColors.textPrimary,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
