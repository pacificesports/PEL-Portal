// ignore_for_file: non_constant_identifier_names

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pel_portal/models/organization.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/tournament.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/models/version.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = FluroRouter();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

var httpClient = http.Client();

late SharedPreferences prefs;

Version appVersion = Version("2.1.0+1");
Version stableVersion = Version("1.0.0+1");

String API_HOST = "pel-api-host";

String PEL_API_KEY = "pel-api-key";
String PEL_AUTH_TOKEN = "pel-auth-token";
String ONESIGNAL_APP_ID = "onesignal-app-id";

String DISCORD_CLIENT_ID = "discord-client-id";
String DISCORD_CLIENT_SECRET = "discord-client-secret";
String DISCORD_REDIRECT_URI = "discord-redirect-uri";

User currentUser = User();
List<Organization> currentOrganizations = [];
List<Team> currentTeams = [];
List<Tournament> currentTournaments = [];