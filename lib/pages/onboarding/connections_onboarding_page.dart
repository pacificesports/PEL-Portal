import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/breadcrumbs/onboarding_breadcrumb.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class ConnectionsOnboardingPage extends StatefulWidget {
  const ConnectionsOnboardingPage({super.key});

  @override
  State<ConnectionsOnboardingPage> createState() => _ConnectionsOnboardingPageState();
}

class _ConnectionsOnboardingPageState extends State<ConnectionsOnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: LH.p(context),
          width: LH.cw(context),
          child: Card(
              color: PEL_MAIN,
              child: SizedBox(
                height: LH.h(context) * 2/3,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        color: PEL_MAIN,
                        child: Container(
                          padding: LH.p(context),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Add\nConnections",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Card(
                        child: Container(
                          height: double.infinity,
                          padding: LH.p(context),
                          child: Column(
                            children: [
                              const OnboardingBreadcrumb(),
                              const Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  PELTextButton(
                                    text: "Back",
                                    style: PELTextButtonStyle.outlined,
                                    onPressed: () {
                                      router.navigateTo(context, "/onboarding/verification", transition: TransitionType.fadeIn);
                                    },
                                  ),
                                  const Padding(padding: EdgeInsets.all(4)),
                                  PELTextButton(
                                    text: "Next",
                                    style: currentUser.verification.isVerified ? PELTextButtonStyle.filled : PELTextButtonStyle.outlined,
                                    onPressed: () {
                                      router.navigateTo(context, "/onboarding/connections", transition: TransitionType.fadeIn);
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}
