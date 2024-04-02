import 'dart:convert';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
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

class EditTeamPage extends StatefulWidget {
  final String id;
  const EditTeamPage({super.key, required this.id});

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {

  Team team = Team();
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController socialTwitterController = TextEditingController();
  TextEditingController socialInstagramController = TextEditingController();
  TextEditingController socialTikTokController = TextEditingController();

  bool loading = false;
  double iconProgress = 0.0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/teams/${widget.id}/edit")) {
      getTeams();
    }
  }

  Future<void> getTeams() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/teams/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        team = Team.fromJson(jsonDecode(response.body)["data"]);
        nameController.text = team.name;
        bioController.text = team.bio;
        websiteController.text = team.website;
        socialTwitterController.text = team.socialTwitterURL;
        socialInstagramController.text = team.socialInstagramURL;
        socialTikTokController.text = team.socialTikTokURL;
      });
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/teams/${widget.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        team.users = List<TeamUser>.from(jsonDecode(response.body)["data"].map((x) => TeamUser.fromJson(x)));
      });
    } catch(err) {
      Logger.info("[edit_team_page] Error getting team: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get team!"));
    }
  }

  Future<void> saveTeam() async {
    if (team.name == "" || team.game == "") {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Team name and game cannot be empty!"));
      return;
    }
    setState(() => loading = true);
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/teams"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(team));
      if (response.statusCode == 200) {
        await AuthService.getUser(currentUser.id);
        Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams/${widget.id}", transition: TransitionType.fadeIn));
      } else {
        Logger.error("[edit_team_page] Failed to save team! ${response.statusCode} ${response.body}");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to save team!"));
      }
    } catch(err) {
      Logger.info("[edit_team_page] Error saving team: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to save team!"));
      setState(() => loading = false);
    }
    setState(() => loading = false);
  }

  Future<void> deleteTeam() async {
    setState(() => loading = true);
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.delete(Uri.parse("$API_HOST/teams/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      if (response.statusCode == 200) {
        await AuthService.getAuthToken();
        await httpClient.delete(Uri.parse("$API_HOST/teams/${widget.id}/users/${currentUser.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
        await AuthService.getUser(currentUser.id);
        Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams", transition: TransitionType.fadeIn));
      } else {
        Logger.error("[edit_team_page] Failed to delete team! ${response.statusCode} ${response.body}");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to delete team!"));
      }
    } catch(err) {
      Logger.info("[edit_team_page] Error deleting team: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to delete team!"));
      setState(() => loading = false);
    }
    setState(() => loading = false);
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
                              Expanded(
                                child: MaterialTextField(
                                  keyboardType: TextInputType.text,
                                  hint: "Team Name",
                                  controller: nameController,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) {
                                    setState(() {
                                      team.name = value;
                                    });
                                  },
                                ),
                              ),
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
                                onTap: () {
                                  router.navigateTo(context, "/teams/${team.id}", transition: TransitionType.fadeIn);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Details", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                            Card(
                              child: InkWell(
                                onTap: () {},
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Edit", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      !loading ? Row(
                        children: [
                          PELTextButton(
                            text: "Save Changes",
                            onPressed: () {
                              saveTeam();
                            },
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          PELTextButton(
                            text: "Delete",
                            color: Colors.redAccent,
                            onPressed: () {
                              Future.delayed(Duration.zero, () => AlertService.showConfirmationDialog(context, "Delete Team?", "Are you sure you want to delete this team? This action cannot be undone!", () => deleteTeam()));
                            },
                          )
                        ],
                      ) : const Center(
                        child: RefreshProgressIndicator(
                          backgroundColor: PEL_MAIN,
                          color: Colors.white,
                        ),
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
                                    MaterialTextField(
                                      keyboardType: TextInputType.text,
                                      hint: "Bio",
                                      controller: bioController,
                                      textInputAction: TextInputAction.done,
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
                                      textInputAction: TextInputAction.done,
                                      controller: websiteController,
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
                                      textInputAction: TextInputAction.done,
                                      controller: socialTwitterController,
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
                                      textInputAction: TextInputAction.done,
                                      controller: socialInstagramController,
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
                                      textInputAction: TextInputAction.done,
                                      controller: socialTikTokController,
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
                          ],
                        ),
                      ),
                      Padding(padding: LH.hp(context) / 2),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                          ],
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
