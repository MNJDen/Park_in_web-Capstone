import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

void errorSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    width: MediaQuery.of(context).size.width * 0.3,
    behavior: SnackBarBehavior.floating,
    backgroundColor: blackColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_rounded,
          color: parkingRedColor,
          size: 20,
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(
              color: whiteColor,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
