import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/alert_service.dart';
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

        } catch (err) {
          Logger.error("[auth_checker_page] $err");
          trace.stop();
          return;
        }
      }
    });
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
                      // progressColor: sbNavy,
                      progressColor: Theme.of(context).cardColor,
                    ),
                    CircularPercentIndicator(
                      radius: 48,
                      lineWidth: 7,
                      circularStrokeCap: CircularStrokeCap.round,
                      percent: 1,
                      // progressColor: sbNavy,
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
                        // backgroundColor: sbNavy,
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
