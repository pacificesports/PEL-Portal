import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_home_header.dart';
import 'package:pel_portal/widgets/home/no_teams_card.dart';
import 'package:pel_portal/widgets/home/no_tournaments_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/home")) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PortalHomeHeader(),
            Container(
              padding: LH.p(context),
              width: LH.cw(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context), right: LH.hpd(context), bottom: LH.hpd(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Teams",
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: "Helvetica",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PELTextButton(
                              text: "Create Team",
                              onPressed: () {
                                router.navigateTo(context, "/teams/new", transition: TransitionType.fadeIn);
                              },
                            ),
                            const Padding(padding: EdgeInsets.all(8)),
                            Visibility(
                              visible: currentTeams.isNotEmpty,
                              child: PELTextButton(
                                text: "Explore Teams",
                                style: PELTextButtonStyle.outlined,
                                onPressed: () {
                                  router.navigateTo(context, "/teams", transition: TransitionType.fadeIn);
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  currentTeams.isEmpty ? const NoTeamsCard() : ListView.builder(
                      itemCount: currentTeams.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                router.navigateTo(context, "/teams/${currentTeams[index].id}", transition: TransitionType.fadeIn);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(512)),
                                      child: ExtendedImage.network(
                                        currentTeams[index].iconURL,
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
                                          Text(currentTeams[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Text(currentTeams[index].game, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                        ],
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
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context), right: LH.hpd(context), bottom: LH.hpd(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Tournaments",
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: "Helvetica",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: currentUser.canCreateTournament(),
                              child: PELTextButton(
                                text: "Create Tournament",
                                onPressed: () {
                                  router.navigateTo(context, "/tournaments/new", transition: TransitionType.fadeIn);
                                },
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(8)),
                            Visibility(
                              visible: currentTournaments.isNotEmpty,
                              child: PELTextButton(
                                text: "Explore Tournaments",
                                style: PELTextButtonStyle.outlined,
                                onPressed: () {
                                  router.navigateTo(context, "/tournaments", transition: TransitionType.fadeIn);
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  currentTournaments.isEmpty ? const NoTournamentsCard() : ListView.builder(
                      itemCount: currentTeams.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                router.navigateTo(context, "/teams/${currentTeams[index].id}", transition: TransitionType.fadeIn);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(512)),
                                      child: ExtendedImage.network(
                                        currentTeams[index].iconURL,
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
                                          Text(currentTeams[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Text(currentTeams[index].game, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                        ],
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
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
                  //   child: const Text(
                  //     "My Organizations",
                  //     style: TextStyle(
                  //       fontSize: 32,
                  //       fontFamily: "Helvetica",
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // const NoOrganizationCard()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
