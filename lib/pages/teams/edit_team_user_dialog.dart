import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class EditTeamUserDialog extends StatefulWidget {
  final String teamID;
  final String userID;
  const EditTeamUserDialog({super.key, required this.teamID, required this.userID});

  @override
  State<EditTeamUserDialog> createState() => _EditTeamUserDialogState();
}

class _EditTeamUserDialogState extends State<EditTeamUserDialog> {

  List<TeamUser> users = [];
  TeamUser user = TeamUser();

  TextEditingController titleController = TextEditingController();
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
    getUsers();
  }

  Future<void> getUsers() async {
    await AuthService.getAuthToken();
    var response = await httpClient.get(Uri.parse("$API_HOST/teams/${widget.teamID}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body)["data"].map<TeamUser>((e) => TeamUser.fromJson(e)).toList();
        user = users.firstWhere((element) => element.userID == widget.userID);
        titleController.text = user.title;
      });
    }
  }

  Future<void> saveUser() async {
    if (user.roles.isEmpty) {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Please select at least one role!"));
      return;
    } else if (user.userID == currentUser.id && !user.roles.contains("ADMIN") && users.where((element) => element.roles.contains("ADMIN")).isEmpty) {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "You cannot remove your own admin role before assigning at least one other user as an admin."));
      return;
    }
    setState(() => loading = true);
    await AuthService.getAuthToken();
    var response = await httpClient.post(Uri.parse("$API_HOST/teams/${widget.teamID}/users"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(user));
    if (response.statusCode == 200) {
      var response = await httpClient.post(Uri.parse("$API_HOST/teams/${widget.teamID}/users/${user.userID}/roles"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(user.roles));
      if (response.statusCode == 200) {
        Future.delayed(Duration.zero, () => router.pop(context));
        Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams/${widget.teamID}", transition: TransitionType.fadeIn));
      } else {
        Logger.error("[edit_team_user_dialog] Failed to save user roles! ${response.statusCode} ${response.body}");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to save user!"));
      }
    } else {
      Logger.error("[edit_team_user_dialog] Failed to save user roles! ${response.statusCode} ${response.body}");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to save user!"));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: user.userID != "" ? Container(
            width: 400,
            height: 400,
            padding: const EdgeInsets.only(top: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${user.user.firstName} ${user.user.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: PEL_MAIN)),
                  const Padding(padding: EdgeInsets.all(8)),
                  const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                  const Padding(padding: EdgeInsets.all(4)),
                  MaterialTextField(
                    keyboardType: TextInputType.name,
                    hint: "Title",
                    textInputAction: TextInputAction.done,
                    controller: titleController,
                    prefixIcon: const Icon(Icons.badge_rounded),
                    onChanged: (value) {
                      setState(() {
                        user.title = value;
                      });
                    },
                  ),
                  const Padding(padding: EdgeInsets.all(8)),
                  const Text("Roles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                  const Padding(padding: EdgeInsets.all(4)),
                  Column(
                    children: teamRoles.keys.map((role) => Card(
                      color: Theme.of(context).colorScheme.background,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: user.roles.contains(role),
                              onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    if (role == "PENDING") {
                                      user.roles.clear();
                                    } else {
                                      user.roles.remove("PENDING");
                                    }
                                    user.roles.add(role);
                                  } else {
                                    user.roles.remove(role);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(role, style: const TextStyle(fontSize: 16)),
                                  Text(teamRoles[role]!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                  const Padding(padding: EdgeInsets.all(8)),
                  Row(
                    children: [
                      Expanded(
                        child: !loading ? PELTextButton(
                          text: "Save",
                          onPressed: () {
                            saveUser();
                          },
                        ) : const Center(
                          child: RefreshProgressIndicator(
                            backgroundColor: PEL_MAIN,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
        ) : const SizedBox(
          width: 400,
          height: 400,
          child: Center(
            child: RefreshProgressIndicator(
              backgroundColor: PEL_MAIN,
              color: Colors.white,
            ),
          ),
        )
    );
  }
}
