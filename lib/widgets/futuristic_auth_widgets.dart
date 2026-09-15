import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumGlassAuthCard
    extends StatefulWidget {
  final Widget child;

  final double mouseX;
  final double mouseY;

  final double maxWidth;

  const PremiumGlassAuthCard({
    super.key,
    required this.child,
    required this.mouseX,
    required this.mouseY,
    this.maxWidth = 450,
  });

  @override
  State<PremiumGlassAuthCard>
      createState() =>
          _PremiumGlassAuthCardState();
}

class _PremiumGlassAuthCardState
    extends State<
        PremiumGlassAuthCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final translateX =
        widget.mouseX * 8;

    final translateY =
        widget.mouseY * 6;

    final rotateY =
        widget.mouseX *
        0.018;

    final rotateX =
        -widget.mouseY *
        0.014;

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
            const Duration(
          milliseconds: 180,
        ),
        curve:
            Curves.easeOutCubic,
        transformAlignment:
            Alignment.center,
        transform:
            Matrix4.identity()
              ..setEntry(
                3,
                2,
                0.001,
              )
              ..translate(
                translateX,
                translateY,
              )
              ..rotateX(
                rotateX,
              )
              ..rotateY(
                rotateY,
              ),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(
            maxWidth:
                widget.maxWidth,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              28,
            ),
            child:
                BackdropFilter(
              filter:
                  ImageFilter.blur(
                sigmaX: 22,
                sigmaY: 22,
              ),
              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 220,
                ),
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  34,
                  34,
                  34,
                  30,
                ),
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: [
                      Colors.white
                          .withOpacity(
                        hovering
                            ? 0.16
                            : 0.12,
                      ),
                      const Color(
                        0xFF111D34,
                      ).withOpacity(
                        0.65,
                      ),
                      const Color(
                        0xFF080F20,
                      ).withOpacity(
                        0.63,
                      ),
                    ],
                  ),
                  border:
                      Border.all(
                    width: 1.1,
                    color:
                        Colors.white
                            .withOpacity(
                      hovering
                          ? 0.28
                          : 0.17,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(
                        0.36,
                      ),
                      blurRadius:
                          hovering
                              ? 50
                              : 38,
                      offset:
                          const Offset(
                        0,
                        24,
                      ),
                    ),
                    BoxShadow(
                      color:
                          const Color(
                            0xFF118EFF,
                          ).withOpacity(
                        hovering
                            ? 0.14
                            : 0.07,
                      ),
                      blurRadius:
                          42,
                      offset:
                          const Offset(
                        -10,
                        -5,
                      ),
                    ),
                    BoxShadow(
                      color:
                          const Color(
                            0xFF785CFF,
                          ).withOpacity(
                        hovering
                            ? 0.15
                            : 0.08,
                      ),
                      blurRadius:
                          48,
                      offset:
                          const Offset(
                        12,
                        12,
                      ),
                    ),
                  ],
                ),
                child:
                    widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// INPUT FIELD
// ============================================================================

class PremiumAuthField
    extends StatefulWidget {
  final TextEditingController
      controller;

  final String hintText;

  final IconData icon;

  final bool obscureText;

  final TextInputType?
      keyboardType;

  final VoidCallback?
      onToggleObscure;

  const PremiumAuthField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.onToggleObscure,
  });

  @override
  State<PremiumAuthField>
      createState() =>
          _PremiumAuthFieldState();
}

class _PremiumAuthFieldState
    extends State<
        PremiumAuthField> {
  final FocusNode focusNode =
      FocusNode();

  bool focused = false;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          focused =
              focusNode.hasFocus;
        });
      },
    );
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 200,
      ),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        boxShadow:
            focused
                ? [
                    BoxShadow(
                      color:
                          const Color(
                            0xFF118EFF,
                          ).withOpacity(
                        0.17,
                      ),
                      blurRadius:
                          22,
                    ),
                  ]
                : null,
      ),
      child: TextField(
        controller:
            widget.controller,
        focusNode:
            focusNode,
        obscureText:
            widget.obscureText,
        keyboardType:
            widget.keyboardType,
        cursorColor:
            const Color(
          0xFF65C9FF,
        ),
        style:
            const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
        ),
        decoration:
            InputDecoration(
          filled: true,
          fillColor:
              Colors.black
                  .withOpacity(
            0.22,
          ),
          hintText:
              widget.hintText,
          hintStyle:
              TextStyle(
            color:
                Colors.white
                    .withOpacity(
              0.43,
            ),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color:
                focused
                    ? const Color(
                        0xFF65C9FF,
                      )
                    : Colors.white
                        .withOpacity(
                          0.50,
                        ),
          ),
          suffixIcon:
              widget.onToggleObscure ==
                      null
                  ? null
                  : IconButton(
                      onPressed:
                          widget
                              .onToggleObscure,
                      icon: Icon(
                        widget.obscureText
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                        color:
                            Colors.white
                                .withOpacity(
                          0.50,
                        ),
                      ),
                    ),
          contentPadding:
              const EdgeInsets
                  .symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                BorderSide(
              color:
                  Colors.white
                      .withOpacity(
                0.11,
              ),
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(
                0xFF4FBFFF,
              ),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN BUTTON
// ============================================================================

class GradientLoginButton
    extends StatefulWidget {
  final String label;

  final bool loading;

  final VoidCallback?
      onPressed;

  const GradientLoginButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  State<GradientLoginButton>
      createState() =>
          _GradientLoginButtonState();
}

class _GradientLoginButtonState
    extends State<
        GradientLoginButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.onPressed ==
                  null
              ? SystemMouseCursors
                  .basic
              : SystemMouseCursors
                  .click,
      onEnter: (_) {
        if (widget.onPressed ==
            null) {
          return;
        }

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
            const Duration(
          milliseconds: 160,
        ),
        scale:
            hovering
                ? 1.02
                : 1,
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 200,
          ),
          height: 54,
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            gradient:
                const LinearGradient(
              colors: [
                Color(
                  0xFF098FFF,
                ),
                Color(
                  0xFF655CFF,
                ),
                Color(
                  0xFF9450FF,
                ),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                      0xFF118EFF,
                    ).withOpacity(
                  hovering
                      ? 0.36
                      : 0.20,
                ),
                blurRadius:
                    hovering
                        ? 30
                        : 20,
                offset:
                    const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),
          child: Material(
            color:
                Colors.transparent,
            child: InkWell(
              onTap:
                  widget.onPressed,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              child: Center(
                child:
                    widget.loading
                        ? const SizedBox(
                            width:
                                22,
                            height:
                                22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2.3,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Text(
                            widget.label,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  15.5,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SOCIAL BUTTON
// ============================================================================

class SocialLoginButton
    extends StatefulWidget {
  final Widget icon;

  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  State<SocialLoginButton>
      createState() =>
          _SocialLoginButtonState();
}

class _SocialLoginButtonState
    extends State<
        SocialLoginButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          SystemMouseCursors
              .click,
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
        scale:
            hovering
                ? 1.06
                : 1,
        duration:
            const Duration(
          milliseconds: 150,
        ),
        child:
            GestureDetector(
          onTap:
              widget.onTap,
          child:
              AnimatedContainer(
            duration:
                const Duration(
              milliseconds:
                  180,
            ),
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              color:
                  Colors.white
                      .withOpacity(
                hovering
                    ? 0.13
                    : 0.07,
              ),
              border:
                  Border.all(
                color:
                    Colors.white
                        .withOpacity(
                  hovering
                      ? 0.23
                      : 0.12,
                ),
              ),
              boxShadow:
                  hovering
                      ? [
                          BoxShadow(
                            color:
                                const Color(
                                  0xFF118EFF,
                                ).withOpacity(
                              0.15,
                            ),
                            blurRadius:
                                18,
                          ),
                        ]
                      : null,
            ),
            child:
                Center(
              child:
                  widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STAGGER REVEAL
// ============================================================================

class AuthReveal
    extends StatelessWidget {
  final Widget child;
  final int index;

  const AuthReveal({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<
        double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration:
          Duration(
        milliseconds:
            420 +
            index *
                95,
      ),
      curve:
          Curves.easeOutCubic,
      builder: (
        context,
        value,
        child,
      ) {
        return Opacity(
          opacity:
              value,
          child:
              Transform.translate(
            offset:
                Offset(
              0,
              14 *
                  (1 -
                      value),
            ),
            child:
                child,
          ),
        );
      },
      child: child,
    );
  }
}