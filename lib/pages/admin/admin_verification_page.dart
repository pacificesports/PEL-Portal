import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';

class AdminVerificationPage extends StatefulWidget {
  const AdminVerificationPage({super.key});

  @override
  State<AdminVerificationPage> createState() => _AdminVerificationPageState();
}

class _AdminVerificationPageState extends State<AdminVerificationPage> {

  List<User> users = [];
  List<User> displayList = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/admin/verification")) {
      getUsers();
    }
  }

  Future<void> getUsers() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        users = json.decode(response.body)["data"].map<User>((json) => User.fromJson(json)).toList();
        displayList = users;
        displayList.sort((a, b) => a.verification.isVerified ? 1 : -1);
      });
    } catch(err) {
      Logger.info("[admin_verification_page] Error getting users: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get users!"));
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
                      "Verification Requests",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(padding: LH.hp(context) / 2),
                  ListView.builder(
                      itemCount: displayList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                router.navigateTo(context, "/admin/verification/users/${displayList[index].id}", transition: TransitionType.fadeIn);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(512)),
                                      child: ExtendedImage.network(
                                        displayList[index].profilePictureURL,
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
                                          Text("${displayList[index].firstName} ${displayList[index].lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                          Text(displayList[index].email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: displayList[index].verification.isVerified,
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
                                                Text("Verified", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
