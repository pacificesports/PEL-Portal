// ignore_for_file: non_constant_identifier_names

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pel_portal/models/version.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = FluroRouter();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

var httpClient = http.Client();

late SharedPreferences prefs;

Version appVersion = Version("2.0.0+1");
Version stableVersion = Version("1.0.0+1");

String API_HOST = "https://api.stage.pacificesports.org";

String PEL_API_KEY = "pel-api-key";
String ONESIGNAL_APP_ID = "onesignal-app-id";