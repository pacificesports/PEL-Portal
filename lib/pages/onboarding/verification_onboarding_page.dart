import 'package:flutter/material.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/breadcrumbs/onboarding_breadcrumb.dart';

class VerificationOnboardingPage extends StatefulWidget {
  const VerificationOnboardingPage({super.key});

  @override
  State<VerificationOnboardingPage> createState() => _VerificationOnboardingPageState();
}

class _VerificationOnboardingPageState extends State<VerificationOnboardingPage> {
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
                                  "Upload\nVerification",
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
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                OnboardingBreadcrumb(),

                              ],
                            ),
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
