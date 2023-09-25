import 'dart:convert';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/widgets/markdown_auto_preview.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:pel_portal/models/tournament.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/date_time_picker.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';

class EditTournamentPage extends StatefulWidget {
  final String id;
  const EditTournamentPage({super.key, required this.id});

  @override
  State<EditTournamentPage> createState() => _EditTournamentPageState();
}

class _EditTournamentPageState extends State<EditTournamentPage> {

  Tournament tournament = Tournament();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController registrationStartController = TextEditingController();
  TextEditingController registrationEndController = TextEditingController();
  TextEditingController seasonStartController = TextEditingController();
  TextEditingController seasonEndController = TextEditingController();

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
    if (AuthService.verifyUserSession(context, "/tournaments/${widget.id}/edit")) {
      getTournament();
    }
  }

  Future<void> getTournament() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/tournaments/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        tournament = Tournament.fromJson(jsonDecode(response.body)["data"]);
        nameController.text = tournament.name;
        descriptionController.text = tournament.description;
        registrationStartController.text = tournament.registrationStart.toLocal().toString();
        registrationEndController.text = tournament.registrationEnd.toLocal().toString();
        seasonStartController.text = tournament.seasonStart.toLocal().toString();
        seasonEndController.text = tournament.seasonEnd.toLocal().toString();
      });
    } catch(err) {
      Logger.info("[edit_tournament_page] Error getting tournament: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get tournament!"));
    }
  }

  Future<void> selectBannerImage() async {
    Trace trace = FirebasePerformance.instance.newTrace("selectBannerImage()");
    await trace.start();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpeg", "jpg", "png"],
    );
    try {
      if (result != null) {
        PlatformFile file = result.files.first;
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = "banner.${file.extension}";
        FirebaseStorage.instance.ref("tournaments/${tournament.id}/$fileName").putData(fileBytes!).snapshotEvents.listen((event) async {
          if (event.state == TaskState.success) {
            tournament.bannerURL = await event.ref.getDownloadURL();
            setState(() {
              iconProgress = 0.0;
            });
            Logger.info("[edit_tournament_page] Image uploaded successfully: ${tournament.bannerURL}");
          } else {
            setState(() => iconProgress = event.bytesTransferred / event.totalBytes);
          }
        });
      }
    } catch (err) {
      Logger.error("[edit_tournament_page] Failed to upload image! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to upload image!"));
    }
    trace.stop();
  }

  Future<void> saveTournament() async {
    if (tournament.name == "") {
      AlertService.showErrorSnackbar(context, "Please enter a name for your tournament!");
      return;
    } else if (tournament.game == "") {
      AlertService.showErrorSnackbar(context, "Please select a game for your tournament!");
      return;
    }
    setState(() => loading = true);
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/tournaments"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(tournament));
      if (response.statusCode == 200) {
        Logger.info("[edit_tournament_page] Created tournament successfully!");
        Future.delayed(Duration.zero, () => AlertService.showSuccessSnackbar(context, "Created tournament successfully!"));
        Future.delayed(Duration.zero, () => router.navigateTo(context, "/tournaments/${tournament.id}", transition: TransitionType.fadeIn));
      } else {
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to create tournament!"));
      }
    } catch (err) {
      setState(() => loading = false);
      Logger.error("[edit_tournament_page] Failed to create tournament! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to create tournament!"));
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
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context), right: LH.hpd(context), bottom: LH.hpd(context)),
                    child: const Text(
                      "Create Tournament",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                            tournament.bannerURL == "" ? Tournament.defaultBannerURL : tournament.bannerURL,
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
                                onTap: () {
                                  router.navigateTo(context, "/tournaments/${tournament.id}", transition: TransitionType.fadeIn);
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
                    ],
                  ),
                  Container(
                    width: LH.cw(context),
                    padding: const EdgeInsets.only(top: 16),
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
                                    hint: "Tournament Name",
                                    textInputAction: TextInputAction.next,
                                    controller: nameController,
                                    prefixIcon: const Icon(Icons.group_rounded),
                                    onChanged: (value) {
                                      setState(() {
                                        tournament.name = value;
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
                                        value: tournament.game,
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
                                            tournament.game = item!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  const Text("Tournament Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Padding(padding: EdgeInsets.only(top: LH.hpd(context))),
                                  MarkdownAutoPreview(
                                    toolbarBackground: Theme.of(context).cardColor,
                                    showEmojiSelection: false,
                                    controller: descriptionController,
                                    onChanged: (value) {
                                      setState(() {
                                        tournament.description = value;
                                      });
                                    },
                                  )
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Custom Banner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          PELTextButton(
                                            text: "Upload",
                                            onPressed: () {
                                              selectBannerImage();
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
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.calendar_today_rounded, color: PEL_MAIN,),
                                          Padding(padding: EdgeInsets.all(4)),
                                          Text("Registration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.all(4)),
                                      Row(
                                        children: [
                                          const Expanded(
                                              flex: 2,
                                              child: Text("Start Date", style: TextStyle(fontSize: 16))
                                          ),
                                          const Padding(padding: EdgeInsets.all(4)),
                                          Expanded(
                                            flex: 5,
                                            child: DateTimePicker(
                                              dateMask: "",
                                              timePickerEntryModeInput: true,
                                              controller: registrationStartController,
                                              type: DateTimePickerType.dateTimeSeparate,
                                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                              lastDate: DateTime.now().add(const Duration(days: 730)),
                                              onChanged: (val) {
                                                DateTime parsed = DateTime.parse(val);
                                                setState(() {
                                                  tournament.registrationStart = parsed.toUtc();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.all(4)),
                                      Row(
                                        children: [
                                          const Expanded(
                                              flex: 2,
                                              child: Text("End Date", style: TextStyle(fontSize: 16))
                                          ),
                                          const Padding(padding: EdgeInsets.all(4)),
                                          Expanded(
                                            flex: 5,
                                            child: DateTimePicker(
                                              dateMask: "",
                                              timePickerEntryModeInput: true,
                                              type: DateTimePickerType.dateTimeSeparate,
                                              controller: registrationEndController,
                                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                              lastDate: DateTime.now().add(const Duration(days: 730)),
                                              onChanged: (val) {
                                                DateTime parsed = DateTime.parse(val);
                                                setState(() {
                                                  tournament.registrationEnd = parsed.toUtc();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.all(4)),
                                      const Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.calendar_today_rounded, color: PEL_MAIN,),
                                          Padding(padding: EdgeInsets.all(4)),
                                          Text("Season", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.all(4)),
                                      Row(
                                        children: [
                                          const Expanded(
                                              flex: 2,
                                              child: Text("Start Date", style: TextStyle(fontSize: 16))
                                          ),
                                          const Padding(padding: EdgeInsets.all(4)),
                                          Expanded(
                                            flex: 5,
                                            child: DateTimePicker(
                                              dateMask: "",
                                              timePickerEntryModeInput: true,
                                              type: DateTimePickerType.dateTimeSeparate,
                                              controller: seasonStartController,
                                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                              lastDate: DateTime.now().add(const Duration(days: 730)),
                                              onChanged: (val) {
                                                DateTime parsed = DateTime.parse(val);
                                                setState(() {
                                                  tournament.seasonStart = parsed.toUtc();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(padding: EdgeInsets.all(4)),
                                      Row(
                                        children: [
                                          const Expanded(
                                              flex: 2,
                                              child: Text("End Date", style: TextStyle(fontSize: 16))
                                          ),
                                          const Padding(padding: EdgeInsets.all(4)),
                                          Expanded(
                                            flex: 5,
                                            child: DateTimePicker(
                                              dateMask: "",
                                              timePickerEntryModeInput: true,
                                              type: DateTimePickerType.dateTimeSeparate,
                                              controller: seasonEndController,
                                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                              lastDate: DateTime.now().add(const Duration(days: 730)),
                                              onChanged: (val) {
                                                DateTime parsed = DateTime.parse(val);
                                                setState(() {
                                                  tournament.seasonEnd = parsed.toUtc();
                                                });
                                              },
                                            ),
                                          )
                                        ],
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
                                    text: "Save Changes",
                                    onPressed: () {
                                      saveTournament();
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
