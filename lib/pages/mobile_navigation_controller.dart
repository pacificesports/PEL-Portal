import 'package:flutter/material.dart';
import 'package:pel_portal/pages/home/home_page_mobile.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MobileNavigationController extends StatefulWidget {
  const MobileNavigationController({super.key});

  @override
  State<MobileNavigationController> createState() => _MobileNavigationControllerState();
}

class _MobileNavigationControllerState extends State<MobileNavigationController> {

  int currentIndex = 0;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (AuthService.verifyUserSession(context, "/home")) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: const HomePageMobile(),
      bottomNavigationBar:  SalomonBottomBar(
        currentIndex: currentIndex,
        backgroundColor: Theme.of(context).cardColor,
        onTap: (i) => setState(() => currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: PEL_MAIN,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: PEL_MAIN,
          ),
        ],
      ),
    );
  }
}
