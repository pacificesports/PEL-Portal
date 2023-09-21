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
import 'package:url_launcher/url_launcher_string.dart';

import 'edit_organization_user_dialog.dart';

class OrganizationDetailsPage extends StatefulWidget {
  final String id;
  const OrganizationDetailsPage({super.key, required this.id});

  @override
  State<OrganizationDetailsPage> createState() => _OrganizationDetailsPageState();
}

class _OrganizationDetailsPageState extends State<OrganizationDetailsPage> {

  Organization organization = Organization();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/organizations/${widget.id}")) {
      getOrganizations();
    }
  }

  Future<void> getOrganizations() async {
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/organizations/${widget.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        organization = Organization.fromJson(jsonDecode(response.body)["data"]);
      });
      await AuthService.getAuthToken();
      response = await httpClient.get(Uri.parse("$API_HOST/organizations/${widget.id}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        organization.users = List<OrganizationUser>.from(jsonDecode(response.body)["data"].map((x) => OrganizationUser.fromJson(x)));
      });
    } catch(err) {
      Logger.info("[organizations_page] Error getting organization: $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get organization!"));
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
                            organization.bannerURL,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible: organization.verified,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Card(
                                      child: InkWell(
                                        onTap: () {
                                          AlertService.showInfoSnackbar(context, "This organization has been verified by PEL.");
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(left: 16, right: 16, top: 8.0, bottom: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.verified_rounded, color: PEL_MAIN),
                                              Padding(padding: EdgeInsets.all(4)),
                                              Text("Verified", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(512)),
                                    child: ExtendedImage.network(
                                      organization.iconURL,
                                      fit: BoxFit.cover,
                                      width: 65,
                                      height: 65,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.all(8)),
                                  Expanded(child: Text(organization.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white)),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                organization.bio != "" ? organization.bio : "No bio.",
                                                style: const TextStyle(fontSize: 22, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Visibility(
                                              visible: organization.website != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(organization.website);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.language, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "Website",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: organization.socialTwitterURL != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(organization.socialTwitterURL);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_outlined, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "Twitter",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: organization.socialInstagramURL != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(organization.socialInstagramURL);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_outlined, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "Instagram",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: organization.socialTikTokURL != "",
                                              child: Card(
                                                child: InkWell(
                                                  onTap: () {
                                                    launchUrlString(organization.socialTikTokURL);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(left: 8, right: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.circle_outlined, color: PEL_MAIN),
                                                        Padding(padding: EdgeInsets.all(4)),
                                                        Text(
                                                          "TikTok",
                                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(padding: LH.hp(context) / 2),
                            Card(
                              child: Padding(
                                padding: LH.hp(context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Teams",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontFamily: "Helvetica",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(8)),
                                    Card(
                                      color: Theme.of(context).colorScheme.background,
                                      // color: Theme.of(context).cardColor,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(512)),
                                              child: ExtendedImage.network(
                                                organization.iconURL,
                                                fit: BoxFit.cover,
                                                width: 55,
                                                height: 55,
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.all(8)),
                                            const Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Bharat Kathi", style: TextStyle(fontSize: 22, color: Colors.white)),
                                                  Text("Owner", style: TextStyle(fontSize: 18, color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
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
                        child: Card(
                          child: Padding(
                            padding: LH.hp(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Users",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  children: organization.users.where((u) => !u.roles.contains("PENDING")).map((user) => Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Card(
                                      color: Theme.of(context).colorScheme.background,
                                      // color: Theme.of(context).cardColor,
                                      child: InkWell(
                                        onTap: () {
                                          if (organization.users.firstWhere((element) => element.userID == currentUser.id).roles.contains("ADMIN")) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Theme.of(context).cardColor,
                                                surfaceTintColor: Theme.of(context).cardColor,
                                                content: EditOrganizationUserDialog(organizationID: organization.id, userID: user.userID),
                                              )
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.all(Radius.circular(512)),
                                                child: ExtendedImage.network(
                                                  user.user.profilePictureURL,
                                                  fit: BoxFit.cover,
                                                  width: 55,
                                                  height: 55,
                                                ),
                                              ),
                                              const Padding(padding: EdgeInsets.all(8)),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${user.user.firstName} ${user.user.lastName}", style: const TextStyle(fontSize: 22, color: Colors.white)),
                                                    Text(user.title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                ),
                                const Padding(padding: EdgeInsets.all(8)),
                                Visibility(
                                  visible: organization.users.where((u) => u.roles.contains("PENDING")).isNotEmpty,
                                  child: const Text(
                                    "Pending Users",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: organization.users.where((u) => u.roles.contains("PENDING")).map((user) => Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Card(
                                      color: Theme.of(context).colorScheme.background,
                                      // color: Theme.of(context).cardColor,
                                      child: InkWell(
                                        onTap: () {
                                          if (organization.users.firstWhere((element) => element.userID == currentUser.id).roles.contains("ADMIN")) {
                                            showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: Theme.of(context).cardColor,
                                                  surfaceTintColor: Theme.of(context).cardColor,
                                                  content: EditOrganizationUserDialog(organizationID: organization.id, userID: user.userID),
                                                )
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.all(Radius.circular(512)),
                                                child: ExtendedImage.network(
                                                  user.user.profilePictureURL,
                                                  fit: BoxFit.cover,
                                                  width: 55,
                                                  height: 55,
                                                ),
                                              ),
                                              const Padding(padding: EdgeInsets.all(8)),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${user.user.firstName} ${user.user.lastName}", style: const TextStyle(fontSize: 22, color: Colors.white)),
                                                    Text("Pending", style: const TextStyle(fontSize: 18, color: PEL_WARNING)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                )
                              ],
                            ),
                          ),
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
