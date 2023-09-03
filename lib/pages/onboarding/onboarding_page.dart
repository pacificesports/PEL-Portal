import 'package:flutter/material.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/public_header.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

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
              padding: LH.p(context),
              width: LH.cw(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Container(
                      padding: LH.p(context),
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
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
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
                    padding: EdgeInsets.only(top: LH.hpd(context)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Card(
                            child: Container(
                              padding: LH.p(context),
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
                                    padding: LH.p(context),
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
                              Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                              Expanded(
                                child: Card(
                                  child: Container(
                                    padding: LH.p(context),
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
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
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
                    padding: EdgeInsets.only(top: LH.hpd(context)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Container(
                              padding: LH.p(context),
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
                        Padding(padding: EdgeInsets.only(left: LH.hpd(context))),
                        Expanded(
                          child: Card(
                            child: Container(
                              padding: LH.p(context),
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
                    padding: EdgeInsets.all(LH.pd(context) * 2),
                    child: Center(
                      child: SizedBox(
                        width: 400,
                        child: PELTextButton(
                          text: "Join a tournament today!",
                          onPressed: () {},
                        ),
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
