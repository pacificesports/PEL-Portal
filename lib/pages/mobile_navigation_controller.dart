import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';

class MobileNavigationController extends StatefulWidget {
  const MobileNavigationController({super.key});

  @override
  State<MobileNavigationController> createState() => _MobileNavigationControllerState();
}

class _MobileNavigationControllerState extends State<MobileNavigationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Welcome, ${currentUser.firstName}!"),
      ),
    );
  }
}
