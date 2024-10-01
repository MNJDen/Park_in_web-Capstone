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
                        child: Column(
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
                                totalParkingCount.toString(),
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
                                "Approximately",
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
