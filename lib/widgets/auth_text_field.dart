import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A dark, rounded text field with a leading icon, matching the Codexia
/// sign in / create account design. Pass [obscureText] + [onToggleObscure]
/// together to get a password field with a show/hide eye icon.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? errorText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onToggleObscure,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final showToggle = onToggleObscure != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: CodexiaColors.navy.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText == null
                  ? CodexiaColors.cardBorder
                  : Colors.redAccent.withValues(alpha: 0.8),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: CodexiaColors.white),
            cursorColor: CodexiaColors.gold,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(color: CodexiaColors.muted),
              prefixIcon: Icon(icon, color: CodexiaColors.muted, size: 20),
              suffixIcon: showToggle
                  ? IconButton(
                      onPressed: onToggleObscure,
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: CodexiaColors.muted,
                        size: 20,
                      ),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
            ),
          ),
      ],
    );
  }
}