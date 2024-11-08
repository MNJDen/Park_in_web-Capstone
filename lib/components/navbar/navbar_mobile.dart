import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class NavbarMobile extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final String pageName;

  const NavbarMobile({
    super.key,
    required this.onMenuPressed,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onMenuPressed,
          icon: const Icon(
            Icons.menu_rounded,
            color: whiteColor,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          pageName,
          style: const TextStyle(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
