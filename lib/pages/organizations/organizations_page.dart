import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/organization.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/headers/portal_header.dart';

class OrganizationsPage extends StatefulWidget {
  const OrganizationsPage({super.key});

  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {

  List<Organization> organizationList = [];
  List<Organization> displayList = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/organizations")) {
      getOrganizations();
    }
  }

  Future<void> getOrganizations() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/organizations"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        organizationList = json.decode(response.body)["data"].map<Organization>((json) => Organization.fromJson(json)).toList();
        displayList = organizationList;
      });
    } catch(err) {
      Logger.info("[organizations_page] Error getting organizations: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get organizations!"));
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
                      "Organizations",
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: "Helvetica",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: displayList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            router.navigateTo(context, "/organizations/${displayList[index].id}", transition: TransitionType.fadeIn);
                          },
                          child: SizedBox(
                            width: 300,
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
                                          displayList[index].bannerURL,
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
                                                displayList[index].iconURL,
                                                fit: BoxFit.cover,
                                                width: 55,
                                                height: 55,
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.all(4)),
                                            Expanded(child: Text(displayList[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),),
                                            Visibility(
                                              visible: displayList[index].verified,
                                              child: Tooltip(
                                                message: "Verified Organization",
                                                child: GestureDetector(
                                                  onTap: () {
                                                    AlertService.showInfoSnackbar(context, "This organization has been verified by PEL.");
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Icon(Icons.verified_rounded, color: PEL_MAIN),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  child: Text(displayList[index].bio != "" ? displayList[index].bio : "No Bio", style: const TextStyle(fontSize: 16)),
                                ),
                                Visibility(
                                  visible: displayList[index].website != "",
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(left: 16, right: 16),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.link_rounded, color: PEL_MAIN),
                                        const Padding(padding: EdgeInsets.all(4)),
                                        Text(displayList[index].website, style: const TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible: currentOrganizations.any((element) => element.id == displayList[index].id),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Card(
                                            color: Theme.of(context).colorScheme.background,
                                            child: Container(
                                              width: double.infinity,
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
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
