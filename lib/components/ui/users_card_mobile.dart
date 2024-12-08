import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class PRKUserCardMobile extends StatefulWidget {
  final double height;

  const PRKUserCardMobile({
    super.key,
    required this.height,
  });

  @override
  State<PRKUserCardMobile> createState() => _PRKUserCardMobileState();
}

class _PRKUserCardMobileState extends State<PRKUserCardMobile> {
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
    return Container(
      height: widget.height,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(
            height: 16,
          ),
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blueColor.withOpacity(0.1),
              ),
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: blueColor,
                      value: studentCount.toDouble(),
                      title:
                          '${((studentCount / (studentCount + employeeCount)) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                    PieChartSectionData(
                      color: yellowColor,
                      value: employeeCount.toDouble(),
                      title:
                          '${((employeeCount / (studentCount + employeeCount)) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                  ],
                  sectionsSpace: 4, // Spacing between slices
                  centerSpaceRadius: 40, // Space at the center of the pie chart
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${studentCount + employeeCount}",
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Total users using the app ",
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        height: 11,
                        width: 20,
                        decoration: BoxDecoration(
                          color: blueColor,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
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
                  Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        height: 11,
                        width: 20,
                        decoration: BoxDecoration(
                          color: yellowColor,
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
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
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
