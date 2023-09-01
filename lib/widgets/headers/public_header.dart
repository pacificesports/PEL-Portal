import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PublicHeader extends StatelessWidget {
  const PublicHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      height: 200,
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/images/pel_abbrev/abbrev-mono.svg",
            height: 100,
          )
        ],
      ),
    );
  }
}
