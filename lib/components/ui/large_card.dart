import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class PRKLargeCard extends StatefulWidget {
  const PRKLargeCard({
    super.key,
  });

  @override
  State<PRKLargeCard> createState() => _PRKLargeCardState();
}

class _PRKLargeCardState extends State<PRKLargeCard> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("parkingAreas");

  Map<String, int> studentParkingData = {};
  final List<String> allowedStudentParkingSpaces = [
    "Alingal A",
    "Alingal B",
    "Burns",
    "Coko Cafe",
    "Covered Court",
    "Library",
  ];

  Map<String, int> employeeParkingData = {};
  final List<String> allowedEmployeeSpaces = [
    "Alingal",
    "Phelan",
  ];

  Map<String, int> twoWheelsParkingData = {};
  final List<String> allowedTwoWheelsSpaces = [
    "Alingal (M)",
    "Dolan (M)",
    "Library (M)",
  ];

  @override
  void initState() {
    super.initState();
    _fetchStudentParkingData();
    _fetchEmployeeParkingData();
    _fetchTwoWheelsParkingData();
  }

  Future<void> _fetchStudentParkingData() async {
    _database.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final Map<String, int> filteredData = {};
      for (var entry in data.entries) {
        if (allowedStudentParkingSpaces.contains(entry.key)) {
          filteredData[entry.key] = entry.value['count'] as int;
        }
      }
      setState(() {
        studentParkingData = filteredData;
      });
    });
  }

  Future<void> _fetchEmployeeParkingData() async {
    _database.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final Map<String, int> filteredData = {};
      for (var entry in data.entries) {
        if (allowedEmployeeSpaces.contains(entry.key)) {
          filteredData[entry.key] = entry.value['count'] as int;
        }
      }
      setState(() {
        employeeParkingData = filteredData;
      });
    });
  }

  Future<void> _fetchTwoWheelsParkingData() async {
    _database.onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final Map<String, int> filteredData = {};
      for (var entry in data.entries) {
        if (allowedTwoWheelsSpaces.contains(entry.key)) {
          filteredData[entry.key] = entry.value['count'] as int;
        }
      }
      setState(() {
        twoWheelsParkingData = filteredData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.34,
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
                  "Parking Spaces",
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
                    color: parkingRedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: blackColor,
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.013,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height * 0.238,
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Student",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: studentParkingData.isNotEmpty
                              ? BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    gridData: const FlGridData(
                                        drawVerticalLine: false),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) {
                                          return bgColor;
                                        },
                                      ),
                                    ),
                                    barGroups:
                                        studentParkingData.entries.map((entry) {
                                      return BarChartGroupData(
                                        x: studentParkingData.keys
                                            .toList()
                                            .indexOf(entry.key),
                                        barRods: [
                                          BarChartRodData(
                                            toY: entry.value.toDouble(),
                                            width: 35,
                                            color: blueColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 &&
                                                index <
                                                    studentParkingData
                                                        .keys.length) {
                                              return Text(
                                                studentParkingData.keys
                                                    .elementAt(index),
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ).animate().fade(
                                  delay: const Duration(milliseconds: 350))
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.009,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height * 0.238,
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Employee",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: employeeParkingData.isNotEmpty
                              ? BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    gridData: const FlGridData(
                                        drawVerticalLine: false),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) {
                                          return bgColor;
                                        },
                                      ),
                                    ),
                                    barGroups: employeeParkingData.entries
                                        .map((entry) {
                                      return BarChartGroupData(
                                        x: employeeParkingData.keys
                                            .toList()
                                            .indexOf(entry.key),
                                        barRods: [
                                          BarChartRodData(
                                            toY: entry.value.toDouble(),
                                            width: 35,
                                            color: blueColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 &&
                                                index <
                                                    employeeParkingData
                                                        .keys.length) {
                                              return Text(
                                                employeeParkingData.keys
                                                    .elementAt(index),
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ).animate().fade(
                                  delay: const Duration(milliseconds: 350))
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.009,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height * 0.238,
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Two-Wheels",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: twoWheelsParkingData.isNotEmpty
                              ? BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    gridData: const FlGridData(
                                        drawVerticalLine: false),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) {
                                          return bgColor;
                                        },
                                      ),
                                    ),
                                    barGroups: twoWheelsParkingData.entries
                                        .map((entry) {
                                      return BarChartGroupData(
                                        x: twoWheelsParkingData.keys
                                            .toList()
                                            .indexOf(entry.key),
                                        barRods: [
                                          BarChartRodData(
                                            toY: entry.value.toDouble(),
                                            width: 35,
                                            color: blueColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          )
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index >= 0 &&
                                                index <
                                                    twoWheelsParkingData
                                                        .keys.length) {
                                              return Text(
                                                twoWheelsParkingData.keys
                                                    .elementAt(index),
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ).animate().fade(
                                  delay: const Duration(milliseconds: 350))
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
