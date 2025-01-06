import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:fl_chart/fl_chart.dart';

class PRKUserCard extends StatefulWidget {
  const PRKUserCard({
    super.key,
  });

  @override
  State<PRKUserCard> createState() => _PRKUserCardState();
}

class _PRKUserCardState extends State<PRKUserCard> {
  int studentCount = 0;
  int employeeCount = 0;

  @override
  void initState() {
    super.initState();
    listenToUserCounts();
  }

  void listenToUserCounts() {
    FirebaseFirestore.instance
        .collection('User')
        .where('userType', whereIn: ['Student', 'Employee'])
        .snapshots()
        .listen((snapshot) {
          int students = 0;
          int employees = 0;

          for (var doc in snapshot.docs) {
            if (doc['userType'] == 'Student') {
              students++;
            } else if (doc['userType'] == 'Employee') {
              employees++;
            }
          }

          setState(() {
            studentCount = students;
            employeeCount = employees;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    int totalUsers = studentCount + employeeCount;
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.33,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: blackColor.withOpacity(0.1),
            width: 0.5,
          ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Users",
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
                    color: blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: blackColor,
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Pie Chart
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: blueColor,
                          value: studentCount.toDouble(),
                          title: '$studentCount',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                          titlePositionPercentageOffset: 1.35,
                        ),
                        PieChartSectionData(
                          color: yellowColor,
                          value: employeeCount.toDouble(),
                          title: '$employeeCount',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                          titlePositionPercentageOffset: 1.35,
                        ),
                      ],
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                // Text and Stats Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      direction: Axis.vertical,
                      children: [
                        Text(
                          "${studentCount + employeeCount}",
                          style: const TextStyle(
                            color: blackColor,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fade(delay: const Duration(milliseconds: 350)),
                        const Text(
                          "Total users using the app ",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          children: [
                            Container(
                              height: 11,
                              width: 20,
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Text(
                              "Student",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          children: [
                            Container(
                              height: 11,
                              width: 20,
                              decoration: BoxDecoration(
                                color: yellowColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Text(
                              "Employee",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
