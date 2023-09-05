import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
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

  bool emailVerificationLoading = false;
  Timer? emailVerificationTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/onboarding/verification")) {
      checkEmailVerification();
    }
  }


  @override
  void dispose() {
    super.dispose();
    emailVerificationTimer?.cancel();
  }

  void sendEmailVerification() {
    fb.FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
      AlertService.showSuccessSnackbar(context, "Verification email sent!");
      setState(() => emailVerificationLoading = true);
      emailVerificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        checkEmailVerification();
      });
    }).catchError((err) {
      AlertService.showErrorSnackbar(context, "Failed to send verification email!");
    });
  }

  void checkEmailVerification() {
    fb.FirebaseAuth.instance.currentUser!.reload().then((value) {
      if (fb.FirebaseAuth.instance.currentUser!.emailVerified) {
        AlertService.showSuccessSnackbar(context, "Email verified!");
        setState(() {
          currentUser.verification.isEmailVerified = true;
          emailVerificationLoading = false;
        });
        emailVerificationTimer?.cancel();
      }
    }).catchError((err) {
      AlertService.showErrorSnackbar(context, "Failed to check email verification!");
    });
  }

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
                                      Card(
                                        color: Theme.of(context).colorScheme.background,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          title: Text("Email Verification (${currentUser.email})"),
                                          trailing: SizedBox(
                                            height: 50,
                                            child: !currentUser.verification.isEmailVerified && !emailVerificationLoading ? PELTextButton(
                                              text: "Verify",
                                              style: PELTextButtonStyle.filled,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                              onPressed: () {
                                                sendEmailVerification();
                                              },
                                            ) : emailVerificationLoading ? const RefreshProgressIndicator(
                                                backgroundColor: PEL_MAIN,
                                                color: Colors.white,
                                            ) : const Icon(Icons.check_circle_rounded, color: PEL_SUCCESS),
                                          )
                                        ),
                                      ),
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
