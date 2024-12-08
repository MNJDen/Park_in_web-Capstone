import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_mobile.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/large_card_mobile.dart';
import 'package:park_in_web/components/ui/primary_btn.dart';
import 'package:park_in_web/components/ui/small_card_mobile.dart';
import 'package:park_in_web/components/ui/users_card_mobile.dart';
import 'package:park_in_web/services/Auth/Auth_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardMobileScreen extends StatefulWidget {
  const DashboardMobileScreen({super.key});

  @override
  State<DashboardMobileScreen> createState() => _DashboardMobileScreenState();
}

class _DashboardMobileScreenState extends State<DashboardMobileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref("parkingAreas");
  final CollectionReference _violationTickets =
      FirebaseFirestore.instance.collection("Violation Ticket");
  final CollectionReference _incidentReports =
      FirebaseFirestore.instance.collection("Incident Report");

  Map<String, int> _calculateCounts(Map<dynamic, dynamic> data) {
    int tempTwoWheelsCount = 0;
    int tempFourWheelsCount = 0;

    data.forEach((key, value) {
      final int count = (value['count'] ?? 0) as int;

      if (key == "Dolan (M)" || key == "Library (M)" || key == "Alingal (M)") {
        tempTwoWheelsCount += count;
      } else {
        tempFourWheelsCount += count;
      }
    });

    return {
      'twoWheelsCount': tempTwoWheelsCount,
      'fourWheelsCount': tempFourWheelsCount,
    };
  }

  Widget build(BuildContext context) {
    String pageName;
    if (_selectedPage == '/dashboard') {
      pageName = 'Dashboard';
    } else if (_selectedPage == '/reports') {
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
                      Icons.dashboard_outlined,
                      color: blackColor,
                    ),
                    title: const Text('Dashboard'),
                    onTap: () {
                      _onItemTap('Dashboard');
                    },
                  ),
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
            ListTile(
              leading: const Icon(
                Icons.tv_rounded,
                color: blackColor,
              ),
              title: const Text('View'),
              onTap: () {
                _onItemTap('View');
              },
            ),
            const Divider(
              thickness: 0.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: PRKPrimaryBtn(
                label: "Sign Out",
                onPressed: () {
                  logout(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            NavbarMobile(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              pageName: pageName,
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: StreamBuilder(
                  stream: _database.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.snapshot.value != null) {
                      final data = snapshot.data!.snapshot.value
                          as Map<dynamic, dynamic>;
                      final counts = _calculateCounts(data);

                      return ListView(
                        children: [
                          PRKSmallCardMobile(
                            label: "Two-Wheels",
                            content: "${counts['twoWheelsCount']}",
                            sub: "Parking spaces available",
                            height: 190,
                            color: parkingGreenColor,
                            icon: Icons.two_wheeler_rounded,
                          ),
                          const SizedBox(height: 16),
                          PRKSmallCardMobile(
                            label: "Four-Wheels",
                            content: "${counts['fourWheelsCount']}",
                            sub: "Parking spaces available",
                            height: 190,
                            color: parkingYellowColor,
                            icon: Icons.airport_shuttle_rounded,
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: _violationTickets.snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> ticketSnapshot) {
                              int violationCount = 0;
                              if (ticketSnapshot.hasData) {
                                violationCount = ticketSnapshot.data!.size;
                              }
                              return PRKSmallCardMobile(
                                label: "Violations",
                                content: "$violationCount",
                                sub: "Infractions committed",
                                height: 190,
                                onPressed: () {},
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: _incidentReports.snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> reportSnapshot) {
                              int reportCount = 0;
                              if (reportSnapshot.hasData) {
                                reportCount = reportSnapshot.data!.size;
                              }
                              return PRKSmallCardMobile(
                                label: "Reports",
                                content: "$reportCount",
                                sub: "Received reports",
                                height: 190,
                                onPressed: () {},
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const PRKUserCardMobile(height: 400),
                          const SizedBox(height: 16),
                          const PRKLargeCardMobile(height: 750),
                        ],
                      );
                    } else {
                      return ListView(
                        children: [
                          PRKSmallCardMobile(
                            label: "Two-Wheels",
                            content: "Loading...",
                            sub: "Parking spaces available",
                            height: 190,
                            color: parkingGreenColor,
                            icon: Icons.two_wheeler_rounded,
                          ),
                          const SizedBox(height: 16),
                          PRKSmallCardMobile(
                            label: "Four-Wheels",
                            content: "Loading...",
                            sub: "Parking spaces available",
                            height: 190,
                            color: parkingYellowColor,
                            icon: Icons.airport_shuttle_rounded,
                          ),
                          const SizedBox(height: 16),
                          PRKSmallCardMobile(
                            label: "Violations",
                            content: "Loading...",
                            sub: "Infractions committed",
                            height: 190,
                            onPressed: () {},
                          ),
                          const SizedBox(height: 16),
                          PRKSmallCardMobile(
                            label: "Reports",
                            content: "Loading...",
                            sub: "Received reports",
                            height: 190,
                            onPressed: () {},
                          ),
                          const SizedBox(height: 16),
                          const PRKUserCardMobile(height: 400),
                          const SizedBox(height: 16),
                          const PRKLargeCardMobile(height: 750),
                        ],
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
