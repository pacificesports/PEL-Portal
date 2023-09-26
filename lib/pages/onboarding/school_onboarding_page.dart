import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:pel_portal/models/school.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/models/user_school.dart';
import 'package:pel_portal/models/verification.dart';
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
  TextEditingController gradYearController = TextEditingController();

  bool creatingSchool = false;
  String schoolName = "";
  String schoolAddress = "";
  String schoolWebsite = "";
  String schoolType = "";

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
      checkExistingSchool();
      getSchools();
    }
  }

  void checkExistingSchool() {
    if (currentUser.school.schoolID != "") {
      setState(() {
        selectedSchool = currentUser.school.school;
      });
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
      currentUser.school = UserSchool();
      currentUser.school.userID = currentUser.id;
      currentUser.school.schoolID = selectedSchool.id;
      currentUser.school.graduationYear = gradYear;
      try {
        await AuthService.getAuthToken();
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

  Future<void> resetSchool() async {
    currentUser.school = UserSchool();
    currentUser.verification = Verification();
    currentUser.school.userID = currentUser.id;
    currentUser.verification.userID = currentUser.id;
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/users/${currentUser.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(currentUser));
      if (response.statusCode == 200) {
        setState(() {
          currentUser = User.fromJson(jsonDecode(response.body)["data"]);
        });
      } else {
        Logger.error("[school_onboarding_page] Failed to reset school! ${response.body}");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to reset school!"));
      }
    } catch (err) {
      Logger.error("[school_onboarding_page] Failed to set school! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to reset school!"));
    }
  }

  Future<void> createSchool() async {
    if (schoolName != "" && schoolType != "" && schoolAddress != "" && schoolWebsite != "") {
      School school = School();
      school.id = await FirebaseFirestore.instance.collection("gen-id").add({"school_name": schoolName}).then((value) => value.id);
      school.name = schoolName;
      school.type = schoolType;
      school.address = schoolAddress;
      school.website = schoolWebsite;
      try {
        await AuthService.getAuthToken();
        var response = await httpClient.post(Uri.parse("$API_HOST/schools/${school.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(school));
        if (response.statusCode == 200) {
          setState(() {
            selectedSchool = School.fromJson(jsonDecode(response.body)["data"]);
            creatingSchool = false;
            gradYear = 0;
            gradYearController.clear();
            schoolName = "";
            schoolAddress = "";
            schoolWebsite = "";
            schoolType = "";
          });
          getSchools();
        } else {
          Logger.error("[school_onboarding_page] Failed to create school! ${response.body}");
          Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to create school!"));
        }
      } catch (err) {
        Logger.error("[school_onboarding_page] Failed to create school! $err");
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to create school!"));
      }
    } else {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Make sure all fields are filled out."));
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
                          child: Column(
                            children: [
                              const OnboardingBreadcrumb(),
                              const Padding(padding: EdgeInsets.all(8)),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(4),
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
                                                        if (currentUser.school.schoolID == "") {
                                                          setState(() {
                                                            selectedSchool = filteredSchools[index];
                                                            creatingSchool = false;
                                                          });
                                                        } else {
                                                          CoolAlert.show(
                                                            context: context,
                                                            type: CoolAlertType.warning,
                                                            title: "Change School?",
                                                            text: "Are you sure you want to change your school? You will need to re-verify your student status.",
                                                            confirmBtnColor: PEL_MAIN,
                                                            width: 400,
                                                            onConfirmBtnTap: () {
                                                              setState(() {
                                                                resetSchool();
                                                                selectedSchool = filteredSchools[index];
                                                                creatingSchool = false;
                                                              });
                                                            },
                                                          );
                                                        }
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
                                                                  Text(filteredSchools[index].name, style: const TextStyle(fontSize: 16)),
                                                                  Text(filteredSchools[index].address, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                                                ],
                                                              ),
                                                            ),
                                                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey)
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  );
                                                },
                                              ),
                                              Visibility(
                                                visible: filteredSchools.length < 10 && !creatingSchool && currentUser.school.schoolID == "",
                                                child: Center(
                                                  child: PELTextButton(
                                                    text: "Don't see your school?",
                                                    style: PELTextButtonStyle.text,
                                                    onPressed: () {
                                                      setState(() {
                                                        selectedSchool = School();
                                                        creatingSchool = true;
                                                      });
                                                    }
                                                  )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: selectedSchool.id == "" ? 0 : 400,
                                        child: Visibility(
                                          visible: selectedSchool.id != "",
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
                                                      padding: const EdgeInsets.all(8),
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
                                                          Visibility(
                                                            visible: selectedSchool.verified,
                                                            child: Tooltip(
                                                              message: "Verified School",
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  AlertService.showInfoSnackbar(context, "This school has been verified by PEL.");
                                                                },
                                                                child: const Padding(
                                                                  padding: EdgeInsets.all(8.0),
                                                                  child: Icon(Icons.verified_rounded, color: PEL_SUCCESS),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                                      child:  Text(selectedSchool.description, style: const TextStyle(fontSize: 16)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: currentUser.school.schoolID == "",
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 4, right: 4, top: 16),
                                                  child: MaterialTextField(
                                                    keyboardType: TextInputType.number,
                                                    hint: 'Graduation Year',
                                                    prefixIcon: const Icon(Icons.school_outlined),
                                                    controller: gradYearController,
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
                                              ),
                                              Visibility(
                                                visible: currentUser.school.schoolID != "",
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 4, right: 4, top: 16),
                                                  child: Card(
                                                    color: Theme.of(context).colorScheme.background,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.school_outlined, color: PEL_MAIN),
                                                          const Padding(padding: EdgeInsets.all(8)),
                                                          Text("Graduating ${currentUser.school.graduationYear}", style: const TextStyle(fontSize: 16)),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ),
                                              ),
                                              Visibility(
                                                visible: currentUser.school.schoolID == "",
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: 4, right: 4, top: 16),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      PELTextButton(
                                                        text: "Cancel",
                                                        style: PELTextButtonStyle.outlined,
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedSchool = School();
                                                            gradYear = 0;
                                                          });
                                                          gradYearController.clear();
                                                        },
                                                      ),
                                                      const Padding(padding: EdgeInsets.all(4)),
                                                      PELTextButton(
                                                        text: "Select School",
                                                        onPressed: () {
                                                          setSchool();
                                                        },
                                                      )
                                                    ],
                                                  )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: creatingSchool ? 400 : 0,
                                        child: Visibility(
                                          visible: creatingSchool,
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
                                                                    selectedSchool.iconURL,
                                                                    width: 55,
                                                                    height: 55,
                                                                  ),
                                                                ),
                                                                const Padding(padding: EdgeInsets.all(4)),
                                                                Expanded(
                                                                  child: MaterialTextField(
                                                                    keyboardType: TextInputType.name,
                                                                    hint: "School Name",
                                                                    prefixIcon: const Icon(Icons.school_outlined),
                                                                    theme: FilledOrOutlinedTextTheme(
                                                                      radius: 8,
                                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                                      fillColor: Theme.of(context).cardColor,
                                                                      prefixIconColor: PEL_MAIN,
                                                                    ),
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        schoolName = value;
                                                                      });
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                                      child:  MaterialTextField(
                                                        keyboardType: TextInputType.url,
                                                        hint: "School City, State",
                                                        prefixIcon: const Icon(Icons.location_on_outlined),
                                                        theme: FilledOrOutlinedTextTheme(
                                                          radius: 8,
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          fillColor: Theme.of(context).cardColor,
                                                          prefixIconColor: PEL_MAIN,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            schoolAddress = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                                      child:  MaterialTextField(
                                                        keyboardType: TextInputType.url,
                                                        hint: "School Website",
                                                        prefixIcon: const Icon(Icons.link_rounded),
                                                        theme: FilledOrOutlinedTextTheme(
                                                          radius: 8,
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          fillColor: Theme.of(context).cardColor,
                                                          prefixIconColor: PEL_MAIN,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            schoolWebsite = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                                      child:  Card(
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: PELTextButton(
                                                                text: "High School",
                                                                color: schoolType == "HIGH_SCHOOL" ? PEL_MAIN : Theme.of(context).cardColor,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    schoolType = "HIGH_SCHOOL";
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: PELTextButton(
                                                                text: "College",
                                                                color: schoolType == "COLLEGE" ? PEL_MAIN : Theme.of(context).cardColor,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    schoolType = "COLLEGE";
                                                                  });
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  padding: const EdgeInsets.only(left: 4, right: 4, top: 16),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      PELTextButton(
                                                        text: "Cancel",
                                                        style: PELTextButtonStyle.outlined,
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedSchool = School();
                                                            gradYear = 0;
                                                            creatingSchool = false;
                                                            schoolName = "";
                                                            schoolAddress = "";
                                                            schoolWebsite = "";
                                                            schoolType = "";
                                                          });
                                                        },
                                                      ),
                                                      const Padding(padding: EdgeInsets.all(4)),
                                                      PELTextButton(
                                                        text: "Select School",
                                                        onPressed: () {
                                                          createSchool();
                                                        },
                                                      )
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // PELTextButton(
                                  //   text: "Back",
                                  //   style: PELTextButtonStyle.outlined,
                                  //   onPressed: () {
                                  //   },
                                  // ),
                                  const Padding(padding: EdgeInsets.all(4)),
                                  PELTextButton(
                                    text: "Next",
                                    style: currentUser.school.schoolID == "" ? PELTextButtonStyle.outlined : PELTextButtonStyle.filled,
                                    onPressed: () {
                                      router.navigateTo(context, "/onboarding/verification", transition: TransitionType.fadeIn);
                                    },
                                  )
                                ],
                              )
                            ],
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
