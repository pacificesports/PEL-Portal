import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class PortalHeader extends StatefulWidget {
  const PortalHeader({super.key});

  @override
  State<PortalHeader> createState() => _PortalHeaderState();
}

class _PortalHeaderState extends State<PortalHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          width: LayoutHelper.width(context),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          height: 85,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/pel_abbrev/abbrev-mono.svg",
                height: 75,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome, ${currentUser.firstName}!",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton(
                        tooltip: "",
                        offset: const Offset(0, 60),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              onTap: () {
                                Future.delayed(Duration.zero, () => router.navigateTo(context, "/profile", transition: TransitionType.fadeIn));
                              },
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 35,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: ExtendedImage.network(
                                              currentUser.profilePictureURL,
                                              height: 35,
                                              width: 35,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const Padding(padding: EdgeInsets.only(right: 16)),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${currentUser.firstName} ${currentUser.lastName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text("@${currentUser.getConnection("discord_username").connection}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                Future.delayed(Duration.zero, () => router.navigateTo(context, "/settings", transition: TransitionType.fadeIn));
                              },
                              child: const SizedBox(
                                width: 200,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: Icon(Icons.settings_outlined, color: PEL_MAIN)
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 16)),
                                    Text("Account Settings", style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () async {
                                await AuthService.signOut();
                                Future.delayed(Duration.zero, () => router.navigateTo(context, "/auth/check", clearStack: true, replace: true, transition: TransitionType.fadeIn));
                              },
                              child: const SizedBox(
                                width: 200,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 35,
                                        child: Icon(Icons.logout_rounded, color: PEL_MAIN)
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 16)),
                                    Text("Sign out", style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            )
                          ];
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: ExtendedImage.network(
                            currentUser.profilePictureURL,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
        const Divider(color: PEL_MAIN, height: 0,)
      ],
    );
  }
}
