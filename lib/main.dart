import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pel_portal/pages/auth/auth_checker.dart';
import 'package:pel_portal/pages/auth/login_page.dart';
import 'package:pel_portal/pages/auth/register_page.dart';
import 'package:pel_portal/pages/home/home_page.dart';
import 'package:pel_portal/pages/mobile_navigation_controller.dart';
import 'package:pel_portal/pages/not_found_page.dart';
import 'package:pel_portal/pages/onboarding/connections_onboarding_page.dart';
import 'package:pel_portal/pages/onboarding/onboarding_page.dart';
import 'package:pel_portal/pages/onboarding/school_onboarding_page.dart';
import 'package:pel_portal/pages/onboarding/verification_onboarding_page.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

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
  DISCORD_CLIENT_ID = dotenv.env["DISCORD_CLIENT_ID"]!;
  DISCORD_CLIENT_SECRET = dotenv.env["DISCORD_CLIENT_SECRET"]!;
  DISCORD_REDIRECT_URI = dotenv.env["DISCORD_REDIRECT_URI"]!;

  prefs = await SharedPreferences.getInstance();

  log("PEL Portal v${appVersion.toString()}");
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log("Initialized default app ${app.name}");
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // ROUTE DEFINITIONS
  router.define("/", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const OnboardingPage();
  }));

  router.define("/auth/check", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const AuthChecker();
  }));
  router.define("/auth/login", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const LoginPage();
  }));
  router.define("/auth/register", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const RegisterPage();
  }));

  router.define("/onboarding/school", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const SchoolOnboardingPage();
  }));
  router.define("/onboarding/verification", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const VerificationOnboardingPage();
  }));
  router.define("/onboarding/connections", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const ConnectionsOnboardingPage();
  }));

  router.define("/home", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return (LayoutHelper.isMobile(context)) ? const MobileNavigationController() : const HomePage();
  }));

  router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return const NotFoundPage();
  });

  usePathUrlStrategy();
  runApp(AdaptiveTheme(
    light: darkTheme,
    dark: darkTheme,
    initial: AdaptiveThemeMode.dark,
    builder: (theme, darkTheme) =>
      MaterialApp(
        title: "PEL Portal",
        initialRoute: kIsWeb ? "/" : "/auth/check",
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