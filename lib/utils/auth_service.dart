import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:pel_portal/models/organization.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/tournament.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/logger.dart';

class AuthService {

  /// only call this function when fb auth state has been verified!
  /// sets the [currentUser] to retrieved user with [id] from db
  static Future<void> getUser(String id) async {
    Trace trace = FirebasePerformance.instance.newTrace("getUser()");
    await trace.start();
    await AuthService.getAuthToken();
    var response = await httpClient.get(Uri.parse("$API_HOST/users/$id"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
    if (response.statusCode == 200) {
      currentUser = User.fromJson(jsonDecode(response.body)["data"]);
      log("====== USER DEBUG INFO ======");
      log("FIRST NAME: ${currentUser.firstName}");
      log("LAST NAME: ${currentUser.lastName}");
      log("EMAIL: ${currentUser.email}");
      log("====== =============== ======");
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/users/organizations/$id"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      if (response.statusCode == 200) {
        currentOrganizations = jsonDecode(response.body)["data"].map<Organization>((json) => Organization.fromJson(json)).toList();
      } else {
        log("Failed to get organizations for user $id");
      }
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/users/teams/$id"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      if (response.statusCode == 200) {
        currentTeams = jsonDecode(response.body)["data"].map<Team>((json) => Team.fromJson(json)).toList();
      } else {
        log("Failed to get teams for user $id");
      }
      currentTournaments.clear();
      for (Team team in currentTeams) {
        await AuthService.getAuthToken();
        response = await httpClient.get(Uri.parse("$API_HOST/teams/tournaments/${team.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
        if (response.statusCode == 200) {
          currentTournaments.addAll(jsonDecode(response.body)["data"].map<Tournament>((json) => Tournament.fromJson(json)).toList());
        } else {
          log("Failed to get tournaments for team ${team.id}");
        }
      }
    }
    else {
      // logged but not user data found!
      log("PEL Portal account not found!");
      currentUser = User();
      // signOut();
    }
    trace.stop();
  }

  static Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    currentUser = User();
    await prefs.clear();
  }

  static Future<void> getAuthToken() async {
    Trace trace = FirebasePerformance.instance.newTrace("getAuthToken()");
    await trace.start();
    PEL_AUTH_TOKEN = (await fb.FirebaseAuth.instance.currentUser!.getIdToken(true))!;
    Logger.info("Retrieved auth token: ...${PEL_AUTH_TOKEN.substring(PEL_AUTH_TOKEN.length - 20)}");
    trace.stop();
  }

  static bool verifyUserSession(context, String path) {
    if (currentUser.id == "") {
      Logger.info("User info is missing, checking auth...");
      Future.delayed(Duration.zero, () {
        router.navigateTo(context, "/auth/check?route=${Uri.encodeComponent(path)}", clearStack: true, replace: true, transition: TransitionType.fadeIn);
      });
      return false;
    } else {
      return true;
    }
  }
}