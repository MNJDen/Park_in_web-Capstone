import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/large_card.dart';
import 'package:park_in_web/components/ui/small_card.dart';
import 'package:park_in_web/components/ui/today_card.dart';
import 'package:park_in_web/components/ui/users_card.dart';

class DashboardDesktopScreen extends StatefulWidget {
  const DashboardDesktopScreen({super.key});

  @override
  State<DashboardDesktopScreen> createState() => _DashboardDesktopScreenState();
}

class _DashboardDesktopScreenState extends State<DashboardDesktopScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("parkingAreas");
  final CollectionReference _violationTickets =
      FirebaseFirestore.instance.collection("Violation Ticket");
  final CollectionReference _incidentReports =
      FirebaseFirestore.instance.collection("Incident Report");
  String _selectedPage = '';

  Map<String, int> _calculateCounts(Map<dynamic, dynamic> data) {
    int tempTwoWheelsCount = 0;
    int tempFourWheelsCount = 0;

    data.forEach((key, value) {
      final int count = (value['count'] ?? 0) as int;

      if (key == "Dolan (M)" || key == "Library (M)" || key == "Alingal (M)") {
        tempTwoWheelsCount += count;
      } else {
        tempFourWheelsCount += count;
      }
    });

    return {
      'twoWheelsCount': tempTwoWheelsCount,
      'fourWheelsCount': tempFourWheelsCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    void _onItemTap(String page) {
      String targetRoute = '/${page.toLowerCase().replaceAll(' ', '-')}';
      if (_selectedPage != targetRoute) {
        setState(() {
          _selectedPage = targetRoute;
        });

        Navigator.pushNamed(context, targetRoute).then((_) {
          setState(() {});
        });
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            const NavbarDesktop(),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: _database.onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.snapshot.value != null) {
                          final data = snapshot.data!.snapshot.value
                              as Map<dynamic, dynamic>;
                          final counts = _calculateCounts(data);
                          return Row(
                            children: [
                              PRKSmallCard(
                                label: "Two-Wheels",
                                content: counts['twoWheelsCount'] == 0
                                    ? "Full"
                                    : "${counts['twoWheelsCount']}",
                                sub: "Parking spaces available",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                color: parkingGreenColor,
                                icon: Icons.two_wheeler_rounded,
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.009),
                              PRKSmallCard(
                                label: "Four-Wheels",
                                content: counts['fourWheelsCount'] == 0
                                    ? "Full"
                                    : "${counts['fourWheelsCount']}",
                                sub: "Parking spaces available",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                color: parkingYellowColor,
                                icon: Icons.airport_shuttle_rounded,
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.009),
                              StreamBuilder<QuerySnapshot>(
                                stream: _violationTickets.snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  int violationCount = 0;
                                  if (snapshot.hasData) {
                                    violationCount = snapshot.data!.size;
                                  }
                                  return PRKSmallCard(
                                    label: "Violations",
                                    content: "$violationCount",
                                    sub: "Infractions committed",
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    onPressed: () {
                                      _onItemTap('Tickets Issued');
                                    },
                                  );
                                },
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.009),
                              StreamBuilder<QuerySnapshot>(
                                stream: _incidentReports.snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  int reportCount = 0;
                                  if (snapshot.hasData) {
                                    reportCount = snapshot.data!.size;
                                  }
                                  return PRKSmallCard(
                                    label: "Reports",
                                    content: "$reportCount",
                                    sub: "Received Reports",
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    onPressed: () {
                                      _onItemTap('Reports');
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              PRKSmallCard(
                                label: "Two-Wheels",
                                content: "...",
                                sub: "Parking spaces available",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                color: parkingGreenColor,
                                icon: Icons.two_wheeler_rounded,
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.009),
                              PRKSmallCard(
                                label: "Four-Wheels",
                                content: "...",
                                sub: "Parking spaces available",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                color: parkingYellowColor,
                                icon: Icons.airport_shuttle_rounded,
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.009),
                              PRKSmallCard(
                                label: "Violations",
                                content: "...",
                                sub: "Infractions committed",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                onPressed: () {},
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.009),
                              PRKSmallCard(
                                label: "Reports",
                                content: "...",
                                sub: "Received Reports",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                onPressed: () {},
                              ),
                            ],
                          );
                        }
                      },
                    )
                        .animate()
                        .fade(
                          delay: const Duration(
                            milliseconds: 100,
                          ),
                        )
                        .moveY(
                          begin: 10,
                          end: 0,
                          curve: Curves.fastEaseInToSlowEaseOut,
                          duration: const Duration(milliseconds: 250),
                        ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    Row(
                      children: [
                        const PRKUserCard(),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.009),
                        const PRKTodayCard(),
                      ],
                    )
                        .animate()
                        .fade(
                          delay: const Duration(
                            milliseconds: 200,
                          ),
                        )
                        .moveY(
                          begin: 10,
                          end: 0,
                          curve: Curves.fastEaseInToSlowEaseOut,
                          duration: const Duration(milliseconds: 450),
                        ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    const Row(
                      children: [PRKLargeCard()],
                    )
                        .animate()
                        .fade(
                          delay: const Duration(
                            milliseconds: 300,
                          ),
                        )
                        .moveY(
                          begin: 10,
                          end: 0,
                          curve: Curves.fastEaseInToSlowEaseOut,
                          duration: const Duration(milliseconds: 650),
                        )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
