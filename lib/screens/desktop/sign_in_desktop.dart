import 'package:flutter/material.dart';
import 'package:park_in_web/components/fields/form_field.dart';
import 'package:park_in_web/components/snackbar/error_snackbar.dart';
import 'package:park_in_web/components/snackbar/success_snackbar.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';
import 'package:park_in_web/services/Auth/Auth_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInDesktopScreen extends StatefulWidget {
  const SignInDesktopScreen({super.key});

  @override
  State<SignInDesktopScreen> createState() => _SignInDesktopScreenState();
}

class _SignInDesktopScreenState extends State<SignInDesktopScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  void login(BuildContext context) async {
    final authService = AuthService();

    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      errorSnackbar(
        context,
        "Please fill out all fields.",
        MediaQuery.of(context).size.width * 0.3,
      );
      return;
    }

    try {
      await authService.signInWithEmailPassword(
        _emailCtrl.text,
        _passwordCtrl.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'Admin'); // Store user type
      await prefs.setBool('isLoggedIn', true); // Store login status

      successSnackbar(
        context,
        "Sign in successful!",
        MediaQuery.of(context).size.width * 0.3,
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is AuthServiceException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'An unknown error occurred. Try again later.';
        }

        errorSnackbar(
          context,
          errorMessage,
          MediaQuery.of(context).size.width * 0.3,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        blueColor,
                        Color.fromRGBO(27, 29, 148, 1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/noise.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  top: -41,
                  left: -180,
                  right: 0,
                  child: Container(
                    width: 331,
                    height: 331,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -281,
                  left: 0,
                  right: -30,
                  child: Container(
                    width: 823,
                    height: 823,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: -50,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -259,
                  left: -561,
                  child: Image.asset(
                    'assets/images/4-pillars.png',
                    width: 1757,
                    height: 1318,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Image.asset(
                    'assets/images/s1.png',
                  ),
                ),
                Positioned(
                  bottom: 0,
                  // right: 0,
                  left: 700,
                  child: Image.asset(
                    'assets/images/s2.png',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .5),
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .1,
                    horizontal: MediaQuery.of(context).size.width * .13,
                  ),
                  decoration: const BoxDecoration(
                    color: whiteColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/Logo.png",
                          width: 35,
                        ),
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Enter your given credentials",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      PRKFormField(
                        prefixIcon: Icons.alternate_email_rounded,
                        labelText: "Email Address",
                        controller: _emailCtrl,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PRKFormField(
                        prefixIcon: Icons.password_rounded,
                        suffixIcon: Icons.visibility_off_rounded,
                        labelText: "Password",
                        controller: _passwordCtrl,
                        obscureText: true,
                      ),
                      const Spacer(),
                      PRKPrimaryBtn(
                        label: "Sign In",
                        onPressed: () {
                          login(context);
                          // Navigator.pushNamed(context, '/reports');
                        },
                      ),
                      const SizedBox(
                        height: 140,
                      ),
                      const Center(
                        child: Text(
                          "© 2024 Park-in. All Rights Reserved.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -180,
                  bottom: -100,
                  child: Image.asset(
                    'assets/images/s3.png',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
