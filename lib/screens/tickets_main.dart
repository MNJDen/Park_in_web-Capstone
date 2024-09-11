import 'package:flutter/material.dart';
import 'package:park_in_web/responsive/layout.dart';
import 'package:park_in_web/screens/desktop/tickets_desktop.dart';
import 'package:park_in_web/screens/mobile/tickets_mobile.dart';

class TicketsMain extends StatefulWidget {
  const TicketsMain({super.key});

  @override
  State<TicketsMain> createState() => _ReportMainState();
}

class _ReportMainState extends State<TicketsMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: const TicketsMobileScreen(),
        desktopLayout: const TicketsDesktopScreen(),
      ),
    );
  }
}
