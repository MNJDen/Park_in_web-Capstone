import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  int totalFourWheelCount = 0; // Total for 4-wheel parking
  int totalTwoWheelCount = 0; // Total for 2-wheel parking
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

  void fetchAvailableParkingSpaces() {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('parkingAreas');

    List<String> fourWheels = [
      'Alingal',
      'Phelan',
      'Alingal A',
      'Alingal B',
      'Burns',
      'Coko Cafe',
      'Covered Court',
      'Library',
    ];
    List<String> twoWheels = ['Alingal (M)', 'Dolan (M)', 'Library (M)'];

    dbRef.onValue.listen((DatabaseEvent event) {
      //Explicitly use DatabaseEvent
      int fourWheelSpaces = 0;
      int twoWheelSpaces = 0;

      if (event.snapshot.value != null) {
        Map<String, dynamic> parkingData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        for (String area in fourWheels) {
          fourWheelSpaces +=
              (parkingData[area]?['count'] as num?)?.toInt() ?? 0;
        }
        for (String area in twoWheels) {
          twoWheelSpaces += (parkingData[area]?['count'] as num?)?.toInt() ?? 0;
        }
      }

      if (mounted) {
        setState(() {
          totalFourWheelCount = fourWheelSpaces;
          totalTwoWheelCount = twoWheelSpaces;
          _isLoading = false;
        });
      }
    });
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
    fetchAvailableParkingSpaces();
  }

  // Listen to real-time updates from Firebase
  void _listenToParkingUpdates() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      //Explicitly use DatabaseEvent
      DataSnapshot snapshot = event.snapshot;
      int total = 0;

      if (snapshot.exists) {
        Map<String, dynamic> parkingAreas =
            Map<String, dynamic>.from(snapshot.value as Map);
        parkingAreas.forEach((key, value) {
          total += (value['count'] as num?)?.toInt() ?? 0;
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
                  bottom: 52,
                  left: -150,
                  child: Image.asset(
                    'assets/images/line2.png',
                    height: 200,
                  ),
                ),
                Positioned(
                  bottom: -90,
                  left: -330,
                  child: Image.asset(
                    'assets/images/4-pillars.png',
                    height: 500,
                    // width: 1237,
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: -291,
                  child: Image.asset(
                    'assets/images/line1.png',
                  ),
                ),
                Positioned(
                  top: 0,
                  left: -231,
                  child: Image.asset(
                    'assets/images/line3.png',
                    height: 300,
                  ),
                ),
                // Positioned(
                //   left: 0,
                //   right: 0,
                //   bottom: 50,
                //   child: Column(
                //     children: [
                //       Container(
                //         height: 100,
                //         width: 100,
                //         decoration: BoxDecoration(
                //           color: blueColor.withOpacity(0.1),
                //         ),
                //       ),
                //       const Text(
                //         "Download the app now!",
                //         style: TextStyle(
                //           fontSize: 10,
                //           fontWeight: FontWeight.w400,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/images/Logo.png",
                      color: blueColor,
                      width: 35,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 200)),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    Center(
                      child: _isLoading
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 45),
                              // height: 150,
                              child: LoadingAnimationWidget.waveDots(
                                color: blueColor,
                                size: 90,
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
                                    fontSize: 120,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 200)),
                    Text(
                      "Four Wheels: ${totalFourWheelCount == 0 ? 'FULL' : totalFourWheelCount}",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: totalFourWheelCount == 0
                            ? parkingRedColor
                            : blackColor,
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 100)),
                    Text(
                      "Two Wheels: ${totalTwoWheelCount == 0 ? 'FULL' : totalTwoWheelCount}",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: totalTwoWheelCount == 0
                            ? parkingRedColor
                            : blackColor,
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 100)),
                  ],
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
                            fontSize: 40,
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
