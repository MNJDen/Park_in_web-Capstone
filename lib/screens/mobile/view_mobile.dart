import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class ViewMobileScreen extends StatefulWidget {
  const ViewMobileScreen({super.key});

  @override
  State<ViewMobileScreen> createState() => _ViewDesktopScreenState();
}

class _ViewDesktopScreenState extends State<ViewMobileScreen> {
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
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      'assets/images/view_bg.png',
                      fit: BoxFit.cover,
                    ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Available Parking Spaces",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 55,
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
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 55,
                        ),
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "Approximately",
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
