import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_mobile.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';

class TicketsMobileScreen extends StatefulWidget {
  const TicketsMobileScreen({super.key});

  @override
  State<TicketsMobileScreen> createState() => _TicketsMobileScreenState();
}

class _TicketsMobileScreenState extends State<TicketsMobileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    String pageName;
    if (_selectedPage == '/reports') {
      pageName = 'Reports';
    } else if (_selectedPage == '/tickets-issued') {
      pageName = 'Tickets Issued';
    } else {
      pageName = '';
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: Drawer(
        backgroundColor: whiteColor,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/bg1.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/Logo.png",
                  width: 30,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: blackColor,
                    ),
                    title: const Text('Reports'),
                    onTap: () {
                      _onItemTap('Reports');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: blackColor,
                    ),
                    title: const Text('Tickets Issued'),
                    onTap: () {
                      _onItemTap('Tickets Issued');
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 0.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PRKPrimaryBtn(
                label: "Sign Out",
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          NavbarMobile(
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            pageName: pageName,
          ),
          const SizedBox(
            height: 28,
          ),
          Expanded(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Tickets Issued Mobile",
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _modal(context);
                        },
                        child: const Text(
                          "Modal",
                          style: TextStyle(
                            color: blueColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 28,
          ),
        ],
      ),
    );
  }

  void _modal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.2, color: blackColor),
              ),
            ),
            child: const Text(
              "Ticket Information",
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      Text(
                        'Ticketed To: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'NDA-1234 (202100228)',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '6/28/2024',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      Text(
                        'Phone Number: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '09284655371',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'two-wheels',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Carrying or loading the car of any material when its edge portion causes damage or scrape the pavement of the road/street.',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Attachment/s:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  Container(
                    height: 160,
                    // width: 215,
                    decoration: BoxDecoration(
                      color: blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                    height: 160,
                    // width: 215,
                    decoration: BoxDecoration(
                      color: blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                    height: 160,
                    // width: 215,
                    decoration: BoxDecoration(
                      color: blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Resolve",
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
