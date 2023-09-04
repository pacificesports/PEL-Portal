import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_performance/firebase_performance.dart';
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
    }
    else {
      // logged but not user data found!
      log("PEL Portal account not found!");
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
    return true;
  }
}