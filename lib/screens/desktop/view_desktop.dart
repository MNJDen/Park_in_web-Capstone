import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class ViewDesktopScreen extends StatefulWidget {
  const ViewDesktopScreen({super.key});

  @override
  State<ViewDesktopScreen> createState() => _ViewDesktopScreenState();
}

class _ViewDesktopScreenState extends State<ViewDesktopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  child: Image.asset(
                    'assets/images/bgdot.png',
                    height: 1000,
                    width: 1000,
                    repeat: ImageRepeat.repeat,
                    color: blueColor.withOpacity(0.2),
                  ),
                ),
                Positioned(
                  bottom: -154,
                  left: -517,
                  child: Image.asset(
                    'assets/images/4-pillars.png',
                    height: 928,
                    width: 1237,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/images/Logo.png",
                      width: 45,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 848,
                    height: 450,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        padding: const EdgeInsets.all(30),
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Parking Spaces",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 55,
                            ),
                            Center(
                              child: Text(
                                "44",
                                style: TextStyle(
                                  fontSize: 150,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 55,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Aprroximately",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
