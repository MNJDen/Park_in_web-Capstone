import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ViewDesktopScreen extends StatefulWidget {
  const ViewDesktopScreen({super.key});

  @override
  State<ViewDesktopScreen> createState() => _ViewDesktopScreenState();
}

class _ViewDesktopScreenState extends State<ViewDesktopScreen> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('parkingAreas');
  int totalParkingCount = 0;
  bool _isLoading = true;

  late Timer _timer;
  DateTime now = DateTime.now();

  final List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    _listenToParkingUpdates();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        now = DateTime.now();
      });
    });
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
            _isLoading = false;
          });
        }
      } else {
        print('Snapshot does not exist');
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    String formattedDate =
        "${monthNames[now.month - 1]} ${now.day.toString().padLeft(2, '0')}, ${now.year} | ${_getDayOfWeek(now.weekday)}";

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
                  bottom: -10,
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
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: blackColor,
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ).animate().fade(delay: const Duration(milliseconds: 200)),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 50,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/images/Logo.png",
                      width: 35,
                      color: blueColor,
                    ),
                  ),
                ).animate().fade(delay: const Duration(milliseconds: 200)),
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
                    ).animate().fade(delay: const Duration(milliseconds: 150)),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    Center(
                      child: _isLoading
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 75),
                              // height: 150,
                              child: LoadingAnimationWidget.waveDots(
                                color: blueColor,
                                size: 150,
                              ),
                            )
                              .animate()
                              .fade(delay: const Duration(milliseconds: 100))
                          : TweenAnimationBuilder<int>(
                              tween: IntTween(
                                begin: 0,
                                end: totalParkingCount,
                              ),
                              duration: const Duration(seconds: 1),
                              builder: (context, value, child) {
                                return Text(
                                  value == 0 ? 'FULL' : value.toString(),
                                  style: TextStyle(
                                    fontSize: 200,
                                    fontWeight: FontWeight.bold,
                                    color: value == 0
                                        ? parkingRedColor
                                        : blackColor,
                                  ),
                                );
                              },
                            )
                              .animate()
                              .fade(delay: const Duration(milliseconds: 100)),
                    ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    const Text(
                      "Approximately",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 150)),
                  ],
                ),
                // Positioned(
                //   right: 10,
                //   bottom: 10,
                //   child: Column(
                //     children: [
                //       Container(
                //         padding: const EdgeInsets.all(20),
                //         decoration: BoxDecoration(
                //           color: whiteColor,
                //           borderRadius: BorderRadius.circular(10),
                //           border: Border.all(
                //               color: blackColor.withOpacity(0.1), width: 0.5),
                //           boxShadow: [
                //             BoxShadow(
                //               color: blackColor.withOpacity(0.05),
                //               blurRadius: 8,
                //               offset: const Offset(0, 4),
                //             ),
                //           ],
                //         ),
                //         child: Image.asset(
                //           "assets/images/QR.png",
                //           height: 100,
                //         ),
                //       ),
                //       Container(
                //         padding: const EdgeInsets.all(20),
                //         decoration: BoxDecoration(
                //           color: blackColor,
                //           borderRadius: BorderRadius.circular(10),
                //           border: Border.all(
                //               color: blackColor.withOpacity(0.1), width: 0.5),
                //           boxShadow: [
                //             BoxShadow(
                //               color: blackColor.withOpacity(0.05),
                //               blurRadius: 8,
                //               offset: const Offset(0, 4),
                //             ),
                //           ],
                //         ),
                //         child: const Text(
                //           "Download the app now!",
                //           style: TextStyle(
                //             fontSize: 12,
                //             color: whiteColor,
                //             fontWeight: FontWeight.w400,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
