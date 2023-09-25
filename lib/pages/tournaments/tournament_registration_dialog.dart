import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/tournament.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class TournamentRegistrationDialog extends StatefulWidget {
  final String tournamentID;
  const TournamentRegistrationDialog({super.key, required this.tournamentID});

  @override
  State<TournamentRegistrationDialog> createState() => _TournamentRegistrationDialogState();
}

class _TournamentRegistrationDialogState extends State<TournamentRegistrationDialog> {

  Tournament tournament = Tournament();
  bool loading = false;
  String selectedTeamID = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getTournament();
    getTeams();
  }

  Future<void> getTournament() async {
    await AuthService.getAuthToken();
    var response = await httpClient.get(Uri.parse("$API_HOST/tournaments/${widget.tournamentID}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
    if (response.statusCode == 200) {
      setState(() {
        tournament = Tournament.fromJson(jsonDecode(response.body)["data"]);
      });
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/tournaments/${widget.tournamentID}/teams"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      if (response.statusCode == 200) {
        setState(() {
          tournament.teams = jsonDecode(response.body)["data"].map<TournamentTeam>((json) => TournamentTeam.fromJson(json)).toList();
        });
      } else {
        Logger.info("[tournament_registration_dialog] Error getting tournament teams: ${response.statusCode}");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get tournament teams!"));
      }
    } else {
      Logger.info("[tournament_registration_dialog] Error getting tournament: ${response.statusCode}");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get tournament!"));
    }
  }

  Future<void> getTeams() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/users/teams/${currentUser.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        currentTeams = jsonDecode(response.body)["data"].map<Team>((json) => Team.fromJson(json)).toList();
      });
      for (Team team in currentTeams) {
        await AuthService.getAuthToken();
        response = await httpClient.get(Uri.parse("$API_HOST/teams/${team.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
        setState(() {
          team.users = List<TeamUser>.from(jsonDecode(response.body)["data"].map((x) => TeamUser.fromJson(x)));
        });
      }
    } catch(err) {
      Logger.info("[tournament_registration_dialog] Error getting teams: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get teams!"));
    }
  }

  List<dynamic> canRegister(Team team) {
    // log("[tournament_registration_dialog] TEAM DEBUG: ${team.id} - ${team.name}");
    // for (TeamUser user in team.users) {
    //   log("[tournament_registration_dialog] ${user.user.toString()}");
    //   log("[tournament_registration_dialog] ${user.roles.toString()}");
    // }
    if (tournament.teams.any((element) => element.teamID == team.id)) {
      return [false, "Team is already registered for this tournament!"];
    }
    if (!team.users.any((element) => element.userID == currentUser.id)) {
      // shouldn't even be possible tbh
      return [false, "You are not a member of this team!"];
    }
    if (!team.users.firstWhere((element) => element.userID == currentUser.id).roles.any((element) => ["ADMIN", "CAPTAIN"].contains(element))) {
      return [false, "Only team admins and team captains can register their team!"];
    }
    if (team.game != tournament.game) {
      return [false, "Team game does not match tournament game!"];
    }
    if (team.users.where((element) => element.roles.contains("ACTIVE")).isEmpty) {
      return [false, "Team must have at least 1 active player!"];
    }
    return [true, "Team can be registered!"];
  }

  Future<void> registerTeam(Team team) async {
    setState(() => loading = true);
    TournamentTeam tournamentTeam = TournamentTeam();
    tournamentTeam.teamID = team.id;
    tournamentTeam.tournamentID = tournament.id;
    var response = await httpClient.post(Uri.parse("$API_HOST/tournaments/${tournament.id}/teams/${team.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(tournamentTeam));
    if (response.statusCode == 200) {
      Future.delayed(Duration.zero, () => router.pop(context));
      Future.delayed(Duration.zero, () => router.navigateTo(context, "/tournaments/${tournament.id}", transition: TransitionType.fadeIn));
    } else {
      Logger.error("[tournament_registration_dialog] Error registering team: ${response.body}");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to register team!"));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: tournament.id != "" ? Container(
            width: 500,
            height: 500,
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Register for ${tournament.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: PEL_MAIN)),
                const Padding(padding: EdgeInsets.all(8)),
                const Text("Select a team", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                const Padding(padding: EdgeInsets.all(4)),
                currentTeams.isNotEmpty ? Expanded(
                  child: ListView.builder(
                    itemCount: currentTeams.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      Team team = currentTeams[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          color: canRegister(team)[0] ? Theme.of(context).colorScheme.background : Theme.of(context).cardColor,
                          child: InkWell(
                            onTap: () {
                              List<dynamic> reg = canRegister(team);
                              if (!reg[0]) {
                                log("[tournament_registration_dialog] ${reg[1]}");
                                Future.delayed(Duration.zero, () => AlertService.showInfoSnackbar(context, reg[1]));
                                return;
                              }
                              setState(() => selectedTeamID = team.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(512)),
                                    child: ExtendedImage.network(
                                      team.iconURL,
                                      fit: BoxFit.cover,
                                      width: 55,
                                      height: 55,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.all(8)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                        Text(team.game, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.all(8)),
                                  Icon(selectedTeamID == team.id ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selectedTeamID == team.id ? PEL_MAIN : Colors.grey)
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ) : const Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(padding: EdgeInsets.all(16)),
                        Icon(Icons.group_off, size: 64, color: PEL_MAIN),
                        Padding(padding: EdgeInsets.all(8)),
                        Text("You are not a member of any teams!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Padding(padding: EdgeInsets.all(4)),
                        Text("Try joining a team before registering for a tournament.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: !loading ? PELTextButton(
                        text: "Register",
                        onPressed: () {
                          if (selectedTeamID == "") {
                            Future.delayed(Duration.zero, () => AlertService.showInfoSnackbar(context, "Please select a team!"));
                            return;
                          } else {
                            registerTeam(currentTeams.firstWhere((element) => element.id == selectedTeamID));
                          }
                        },
                      ) : const Center(
                        child: RefreshProgressIndicator(
                          backgroundColor: PEL_MAIN,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
        ) : const SizedBox(
          width: 500,
          height: 500,
          child: Center(
            child: RefreshProgressIndicator(
              backgroundColor: PEL_MAIN,
              color: Colors.white,
            ),
          ),
        )
    );
  }
}
