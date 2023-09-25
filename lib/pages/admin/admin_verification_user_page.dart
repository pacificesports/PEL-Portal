import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/models/verification.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AdminVerificationUserPage extends StatefulWidget {
  final String id;
  const AdminVerificationUserPage({super.key, required this.id});

  @override
  State<AdminVerificationUserPage> createState() => _AdminVerificationUserPageState();
}

class _AdminVerificationUserPageState extends State<AdminVerificationUserPage> {

  User user = User();
  bool enrollmentVerificationLoading = false;

  String comments = "";
  TextEditingController commentsController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/admin/verification/users/${widget.id}")) {
      getUser();
    }
  }

  Future<void> getUser() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/users/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        user = User.fromJson(json.decode(response.body)["data"]);
      });
    } catch(err) {
      Logger.info("[admin_verification_user_page] Error getting user: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get user!"));
    }
  }

  Future<void> updateVerification(String status) async {
    Trace trace = FirebasePerformance.instance.newTrace("updateVerification()");
    await trace.start();
    if (comments != "") {
      user.verification.comments += "\n––––––\nPEL ${currentUser.firstName}: $comments";
    }
    comments = "";
    commentsController.clear();
    user.verification.status = status;
    setState(() => enrollmentVerificationLoading = true);
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/users/${user.id}/verification"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(user.verification));
      if (response.statusCode == 200) {
        setState(() {
          user.verification = Verification.fromJson(jsonDecode(response.body)["data"]);
        });
      } else {
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to update verification!"));
      }
    } catch (err) {
      setState(() => enrollmentVerificationLoading = false);
      Logger.error("[admin_verification_user_page] Failed to update verification! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to update verification!"));
    }
    setState(() => enrollmentVerificationLoading = false);
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
                  Padding(
                    padding: EdgeInsets.only(top: LH.pd(context), left: LH.hpd(context)),
                    child: const Text(
                      "Verification Details",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
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
                                  child: Text("Admin", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                            Card(
                              child: InkWell(
                                onTap: () {
                                  router.navigateTo(context, "/admin/verification", transition: TransitionType.fadeIn);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Verification", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                    ],
                  ),
                  Padding(padding: LH.hp(context) / 2),
                  Card(
                    child: Container(
                      padding: LH.p(context),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ExtendedImage.network(
                                user.profilePictureURL,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                shape: BoxShape.circle,
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${user.firstName} ${user.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                                    Text(user.email, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Connections", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: user.connections.map((e) {
                                      if (!["discord_auth_token", "discord_refresh_token"].contains(e.key)) {
                                        return Text("${e.name}: ${e.connection}", style: const TextStyle(color: Colors.grey));
                                      } else {
                                        return Text("${e.name}: ${e.connection.substring(0, 15)}...", style: const TextStyle(color: Colors.grey));
                                      }
                                    }).toList()
                                  )
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Padding(padding: EdgeInsets.all(8)),
                              Card(
                                color: Theme.of(context).colorScheme.background,
                                child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text("Email Verification (${user.email})"),
                                    trailing: SizedBox(
                                      height: 50,
                                      child: user.verification.isEmailVerified ? const Icon(Icons.check_circle_rounded, color: PEL_SUCCESS) : const Icon(Icons.cancel_rounded, color: PEL_ERROR),
                                    )
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              Column(
                                children: [
                                  Card(
                                    color: Theme.of(context).colorScheme.background,
                                    child: Column(
                                      children: [
                                        ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            title: Text("Enrollment Verification (${user.school.school.name})"),
                                            trailing: SizedBox(
                                              width: 150,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(user.verification.status == "ACCEPTED" ? Icons.check_circle_rounded : user.verification.status == "REJECTED" ? Icons.cancel_rounded : Icons.circle_outlined, color: user.verification.status == "ACCEPTED" ? PEL_SUCCESS : user.verification.status == "REJECTED" ? PEL_ERROR : PEL_WARNING),
                                                  const Padding(padding: EdgeInsets.all(4)),
                                                  Text(user.verification.status, style: TextStyle(fontSize: 16, color: user.verification.status == "ACCEPTED" ? PEL_SUCCESS : user.verification.status == "REJECTED" ? PEL_ERROR : PEL_WARNING)),
                                                ],
                                              ),
                                            )
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Card(
                                                      child: ExtendedImage.network(
                                                        user.verification.fileURL,
                                                        height: 300,
                                                        width: double.infinity,
                                                        fit: BoxFit.fitHeight,
                                                      ),
                                                    ),
                                                    PELTextButton(
                                                        text: "Open in new tab",
                                                        style: PELTextButtonStyle.text,
                                                        onPressed: () {
                                                          launchUrlString(user.verification.fileURL);
                                                        }
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Padding(padding: EdgeInsets.all(4)),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      title: const Text("Verification Type:"),
                                                      trailing: Card(
                                                        child: DropdownButton<String>(
                                                          value: user.verification.type,
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                          alignment: Alignment.centerRight,
                                                          underline: Container(),
                                                          style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color),
                                                          items: const [
                                                            DropdownMenuItem(
                                                              value: "",
                                                              child: Text("Select type"),
                                                            ),
                                                            DropdownMenuItem(
                                                              value: "Student ID",
                                                              child: Text("Student ID"),
                                                            ),
                                                            DropdownMenuItem(
                                                              value: "Class Schedule",
                                                              child: Text("Class Schedule"),
                                                            ),
                                                            DropdownMenuItem(
                                                              value: "Transcript",
                                                              child: Text("Transcript"),
                                                            ),
                                                            DropdownMenuItem(
                                                              value: "School Portal",
                                                              child: Text("School Portal"),
                                                            ),
                                                            DropdownMenuItem(
                                                              value: "Other",
                                                              child: Text("Other"),
                                                            ),
                                                          ],
                                                          borderRadius: BorderRadius.circular(8),
                                                          onChanged: (item) {
                                                            setState(() {
                                                              user.verification.type = item!;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 16, right: 16),
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: Text(user.verification.comments, style: const TextStyle(fontSize: 16)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: MaterialTextField(
                                                        hint: "Enter any comments here.",
                                                        controller: commentsController,
                                                        theme: FilledOrOutlinedTextTheme(
                                                          radius: 8,
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          fillColor: Theme.of(context).cardColor,
                                                          prefixIconColor: PEL_MAIN,
                                                        ),
                                                        onChanged: (input) {
                                                          setState(() {
                                                            comments = input;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            PELTextButton(
                                                              color: PEL_ERROR,
                                                              text: "Reject",
                                                              style: PELTextButtonStyle.outlined,
                                                              onPressed: () {
                                                                updateVerification("REJECTED");
                                                              },
                                                            ),
                                                            const Padding(padding: EdgeInsets.all(4)),
                                                            PELTextButton(
                                                              text: "Approve",
                                                              onPressed: () {
                                                                updateVerification("ACCEPTED");
                                                              },
                                                            )
                                                          ],
                                                        )
                                                    )
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
                            ],
                          ),
                          // const Padding(padding: EdgeInsets.all(8)),
                        ],
                      ),
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
