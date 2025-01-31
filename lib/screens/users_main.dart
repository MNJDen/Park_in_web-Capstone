import 'package:flutter/material.dart';
import 'package:park_in_web/responsive/layout.dart';
import 'package:park_in_web/screens/desktop/users_desktop.dart';
import 'package:park_in_web/screens/mobile/users_mobile.dart';

class UsersMain extends StatefulWidget {
  const UsersMain({super.key});

  @override
  State<UsersMain> createState() => _UsersMainState();
}

class _UsersMainState extends State<UsersMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: const UsersMobileScreen(),
        desktopLayout: const UsersDesktopScreen(),
      ),
    );
  }
}
