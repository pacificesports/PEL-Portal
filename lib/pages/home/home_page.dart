import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
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
                  currentTournaments.isEmpty ? const NoTournamentsCard() : GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: LH.w(context) / 2,
                      mainAxisExtent: 300,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: currentTournaments.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            router.navigateTo(context, "/tournaments/${currentTournaments[index].id}", transition: TransitionType.fadeIn);
                          },
                          child: SizedBox(
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
                                      currentTournaments[index].bannerURL,
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
                                              visible: currentTournaments.any((element) => element.id == currentTournaments[index].id),
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
                                                  Text(currentTournaments[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),
                                                  Text("${DateFormat("MMM d").format(currentTournaments[index].seasonStart)} - ${DateFormat("MMM d, yyyy").format(currentTournaments[index].seasonEnd)}", style: const TextStyle(fontSize: 24, color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.all(8)),
                                            Image.asset(getGameImage(currentTournaments[index].game), width: 55, height: 55),
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
                  // const NoOrganizationCard(),
                  Visibility(
                    visible: currentUser.canSeeAdmin(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
                          child: const Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: "Helvetica",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Card(
                          child: InkWell(
                            onTap: () {
                              router.navigateTo(context, "/admin/verification", transition: TransitionType.fadeIn);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Verification Requests", style: TextStyle(fontSize: 18)),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey)
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
