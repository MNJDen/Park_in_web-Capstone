import 'package:flutter/material.dart';
import 'package:park_in_web/components/fields/form_field.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';

class SignInMobileScreen extends StatefulWidget {
  const SignInMobileScreen({super.key});

  @override
  State<SignInMobileScreen> createState() => _SignInMobileScreenState();
}

class _SignInMobileScreenState extends State<SignInMobileScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

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
                          labelText: "Password",
                          controller: _passwordCtrl,
                        ),
                        const Spacer(),
                        PRKPrimaryBtn(
                          label: "Sign In",
                          onPressed: () {
                            Navigator.pushNamed(context, '/reports');
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
