import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Container(
        padding: const EdgeInsets.all(30),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .1,
        ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/images/Logo.png",
              width: 30,
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavbarDesktopItem(
                      title: "Reports",
                      isSelected: _selectedPage == '/reports',
                      onTap: () => _onItemTap("Reports"),
                    ),
                    _NavbarDesktopItem(
                      title: "Tickets Issued",
                      isSelected: _selectedPage == '/tickets-issued',
                      onTap: () => _onItemTap("Tickets Issued"),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavbarDesktopItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavbarDesktopItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? blueColor : blackColor,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
