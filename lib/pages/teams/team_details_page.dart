import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/pages/teams/edit_team_user_dialog.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TeamDetailsPage extends StatefulWidget {
  final String id;
  const TeamDetailsPage({super.key, required this.id});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {

  Team team = Team();
  bool joinLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/teams/${widget.id}")) {
      getTeams();
    }
  }

  Future<void> getTeams() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/teams/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        team = Team.fromJson(jsonDecode(response.body)["data"]);
      });
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/teams/${widget.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        team.users = List<TeamUser>.from(jsonDecode(response.body)["data"].map((x) => TeamUser.fromJson(x)));
      });
    } catch(err) {
      Logger.info("[team_details_page] Error getting team: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get team!"));
    }
  }

  Future<void> joinTeam() async {
    setState(() => joinLoading = true);
    try {
      TeamUser teamUser = TeamUser();
      teamUser.teamID = team.id;
      teamUser.userID = currentUser.id;
      teamUser.title = "Member";
      teamUser.roles = ["PENDING"];
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/teams/${team.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(teamUser));
      if (response.statusCode == 200) {
        await AuthService.getAuthToken();
        response = await httpClient.post(Uri.parse("$API_HOST/teams/${team.id}/users/${currentUser.id}/roles"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(teamUser.roles));
        if (response.statusCode == 200) {
          await AuthService.getUser(currentUser.id);
          Future.delayed(Duration.zero, () => AlertService.showSuccessSnackbar(context, "Team joined successfully!"));
          Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams/${team.id}", transition: TransitionType.fadeIn));
        } else {
          Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to add user to team!"));
        }
      } else {
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to add user to team!"));
      }
    } catch(err) {
      Logger.info("[team_details_page] Error joining team: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to join team!"));
      setState(() => joinLoading = false);
    }
    setState(() => joinLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PortalHeader(),
            Container(
              padding: LH.p(context),
              width: LH.cw(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        SizedBox(
                          height: 250,
                          width: LH.cw(context),
                          child: ExtendedImage.network(
                            team.bannerURL == "" ? defaultBannerURL : team.bannerURL,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Theme.of(context).cardColor.withOpacity(0.1),
                                    Theme.of(context).cardColor,
                                  ],
                                  stops: const [0, 1]
                              )
                          ),
                        ),
                        Container(
                          height: 250,
                          width: LH.cw(context),
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(512)),
                                child: ExtendedImage.network(
                                  team.iconURL,
                                  fit: BoxFit.cover,
                                  width: 65,
                                  height: 65,
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              Expanded(child: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: LH.hp(context) / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        child: Row(
                          children: [
                            Card(
                              child: InkWell(
                                onTap: () {
                                  router.navigateTo(context, "/home", transition: TransitionType.fadeIn);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Home", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                            Card(
                              child: InkWell(
                                onTap: () {
                                  router.navigateTo(context, "/teams", transition: TransitionType.fadeIn);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Teams", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                            Card(
                              child: InkWell(
                                onTap: () {},
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Details", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: team.users.firstWhere((element) => element.userID == currentUser.id).roles.any((element) => ["ADMIN", "CAPTAIN", "EDITOR"].contains(element)),
                            child: PELTextButton(
                              text: "Edit Team",
                              style: PELTextButtonStyle.outlined,
                              onPressed: () {
                                router.navigateTo(context, "/teams/${team.id}/edit", transition: TransitionType.fadeIn);
                              },
                            )
                          ),
                          Visibility(
                              visible: !team.users.any((element) => element.userID == currentUser.id),
                              child: PELTextButton(
                                text: "Join Team",
                                onPressed: () {
                                  joinTeam();
                                },
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(padding: LH.hp(context) / 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Card(
                              // color: Theme.of(context).colorScheme.background,
                              color: Theme.of(context).cardColor,
                              child: Padding(
                                padding: LH.hp(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "About",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontFamily: "Helvetica",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(8)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                team.bio != "" ? team.bio : "No bio.",
                                                style: const TextStyle(fontSize: 22, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Visibility(
                                              visible: team.website != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(team.website);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.language, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "Website",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: team.socialTwitterURL != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(team.socialTwitterURL);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_outlined, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "Twitter",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: team.socialInstagramURL != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(team.socialInstagramURL);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_outlined, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "Instagram",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: team.socialTikTokURL != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(team.socialTikTokURL);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_outlined, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "TikTok",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: LH.hp(context) / 2),
                      Expanded(
                        flex: 3,
                        child: Card(
                          child: Padding(
                            padding: LH.hp(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Users",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  children: team.users.where((u) => !u.roles.contains("PENDING")).map((user) => Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Card(
                                      color: Theme.of(context).colorScheme.background,
                                      // color: Theme.of(context).cardColor,
                                      child: InkWell(
                                        onTap: () {
                                          if (team.users.firstWhere((element) => element.userID == currentUser.id).roles.contains("ADMIN")) {
                                            showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: Theme.of(context).cardColor,
                                                  surfaceTintColor: Theme.of(context).cardColor,
                                                  content: EditTeamUserDialog(teamID: team.id, userID: user.userID),
                                                )
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.all(Radius.circular(512)),
                                                child: ExtendedImage.network(
                                                  user.user.profilePictureURL,
                                                  fit: BoxFit.cover,
                                                  width: 55,
                                                  height: 55,
                                                ),
                                              ),
                                              const Padding(padding: EdgeInsets.all(8)),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${user.user.firstName} ${user.user.lastName}", style: const TextStyle(fontSize: 22, color: Colors.white)),
                                                    Text(user.title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                ),
                                const Padding(padding: EdgeInsets.all(8)),
                                Visibility(
                                  visible: team.users.where((u) => u.roles.contains("PENDING")).isNotEmpty,
                                  child: const Text(
                                    "Pending Users",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: team.users.where((u) => u.roles.contains("PENDING")).map((user) => Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Card(
                                      color: Theme.of(context).colorScheme.background,
                                      // color: Theme.of(context).cardColor,
                                      child: InkWell(
                                        onTap: () {
                                          if (team.users.firstWhere((element) => element.userID == currentUser.id).roles.contains("ADMIN")) {
                                            showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: Theme.of(context).cardColor,
                                                  surfaceTintColor: Theme.of(context).cardColor,
                                                  content: EditTeamUserDialog(teamID: team.id, userID: user.userID),
                                                )
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.all(Radius.circular(512)),
                                                child: ExtendedImage.network(
                                                  user.user.profilePictureURL,
                                                  fit: BoxFit.cover,
                                                  width: 55,
                                                  height: 55,
                                                ),
                                              ),
                                              const Padding(padding: EdgeInsets.all(8)),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${user.user.firstName} ${user.user.lastName}", style: const TextStyle(fontSize: 22, color: Colors.white)),
                                                    const Text("Pending", style: TextStyle(fontSize: 18, color: PEL_WARNING)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
