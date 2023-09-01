import 'package:flutter/material.dart';
import 'package:pel_portal/widgets/headers/public_header.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          PublicHeader(),
          Center(
            child: Text("Onboarding Page"),
          )
        ],
      ),
    );
  }
}
