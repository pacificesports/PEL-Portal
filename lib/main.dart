import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pel_portal/pages/admin/admin_verification_page.dart';
import 'package:pel_portal/pages/admin/admin_verification_user_page.dart';
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
import 'package:pel_portal/pages/organizations/new_organization_page.dart';
import 'package:pel_portal/pages/organizations/organization_details_page.dart';
import 'package:pel_portal/pages/organizations/organizations_page.dart';
import 'package:pel_portal/pages/teams/edit_team_page.dart';
import 'package:pel_portal/pages/teams/new_team_page.dart';
import 'package:pel_portal/pages/teams/team_details_page.dart';
import 'package:pel_portal/pages/teams/teams_page.dart';
import 'package:pel_portal/pages/tournaments/edit_tournament_page.dart';
import 'package:pel_portal/pages/tournaments/new_tournament_page.dart';
import 'package:pel_portal/pages/tournaments/tournament_details_page.dart';
import 'package:pel_portal/pages/tournaments/tournaments_page.dart';
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
          child: RefreshProgressIndicator(backgroundColor: PEL_MAIN, color: Colors.white),
        )
    );
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

  router.define("/teams", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const TeamsPage();
  }));
  router.define("/teams/new", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const NewTeamPage();
  }));
  router.define("/teams/:id", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return TeamDetailsPage(id: params!["id"][0]);
  }));
  router.define("/teams/:id/edit", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return EditTeamPage(id: params!["id"][0]);
  }));

  router.define("/organizations", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const OrganizationsPage();
  }));
  router.define("/organizations/new", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const NewOrganizationPage();
  }));
  router.define("/organizations/:id", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return OrganizationDetailsPage(id: params!["id"][0]);
  }));

  router.define("/tournaments", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const TournamentsPage();
  }));
  router.define("/tournaments/new", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const NewTournamentPage();
  }));
  router.define("/tournaments/:id", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return TournamentDetailsPage(id: params!["id"][0]);
  }));
  router.define("/tournaments/:id/edit", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return EditTournamentPage(id: params!["id"][0]);
  }));

  router.define("/admin/verification", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return const AdminVerificationPage();
  }));
  router.define("/admin/verification/users/:id", handler: Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return AdminVerificationUserPage(id: params!["id"][0]);
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