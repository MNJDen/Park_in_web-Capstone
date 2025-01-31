import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/theme/transition.dart';
import 'package:park_in_web/screens/dashboard_main.dart';
import 'package:park_in_web/screens/report_main.dart';
import 'package:park_in_web/screens/sign_in_main.dart';
import 'package:park_in_web/screens/tickets_main.dart';
import 'package:park_in_web/screens/users_main.dart';
import 'package:park_in_web/screens/view_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCVQc1KGS6rxgznVo7A_M-V0-JwoE0u4aU",
          databaseURL:
              "https://park-in-capstone-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "park-in-capstone",
          messagingSenderId: "66482745641",
          appId: "1:66482745641:web:e3562dae74becc1b504738"));
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
        cardTheme: CardTheme(
          surfaceTintColor: whiteColor,
          color: whiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        '/dashboard': (context) => const DashboardMain(),
        '/users': (context) => const UsersMain(),
        '/reports': (context) => const ReportMain(),
        '/tickets-issued': (context) => const TicketsMain(),
        '/view': (context) => const ViewMain(),
      },
    );
  }
}
