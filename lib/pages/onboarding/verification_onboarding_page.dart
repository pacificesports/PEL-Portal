import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/breadcrumbs/onboarding_breadcrumb.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

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
                          child: Column(
                            children: [
                              const OnboardingBreadcrumb(),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const Padding(padding: EdgeInsets.all(8)),
                                      const Text(
                                        "Upload a photo of your student ID card or other proof of enrollment.",
                                      ),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.upload_file,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      const Text(
                                        "We will review your submission and notify you when you are verified.",
                                      ),
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
                                      router.navigateTo(context, "/onboarding/school", transition: TransitionType.fadeIn);
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
