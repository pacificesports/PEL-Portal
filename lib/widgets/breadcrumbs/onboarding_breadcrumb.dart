import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';

class OnboardingBreadcrumb extends StatefulWidget {
  const OnboardingBreadcrumb({super.key});

  @override
  State<OnboardingBreadcrumb> createState() => _OnboardingBreadcrumbState();
}

class _OnboardingBreadcrumbState extends State<OnboardingBreadcrumb> {

  String currentPage = "";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => getCurrentPage());
  }

  getCurrentPage() {
    String route = ModalRoute.of(context)!.settings.name!;
    setState(() {
      currentPage = route.split("/onboarding/")[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            color: currentPage == "school" ? PEL_MAIN : Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                router.navigateTo(context, "/onboarding/school", transition: TransitionType.fadeIn);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.white),
                    const Padding(padding: EdgeInsets.all(4)),
                    const Text("School", style: TextStyle(fontSize: 16, color: Colors.white)),
                    const Padding(padding: EdgeInsets.all(4)),
                    Visibility(
                      visible: currentUser.school.schoolID != "",
                      child: const Icon(Icons.check_circle_outline_rounded, color: PEL_SUCCESS)
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ),
          Card(
            color: currentPage == "verification" ? PEL_MAIN : Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                router.navigateTo(context, "/onboarding/verification", transition: TransitionType.fadeIn);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Colors.white),
                    const Padding(padding: EdgeInsets.all(4)),
                    const Text("Verification", style: TextStyle(fontSize: 16, color: Colors.white)),
                    const Padding(padding: EdgeInsets.all(4)),
                    Visibility(
                      visible: currentUser.verification.status != "",
                      child: Icon(
                        currentUser.verification.status == "REQUESTED" ? Icons.circle_outlined : currentUser.verification.status == "REJECTED" ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
                        color: currentUser.verification.status == "REQUESTED" ? PEL_WARNING : currentUser.verification.status == "REJECTED" ? PEL_ERROR : PEL_SUCCESS
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ),
          Card(
            color: currentPage == "connections" ? PEL_MAIN : Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                router.navigateTo(context, "/onboarding/connections", transition: TransitionType.fadeIn);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.sports_esports_rounded, color: Colors.white),
                    const Padding(padding: EdgeInsets.all(4)),
                    const Text("Connections", style: TextStyle(fontSize: 16, color: Colors.white)),
                    const Padding(padding: EdgeInsets.all(4)),
                    Visibility(
                        visible: currentUser.connections.length > 4,
                        child: const Icon(Icons.check_circle_outline_rounded, color: PEL_SUCCESS)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
