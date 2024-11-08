import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class PRKUserCard extends StatefulWidget {
  const PRKUserCard({
    super.key,
  });

  @override
  State<PRKUserCard> createState() => _PRKUserCardState();
}

class _PRKUserCardState extends State<PRKUserCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Users",
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
                    color: blueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: blackColor,
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blueColor.withOpacity(0.1),
                  ),
                  child: const Center(
                    child: Text("Pie Graph"),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      direction: Axis.vertical,
                      children: [
                        Text(
                          "768",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total users using the app ",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          children: [
                            Wrap(
                              children: [
                                Container(
                                  height: 11,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: blueColor,
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Student",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          children: [
                            Wrap(
                              children: [
                                Container(
                                  height: 11,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: yellowColor,
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Employee",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
