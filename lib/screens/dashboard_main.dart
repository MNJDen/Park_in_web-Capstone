import 'package:flutter/material.dart';
import 'package:park_in_web/responsive/layout.dart';
import 'package:park_in_web/screens/desktop/dashboard_desktop.dart';
import 'package:park_in_web/screens/mobile/dashboard_mobile.dart';

class DashboardMain extends StatefulWidget {
  const DashboardMain({super.key});

  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: const DashboardMobileScreen(),
        desktopLayout: const DashboardDesktopScreen(),
      ),
    );
  }
}
