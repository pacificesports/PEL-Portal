import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:pel_portal/models/connection.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/breadcrumbs/onboarding_breadcrumb.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class ConnectionsOnboardingPage extends StatefulWidget {
  const ConnectionsOnboardingPage({super.key});

  @override
  State<ConnectionsOnboardingPage> createState() => _ConnectionsOnboardingPageState();
}

class _ConnectionsOnboardingPageState extends State<ConnectionsOnboardingPage> {

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/onboarding/connections")) {
    }
  }

  Future<void> updateUserConnections() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/users/${currentUser.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(currentUser));
      if (response.statusCode == 200) {
        setState(() {
          currentUser = User.fromJson(jsonDecode(response.body)["data"]);
        });
      } else {
        Logger.error("[school_onboarding_page] Failed to update connections! ${response.body}");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to update connections!"));
      }
    } catch (err) {
      Logger.error("[school_onboarding_page] Failed to update connections! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to update connections!"));
    }
  }

  Widget buildDiscordConnectionWidget() {
    return Card(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset("assets/images/icons/discord-circle.png", width: 50, height: 50),
                const Padding(padding: EdgeInsets.all(8)),
                const Text("Discord", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Padding(padding: EdgeInsets.all(8)),
                const Icon(Icons.check_circle_rounded, color: PEL_SUCCESS),
                const Padding(padding: EdgeInsets.all(4)),
                const Text("Connected", style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("@${currentUser.connections.firstWhere((element) => element.key == "discord_username").connection}", style: const TextStyle(fontSize: 16)),
                const Padding(padding: EdgeInsets.all(4)),
                Text(currentUser.connections.firstWhere((element) => element.key == "discord_id").connection, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildConnectionWidget(String id, String name, String imageName, String hintText) {
    String connectionString = "";
    TextEditingController controller = TextEditingController();
    return Card(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset("assets/images/icons/$imageName", width: 50, height: 50),
                const Padding(padding: EdgeInsets.all(8)),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Padding(padding: EdgeInsets.all(8)),
                Visibility(
                  visible: currentUser.getConnection(id).connection != "",
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: PEL_SUCCESS),
                      Padding(padding: EdgeInsets.all(4)),
                      Text("Connected", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  )
                ),
              ],
            ),
            SizedBox(
              width: LH.cw(context) * 1/4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  currentUser.getConnection(id).connection == "" ? Expanded(
                    child: MaterialTextField(
                      keyboardType: TextInputType.name,
                      hint: hintText,
                      controller: controller,
                      theme: FilledOrOutlinedTextTheme(
                        radius: 8,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        fillColor: Theme.of(context).cardColor,
                      ),
                      onChanged: (value) {
                        connectionString = value;
                      },
                    ),
                  ) : Text(currentUser.getConnection(id).connection, style: const TextStyle(fontSize: 16)),
                  const Padding(padding: EdgeInsets.all(8)),
                  PELTextButton(
                    text: currentUser.getConnection(id).connection == "" ? "Add" : "Remove",
                    color: currentUser.getConnection(id).connection == "" ? PEL_MAIN : PEL_ERROR,
                    style: PELTextButtonStyle.filled,
                    onPressed: () {
                      if (currentUser.getConnection(id).connection == "" && connectionString != "") {
                        Connection connection = Connection();
                        connection.userID = currentUser.id;
                        connection.name = name;
                        connection.key = id;
                        connection.connection = connectionString;
                        currentUser.connections.add(connection);
                        controller.clear();
                      } else {
                        currentUser.connections.removeWhere((element) => element.key == id);
                      }
                      updateUserConnections();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
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
                                  "Add\nConnections",
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
                                      buildDiscordConnectionWidget(),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      buildConnectionWidget("league_id", "League of Legends", "league.jpeg", "Summoner Name"),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      buildConnectionWidget("league_tracker_url", "LoL Tracker Link", "league.jpeg", "Tracker URL"),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      buildConnectionWidget("valorant_id", "Valorant", "valorant.png", "Riot ID"),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      buildConnectionWidget("valorant_tracker_url", "Valorant Tracker Link", "valorant.png", "Tracker URL"),
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
                                      router.navigateTo(context, "/onboarding/verification", transition: TransitionType.fadeIn);
                                    },
                                  ),
                                  const Padding(padding: EdgeInsets.all(4)),
                                  Visibility(
                                    visible: currentUser.verification.isVerified && currentUser.verification.isEmailVerified,
                                    child: PELTextButton(
                                      text: "Done",
                                      style: currentUser.connections.length > 4 ? PELTextButtonStyle.filled : PELTextButtonStyle.outlined,
                                      onPressed: () {
                                        router.navigateTo(context, "/auth/check", transition: TransitionType.fadeIn);
                                      },
                                    ),
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
