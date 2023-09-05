import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:pel_portal/models/school.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/models/user_school.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/string_extension.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/breadcrumbs/onboarding_breadcrumb.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class SchoolOnboardingPage extends StatefulWidget {
  const SchoolOnboardingPage({super.key});

  @override
  State<SchoolOnboardingPage> createState() => _SchoolOnboardingPageState();
}

class _SchoolOnboardingPageState extends State<SchoolOnboardingPage> {

  List<School> schools = [];
  List<School> filteredSchools = [];
  School selectedSchool = School();

  int gradYear = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/onboarding/school")) {
      getSchools();
    }
  }

  Future<void> getSchools() async {
    Trace trace = FirebasePerformance.instance.newTrace("getSchools()");
    await trace.start();
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.get(Uri.parse("$API_HOST/schools"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"});
      setState(() {
        schools = List<School>.from(jsonDecode(response.body)["data"].map((x) => School.fromJson(x)));
        schools.sort((a, b) => a.name.compareTo(b.name));
        filteredSchools = schools;
      });
    } catch (err) {
      Logger.error("[school_onboarding_page] Failed to get schools! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to get schools!"));
    }
    trace.stop();
  }

  handleSearch(String input) {
    if (input.isNotEmpty) {
      setState(() {
        filteredSchools = extractTop(
          query: input,
          choices: schools,
          limit: 7,
          cutoff: 50,
          getter: (School s) => "${s.name} ${s.type} ${s.tags.join(" ")}",
        ).map((e) => e.choice).toList();
      });
    } else {
      setState(() {
        filteredSchools = schools;
      });
    }
  }

  Future<void> setSchool() async {
    if (selectedSchool.id != "" && gradYear != 0) {
      currentUser.school.userID = currentUser.id;
      currentUser.school = UserSchool();
      currentUser.school.schoolID = selectedSchool.id;
      currentUser.school.graduationYear = gradYear;
      try {
        var response = await httpClient.post(Uri.parse("$API_HOST/users/${currentUser.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(currentUser));
        if (response.statusCode == 200) {
          setState(() {
            currentUser = User.fromJson(jsonDecode(response.body)["data"]);
          });
        } else {
          Logger.error("[school_onboarding_page] Failed to set school! ${response.body}");
          Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to set school!"));
        }
      } catch (err) {
        Logger.error("[school_onboarding_page] Failed to set school! $err");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to set school!"));
      }
    } else {
      AlertService.showErrorSnackbar(context, "Please select a school and enter a valid graduation year!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: LH.p(context),
          width: LH.cw(context),
          child: Card(
              color: PEL_MAIN,
              child: SizedBox(
                height: LH.h(context) * 2/3,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        color: PEL_MAIN,
                        child: Container(
                          padding: LH.p(context),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Select\nSchool",
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Card(
                        child: Container(
                          height: double.infinity,
                          padding: LH.p(context),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                OnboardingBreadcrumb(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        color: Colors.greenAccent,
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              child: MaterialTextField(
                                                keyboardType: TextInputType.number,
                                                hint: "Search for your school",
                                                textInputAction: TextInputAction.next,
                                                prefixIcon: const Icon(Icons.search_rounded),
                                                onChanged: handleSearch
                                              ),
                                            ),
                                            Visibility(
                                              visible: schools.isEmpty,
                                              child: const Center(child: RefreshProgressIndicator(backgroundColor: PEL_MAIN, color: Colors.white,)),
                                            ),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: filteredSchools.length,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                  color: Theme.of(context).colorScheme.background,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedSchool = filteredSchools[index];
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius.all(Radius.circular(512)),
                                                            child: ExtendedImage.network(
                                                              filteredSchools[index].iconURL,
                                                              width: 45,
                                                              height: 45,
                                                            ),
                                                          ),
                                                          const Padding(padding: EdgeInsets.all(4)),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(filteredSchools[index].name, style: TextStyle(fontSize: 16)),
                                                                Text(filteredSchools[index].address, style: TextStyle(fontSize: 14, color: Colors.grey)),
                                                              ],
                                                            ),
                                                          ),
                                                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey)
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                );
                                              },
                                            ),
                                            Visibility(
                                              visible: filteredSchools.length < 3,
                                              child: Center(
                                                child: PELTextButton(
                                                  text: "Don't see your school?",
                                                  style: PELTextButtonStyle.text,
                                                  onPressed: () {

                                                  }
                                                )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: selectedSchool.id == "" ? 0 : 400,
                                      // color: Colors.redAccent,
                                      child: Column(
                                        children: [
                                          Card(
                                            color: Theme.of(context).colorScheme.background,
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
                                                          selectedSchool.bannerURL,
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
                                                                stops: [0, 1]
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
                                                                selectedSchool.iconURL,
                                                                width: 55,
                                                                height: 55,
                                                              ),
                                                            ),
                                                            const Padding(padding: EdgeInsets.all(4)),
                                                            Expanded(child: Text(selectedSchool.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(8),
                                                  // color: Colors.greenAccent,
                                                  child: Wrap(
                                                    alignment: WrapAlignment.start,
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.0),
                                                        child: Card(
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(selectedSchool.type.replaceAll("_", " ").capitalize(), style: const TextStyle(fontSize: 16)),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(2.0),
                                                        child: Card(
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(selectedSchool.address, style: const TextStyle(fontSize: 16)),
                                                          ),
                                                        ),
                                                      ),
                                                      Tooltip(
                                                        message: "Verified School",
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            AlertService.showInfoSnackbar(context, "This school has been verified by the PEL.");
                                                          },
                                                          child: Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Icon(Icons.verified_rounded, color: PEL_SUCCESS),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                                  // color: Colors.greenAccent,
                                                  child:  Text(selectedSchool.description, style: const TextStyle(fontSize: 16)),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: MaterialTextField(
                                              keyboardType: TextInputType.number,
                                              hint: 'Graduation Year',
                                              textInputAction: TextInputAction.next,
                                              prefixIcon: const Icon(Icons.school_outlined),
                                              onChanged: (value) {
                                                if (int.tryParse(value) != null) {
                                                  setState(() {
                                                    gradYear = int.parse(value);
                                                  });
                                                } else {
                                                  setState(() {
                                                    gradYear = 0;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}
