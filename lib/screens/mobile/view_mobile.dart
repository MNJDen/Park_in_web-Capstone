import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class ViewMobileScreen extends StatefulWidget {
  const ViewMobileScreen({super.key});

  @override
  State<ViewMobileScreen> createState() => _ViewDesktopScreenState();
}

class _ViewDesktopScreenState extends State<ViewMobileScreen> {
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
                  bottom: -120,
                  left: -517,
                  child: Image.asset(
                    'assets/images/4-pillars.png',
                    height: 700,
                    // width: 1237,
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
                  child: Container(
                    margin:
                        EdgeInsets.all(MediaQuery.of(context).size.width * .1),
                    padding: const EdgeInsets.all(30),
                    height: 330,
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
                            fontSize: 16,
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
                              fontSize: 80,
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
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
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
