import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/theme.dart';

enum PELTextButtonStyle {
  text,
  filled,
  outlined,
}

class PELTextButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  final Color textColor;
  final PELTextButtonStyle style;
  final EdgeInsetsGeometry? padding;
  final bool disabled;

  const PELTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = PEL_MAIN,
    this.textColor = Colors.white,
    this.style = PELTextButtonStyle.filled,
    this.padding,
    this.disabled = false,
  }) : super(key: key);

  Widget _buildTextButton(BuildContext context) {
    Color colorUsed = color;
    if (textColor != Colors.white) {
      colorUsed = textColor;
    }
    return CupertinoButton(
      onPressed: disabled ? null : onPressed as void Function()?,
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text,
        style: TextStyle(color: colorUsed, fontFamily: "Helvetica"),
      ),
    );
  }

  Widget _buildFilledButton(BuildContext context) {
    return CupertinoButton(
      onPressed: disabled ? null : onPressed as void Function()?,
      padding: padding ??
          const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 14),
      color: color,
      disabledColor: color.withOpacity(0.5),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontFamily: "Helvetica"),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return CupertinoButton(
      onPressed: disabled ? null : onPressed as void Function()?,
      color: Colors.transparent,
      disabledColor: color.withOpacity(0.5),
      padding: EdgeInsets.zero,
      child: Container(
          padding: padding ??
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: 2,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Text(
            text,
            style: TextStyle(color: textColor, fontFamily: "Helvetica"),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case PELTextButtonStyle.text:
        return _buildTextButton(context);
      case PELTextButtonStyle.filled:
        return _buildFilledButton(context);
      case PELTextButtonStyle.outlined:
        return _buildOutlinedButton(context);
      default:
        return _buildFilledButton(context);
    }
  }
}
