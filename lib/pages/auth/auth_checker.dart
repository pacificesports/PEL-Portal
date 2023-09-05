import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {

  double percent = 0.0;
  StreamSubscription<User?>? _fbAuthSubscription;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    checkServerStatus().then((online) {
      if (online) checkAuthState();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fbAuthSubscription?.cancel();
  }

  Future<bool> checkServerStatus() async {
    Trace trace = FirebasePerformance.instance.newTrace("checkServerStatus()");
    await trace.start();
    try {
      var serverStatus = await httpClient.get(Uri.parse("$API_HOST/sanfrancisco/ping"), headers: {"PEL-API-KEY": PEL_API_KEY});
      Logger.info("[auth_checker_page] Server Status: ${serverStatus.statusCode}");
      if (serverStatus.statusCode == 200) {
        trace.stop();
        return true;
      }
    } catch (err) {
      Logger.error("[auth_checker_page] Failed to connect to server! $err");
    }
    setState(() {percent = 0.45;});
    trace.stop();
    if (mounted) {
      AlertService.showErrorSnackbar(context, "Failed to connect to server!");
    }
    return false;
  }

  Future<void> checkAuthState() async {
    Trace trace = FirebasePerformance.instance.newTrace("checkAuthState()");
    await trace.start();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {percent = 1;});
    });
    _fbAuthSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        // Not logged in
        router.navigateTo(context, "/auth/register", transition: TransitionType.fadeIn, replace: true, clearStack: true);
        trace.stop();
        return;
      } else {
        // User logged in
        try {
          Logger.info("[auth_checker_page] Firebase session detected: ${user.uid}");
          await AuthService.getUser(user.uid);
          if (currentUser.id == "") {
            // User logged in, but no user data in db
            Future.delayed(Duration.zero, () => router.navigateTo(context, "/auth/register", transition: TransitionType.fadeIn, replace: true, clearStack: true));
            trace.stop();
            return;
          }
          checkUserStatus();
        } catch (err) {
          Logger.error("[auth_checker_page] $err");
          trace.stop();
          return;
        }
      }
    });
  }

  void checkUserStatus() {
    Trace trace = FirebasePerformance.instance.newTrace("checkUserStatus()");
    trace.start();
    if (currentUser.school.schoolID == "") {
      // User needs to set school
      Future.delayed(Duration.zero, () => router.navigateTo(context, "/onboarding/school", transition: TransitionType.fadeIn, replace: true, clearStack: true));
    } else if (currentUser.verification.status == "" || currentUser.verification.status == "REJECTED") {
      // Verification is empty or was rejected (needs immediate attention)
      Future.delayed(Duration.zero, () => router.navigateTo(context, "/onboarding/verification", transition: TransitionType.fadeIn, replace: true, clearStack: true));
    } else if (currentUser.connections.length == 4 && !currentUser.verification.isVerified) {
      // Only the default 4 discord connections, let user add more while waiting for verification
      Future.delayed(Duration.zero, () => router.navigateTo(context, "/onboarding/connections", transition: TransitionType.fadeIn, replace: true, clearStack: true));
    } else {
      // User is good to go!
      if (ModalRoute.of(context)!.settings.name!.contains("?route=")) {
        String route = ModalRoute.of(context)!.settings.name!.split("?route=")[1];
        String routeDecoded = Uri.decodeComponent(route);
        Future.delayed(Duration.zero, () => router.navigateTo(context, routeDecoded, transition: TransitionType.fadeIn, replace: true, clearStack: true));
      } else {
        Future.delayed(Duration.zero, () => router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true, clearStack: true));
      }
    }
    trace.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Center(
          //   child: Hero(
          //     tag: "storke-banner",
          //     child: Image.asset(
          //       "images/storke.jpeg",
          //       height: MediaQuery.of(context).size.height,
          //       alignment: const Alignment(0.4,0),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 42,
                      lineWidth: 7,
                      circularStrokeCap: CircularStrokeCap.round,
                      percent: 1,
                      // progressColor: Colors.white,
                      progressColor: Theme.of(context).cardColor,
                    ),
                    CircularPercentIndicator(
                      radius: 48,
                      lineWidth: 7,
                      circularStrokeCap: CircularStrokeCap.round,
                      percent: 1,
                      // progressColor: Colors.white,
                      progressColor: Theme.of(context).cardColor,
                    ),
                    CircularPercentIndicator(
                        radius: 45,
                        lineWidth: 7,
                        circularStrokeCap: CircularStrokeCap.round,
                        animateFromLastPercent: true,
                        animation: true,
                        percent: percent,
                        // progressColor: Colors.white,
                        progressColor: PEL_MAIN,
                        // backgroundColor: Colors.white,
                        backgroundColor: Theme.of(context).cardColor,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
