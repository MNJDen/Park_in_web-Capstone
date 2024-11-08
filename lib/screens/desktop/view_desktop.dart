import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:firebase_database/firebase_database.dart';

class ViewDesktopScreen extends StatefulWidget {
  const ViewDesktopScreen({super.key});

  @override
  State<ViewDesktopScreen> createState() => _ViewDesktopScreenState();
}

class _ViewDesktopScreenState extends State<ViewDesktopScreen> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('parkingAreas');
  int totalParkingCount = 0;

  @override
  void initState() {
    super.initState();
    _listenToParkingUpdates();
  }

  // Listen to real-time updates from Firebase
  void _listenToParkingUpdates() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      int total = 0;

      if (snapshot.exists) {
        Map<String, dynamic> parkingAreas =
            Map<String, dynamic>.from(snapshot.value as Map);
        parkingAreas.forEach((key, value) {
          num count = value['count'] ?? 0;
          total += count.toInt();
        });

        if (mounted) {
          setState(() {
            totalParkingCount = total;
          });
        }
      } else {
        print('Snapshot does not exist');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  child: Image.asset(
                    'assets/images/dottedbg.png',
                    repeat: ImageRepeat.repeat,
                    color: blackColor.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  bottom: -52,
                  left: 0,
                  child: Image.asset(
                    'assets/images/line2.png',
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
                Positioned(
                  top: 80,
                  right: -51,
                  child: Image.asset(
                    'assets/images/line1.png',
                  ),
                ),
                // Positioned(
                //   bottom: -155,
                //   right: -44,
                //   child: Image.asset(
                //     'assets/images/car.png',
                //   ),
                // ),
                Positioned(
                  top: 17,
                  left: -51,
                  child: Image.asset(
                    'assets/images/line3.png',
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 50,
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.1),
                        ),
                      ),
                      const Text(
                        "Download the app now!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/images/Logo.png",
                      width: 40,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Available Parking Spaces",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(
                          begin: 0,
                          end: totalParkingCount,
                        ),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Text(
                            value.toString(),
                            style: const TextStyle(
                              fontSize: 200,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Approximately",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/dashboard');
                    },
                    child: Text(
                      "Go Back",
                      style: TextStyle(
                        color: blackColor.withOpacity(0.1),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
