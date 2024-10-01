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
      errorSnackbar(context, "Please fill out all fields.");
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

      successSnackbar(context, "Sign in successful!");

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
          errorMessage = 'An unknown error occurred. Try again later.';
        }

        errorSnackbar(context, errorMessage);
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
                  child: Container(
                    margin:
                        EdgeInsets.all(MediaQuery.of(context).size.width * .1),
                    padding: const EdgeInsets.all(30),
                    height: 500,
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
