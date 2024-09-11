import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/theme/transition.dart';
import 'package:park_in_web/screens/report_main.dart';
import 'package:park_in_web/screens/sign_in_main.dart';
import 'package:park_in_web/screens/tickets_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park-in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: NoTransitionPageBuilder(),
            TargetPlatform.android: NoTransitionPageBuilder(),
            TargetPlatform.fuchsia: NoTransitionPageBuilder(),
            TargetPlatform.windows: NoTransitionPageBuilder(),
            TargetPlatform.macOS: NoTransitionPageBuilder(),
          },
        ),
        fontFamily: 'General Sans',
      ).copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(primary: blueColor),
      ),
      initialRoute: '/sign-in',
      routes: {
        '/sign-in': (context) => const SignInMain(),
        '/reports': (context) => const ReportMain(),
        '/tickets-issued': (context) => const TicketsMain(),
      },
    );
  }
}
