import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class PRKIconButton extends StatefulWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  const PRKIconButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
  });

  @override
  State<PRKIconButton> createState() => PRKIconButtonState();
}

class PRKIconButtonState extends State<PRKIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _isHovered ? blueColor : blackColor,
              width: 0.5,
            ),
            color: _isHovered ? blueColor : whiteColor,
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Icon(
                widget.icon,
                color: _isHovered ? whiteColor : blackColor,
                size: 16,
              ),
              Text(
                widget.title,
                style: TextStyle(
                  color: _isHovered ? whiteColor : blackColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
