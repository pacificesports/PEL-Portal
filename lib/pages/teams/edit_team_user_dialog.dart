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
    } else if (user.roles.contains("MANAGER") && users.where((element) => element.roles.contains("MANAGER")).length > 1) {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Team can only have one manager! Please remove the manager role from another user first."));
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

  Future<void> removeUser() async {
    if (users.length == 1) {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "There is only one member in this team, please delete the team instead!"));
      return;
    }
    setState(() => loading = true);
    await AuthService.getAuthToken();
    var response = await httpClient.delete(Uri.parse("$API_HOST/teams/${widget.teamID}/users/${user.userID}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
    if (response.statusCode == 200) {
      Future.delayed(Duration.zero, () => router.pop(context));
      Future.delayed(Duration.zero, () => router.navigateTo(context, "/teams/${widget.teamID}", transition: TransitionType.fadeIn));
    } else {
      Logger.error("[edit_team_user_dialog] Failed to remove user! ${response.statusCode} ${response.body}");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to remove user!"));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: user.userID != "" ? Container(
            width: 500,
            height: 600,
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Editing ${user.user.firstName} ${user.user.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: PEL_MAIN)),
                const Padding(padding: EdgeInsets.all(8)),
                const Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                const Text("A title is a public-facing name to represent a user's role on the team. This can be anything you want (e.g. Coach, Jungler, Head of Eco-Round Strategies)!", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                const Text("Roles are internal tags used to give users access to various parts of the team.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const Padding(padding: EdgeInsets.all(4)),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
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
                  ),
                ),
                const Padding(padding: EdgeInsets.all(8)),
                !loading ? Row(
                  children: [
                    Expanded(
                      child: PELTextButton(
                        text: "Save",
                        onPressed: () {
                          saveUser();
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                    Expanded(
                      child: PELTextButton(
                        text: "Remove User",
                        style: PELTextButtonStyle.filled,
                        color: Colors.redAccent,
                        onPressed: () {
                          Future.delayed(Duration.zero, () => AlertService.showConfirmationDialog(context, "Remove User?", "Are you sure you want to remove this user? This action cannot be undone!", () => removeUser()));
                        },
                      )
                    )
                  ],
                ) : const Center(
                  child: RefreshProgressIndicator(
                    backgroundColor: PEL_MAIN,
                    color: Colors.white,
                  ),
                ),
              ],
            )
        ) : const SizedBox(
          width: 500,
          height: 600,
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
