import 'package:flutter/material.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/public_header.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PublicHeader(),
            Container(
              padding: LayoutHelper.getPadding(context),
              width: LayoutHelper.getContentWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Container(
                      padding: LayoutHelper.getPadding(context),
                      width: double.infinity,
                      height: 500,
                      child: const Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Through esports,\nwe excel.",
                                style: TextStyle(
                                  fontSize: 64,
                                  fontFamily: "Helvetica",
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: LayoutHelper.getPaddingDouble(context), left: 16),
                    child: const Text(
                      "Recent News",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 600,
                    padding: EdgeInsets.only(top: LayoutHelper.getPaddingDouble(context) / 2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Card(
                            child: Container(
                              padding: LayoutHelper.getPadding(context),
                              width: double.infinity,
                              child: const Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Through esports,\nwe excel.",
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontFamily: "Helvetica",
                                            fontWeight: FontWeight.bold,
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 16)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(
                                child: Card(
                                  child: Container(
                                    padding: LayoutHelper.getPadding(context),
                                    width: double.infinity,
                                    child: const Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Through esports,\nwe excel.",
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontFamily: "Helvetica",
                                                fontWeight: FontWeight.bold,
                                              )
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 16)),
                              Expanded(
                                child: Card(
                                  child: Container(
                                    padding: LayoutHelper.getPadding(context),
                                    width: double.infinity,
                                    child: const Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Through esports,\nwe excel.",
                                                style: TextStyle(
                                                  fontSize: 32,
                                                  fontFamily: "Helvetica",
                                                  fontWeight: FontWeight.bold,
                                                )
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: LayoutHelper.getPaddingDouble(context), left: 16),
                    child: const Text(
                      "Pacific Esports Tournaments",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    padding: EdgeInsets.only(top: LayoutHelper.getPaddingDouble(context) / 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Container(
                              padding: LayoutHelper.getPadding(context),
                              child: const Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Redwood Rumble",
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontFamily: "Helvetica",
                                            fontWeight: FontWeight.bold,
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 16)),
                        Expanded(
                          child: Card(
                            child: Container(
                              padding: LayoutHelper.getPadding(context),
                              child: const Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "California Clash",
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontFamily: "Helvetica",
                                            fontWeight: FontWeight.bold,
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: LayoutHelper.getPadding(context),
                    child: Center(
                      child: PELTextButton(
                        text: "Join a tournament today!",
                        onPressed: () {},
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
