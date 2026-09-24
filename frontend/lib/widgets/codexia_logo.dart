import 'package:flutter/material.dart';

/// A lightweight CODEXIA wordmark styled to match the reference image.
class CodexiaLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;

  const CodexiaLogo({super.key, this.iconSize = 44, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.8,
      color: Colors.white,
      shadows: const [
        Shadow(
          blurRadius: 0,
          offset: Offset(0, 2),
          color: Color(0x66000000),
        ),
        Shadow(
          blurRadius: 8,
          offset: Offset(0, 0),
          color: Color(0x66B8D8FF),
        ),
      ],
    );

    return SizedBox(
      height: iconSize,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'CODEXIA',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
