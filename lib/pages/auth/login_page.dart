import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:pel_portal/utils/alert_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/logger.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String email = "";
  String password = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
  }

  Future<void> login() async {
    setState(() {loading = true;});
    try {
      var authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (authResult.user != null) {
        Logger.info("[login_page] Successfully logged in as ${authResult.user!.uid}.");
        Future.delayed(Duration.zero, () => AlertService.showSuccessSnackbar(context, "Successfully logged in!"));
        Future.delayed(Duration.zero, () => router.navigateTo(context, "/auth/check", clearStack: true, replace: true, transition: TransitionType.fadeIn));
      }
    } catch (err) {
      Logger.error("[login_page] Error occurred while logging in. $err");
      Future.delayed(Duration.zero, () => AlertService.showErrorSnackbar(context, "Error occurred while trying to log you in. $err"));
    }
    setState(() {loading = false;});
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
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontFamily: "Helvetica",
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                const Text("Welcome back!", style: TextStyle(fontSize: 18)),
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
                                Padding(padding: LH.p(context)),
                                Visibility(
                                  visible: loading,
                                  child: const Center(child: RefreshProgressIndicator(backgroundColor: PEL_MAIN, color: Colors.white,)),
                                ),
                                Visibility(
                                  visible: !loading,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: PELTextButton(
                                      text: "Login",
                                      onPressed: () {
                                        login();
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
                                      const Text("Don't have an account?", style: TextStyle(fontSize: 16, color: Colors.grey)),
                                      const Padding(padding: EdgeInsets.all(4)),
                                      PELTextButton(
                                        text: "Create Account",
                                        style: PELTextButtonStyle.text,
                                        onPressed: () {
                                          router.navigateTo(context, "/auth/register", transition: TransitionType.fadeIn);
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
