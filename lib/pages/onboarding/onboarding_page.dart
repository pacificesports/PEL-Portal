import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/public_header.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
                  SizedBox(
                    height: 500,
                    child: Card(
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/onboarding/main.png",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    colors: [
                                      Theme.of(context).cardColor.withOpacity(0.1),
                                      Theme.of(context).cardColor,
                                    ],
                                    stops: const [0, 1]
                                )
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
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
                    height: 500,
                    padding: EdgeInsets.only(top: LH.hpd(context)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Card(
                            child: InkWell(
                              onTap: () => launchUrlString("https://pel.gg/sapling"),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    "assets/images/onboarding/sapling-initiative.png",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "",
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
                                  child: InkWell(
                                    onTap: () => launchUrlString("https://youtu.be/KQJsFHmRFAw"),
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          "assets/images/onboarding/redwood-rumble.png",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                        const Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "",
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
                                  child: InkWell(
                                    onTap: () => launchUrlString("https://youtu.be/w4Tt4f1CXfU"),
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          "assets/images/onboarding/why-pel.jpg",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: FractionalOffset.center,
                                                  end: FractionalOffset.bottomCenter,
                                                  colors: [
                                                    Theme.of(context).cardColor.withOpacity(0.1),
                                                    Theme.of(context).cardColor,
                                                  ],
                                                  stops: const [0, 1]
                                              )
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "What is PEL",
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontFamily: "Helvetica",
                                                    fontWeight: FontWeight.bold,
                                                  )
                                              ),
                                            ],
                                          ),
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
                    padding: EdgeInsets.all(LH.pd(context) * 2),
                    child: Center(
                      child: SizedBox(
                        width: 400,
                        child: PELTextButton(
                          text: "Join a tournament today!",
                          onPressed: () {
                            router.navigateTo(context, "/tournaments", transition: TransitionType.fadeIn);
                          },
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
