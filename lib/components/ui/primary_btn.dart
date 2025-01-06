import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class PRKPrimaryBtn extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool? isLoading;

  const PRKPrimaryBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  _PRKPrimaryBtnState createState() => _PRKPrimaryBtnState();
}

class _PRKPrimaryBtnState extends State<PRKPrimaryBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor:
                _isHovered ? blueColor.withOpacity(0.8) : blueColor,
            foregroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: widget.onPressed,
          child: widget.isLoading!
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: LoadingAnimationWidget.waveDots(
                    color: whiteColor,
                    size: 30,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
