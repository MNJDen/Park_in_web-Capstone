import 'package:flutter/material.dart';
import 'package:park_in_web/components/fields/form_field.dart';
import 'package:park_in_web/components/snackbar/error_snackbar.dart';
import 'package:park_in_web/components/snackbar/success_snackbar.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';
import 'package:park_in_web/services/Auth/Auth_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInMobileScreen extends StatefulWidget {
  const SignInMobileScreen({super.key});

  @override
  State<SignInMobileScreen> createState() => _SignInMobileScreenState();
}

class _SignInMobileScreenState extends State<SignInMobileScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  void login(BuildContext context) async {
    final authService = AuthService();

    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      errorSnackbar(
        context,
        "Please fill out all fields.",
        MediaQuery.of(context).size.width * 0.9,
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
        MediaQuery.of(context).size.width * 0.9,
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
          MediaQuery.of(context).size.width * 0.9,
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
                  top: -130,
                  right: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: -30,
                  left: -161,
                  child: Image.asset(
                    'assets/images/4-pillars.png',
                    width: 525,
                    height: 394,
                  ),
                ),
                Positioned(
                  top: 50,
                  right: -100,
                  child: Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      'assets/images/s1.png',
                      width: 350,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * .3),
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .05,
                    horizontal: MediaQuery.of(context).size.width * .1,
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
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Enter your given credentials",
                        style: TextStyle(
                          fontSize: 12,
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
                        height: 16,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
