import 'package:flutter/material.dart';
import 'package:park_in_web/responsive/layout.dart';
import 'package:park_in_web/screens/desktop/reports_desktop.dart';
import 'package:park_in_web/screens/mobile/reports_mobile.dart';

class ReportMain extends StatefulWidget {
  const ReportMain({super.key});

  @override
  State<ReportMain> createState() => _ReportMainState();
}

class _ReportMainState extends State<ReportMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: const ReportsMobileScreen(),
        desktopLayout: const ReportsDesktopScreen(),
      ),
    );
  }
}
