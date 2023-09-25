import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class NoTournamentsCard extends StatelessWidget {
  const NoTournamentsCard({super.key});

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
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: PEL_MAIN,
                ),
                Padding(
                  padding: EdgeInsets.only(top: LH.hpd(context)),
                  child: const Text(
                    "You're not registered for any tournaments yet!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: LH.hpd(context)),
                  child: const Text(
                    "Browse tournaments to register for below.",
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
                        text: "Register for a tournament",
                        style: PELTextButtonStyle.outlined,
                        onPressed: () {
                          router.navigateTo(context, "/tournaments", transition: TransitionType.fadeIn);
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
