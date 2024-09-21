import 'package:flutter/material.dart';
import 'package:park_in_web/components/fields/form_field.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';
// import 'package:park_in_web/screens/report_main.dart';
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
    try {
      await authService.signInWithEmailPassword(
        _emailCtrl.text,
        _passwordCtrl.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', 'Admin'); // Store user type
      await prefs.setBool('isLoggedIn', true); // Store login status

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: MediaQuery.of(context).size.width * 0.95,
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color.fromRGBO(217, 255, 214, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Color.fromRGBO(20, 255, 0, 1),
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: const Color.fromRGBO(20, 255, 0, 1),
                size: 20,
              ),
              SizedBox(
                width: 8,
              ),
              Flexible(
                child: Text(
                  'Sign In Successful!', // Use the cleaned error message here
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/reports',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is AuthServiceException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'An unknown error occurred';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: MediaQuery.of(context).size.width * 0.95,
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color.fromARGB(255, 255, 235, 235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Color.fromRGBO(255, 0, 0, 1),
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_rounded,
                  color: const Color.fromRGBO(255, 0, 0, 1),
                  size: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                  child: Text(
                    errorMessage, // Use the cleaned error message here
                    style: TextStyle(
                      color: blackColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                Positioned(
                  top: -444,
                  right: -26,
                  child: Image.asset(
                    'assets/images/top.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  bottom: -581,
                  left: -570,
                  child: Image.asset(
                    'assets/images/bot.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 450,
                    height: 500,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/images/Logo.png",
                                width: 40,
                              ),
                            ),
                            const SizedBox(
                              height: 55,
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
                              prefixIcon: Icons.email_rounded,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
