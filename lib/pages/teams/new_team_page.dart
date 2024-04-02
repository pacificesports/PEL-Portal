import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';

class NewTeamPage extends StatefulWidget {
  const NewTeamPage({super.key});

  @override
  State<NewTeamPage> createState() => _NewTeamPageState();
}

class _NewTeamPageState extends State<NewTeamPage> {

  Team team = Team();

  double iconProgress = 0.0;
  bool loading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/teams/new")) {
      generateId();
    }
  }

  Future<void> generateId() async {
    String genId = await FirebaseFirestore.instance.collection("gen-id").add({"create-team": true}).then((value) => value.id);
    setState(() {
      team.id = genId;
    });
  }

  Future<void> selectIconImage() async {
    Trace trace = FirebasePerformance.instance.newTrace("selectIconImage()");
    await trace.start();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpeg", "jpg", "png"],
    );
    try {
      if (result != null) {
        PlatformFile file = result.files.first;
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = "icon.${file.extension}";
        FirebaseStorage.instance.ref("teams/${team.id}/$fileName").putData(fileBytes!).snapshotEvents.listen((event) async {
          if (event.state == TaskState.success) {
            team.iconURL = await event.ref.getDownloadURL();
            setState(() {
              iconProgress = 0.0;
            });
            Logger.info("[new_team_page] Image uploaded successfully: ${team.iconURL}");
          } else {
            setState(() => iconProgress = event.bytesTransferred / event.totalBytes);
          }
        });
      }
    } catch (err) {
      Logger.error("[new_team_page] Failed to upload image! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to upload image!"));
    }
    trace.stop();
  }

  Future<void> createTeam() async {
    if (team.name == "") {
      AlertService.showErrorSnackbar(context, "Please enter a name for your team!");
      return;
    } else if (team.game == "") {
      AlertService.showErrorSnackbar(context, "Please select a game for your team!");
      return;
    }
    setState(() => loading = true);
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/teams"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(team));
      if (response.statusCode == 200) {
        TeamUser teamUser = TeamUser();
        teamUser.teamID = team.id;
        teamUser.userID = currentUser.id;
        teamUser.title = "Owner";
        teamUser.roles = ["ADMIN"];
        await AuthService.getAuthToken();
        response = await httpClient.post(Uri.parse("$API_HOST/teams/${team.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(teamUser));
        if (response.statusCode == 200) {
          await AuthService.getAuthToken();
          response = await httpClient.post(Uri.parse("$API_HOST/teams/${team.id}/users/${currentUser.id}/roles"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(teamUser.roles));
          if (response.statusCode == 200) {
            Future.delayed(Duration.zero, () => AlertService.showSuccessSnackbar(context, "Team created successfully!"));
            await AuthService.getUser(currentUser.id);
            Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams/${team.id}", transition: TransitionType.fadeIn));
          } else {
            Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to add user to team!"));
          }
        } else {
          Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to add user to team!"));
        }
      } else {
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to create team!"));
      }
    } catch (err) {
      setState(() => loading = false);
      Logger.error("[new_team_page] Failed to create team! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to create team!"));
    }
    setState(() => loading = false);
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
                    child: const Text(
                      "Create Team",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: LH.cw(context),
                    padding: LH.hp(context),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Card(
                            child: Container(
                              padding: LH.p(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MaterialTextField(
                                    keyboardType: TextInputType.name,
                                    hint: "Team Name",
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(Icons.group_rounded),
                                    onChanged: (value) {
                                      setState(() {
                                        team.name = value;
                                      });
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  MaterialTextField(
                                    keyboardType: TextInputType.text,
                                    hint: "Bio",
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(Icons.description),
                                    onChanged: (value) {
                                      setState(() {
                                        team.bio = value;
                                      });
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  ListTile(
                                    leading: const Icon(Icons.sports_esports_rounded, color: PEL_MAIN,),
                                    tileColor: Theme.of(context).colorScheme.background,
                                    title: const Text("Game"),
                                    trailing: Card(
                                      color: Theme.of(context).colorScheme.background,
                                      child: DropdownButton<String>(
                                        value: team.game,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        alignment: Alignment.centerRight,
                                        underline: Container(),
                                        style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "",
                                            child: Text("Select Game"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Valorant",
                                            child: Text("Valorant"),
                                          ),
                                          DropdownMenuItem(
                                            value: "League of Legends",
                                            child: Text("League of Legends"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Team Fight Tactics",
                                            child: Text("Team Fight Tactics"),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                        onChanged: (item) {
                                          setState(() {
                                            team.game = item!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  MaterialTextField(
                                    keyboardType: TextInputType.url,
                                    hint: "Website URL",
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(Icons.language_rounded),
                                    onChanged: (value) {
                                      setState(() {
                                        team.website = value;
                                      });
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.pd(context))),
                                  const Text("Socials", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  MaterialTextField(
                                    keyboardType: TextInputType.url,
                                    hint: "Twitter URL",
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(Icons.link_rounded),
                                    onChanged: (value) {
                                      setState(() {
                                        team.socialTwitterURL = value;
                                      });
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  MaterialTextField(
                                    keyboardType: TextInputType.url,
                                    hint: "Instagram URL",
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(Icons.link_rounded),
                                    onChanged: (value) {
                                      setState(() {
                                        team.socialInstagramURL = value;
                                      });
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  MaterialTextField(
                                    keyboardType: TextInputType.url,
                                    hint: "TikTok URL",
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(Icons.link_rounded),
                                    onChanged: (value) {
                                      setState(() {
                                        team.socialTikTokURL = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: LH.hpd(context))),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Card(
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      child: Stack(
                                        alignment: Alignment.bottomLeft,
                                        children: [
                                          SizedBox(
                                            height: 150,
                                            width: MediaQuery.of(context).size.width,
                                            child: ExtendedImage.network(
                                              team.bannerURL,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                          Container(
                                            height: 150,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: FractionalOffset.topCenter,
                                                    end: FractionalOffset.bottomCenter,
                                                    colors: [
                                                      Theme.of(context).colorScheme.background.withOpacity(0.1),
                                                      Theme.of(context).colorScheme.background,
                                                    ],
                                                    stops: const [0, 1]
                                                )
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
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
                                                const Padding(padding: EdgeInsets.all(4)),
                                                Expanded(child: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      child: Text(team.bio != "" ? team.bio : "No Bio", style: const TextStyle(fontSize: 16)),
                                    )
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: LH.hpd(context)) / 2),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Custom Icon", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          PELTextButton(
                                            text: "Upload",
                                            onPressed: () {
                                              selectIconImage();
                                            },
                                          )
                                        ],
                                      ),
                                      Visibility(
                                        visible: iconProgress > 0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                          child: LinearProgressIndicator(
                                            borderRadius: BorderRadius.circular(8),
                                            minHeight: 10,
                                            value: 0.4,
                                            color: PEL_MAIN,
                                            backgroundColor: Theme.of(context).cardColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: LH.hpd(context)) / 2),
                              loading ? Container(
                                padding: const EdgeInsets.all(16),
                                child: const RefreshProgressIndicator(
                                  backgroundColor: PEL_MAIN,
                                  color: Colors.white,
                                ),
                              ) : Card(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: PELTextButton(
                                    text: "Create Team",
                                    onPressed: () {
                                      createTeam();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
