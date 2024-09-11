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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reports Desktop",
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
}
