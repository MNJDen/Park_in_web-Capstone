import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class NavbarMobile extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const NavbarMobile({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onMenuPressed,
      icon: const Icon(
        Icons.menu_rounded,
        color: whiteColor,
      ),
    );
  }
}
