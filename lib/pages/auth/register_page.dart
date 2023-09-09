import 'dart:convert';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:pel_portal/models/connection.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String firstName = "";
  String lastName = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

  String discordCode = "";
  String discordToken = "";
  String discordRefreshToken = "";
  String discordID = "";
  String discordUsername = "";
  String discordProfilePicture = "";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
    Future.delayed(Duration.zero, () => checkDiscordToken());
  }

  Future<void> checkDiscordToken() async {
    String route = ModalRoute.of(context)!.settings.name!;
    if (route.contains("?code=")) {
      String state = route.split("&state=")[1];
      // base64 decode state
      String decodedState = utf8.decode(base64.decode(state));
      var stateJson = jsonDecode(decodedState);
      firstName = stateJson["firstName"];
      firstNameController.text = firstName;
      lastName = stateJson["lastName"];
      lastNameController.text = lastName;
      email = stateJson["email"];
      emailController.text = email;
      password = stateJson["password"];
      passwordController.text = password;
      confirmPassword = stateJson["password"];
      confirmPasswordController.text = confirmPassword;

      setState(() {
        discordCode = route.split("?code=")[1].split("&state=")[0];
      });
      try {
        var oauthResponse = await httpClient.post(Uri.parse("https://discord.com/api/v10/oauth2/token"), headers: {"Content-Type": "application/x-www-form-urlencoded"}, body: {
          "client_id": DISCORD_CLIENT_ID,
          "client_secret": DISCORD_CLIENT_SECRET,
          "grant_type": 'authorization_code',
          "code": discordCode,
          "redirect_uri": DISCORD_REDIRECT_URI
        });
        if (oauthResponse.statusCode != 200) {
          Logger.error("Error occurred while connecting Discord. ${oauthResponse.body}");
          Future.delayed(Duration.zero, () {
            AlertService.showErrorSnackbar(context, "Error occured while connecting Discord. ${oauthResponse.body}");
          });
          return;
        }
        var responseJson = jsonDecode(oauthResponse.body);
        setState(() {
          discordToken = responseJson["access_token"];
          discordRefreshToken = responseJson["refresh_token"];
        });
        var discordResponse = await httpClient.get(Uri.parse("https://discord.com/api/v10/users/@me"), headers: {"Authorization": "Bearer $discordToken"});
        if (discordResponse.statusCode != 200) {
          Logger.error("Error occurred while connecting Discord. ${discordResponse.body}");
          Future.delayed(Duration.zero, () {
            AlertService.showErrorSnackbar(context, "Error occured while connecting Discord. ${discordResponse.body}");
          });
          setState(() {
            discordCode = "";
            discordID = "";
          });
          return;
        }
        var discordJson = jsonDecode(discordResponse.body);
        setState(() {
          discordID = discordJson["id"];
          discordUsername = discordJson["username"];
          discordProfilePicture = "https://cdn.discordapp.com/avatars/$discordID/${discordJson["avatar"]}.png";
        });
      } catch (err) {
        Logger.error("Error occured while connecting Discord. $err");
        Future.delayed(Duration.zero, () {
          AlertService.showErrorSnackbar(context, "Error occured while connecting Discord. $err");
        });
        setState(() {
          discordCode = "";
          discordID = "";
        });
      }
    }
  }

  void connectDiscord() {
    if (firstName == "" || lastName == "" || email == "" || password == "" || confirmPassword == "") {
      AlertService.showErrorSnackbar(context, "Please fill out all fields.");
      return;
    }
    if (password != confirmPassword) {
      AlertService.showErrorSnackbar(context, "Passwords do not match.");
      return;
    }
    String state = base64.encode(utf8.encode(jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password
    })));
    String discordOauthURL = "https://discord.com/oauth2/authorize?response_type=code&client_id=$DISCORD_CLIENT_ID&redirect_uri=$DISCORD_REDIRECT_URI&state=$state&scope=identify%20email";
    launchUrlString(discordOauthURL);
  }

  Future<void> createAccount() async {
    if (firstName == "" || lastName == "" || email == "" || password == "" || confirmPassword == "") {
      AlertService.showErrorSnackbar(context, "Please fill out all fields.");
      return;
    }
    if (password != confirmPassword) {
      AlertService.showErrorSnackbar(context, "Passwords do not match.");
      return;
    }
    setState(() {loading = true;});
    try {
     var loginResponse = await httpClient.post(Uri.parse("$API_HOST/auth/login/$discordID"), headers: {"PEL-API-KEY": PEL_API_KEY});
     if (loginResponse.statusCode != 200) {
       setState(() {loading = false;});
       Logger.error("[register_page] Error occurred while creating account. ${loginResponse.body}");
       Future.delayed(Duration.zero, () {
         AlertService.showErrorSnackbar(context, "Error occurred while creating account. ${loginResponse.body}");
       });
       return;
     }
      var loginJson = jsonDecode(loginResponse.body);
      var loginToken = loginJson["data"]["token"];
      var authResult = await fb.FirebaseAuth.instance.signInWithCustomToken(loginToken);
      Logger.info("Successfully logged in as ${authResult.user!.uid}.");
      fb.AuthCredential emailCredential = fb.EmailAuthProvider.credential(email: email, password: password);
      try {
        await authResult.user!.linkWithCredential(emailCredential);
      } on fb.FirebaseAuthException catch (err) {
        if (err.code == "provider-already-linked") {
          await authResult.user!.unlink(emailCredential.providerId);
          await authResult.user!.linkWithCredential(emailCredential);
        } else {
          setState(() {loading = false;});
          Logger.error("[register_page] Error occured while creating account. $err");
          Future.delayed(Duration.zero, () {
            AlertService.showErrorSnackbar(context, "Error occured while creating account. $err");
          });
        }
      }
      Logger.info("Successfully linked email $email to ${authResult.user!.uid}.");

      User registerUser = User();
      registerUser.id = authResult.user!.uid;
      registerUser.firstName = firstName;
      registerUser.lastName = lastName;
      registerUser.email = email;
      registerUser.profilePictureURL = discordProfilePicture;
      registerUser.privacy.userID = authResult.user!.uid;
      registerUser.connections.add(Connection.fromJson({
        "user_id": authResult.user!.uid,
        "key": "discord_id",
        "name": "Discord ID",
        "connection": discordID,
        "created_at": DateTime.now().toUtc().toIso8601String(),
      }));
      registerUser.connections.add(Connection.fromJson({
        "user_id": authResult.user!.uid,
        "key": "discord_username",
        "name": "Discord Username",
        "connection": discordUsername,
        "created_at": DateTime.now().toUtc().toIso8601String(),
      }));
      registerUser.connections.add(Connection.fromJson({
        "user_id": authResult.user!.uid,
        "key": "discord_auth_token",
        "name": "Discord Auth Token",
        "connection": discordToken,
        "created_at": DateTime.now().toUtc().toIso8601String(),
      }));
      registerUser.connections.add(Connection.fromJson({
        "user_id": authResult.user!.uid,
        "key": "discord_refresh_token",
        "name": "Discord Refresh Token",
        "connection": discordRefreshToken,
        "created_at": DateTime.now().toUtc().toIso8601String(),
      }));

      await AuthService.getAuthToken();
      var createdUser = await httpClient.post(Uri.parse("$API_HOST/users/${registerUser.id}"), headers: {"PEL-API-KEY": PEL_API_KEY, "Authorization": "Bearer $PEL_AUTH_TOKEN"}, body: jsonEncode(registerUser));
      if (createdUser.statusCode != 200) {
        setState(() {loading = false;});
        Logger.error("[register_page] Error occured while creating account. ${createdUser.body}");
        Future.delayed(Duration.zero, () {
          AlertService.showErrorSnackbar(context, "Error occured while creating account. ${createdUser.body}");
        });
        return;
      } else {
        setState(() {loading = false;});
        Logger.info("[register_page] Account created successfully!");
        Future.delayed(Duration.zero, () {
          AlertService.showSuccessSnackbar(context, "Account created successfully!");
          router.navigateTo(context, "/auth/check", clearStack: true, replace: true, transition: TransitionType.fadeIn);
        });
      }
    } catch (err) {
      setState(() {loading = false;});
      Logger.error("[register_page] Error occured while creating account. $err");
      Future.delayed(Duration.zero, () {
        AlertService.showErrorSnackbar(context, "Error occured while creating account. $err");
      });
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
                    child: Card(
                      color: PEL_MAIN,
                      child: Container(
                        padding: LH.p(context),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Through esports,\nwe excel.",
                              style: TextStyle(
                                fontSize: 64,
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
                    child: Card(
                      child: Container(
                        height: double.infinity,
                        padding: LH.p(context),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: "Helvetica",
                                    fontWeight: FontWeight.bold,
                                  )
                              ),
                              const Text("Start your journey today.", style: TextStyle(fontSize: 18)),
                              const Padding(padding: EdgeInsets.all(8)),
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialTextField(
                                      keyboardType: TextInputType.name,
                                      hint: "First Name",
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: const Icon(Icons.person_outline_rounded),
                                      controller: firstNameController,
                                      onChanged: (value) {
                                        firstName = value;
                                      },
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.all(8)),
                                  Expanded(
                                    child: MaterialTextField(
                                      keyboardType: TextInputType.name,
                                      hint: "Last Name",
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: const Icon(Icons.person_outline_rounded),
                                      controller: lastNameController,
                                      onChanged: (value) {
                                        lastName = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              MaterialTextField(
                                keyboardType: TextInputType.emailAddress,
                                hint: 'Email',
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.mail_outline_rounded),
                                controller: emailController,
                                onChanged: (value) {
                                  email = value;
                                },
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              MaterialTextField(
                                keyboardType: TextInputType.text,
                                hint: 'Password',
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                controller: passwordController,
                                onChanged: (value) {
                                  password = value;
                                },
                              ),
                              const Padding(padding: EdgeInsets.all(8)),
                              MaterialTextField(
                                keyboardType: TextInputType.text,
                                hint: 'Password',
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                controller: confirmPasswordController,
                                onChanged: (value) {
                                  confirmPassword = value;
                                },
                              ),
                              Padding(padding: LH.p(context)),
                              Visibility(
                                visible: discordID != "",
                                child: Column(
                                  children: [
                                    Card(
                                      color: Theme.of(context).colorScheme.background,
                                      child: Container(
                                        padding: LH.hp(context),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(512),
                                              child: ExtendedImage.network(
                                                discordProfilePicture,
                                                height: 65,
                                                width: 65,
                                              ),
                                            ),
                                            const Padding(padding: EdgeInsets.all(8)),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Text("Discord ID:", style: TextStyle(fontSize: 18)),
                                                      const Padding(padding: EdgeInsets.all(2)),
                                                      Text(discordID, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                                      const Padding(padding: EdgeInsets.all(2)),
                                                      const Icon(Icons.check_circle_outline_rounded, color: PEL_SUCCESS)
                                                    ],
                                                  ),
                                                  const Padding(padding: EdgeInsets.all(4)),
                                                  Row(
                                                    children: [
                                                      const Text("Discord Username:", style: TextStyle(fontSize: 18)),
                                                      const Padding(padding: EdgeInsets.all(2)),
                                                      Text("@$discordUsername", style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                                      const Padding(padding: EdgeInsets.all(2)),
                                                      const Icon(Icons.check_circle_outline_rounded, color: PEL_SUCCESS)
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      )
                                    ),
                                    const Padding(padding: EdgeInsets.all(8)),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: (discordCode != "" && discordID == "") || loading,
                                child: const Center(child: RefreshProgressIndicator(backgroundColor: PEL_MAIN, color: Colors.white,)),
                              ),
                              Visibility(
                                visible: discordCode == "",
                                child: SizedBox(
                                  width: double.infinity,
                                  child: PELTextButton(
                                    text: "Connect Discord",
                                    onPressed: () {
                                      connectDiscord();
                                    },
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: discordID != "" && !loading,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: PELTextButton(
                                    text: "Create Account",
                                    onPressed: () {
                                      createAccount();
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: LH.hp(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Already have an account?", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                    const Padding(padding: EdgeInsets.all(4)),
                                    PELTextButton(
                                      text: "Login",
                                      style: PELTextButtonStyle.text,
                                      onPressed: () {
                                        router.navigateTo(context, "/auth/login", transition: TransitionType.fadeIn);
                                      },
                                    ),
                                  ],
                                ),
                              ),
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
