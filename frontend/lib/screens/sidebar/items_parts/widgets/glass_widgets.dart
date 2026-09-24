import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// GLASS MODAL SHELL
// ============================================================================

class GlassModalShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeight;

  const GlassModalShell({
    super.key,
    required this.child,
    this.maxWidth = 700,
    this.maxHeight = 850,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.of(context).size.width < 650;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND BLUR
          // ======================================================

          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
            ),
            child: const SizedBox.expand(),
          ),

          // ======================================================
          // CENTER POPUP
          // ======================================================

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 30,
                vertical: isMobile ? 14 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 28,
                        sigmaY: 28,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          // ========================================
                          // GLASS BACKGROUND
                          // ========================================

                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(
                                alpha: 0.78,
                              ),
                              Colors.white.withValues(
                                alpha: 0.58,
                              ),
                              const Color(0xFFDDEAF3)
                                  .withValues(
                                alpha: 0.50,
                              ),
                            ],
                          ),

                          borderRadius:
                              BorderRadius.circular(26),

                          border: Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: 0.92,
                            ),
                            width: 1.3,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF102A3E)
                                      .withValues(
                                alpha: 0.24,
                              ),
                              blurRadius: 55,
                              spreadRadius: 2,
                              offset:
                                  const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.white
                                  .withValues(
                                alpha: 0.30,
                              ),
                              blurRadius: 10,
                              offset:
                                  const Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // ======================================
                            // BLUE GLASS ORB
                            // ======================================

                            Positioned(
                              top: -100,
                              right: -80,
                              child: IgnorePointer(
                                child: Container(
                                  width: 260,
                                  height: 260,
                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,
                                    gradient:
                                        RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFF438BC0,
                                        ).withValues(
                                          alpha: 0.22,
                                        ),
                                        Colors
                                            .transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // PURPLE GLASS ORB
                            // ======================================

                            Positioned(
                              bottom: -120,
                              left: -80,
                              child: IgnorePointer(
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,
                                    gradient:
                                        RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFF7A67B7,
                                        ).withValues(
                                          alpha: 0.14,
                                        ),
                                        Colors
                                            .transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // TOP GLASS SHINE
                            // ======================================

                            Positioned(
                              top: 0,
                              left: 30,
                              right: 30,
                              child: IgnorePointer(
                                child: Container(
                                  height: 1,
                                  decoration:
                                      BoxDecoration(
                                    gradient:
                                        LinearGradient(
                                      colors: [
                                        Colors
                                            .transparent,
                                        Colors.white
                                            .withValues(
                                          alpha: 0.95,
                                        ),
                                        Colors
                                            .transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ======================================
                            // FORM
                            // ======================================

                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class GlassDialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onClose;

  const GlassDialogHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.subtitle,
    this.icon = Icons.add_box_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // HEADER ICON
        // ========================================================

        Container(
          width: isMobile ? 44 : 50,
          height: isMobile ? 44 : 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF153F5F),
                Color(0xFF438CC0),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D557D)
                    .withValues(
                  alpha: 0.23,
                ),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 22 : 25,
          ),
        ),

        const SizedBox(width: 14),

        // ========================================================
        // TITLE
        // ========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 23 : 27,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF123456),
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 5),

                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF718391),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 10),

        // ========================================================
        // CLOSE BUTTON
        // ========================================================

        _GlassCloseButton(
          onPressed: onClose,
        ),
      ],
    );
  }
}

// ============================================================================
// CLOSE BUTTON
// ============================================================================

class _GlassCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _GlassCloseButton({
    required this.onPressed,
  });

  @override
  State<_GlassCloseButton> createState() =>
      _GlassCloseButtonState();
}

class _GlassCloseButtonState
    extends State<_GlassCloseButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        duration:
            const Duration(milliseconds: 160),
        scale: hovering ? 1.08 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius:
                BorderRadius.circular(11),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hovering
                    ? const Color(0xFFFFE9E9)
                        .withValues(
                        alpha: 0.72,
                      )
                    : Colors.white.withValues(
                        alpha: 0.40,
                      ),
                borderRadius:
                    BorderRadius.circular(11),
                border: Border.all(
                  color: hovering
                      ? const Color(0xFFE9AAAA)
                      : Colors.white.withValues(
                          alpha: 0.75,
                        ),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 21,
                color: hovering
                    ? const Color(0xFFC55151)
                    : const Color(0xFF71808C),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LABEL
// ============================================================================

class GlassLabel extends StatelessWidget {
  final String text;
  final bool required;

  const GlassLabel(
    this.text, {
    super.key,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF35495A),
          ),
          children: [
            TextSpan(
              text: text,
            ),

            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFD15C5C),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TEXT FIELD
// ============================================================================

class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<GlassTextField> createState() =>
      _GlassTextFieldState();
}

class _GlassTextFieldState
    extends State<GlassTextField> {
  final FocusNode _focusNode = FocusNode();

  bool focused = false;
  bool hovering = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!mounted) return;

      setState(() {
        focused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = focused
        ? const Color(0xFF5B9CC8)
        : hovering
            ? Colors.white.withValues(
                alpha: 0.95,
              )
            : Colors.white.withValues(
                alpha: 0.72,
              );

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90C2)
                        .withValues(
                      alpha: 0.16,
                    ),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autovalidateMode:
              AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF243B4C),
            fontWeight: FontWeight.w500,
          ),
          cursorColor: const Color(0xFF3F82B4),
          decoration: InputDecoration(
            hintText: widget.hintText,

            hintStyle: const TextStyle(
              color: Color(0xFF8B9AA6),
              fontWeight: FontWeight.w400,
            ),

            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: focused
                        ? const Color(0xFF3E82B4)
                        : const Color(0xFF7D8F9C),
                  ),

            filled: true,

            fillColor: Colors.white.withValues(
              alpha: focused ? 0.62 : 0.42,
            ),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(13),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFF5597C4),
                width: 1.4,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFD16A6A),
              ),
            ),

            focusedErrorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xFFD16A6A),
                width: 1.3,
              ),
            ),

            errorStyle: const TextStyle(
              color: Color(0xFFB44F4F),
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SELECT BOX
// ============================================================================

class GlassSelectBox extends StatefulWidget {
  final GlobalKey boxKey;
  final String? selectedLabel;
  final String placeholder;
  final VoidCallback onTap;
  final IconData icon;

  const GlassSelectBox({
    super.key,
    required this.boxKey,
    required this.selectedLabel,
    required this.placeholder,
    required this.onTap,
    this.icon = Icons.receipt_long_outlined,
  });

  @override
  State<GlassSelectBox> createState() =>
      _GlassSelectBoxState();
}

class _GlassSelectBoxState
    extends State<GlassSelectBox> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          key: widget.boxKey,
          duration:
              const Duration(milliseconds: 180),
          height: 54,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: hovering ? 0.58 : 0.42,
            ),
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color: hovering
                  ? const Color(0xFF6A9FC3)
                  : Colors.white.withValues(
                      alpha: 0.74,
                    ),
              width: hovering ? 1.3 : 1.0,
            ),
            boxShadow: hovering
                ? [
                    BoxShadow(
                      color: const Color(0xFF397CAB)
                          .withValues(
                        alpha: 0.12,
                      ),
                      blurRadius: 15,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: const Color(0xFF64849A),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  widget.selectedLabel ??
                      widget.placeholder,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        widget.selectedLabel == null
                            ? const Color(
                                0xFF8796A2,
                              )
                            : const Color(
                                0xFF263D4E,
                              ),
                  ),
                ),
              ),

              AnimatedRotation(
                duration: const Duration(
                  milliseconds: 180,
                ),
                turns: hovering ? 0.02 : 0,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF60798A),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ADD NEW LINK
// ============================================================================

class GlassAddNewLink extends StatefulWidget {
  final VoidCallback onTap;

  const GlassAddNewLink({
    super.key,
    required this.onTap,
  });

  @override
  State<GlassAddNewLink> createState() =>
      _GlassAddNewLinkState();
}

class _GlassAddNewLinkState
    extends State<GlassAddNewLink> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: hovering
                ? const Color(0xFF387EAE)
                    .withValues(
                    alpha: 0.12,
                  )
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 16,
                color: Color(0xFF236FAD),
              ),
              const SizedBox(width: 3),
              Text(
                'Add New',
                style: TextStyle(
                  color:
                      const Color(0xFF236FAD),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: hovering
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BUTTON
// ============================================================================

class GlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  const GlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = true,
  });

  @override
  State<GlassButton> createState() =>
      _GlassButtonState();
}

class _GlassButtonState
    extends State<GlassButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        scale: hovering ? 1.025 : 1,
        duration:
            const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius:
                BorderRadius.circular(12),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 19,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: widget.primary
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                        colors: [
                          hovering
                              ? const Color(
                                  0xFF245F8B,
                                )
                              : const Color(
                                  0xFF153F61,
                                ),
                          hovering
                              ? const Color(
                                  0xFF438FC4,
                                )
                              : const Color(
                                  0xFF2D709F,
                                ),
                        ],
                      )
                    : null,

                color: widget.primary
                    ? null
                    : Colors.white.withValues(
                        alpha:
                            hovering ? 0.62 : 0.42,
                      ),

                borderRadius:
                    BorderRadius.circular(12),

                border: Border.all(
                  color: widget.primary
                      ? Colors.white.withValues(
                          alpha: 0.35,
                        )
                      : Colors.white.withValues(
                          alpha:
                              hovering ? 0.95 : 0.75,
                        ),
                ),

                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: widget.primary
                              ? const Color(
                                  0xFF174D72,
                                ).withValues(
                                  alpha: 0.25,
                                )
                              : const Color(
                                  0xFF17394F,
                                ).withValues(
                                  alpha: 0.09,
                                ),
                          blurRadius: 18,
                          offset:
                              const Offset(0, 7),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.primary
                        ? Colors.white
                        : const Color(
                            0xFF526979,
                          ),
                  ),

                  const SizedBox(width: 7),

                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.primary
                          ? Colors.white
                          : const Color(
                              0xFF435968,
                            ),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}