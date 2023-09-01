import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pel_portal/pages/onboarding/onboarding_page.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return const Scaffold(
        body: Center(
            child: Text("Unexpected error. See log for details.")));
  };

  await dotenv.load(fileName: ".env");
  API_HOST = dotenv.env["PEL_API_HOST"]!;
  PEL_API_KEY = dotenv.env["PEL_API_KEY"]!;
  ONESIGNAL_APP_ID = dotenv.env["ONESIGNAL_APP_ID"]!;

  prefs = await SharedPreferences.getInstance();

  log("PEL Portal v${appVersion.toString()}");
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log("Initialized default app ${app.name}");
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Remove this method to stop OneSignal Debugging
  // OneSignal.shared.setLogLevel(OSLogLevel.debug, OSLogLevel.none);
  // OneSignal.shared.setAppId(ONESIGNAL_APP_ID);

  // ROUTE DEFINITIONS
  router.define("/", handler: Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
        return const OnboardingPage();
      }));

  runApp(AdaptiveTheme(
    light: lightTheme,
    dark: darkTheme,
    initial: AdaptiveThemeMode.dark,
    builder: (theme, darkTheme) =>
        MaterialApp(
          title: "PEL Portal",
          initialRoute: kIsWeb ? "/" : "/check-auth",
          onGenerateRoute: router.generator,
          theme: theme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            routeObserver,
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        ),
  ));
}