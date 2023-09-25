import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:intl/intl.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/tournament.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {

  List<Tournament> tournamentList = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/tournaments")) {
      getTournaments();
    }
  }

  Future<void> getTournaments() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/tournaments"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        tournamentList = json.decode(response.body)["data"].map<Tournament>((json) => Tournament.fromJson(json)).toList();
      });
    } catch(err) {
      Logger.info("[teams_page] Error getting teams: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get teams!"));
    }
  }

  String getGameImage(String game) {
    switch (game) {
      case "League of Legends":
        return "assets/images/icons/league.jpeg";
      case "Valorant":
        return "assets/images/icons/valorant.png";
      default:
        return "assets/images/pel_icons/Mark Mono.png";
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
                      "Tournaments",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: PELTextButton(
                          text: "Create Tournament",
                          onPressed: () {
                            router.navigateTo(context, "/tournaments/new", transition: TransitionType.fadeIn);
                          },
                        ),
                      )
                    ],
                  ),
                  Padding(padding: LH.hp(context) / 2),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: LH.w(context) / 2,
                      mainAxisExtent: 300,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: tournamentList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            router.navigateTo(context, "/tournaments/${tournamentList[index].id}", transition: TransitionType.fadeIn);
                          },
                          child: Container(
                            height: 300,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  SizedBox(
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                    child: ExtendedImage.network(
                                      tournamentList[index].bannerURL,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Container(
                                    height: 300,
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
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Visibility(
                                              visible: currentTournaments.any((element) => element.id == tournamentList[index].id),
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
                                                      Text("Registered", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(tournamentList[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),
                                                  Text("${DateFormat("MMM d").format(tournamentList[index].seasonStart)} - ${DateFormat("MMM d, yyyy").format(tournamentList[index].seasonEnd)}", style: const TextStyle(fontSize: 24, color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.all(8)),
                                            Image.asset(getGameImage(tournamentList[index].game), width: 55, height: 55),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
