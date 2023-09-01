import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pel_portal/utils/layout.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/buttons/pel_text_button.dart';

class PublicHeader extends StatelessWidget {
  const PublicHeader({super.key});

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/images/pel_abbrev/abbrev-mono.svg",
                    height: 75,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PELTextButton(
                        text: "Login",
                        padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 14),
                        style: PELTextButtonStyle.outlined,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16,),
                      PELTextButton(
                        text: "Create Account",
                        padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 14),
                        style: PELTextButtonStyle.filled,
                        onPressed: () {},
                      ),
                    ],
                  )
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
