import 'package:flutter/material.dart';
import 'package:park_in_web/components/navbar/navbar_desktop.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';
import 'package:park_in_web/components/ui/large_card.dart';
import 'package:park_in_web/components/ui/small_card.dart';
import 'package:park_in_web/components/ui/users_card.dart';

class DashboardDesktopScreen extends StatefulWidget {
  const DashboardDesktopScreen({super.key});

  @override
  State<DashboardDesktopScreen> createState() => _DashboardDesktopScreenState();
}

class _DashboardDesktopScreenState extends State<DashboardDesktopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            const NavbarDesktop(),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        PRKSmallCard(
                          label: "Two-Wheels",
                          content: "48",
                          sub: "Parking spaces available",
                          height: MediaQuery.of(context).size.height * 0.2,
                          color: parkingGreenColor,
                          icon: Icons.two_wheeler_rounded,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.009,
                        ),
                        PRKSmallCard(
                          label: "Four-Wheels",
                          content: "36",
                          sub: "c",
                          height: MediaQuery.of(context).size.height * 0.2,
                          color: parkingYellowColor,
                          icon: Icons.airport_shuttle_rounded,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.009,
                        ),
                        PRKSmallCard(
                          label: "Violations",
                          content: "335",
                          sub: "Infractions committed",
                          height: MediaQuery.of(context).size.height * 0.2,
                          onPressed: () {},
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.009,
                        ),
                        PRKSmallCard(
                          label: "Reports",
                          content: "128",
                          sub: "Received reports",
                          height: MediaQuery.of(context).size.height * 0.2,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    Row(
                      children: [
                        const PRKUserCard(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.009,
                        ),
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.33,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: blackColor.withOpacity(0.1),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Peak Hours",
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            parkingOrangeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.access_time_filled_rounded,
                                        color: blackColor,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.005,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    const Row(
                      children: [PRKLargeCard()],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
