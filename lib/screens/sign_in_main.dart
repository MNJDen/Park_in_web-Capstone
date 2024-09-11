import 'package:flutter/material.dart';
import 'package:park_in_web/responsive/layout.dart';
import 'package:park_in_web/screens/desktop/sign_in_desktop.dart';
import 'package:park_in_web/screens/mobile/sign_in_mobile.dart';

class SignInMain extends StatefulWidget {
  const SignInMain({super.key});

  @override
  State<SignInMain> createState() => _SignInMainState();
}

class _SignInMainState extends State<SignInMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: const SignInMobileScreen(),
        desktopLayout: const SignInDesktopScreen(),
      ),
    );
  }
}
