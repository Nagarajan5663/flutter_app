import 'package:flutter/material.dart';

/// The "CODEXIA" icon + wordmark, reused on the home navbar, the sign in
/// screen and the create account screen so branding stays consistent.
class CodexiaLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;

  const CodexiaLogo({super.key, this.iconSize = 44, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: iconSize,
      width: iconSize * 5.2,
      child: Image.asset(
        'lib/widgets/Codexia_OG1.8.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
