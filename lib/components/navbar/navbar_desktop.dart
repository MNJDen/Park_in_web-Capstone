import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';
import 'package:park_in_web/services/Auth/Auth_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavbarDesktop extends StatefulWidget {
  const NavbarDesktop({super.key});

  @override
  State<NavbarDesktop> createState() => _NavbarDesktopState();
}

class _NavbarDesktopState extends State<NavbarDesktop> {
  String _selectedPage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    String? currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null) {
      setState(() {
        _selectedPage = currentRoute;
      });
    }
  }

  void _onItemTap(String page) {
    String targetRoute = '/${page.toLowerCase().replaceAll(' ', '-')}';
    if (_selectedPage != targetRoute) {
      setState(() {
        _selectedPage = targetRoute;
      });

      Navigator.pushNamed(context, targetRoute).then((_) {
        setState(() {});
      });
    }
  }

  void logout(BuildContext context) async {
    final authService = AuthService();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Confirm Sign Out',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: blackColor,
            ),
          ),
          content: const SizedBox(
            height: 40,
            child: Text('Are you sure you want to exit?'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: whiteColor),
              ),
              onPressed: () async {
                try {
                  await authService.signOut();

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  await prefs.remove('userType');

                  // Navigate to SignInMain and update URL
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/sign-in',
                    (Route<dynamic> route) => false,
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isHovered = false;

    return Container(
      width: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.start,
            spacing: 20,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/Logo.png",
                    width: 18,
                    color: whiteColor,
                  ),
                ),
              ),
              const Text(
                "Park-in",
                style: TextStyle(
                    color: whiteColor, fontSize: 24, fontFamily: "Hiruko Pro"),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.07),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NavbarDesktopItem(
                  title: "Dashboard",
                  icon: Icons.bar_chart_rounded,
                  isSelected: _selectedPage == '/dashboard',
                  onTap: () => _onItemTap("Dashboard"),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                _NavbarDesktopItem(
                  title: "Reports",
                  icon: Icons.flag_rounded,
                  isSelected: _selectedPage == '/reports',
                  onTap: () => _onItemTap("Reports"),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                _NavbarDesktopItem(
                  title: "Tickets Issued",
                  icon: Icons.receipt_long_rounded,
                  isSelected: _selectedPage == '/tickets-issued',
                  onTap: () => _onItemTap("Tickets Issued"),
                ),
              ],
            ),
          ),
          PRKPrimaryBtn(
            label: "Sign Out",
            onPressed: () {
              logout(context);
            },
          )
        ],
      ),
    );
  }
}

class _NavbarDesktopItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavbarDesktopItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  State<_NavbarDesktopItem> createState() => _NavbarDesktopItemState();
}

class _NavbarDesktopItemState extends State<_NavbarDesktopItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isHovered || widget.isSelected ? 1.0 : 0.7,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected || _isHovered
                    ? blueColor
                    : whiteColor.withOpacity(0.3),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isSelected || _isHovered
                      ? blueColor
                      : whiteColor.withOpacity(0.3),
                  fontSize: 16,
                  fontWeight:
                      widget.isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
