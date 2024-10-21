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
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        // padding: const EdgeInsets.all(30),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .05,
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(
                Icons.menu_rounded,
                color: blackColor,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              pageName,
              style: const TextStyle(
                  color: blackColor, fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
