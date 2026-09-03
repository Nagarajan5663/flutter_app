import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The "CODEXIA" icon + wordmark, reused on the home navbar, the sign in
/// screen and the create account screen so branding stays consistent.
class CodexiaLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;

  const CodexiaLogo({super.key, this.iconSize = 44, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: CodexiaColors.gold,
            borderRadius: BorderRadius.circular(iconSize * 0.24),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: CodexiaColors.navyDark,
            size: iconSize * 0.6,
          ),
        ),
        const SizedBox(width: 12),
        _Wordmark(fontSize: fontSize),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  final double fontSize;

  const _Wordmark({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      'CODEXIA',
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        color: CodexiaColors.gold,
        shadows: const [
          Shadow(
            color: Color(0xFF8A5C1D),
            blurRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}