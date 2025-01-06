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
            child: Text(
              'Are you sure you want to exit?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: blackColor,
              ),
            ),
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: whiteColor,
                      ),
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
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: blackColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.start,
            spacing: 20,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 2),
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
                  color: whiteColor,
                  fontSize: 24,
                  fontFamily: "Hiruko Pro",
                ),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          Divider(
            thickness: 0.5,
            color: whiteColor.withOpacity(0.2),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                _NavbarDesktopItem(
                  title: "Reports",
                  icon: Icons.flag_rounded,
                  isSelected: _selectedPage == '/reports',
                  onTap: () => _onItemTap("Reports"),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                _NavbarDesktopItem(
                  title: "Tickets Issued",
                  icon: Icons.receipt_long_rounded,
                  isSelected: _selectedPage == '/tickets-issued',
                  onTap: () => _onItemTap("Tickets Issued"),
                ),
              ],
            ),
          ),
          _NavbarDesktopItem(
            title: "Live View",
            icon: Icons.tv_rounded,
            isSelected: _selectedPage == '/view',
            onTap: () => _onItemTap("View"),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Divider(
            thickness: 0.5,
            color: whiteColor.withOpacity(0.2),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
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
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isHovered || widget.isSelected ? 1.0 : 0.7,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: widget.isSelected ? blueColor : Colors.transparent,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Icon(
                  widget.icon,
                  color: widget.isSelected || _isHovered
                      ? whiteColor
                      : whiteColor.withOpacity(0.3),
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isSelected || _isHovered
                        ? whiteColor
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
      ),
    );
  }
}
