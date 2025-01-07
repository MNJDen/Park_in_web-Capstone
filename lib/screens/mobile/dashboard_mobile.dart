import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: Drawer(
        backgroundColor: bgColor,
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _onItemTap("Dashboard");
                      _selectedPage == '/dashboard';
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 40),
                      child: Wrap(
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
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.dashboard_outlined,
                      color: whiteColor,
                    ),
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: whiteColor,
                      ),
                    ),
                    onTap: () {
                      _onItemTap('Dashboard');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: whiteColor,
                    ),
                    title: const Text(
                      'Reports',
                      style: TextStyle(
                        color: whiteColor,
                      ),
                    ),
                    onTap: () {
                      _onItemTap('Reports');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: whiteColor,
                    ),
                    title: const Text(
                      'Tickets Issued',
                      style: TextStyle(
                        color: whiteColor,
                      ),
                    ),
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
                color: whiteColor,
              ),
              title: const Text(
                'Live View',
                style: TextStyle(
                  color: whiteColor,
                ),
              ),
              onTap: () {
                _onItemTap('View');
              },
            ),
            const Divider(
              color: whiteColor,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NavbarMobile(
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 20,
                    color: whiteColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _database.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final data =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    final counts = _calculateCounts(data);

                    return ListView(
                      children: [
                        PRKSmallCardMobile(
                          label: "Two-Wheels",
                          content: counts['twoWheelsCount'] == 0
                              ? "Full"
                              : "${counts['twoWheelsCount']}",
                          sub: "Parking spaces available",
                          height: 190,
                          color: parkingGreenColor,
                          icon: Icons.two_wheeler_rounded,
                        ),
                        const SizedBox(height: 16),
                        PRKSmallCardMobile(
                          label: "Four-Wheels",
                          content: counts['fourWheelsCount'] == 0
                              ? "Full"
                              : "${counts['fourWheelsCount']}",
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
                              onPressed: () {
                                _onItemTap('Tickets Issued');
                              },
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
                              onPressed: () {
                                _onItemTap('Reports');
                              },
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
                        const PRKSmallCardMobile(
                          label: "Two-Wheels",
                          content: "...",
                          sub: "Parking spaces available",
                          height: 190,
                          color: parkingGreenColor,
                          icon: Icons.two_wheeler_rounded,
                        ),
                        const SizedBox(height: 16),
                        const PRKSmallCardMobile(
                          label: "Four-Wheels",
                          content: "...",
                          sub: "Parking spaces available",
                          height: 190,
                          color: parkingYellowColor,
                          icon: Icons.airport_shuttle_rounded,
                        ),
                        const SizedBox(height: 16),
                        PRKSmallCardMobile(
                          label: "Violations",
                          content: "...",
                          sub: "Infractions committed",
                          height: 190,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),
                        PRKSmallCardMobile(
                          label: "Reports",
                          content: "...",
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
              )
                  .animate()
                  .fade(
                    delay: const Duration(
                      milliseconds: 100,
                    ),
                  )
                  .moveY(
                    begin: 10,
                    end: 0,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: const Duration(milliseconds: 250),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
