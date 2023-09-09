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
          height: 85,
          child: Center(
            child: Container(
              color: Theme.of(context).cardColor,
              width: LayoutHelper.getContentWidth(context),
              padding: EdgeInsets.symmetric(horizontal: LayoutHelper.getPaddingDouble(context)),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: ExtendedImage.network(
                              currentUser.profilePictureURL,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(color: PEL_MAIN, height: 0,)
      ],
    );
  }
}
