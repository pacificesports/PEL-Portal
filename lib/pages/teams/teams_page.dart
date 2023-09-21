import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {

  List<Team> teamList = [];
  List<Team> displayList = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/teams")) {
      getTeams();
    }
  }

  Future<void> getTeams() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/teams"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        teamList = json.decode(response.body)["data"].map<Team>((json) => Team.fromJson(json)).toList();
        displayList = teamList;
      });
    } catch(err) {
      Logger.info("[teams_page] Error getting teams: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get teams!"));
    }
  }

  handleSearch(String input) {
    if (input.isNotEmpty) {
      setState(() {
        displayList = extractTop(
          query: input,
          choices: teamList,
          limit: 7,
          cutoff: 50,
          getter: (Team t) => "${t.name} ${t.game} ${t.id}",
        ).map((e) => e.choice).toList();
      });
    } else {
      setState(() {
        displayList = teamList;
      });
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
                  Padding(
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
                    child: const Text(
                      "Teams",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(padding: LH.hp(context) / 2),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: MaterialTextField(
                            keyboardType: TextInputType.name,
                            hint: "Search for a team",
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.search_rounded),
                            style: const TextStyle(fontSize: 16),
                            theme: FilledOrOutlinedTextTheme(
                              radius: 8,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              fillColor: Theme.of(context).cardColor,
                            ),
                            onChanged: (value) {
                              handleSearch(value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: PELTextButton(
                          text: "Create Team",
                          onPressed: () {
                            router.navigateTo(context, "/teams/new", transition: TransitionType.fadeIn);
                          },
                        ),
                      )
                    ],
                  ),
                  ListView.builder(
                    itemCount: displayList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              router.navigateTo(context, "/teams/${displayList[index].id}", transition: TransitionType.fadeIn);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(512)),
                                    child: ExtendedImage.network(
                                      displayList[index].iconURL,
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
                                        Text(displayList[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                        Text(displayList[index].game, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: currentTeams.any((element) => element.id == displayList[index].id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        color: Theme.of(context).colorScheme.background,
                                        child: Container(
                                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle_rounded, color: PEL_MAIN),
                                              Padding(padding: EdgeInsets.all(4)),
                                              Text("Joined", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey)
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
