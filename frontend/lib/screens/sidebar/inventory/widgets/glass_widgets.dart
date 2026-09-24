import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// SHARED COLORS
// ============================================================================

class InventoryGlassTheme {
  static const Color navy = Color(0xFF123456);
  static const Color primary = Color(0xFF194E75);
  static const Color primaryLight = Color(0xFF438CC0);

  static const Color background1 = Color(0xFFCADAE7);
  static const Color background2 = Color(0xFFD2D6E3);
  static const Color background3 = Color(0xFFC7DCD9);

  static const Color textPrimary = Color(0xFF203A4D);
  static const Color textSecondary = Color(0xFF718391);
}

// ============================================================================
// MAIN PAGE GLASS + 3D TILT
// ============================================================================

class InventoryGlassTiltPanel extends StatefulWidget {
  final Widget child;
  final bool enableTilt;
  final double borderRadius;

  const InventoryGlassTiltPanel({
    super.key,
    required this.child,
    this.enableTilt = true,
    this.borderRadius = 28,
  });

  @override
  State<InventoryGlassTiltPanel> createState() =>
      _InventoryGlassTiltPanelState();
}

class _InventoryGlassTiltPanelState
    extends State<InventoryGlassTiltPanel> {
  double rotateX = 0;
  double rotateY = 0;

  bool hovering = false;

  void _handleHover(PointerEvent event) {
    if (!widget.enableTilt) {
      return;
    }

    final RenderObject? renderObject =
        context.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final Size size = renderObject.size;

    if (size.width == 0 || size.height == 0) {
      return;
    }

    final double x =
        (event.localPosition.dx / size.width) - 0.5;

    final double y =
        (event.localPosition.dy / size.height) - 0.5;

    // Keep the effect subtle/professional.
    const double tiltStrength = 0.025;

    setState(() {
      rotateY = x * tiltStrength;
      rotateX = -y * tiltStrength;
    });
  }

  void _resetTilt() {
    if (!mounted) {
      return;
    }

    setState(() {
      hovering = false;
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enableTilt) {
          return;
        }

        setState(() {
          hovering = true;
        });
      },
      onHover: _handleHover,
      onExit: (_) => _resetTilt(),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: hovering ? 90 : 340,
        ),
        curve: hovering
            ? Curves.linear
            : Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            widget.borderRadius,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173D59).withValues(
                alpha: hovering ? 0.18 : 0.10,
              ),
              blurRadius: hovering ? 50 : 35,
              spreadRadius: hovering ? 2 : 0,
              offset: Offset(
                rotateY * 120,
                14 + (rotateX * 80),
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            widget.borderRadius,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 220,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: hovering ? 0.66 : 0.56,
                ),
                borderRadius: BorderRadius.circular(
                  widget.borderRadius,
                ),
                border: Border.all(
                  width: 1.3,
                  color: Colors.white.withValues(
                    alpha: hovering ? 0.95 : 0.78,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  widget.child,

                  // --------------------------------------------------
                  // TOP RIGHT SHINE
                  // --------------------------------------------------

                  Positioned(
                    top: -120,
                    right: -70,
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha:
                                    hovering ? 0.25 : 0.14,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --------------------------------------------------
                  // TOP GLASS EDGE
                  // --------------------------------------------------

                  Positioned(
                    top: 0,
                    left: 30,
                    right: 30,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(
                                alpha: 0.95,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
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

// ============================================================================
// GLASS TABLE
// ============================================================================

class InventoryGlassTable extends StatefulWidget {
  final Widget child;

  const InventoryGlassTable({
    super.key,
    required this.child,
  });

  @override
  State<InventoryGlassTable> createState() =>
      _InventoryGlassTableState();
}

class _InventoryGlassTableState
    extends State<InventoryGlassTable> {
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
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 230,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: hovering ? 0.43 : 0.31,
          ),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: hovering ? 0.95 : 0.72,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163E5A)
                  .withValues(
                alpha: hovering ? 0.11 : 0.05,
              ),
              blurRadius: hovering ? 28 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================================
// GENERIC HOVER SCALE
// ============================================================================

class InventoryHoverScale extends StatefulWidget {
  final Widget child;
  final double scale;

  const InventoryHoverScale({
    super.key,
    required this.child,
    this.scale = 1.03,
  });

  @override
  State<InventoryHoverScale> createState() =>
      _InventoryHoverScaleState();
}

class _InventoryHoverScaleState
    extends State<InventoryHoverScale> {
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
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOutCubic,
        scale: hovering ? widget.scale : 1,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// TABLE HEADER TEXT
// ============================================================================

class InventoryTableHeader extends StatelessWidget {
  final String title;
  final TextAlign textAlign;

  const InventoryTableHeader({
    super.key,
    required this.title,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.65,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5C7283),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class InventoryEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const InventoryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 52,
      ),
      child: Column(
        children: [
          InventoryHoverScale(
            scale: 1.06,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.42,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.80,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF24587E)
                        .withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 36,
                color: const Color(0xFF427FA8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF203A4D),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF778A98),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// POPUP GLASS SHELL
// ============================================================================

class InventoryGlassModalShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeight;

  const InventoryGlassModalShell({
    super.key,
    required this.child,
    this.maxWidth = 650,
    this.maxHeight = 820,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize =
        MediaQuery.of(context).size;

    final bool isMobile =
        screenSize.width < 650;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ----------------------------------------------------------
          // BLUR PAGE BEHIND POPUP
          // ----------------------------------------------------------

          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
            ),
            child: const SizedBox.expand(),
          ),

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
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(
                                alpha: 0.80,
                              ),
                              Colors.white.withValues(
                                alpha: 0.61,
                              ),
                              const Color(0xFFDDEAF3)
                                  .withValues(
                                alpha: 0.54,
                              ),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(26),
                          border: Border.all(
                            width: 1.3,
                            color: Colors.white
                                .withValues(
                              alpha: 0.94,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF102A3E)
                                      .withValues(
                                alpha: 0.26,
                              ),
                              blurRadius: 55,
                              spreadRadius: 2,
                              offset:
                                  const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // ----------------------------------------
                            // BLUE ORB
                            // ----------------------------------------

                            Positioned(
                              top: -100,
                              right: -70,
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
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ----------------------------------------
                            // PURPLE ORB
                            // ----------------------------------------

                            Positioned(
                              bottom: -130,
                              left: -80,
                              child: IgnorePointer(
                                child: Container(
                                  width: 290,
                                  height: 290,
                                  decoration:
                                      BoxDecoration(
                                    shape:
                                        BoxShape.circle,
                                    gradient:
                                        RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFF7967B4,
                                        ).withValues(
                                          alpha: 0.14,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

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
// POPUP HEADER
// ============================================================================

class InventoryDialogHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;

  const InventoryDialogHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 26,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF123456),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF718391),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _InventoryCloseButton(
          onPressed: onClose,
        ),
      ],
    );
  }
}

// ============================================================================
// CLOSE BUTTON
// ============================================================================

class _InventoryCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _InventoryCloseButton({
    required this.onPressed,
  });

  @override
  State<_InventoryCloseButton> createState() =>
      _InventoryCloseButtonState();
}

class _InventoryCloseButtonState
    extends State<_InventoryCloseButton> {
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
        duration: const Duration(
          milliseconds: 160,
        ),
        scale: hovering ? 1.08 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius:
                BorderRadius.circular(11),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 170,
              ),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hovering
                    ? const Color(0xFFFFE9E9)
                        .withValues(
                        alpha: 0.75,
                      )
                    : Colors.white.withValues(
                        alpha: 0.42,
                      ),
                borderRadius:
                    BorderRadius.circular(11),
                border: Border.all(
                  color: hovering
                      ? const Color(0xFFE7AAAA)
                      : Colors.white.withValues(
                          alpha: 0.78,
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

class InventoryGlassLabel extends StatelessWidget {
  final String text;

  const InventoryGlassLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF35495A),
        ),
      ),
    );
  }
}

// ============================================================================
// TEXT INPUT
// ============================================================================

class InventoryGlassTextField
    extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;

  const InventoryGlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<InventoryGlassTextField> createState() =>
      _InventoryGlassTextFieldState();
}

class _InventoryGlassTextFieldState
    extends State<InventoryGlassTextField> {
  final FocusNode _focusNode = FocusNode();

  bool focused = false;
  bool hovering = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!mounted) {
        return;
      }

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
        duration: const Duration(
          milliseconds: 180,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90C2)
                        .withValues(
                      alpha: 0.17,
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
          cursorColor:
              InventoryGlassTheme.primaryLight,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF243B4C),
            fontWeight: FontWeight.w500,
          ),
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
              alpha: focused
                  ? 0.65
                  : hovering
                      ? 0.55
                      : 0.43,
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
                color: hovering
                    ? const Color(0xFF89B4D0)
                    : Colors.white.withValues(
                        alpha: 0.78,
                      ),
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
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DROPDOWN
// ============================================================================

class InventoryGlassDropdown
    extends StatefulWidget {
  final String? value;
  final List<String> options;
  final String hintText;
  final IconData prefixIcon;
  final ValueChanged<String?> onChanged;

  const InventoryGlassDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
  });

  @override
  State<InventoryGlassDropdown> createState() =>
      _InventoryGlassDropdownState();
}

class _InventoryGlassDropdownState
    extends State<InventoryGlassDropdown> {
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
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        height: 54,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: hovering ? 0.58 : 0.43,
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: hovering
                ? const Color(0xFF74A6C8)
                : Colors.white.withValues(
                    alpha: 0.78,
                  ),
            width: hovering ? 1.3 : 1,
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
              widget.prefixIcon,
              size: 20,
              color: const Color(0xFF64849A),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.value,
                  isExpanded: true,
                  borderRadius:
                      BorderRadius.circular(14),
                  menuMaxHeight: 320,
                  dropdownColor:
                      const Color(0xFF263E54),
                  icon: const Icon(
                    Icons
                        .keyboard_arrow_down_rounded,
                    color: Color(0xFF60798A),
                  ),
                  hint: Text(
                    widget.hintText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8796A2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selectedItemBuilder: (context) {
                    return widget.options.map(
                      (option) {
                        return Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            option,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color:
                                  Color(0xFF263D4E),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ).toList();
                  },
                  items: widget.options.map(
                    (option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS BUTTON
// ============================================================================

class InventoryGlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  const InventoryGlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = true,
  });

  @override
  State<InventoryGlassButton> createState() =>
      _InventoryGlassButtonState();
}

class _InventoryGlassButtonState
    extends State<InventoryGlassButton> {
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
        duration: const Duration(
          milliseconds: 170,
        ),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius:
                BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
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
                            hovering ? 0.65 : 0.44,
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
                              hovering ? 0.98 : 0.78,
                        ),
                ),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: widget.primary
                              ? const Color(
                                  0xFF174D72,
                                ).withValues(
                                  alpha: 0.26,
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
                mainAxisAlignment:
                    MainAxisAlignment.center,
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