import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:pel_portal/models/verification.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/breadcrumbs/onboarding_breadcrumb.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VerificationOnboardingPage extends StatefulWidget {
  const VerificationOnboardingPage({super.key});

  @override
  State<VerificationOnboardingPage> createState() => _VerificationOnboardingPageState();
}

class _VerificationOnboardingPageState extends State<VerificationOnboardingPage> {

  bool emailVerificationLoading = false;
  Timer? emailVerificationTimer;

  bool enrollmentVerificationLoading = false;
  double enrollmentVerificationFileProgress = 0.0;
  String comments = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/onboarding/verification")) {
      checkEmailVerification();
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailVerificationTimer?.cancel();
  }

  void sendEmailVerification() {
    fb.FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
      AlertService.showSuccessSnackbar(context, "Verification email sent!");
      setState(() => emailVerificationLoading = true);
      emailVerificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        checkEmailVerification();
      });
    }).catchError((err) {
      AlertService.showErrorSnackbar(context, "Failed to send verification email!");
    });
  }

  void checkEmailVerification() {
    fb.FirebaseAuth.instance.currentUser!.reload().then((value) {
      if (fb.FirebaseAuth.instance.currentUser!.emailVerified) {
        AlertService.showSuccessSnackbar(context, "Email verified!");
        setState(() {
          currentUser.verification.isEmailVerified = true;
          emailVerificationLoading = false;
        });
        emailVerificationTimer?.cancel();
      }
    }).catchError((err) {
      AlertService.showErrorSnackbar(context, "Failed to check email verification!");
    });
  }

  Future<void> selectVerificationFile() async {
    Trace trace = FirebasePerformance.instance.newTrace("selectVerificationFile()");
    await trace.start();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpeg", "jpg", "png", "pdf"],
    );
    try {
      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.size > 2 * pow(10, 9)) {
          Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "File size must be less than 2GB!"));
          return;
        }
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = "${currentUser.id}-verification-${result.files.first.name}";
        FirebaseStorage.instance.ref("users/${currentUser.id}/verification/$fileName").putData(fileBytes!).snapshotEvents.listen((event) async {
          if (event.state == TaskState.success) {
            currentUser.verification.fileURL = await event.ref.getDownloadURL();
            setState(() {
              enrollmentVerificationFileProgress = 1.0;
            });
            Logger.info("[verification_onboarding_page] File uploaded successfully: ${currentUser.verification.fileURL}");
          } else {
            setState(() => enrollmentVerificationFileProgress = event.bytesTransferred / event.totalBytes);
          }
        });

      }
    } catch (err) {
      Logger.error("[verification_onboarding_page] Failed to upload file! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to upload file!"));
    }
    trace.stop();
  }

  Future<void> submitVerification() async {
    Trace trace = FirebasePerformance.instance.newTrace("submitVerification()");
    await trace.start();
    currentUser.verification.userID = currentUser.id;
    if (comments != "") {
      currentUser.verification.comments += "\n––––––\n${currentUser.firstName}: $comments";
    }
    currentUser.verification.status = "REQUESTED";
    if (currentUser.verification.fileURL == "") {
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "No file was uploaded. Please select a file and try again."));
      return;
    }
    setState(() => enrollmentVerificationLoading = true);
    try {
      await AuthService.getAuthToken();
      var response = await httpClient.post(Uri.parse("$API_HOST/users/${currentUser.id}/verification"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(currentUser.verification));
      if (response.statusCode == 200) {
        setState(() {
          currentUser.verification = Verification.fromJson(jsonDecode(response.body)["data"]);
        });
      } else {
        Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to submit verification!"));
      }
    } catch (err) {
      setState(() => enrollmentVerificationLoading = false);
      Logger.error("[verification_onboarding_page] Failed to submit verification! $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Failed to submit verification!"));
    }
    setState(() => enrollmentVerificationLoading = false);
    trace.stop();
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
                                  "Upload\nVerification",
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
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const Padding(padding: EdgeInsets.all(8)),
                                      Card(
                                        color: Theme.of(context).colorScheme.background,
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          title: Text("Email Verification (${currentUser.email})"),
                                          trailing: SizedBox(
                                            height: 50,
                                            child: !currentUser.verification.isEmailVerified && !emailVerificationLoading ? PELTextButton(
                                              text: "Verify",
                                              style: PELTextButtonStyle.filled,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                              onPressed: () {
                                                sendEmailVerification();
                                              },
                                            ) : emailVerificationLoading ? const RefreshProgressIndicator(
                                                backgroundColor: PEL_MAIN,
                                                color: Colors.white,
                                            ) : const Icon(Icons.check_circle_rounded, color: PEL_SUCCESS),
                                          )
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.all(8)),
                                      Visibility(
                                        visible: currentUser.verification.status == "" && enrollmentVerificationFileProgress == 0.0,
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Upload your proof of student enrollment.",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            const Padding(padding: EdgeInsets.all(8)),
                                            Card(
                                              color: Theme.of(context).colorScheme.background,
                                              child: InkWell(
                                                onTap: () {
                                                  selectVerificationFile();
                                                },
                                                child: SizedBox(
                                                  height: 200,
                                                  width: LH.cw(context) * 0.4,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.file_upload_outlined,
                                                      size: 48,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.all(8)),
                                            const Center(
                                              child: Text(
                                                "This should be a file that allows us to verify that you are a high school or college student and that you attend the school that you selected. This can be anything from a picure of your Student ID to a screenshot of your school portal. Any files you upload here are used solely for verification purposes and nothing else. You may upload a file in any of the supported formats (.png, .jpg, .jpeg, .pdf).",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            PELTextButton(
                                              text: "Check out the Verification FAQ for more information.",
                                              style: PELTextButtonStyle.text,
                                              onPressed: () {
                                                launchUrlString("https://support.pacificesports.org/what-is-a-proof-image");
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: enrollmentVerificationLoading,
                                        child: const Center(child: RefreshProgressIndicator(backgroundColor: PEL_MAIN, color: Colors.white)),
                                      ),
                                      Visibility(
                                        visible: currentUser.verification.status == "" && enrollmentVerificationFileProgress > 0.0,
                                        // visible: true,
                                        child: Column(
                                          children: [
                                            const Padding(padding: EdgeInsets.all(2)),
                                            Card(
                                              color: Theme.of(context).colorScheme.background,
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      title: Text("Enrollment Verification (${currentUser.school.school.name})"),
                                                      trailing: SizedBox(
                                                        height: 50,
                                                        child: currentUser.verification.isVerified ? const Icon(Icons.check_circle_rounded, color: PEL_SUCCESS) : null,
                                                      )
                                                  ),
                                                  Visibility(
                                                    visible: enrollmentVerificationFileProgress < 1,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16),
                                                      child: LinearProgressIndicator(
                                                        borderRadius: BorderRadius.circular(8),
                                                        minHeight: 10,
                                                        value: enrollmentVerificationFileProgress,
                                                        color: PEL_MAIN,
                                                        backgroundColor: Theme.of(context).cardColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: currentUser.verification.fileURL != "",
                                                    // visible: true,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              children: [
                                                                Card(
                                                                  child: ExtendedImage.network(
                                                                    currentUser.verification.fileURL,
                                                                    height: 300,
                                                                  ),
                                                                ),
                                                                PELTextButton(
                                                                  text: "Open in new tab",
                                                                  style: PELTextButtonStyle.text,
                                                                  onPressed: () {
                                                                    launchUrlString(currentUser.verification.fileURL);
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
                                                                      value: currentUser.verification.type,
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
                                                                          currentUser.verification.type = item!;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 16, right: 16),
                                                                  child: SizedBox(
                                                                    width: double.infinity,
                                                                    child: Text(currentUser.verification.comments, style: const TextStyle(fontSize: 16)),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: MaterialTextField(
                                                                    hint: "Enter any comments here.",
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
                                                                        text: "Cancel",
                                                                        style: PELTextButtonStyle.outlined,
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            currentUser.verification.type = "";
                                                                            currentUser.verification.fileURL = "";
                                                                            comments = "";
                                                                            enrollmentVerificationFileProgress = 0.0;
                                                                          });
                                                                        },
                                                                      ),
                                                                      const Padding(padding: EdgeInsets.all(4)),
                                                                      PELTextButton(
                                                                        text: "Submit",
                                                                        onPressed: () {
                                                                          submitVerification();
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
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: currentUser.verification.status != "",
                                        // visible: true,
                                        child: Column(
                                          children: [
                                            const Padding(padding: EdgeInsets.all(2)),
                                            Card(
                                              color: Theme.of(context).colorScheme.background,
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      title: Text("Enrollment Verification (${currentUser.school.school.name})"),
                                                      trailing: SizedBox(
                                                        height: 50,
                                                        child: currentUser.verification.isVerified ? const Icon(Icons.check_circle_rounded, color: PEL_SUCCESS) : currentUser.verification.status == "REQUESTED" ? const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text("Pending Verification", style: TextStyle(color: PEL_WARNING, fontSize: 16)),
                                                            Padding(padding: EdgeInsets.all(4)),
                                                            Icon(Icons.circle, color: PEL_WARNING)
                                                          ],
                                                        ) : const Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text("Verification Rejected", style: TextStyle(color: PEL_ERROR, fontSize: 16)),
                                                            Padding(padding: EdgeInsets.all(4)),
                                                            Icon(Icons.cancel_rounded, color: PEL_ERROR)
                                                          ],
                                                        )
                                                      )
                                                  ),
                                                  Visibility(
                                                    visible: currentUser.verification.fileURL != "",
                                                    // visible: true,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              children: [
                                                                Card(
                                                                  child: ExtendedImage.network(
                                                                    currentUser.verification.fileURL,
                                                                    height: 300,
                                                                  ),
                                                                ),
                                                                PELTextButton(
                                                                    text: "Open in new tab",
                                                                    style: PELTextButtonStyle.text,
                                                                    onPressed: () {
                                                                      launchUrlString(currentUser.verification.fileURL);
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
                                                                  trailing: Text(currentUser.verification.type, style: const TextStyle(fontSize: 16)),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 16, right: 16),
                                                                  child: SizedBox(
                                                                    width: double.infinity,
                                                                    child: Text(currentUser.verification.comments, style: const TextStyle(fontSize: 16)),
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  visible: currentUser.verification.status == "REJECTED",
                                                                  child: const Padding(
                                                                    padding: EdgeInsets.only(left: 16, top: 8, right: 16),
                                                                    child: SizedBox(
                                                                      width: double.infinity,
                                                                      child: Text(
                                                                        "It looks like your verification request was rejected. Check out our comments above and submit another file.",
                                                                        style: TextStyle(color: Colors.grey, fontSize: 16)
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  visible: currentUser.verification.status == "REJECTED",
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                                                                    child: PELTextButton(
                                                                      text: "Resubmit Verification",
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          currentUser.verification.status = "";
                                                                          currentUser.verification.type = "";
                                                                          currentUser.verification.fileURL = "";
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  visible: currentUser.verification.status == "ACCEPTED",
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                                                                    child: SizedBox(
                                                                      width: double.infinity,
                                                                      child: Column(
                                                                        children: [
                                                                          Center(
                                                                            child: Text(
                                                                                "Accepted on ${DateFormat().format(currentUser.verification.updatedAt.toLocal())}.",
                                                                                style: const TextStyle(color: PEL_SUCCESS, fontSize: 16)
                                                                            ),
                                                                          ),
                                                                          const Padding(padding: EdgeInsets.all(4)),
                                                                          const Text(
                                                                              "Congratulations, your verification request was accepted! You can now add connections and join teams.",
                                                                              style: TextStyle(color: Colors.grey, fontSize: 16)
                                                                          ),
                                                                        ],
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
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  PELTextButton(
                                    text: "Back",
                                    style: PELTextButtonStyle.outlined,
                                    onPressed: () {
                                      router.navigateTo(context, "/onboarding/school", transition: TransitionType.fadeIn);
                                    },
                                  ),
                                  const Padding(padding: EdgeInsets.all(4)),
                                  PELTextButton(
                                    text: "Next",
                                    style: currentUser.verification.isVerified ? PELTextButtonStyle.filled : PELTextButtonStyle.outlined,
                                    onPressed: () {
                                      router.navigateTo(context, "/onboarding/connections", transition: TransitionType.fadeIn);
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
