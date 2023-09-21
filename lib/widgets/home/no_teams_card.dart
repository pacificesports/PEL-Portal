import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class NoTeamsCard extends StatelessWidget {
  const NoTeamsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LH.cw(context),
      padding: LH.hp(context),
      child: Card(
        child: Container(
          padding: LH.p(context),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.group_rounded,
                  size: 64,
                  color: PEL_MAIN,
                ),
                Padding(
                  padding: EdgeInsets.only(top: LH.hpd(context)),
                  child: const Text(
                    "You're not on any teams yet!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: LH.hpd(context)),
                  child: const Text(
                    "Create your first team below, or browse existing teams to join.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: LH.pd(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PELTextButton(
                        text: "Create Team",
                        onPressed: () {
                          router.navigateTo(context, "/teams/new", transition: TransitionType.fadeIn);
                        },
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      PELTextButton(
                        text: "Join an existing team",
                        style: PELTextButtonStyle.text,
                        onPressed: () {
                          router.navigateTo(context, "/teams", transition: TransitionType.fadeIn);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
