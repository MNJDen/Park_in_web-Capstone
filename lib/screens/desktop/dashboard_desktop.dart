import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/large_card.dart';
import 'package:park_in_web/components/ui/small_card.dart';
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
                                content: "${counts['twoWheelsCount']}",
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
                                content: "${counts['fourWheelsCount']}",
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
                                    onPressed: () {},
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
                                    onPressed: () {},
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
                                content: "Loading...",
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
                                content: "Loading...",
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
                                content: "Loading...",
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
                                content: "Loading...",
                                sub: "Received Reports",
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                onPressed: () {},
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    Row(
                      children: [
                        const PRKUserCard(),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.009),
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.33,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: blackColor.withOpacity(0.1),
                                  width: 0.5),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Peak Hours",
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            parkingOrangeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.access_time_filled_rounded,
                                        color: blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.005,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015),
                    const Row(
                      children: [PRKLargeCard()],
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
