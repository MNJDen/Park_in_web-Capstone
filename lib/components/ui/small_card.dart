import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PRKSmallCard extends StatefulWidget {
  final String label;
  final String content;
  final String sub;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  const PRKSmallCard({
    super.key,
    required this.label,
    required this.content,
    required this.sub,
    this.color,
    this.icon,
    this.onPressed,
    required this.height,
  });

  @override
  State<PRKSmallCard> createState() => _PRKSmallCardState();
}

class _PRKSmallCardState extends State<PRKSmallCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: blackColor.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                widget.icon != null
                    ? Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: widget.color?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: blackColor,
                        ),
                      )
                    : Material(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          splashColor: widget.color?.withOpacity(0.3) ??
                              bgColor.withOpacity(0.3),
                          onTap: widget.onPressed,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: bgColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: blackColor,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  Text(
                    widget.content,
                    style: const TextStyle(
                      color: blackColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(delay: const Duration(milliseconds: 350)),
                  Text(
                    widget.sub,
                    style: const TextStyle(
                      color: blackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
