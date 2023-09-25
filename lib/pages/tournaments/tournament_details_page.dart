import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:pel_portal/models/tournament.dart';
import 'package:pel_portal/pages/tournaments/tournament_registration_dialog.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TournamentDetailsPage extends StatefulWidget {
  final String id;
  const TournamentDetailsPage({super.key, required this.id});

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {

  Tournament tournament = Tournament();
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
    if (AuthService.verifyUserSession(context, "/tournaments/${widget.id}")) {
      getTournament();
    }
  }

  Future<void> getTournament() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/tournaments/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        tournament = Tournament.fromJson(jsonDecode(response.body)["data"]);
      });
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/tournaments/${widget.id}/teams"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        tournament.teams = List<TournamentTeam>.from(jsonDecode(response.body)["data"].map((x) => TournamentTeam.fromJson(x)));
      });
    } catch(err) {
      Logger.info("[tournament_details_page] Error getting tournament: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get tournament!"));
    }
  }

  // Future<void> joinTeam() async {
  //   setState(() => joinLoading = true);
  //   try {
  //     TeamUser teamUser = TeamUser();
  //     teamUser.teamID = tournament.id;
  //     teamUser.userID = currentUser.id;
  //     teamUser.title = "Member";
  //     teamUser.roles = ["PENDING"];
  //     await AuthService.getAuthToken();
  //     var response = await httpClient.post(Uri.parse("$API_HOST/teams/${tournament.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(teamUser));
  //     if (response.statusCode == 200) {
  //       await AuthService.getAuthToken();
  //       response = await httpClient.post(Uri.parse("$API_HOST/teams/${tournament.id}/users/${currentUser.id}/roles"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(teamUser.roles));
  //       if (response.statusCode == 200) {
  //         Future.delayed(Duration.zero, () => AlertService.showSuccessSnackbar(context, "Team joined successfully!"));
  //         Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams/${tournament.id}", transition: TransitionType.fadeIn));
  //       } else {
  //         Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to add user to team!"));
  //       }
  //     } else {
  //       Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to add user to team!"));
  //     }
  //   } catch(err) {
  //     Logger.info("[tournament_details_page] Error joining team: $err");
  //     Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to join team!"));
  //     setState(() => joinLoading = false);
  //   }
  //   setState(() => joinLoading = false);
  // }

  Future<void> unregisterTeam(String teamID) async {
    var response = await httpClient.delete(Uri.parse("$API_HOST/tournaments/${tournament.id}/teams/$teamID"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
    if (response.statusCode == 200) {
      await AuthService.getUser(currentUser.id);
      Future.delayed(Duration.zero, () => router.pop(context));
      Future.delayed(Duration.zero, () => router.navigateTo(context, "/tournaments/${tournament.id}", transition: TransitionType.fadeIn));
    } else {
      Logger.error("[tournament_details_page] Error unregistering team: ${response.body}");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to unregister team!"));
    }
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
                          height: 350,
                          width: LH.cw(context),
                          child: ExtendedImage.network(
                            tournament.bannerURL == "" ? defaultBannerURL : tournament.bannerURL,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Container(
                          height: 350,
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
                          height: 350,
                          width: LH.cw(context),
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: Text(tournament.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),),
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
                                  router.navigateTo(context, "/tournaments", transition: TransitionType.fadeIn);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Tournaments", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                              visible: currentUser.canCreateTournament(),
                              child: PELTextButton(
                                text: "Edit Tournament",
                                style: PELTextButtonStyle.outlined,
                                onPressed: () {
                                  router.navigateTo(context, "/tournaments/${tournament.id}/edit", transition: TransitionType.fadeIn);
                                },
                              )
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          Visibility(
                              visible: !currentTournaments.any((element) => element.id == tournament.id) && tournament.registrationStart.toLocal().isBefore(DateTime.now()) && tournament.registrationEnd.toLocal().isAfter(DateTime.now()),
                              child: PELTextButton(
                                text: "Register",
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Theme.of(context).cardColor,
                                        surfaceTintColor: Theme.of(context).cardColor,
                                        content: TournamentRegistrationDialog(tournamentID: tournament.id),
                                      )
                                  );
                                },
                              )
                          ),
                          Visibility(
                              visible: currentTournaments.any((element) => element.id == tournament.id),
                              child: const Card(
                                child: Padding(
                                padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: PEL_SUCCESS, size: 16),
                                      Padding(padding: EdgeInsets.all(4)),
                                      Text("Registered", style: TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                ),
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
                          mainAxisSize: MainAxisSize.min,
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
                                    MarkdownParse(
                                      data: tournament.description != "" ? tournament.description : "No description.",
                                      shrinkWrap: true,
                                      onTapLink: (text, href, title) {
                                        launchUrlString(href.toString());
                                      },
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
                                  "Registration",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(8)),
                                const Text(
                                  "Starts: ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat("EEE, MMM d, yyyy h:mm a").format(tournament.registrationStart.toLocal()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Helvetica",
                                    color: Colors.grey,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(8)),
                                const Text(
                                  "Ends: ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat("EEE, MMM d, yyyy h:mm a").format(tournament.registrationEnd.toLocal()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Helvetica",
                                    color: Colors.grey,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(8)),
                                Visibility(
                                  visible: currentTournaments.any((element) => element.id == tournament.id),
                                  child: const Text(
                                    "My Teams: ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Helvetica",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: currentTournaments.any((element) => element.id == tournament.id),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: tournament.teams.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        color: Theme.of(context).colorScheme.background,
                                        child: InkWell(
                                          onTap: () {
                                            router.navigateTo(context, "/teams/${tournament.teams[index].teamID}", transition: TransitionType.fadeIn);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(512)),
                                                  child: ExtendedImage.network(
                                                    tournament.teams[index].team.iconURL,
                                                    fit: BoxFit.cover,
                                                    width: 45,
                                                    height: 45,
                                                  ),
                                                ),
                                                const Padding(padding: EdgeInsets.all(8)),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(tournament.teams[index].team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                                                  onPressed: () {
                                                    AlertService.showConfirmationDialog(context, "Unregister Team", "Are you sure you want to unregister this team from the tournament?", () {
                                                      unregisterTeam(tournament.teams[index].teamID);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Visibility(
                                    visible: currentTournaments.any((element) => element.id == tournament.id) && tournament.registrationStart.toLocal().isBefore(DateTime.now()) && tournament.registrationEnd.toLocal().isAfter(DateTime.now()),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: PELTextButton(
                                        style: PELTextButtonStyle.outlined,
                                        text: "Register Another Team",
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Theme.of(context).cardColor,
                                                surfaceTintColor: Theme.of(context).cardColor,
                                                content: TournamentRegistrationDialog(tournamentID: tournament.id),
                                              )
                                          );
                                        },
                                      ),
                                    )
                                ),
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
