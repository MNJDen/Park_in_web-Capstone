import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/navbar/navbar_mobile.dart';
import 'package:park_in_web/responsive/layout.dart';

class NavbarMain extends StatelessWidget {
  const NavbarMain({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: NavbarMobile(onMenuPressed: () {}, pageName: '',),
      desktopLayout: const NavbarDesktop(),
    );
  }
}
