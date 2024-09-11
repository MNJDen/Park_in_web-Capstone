import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class ReportsDesktopScreen extends StatefulWidget {
  const ReportsDesktopScreen({super.key});

  @override
  State<ReportsDesktopScreen> createState() => _ReportsDesktopScreenState();
}

class _ReportsDesktopScreenState extends State<ReportsDesktopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const NavbarDesktop(),
          const SizedBox(
            height: 28,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .1,
              ),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Reports Desktop",
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _modal(context);
                        },
                        child: const Text(
                          "Modal",
                          style: TextStyle(
                            color: blueColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 28,
          ),
        ],
      ),
    );
  }

  void _modal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.2, color: blackColor),
              ),
            ),
            child: const Text(
              "Report Information",
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.35,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: [
                        Text(
                          'Reported By: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Anonymous',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '6/28/2024',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut vitae volutpat arcu. Duis volutpat eros nulla, eu volutpat ex tincidunt at. Pellentesque ultricies, nisl nec imperdiet lacinia, massa nibh dictum magna, et dictum elit purus sit amet est.',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Attachment/s:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 160,
                      width: 215,
                      decoration: BoxDecoration(
                        color: blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 160,
                      width: 215,
                      decoration: BoxDecoration(
                        color: blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 160,
                      width: 215,
                      decoration: BoxDecoration(
                        color: blueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
