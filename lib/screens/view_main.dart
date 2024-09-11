import 'package:flutter/material.dart';
import 'package:park_in_web/responsive/layout.dart';
import 'package:park_in_web/screens/desktop/view_desktop.dart';
import 'package:park_in_web/screens/mobile/view_mobile.dart';

class ViewMain extends StatefulWidget {
  const ViewMain({super.key});

  @override
  State<ViewMain> createState() => _ReportMainState();
}

class _ReportMainState extends State<ViewMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: const ViewMobileScreen(),
        desktopLayout: const ViewDesktopScreen(),
      ),
    );
  }
}
