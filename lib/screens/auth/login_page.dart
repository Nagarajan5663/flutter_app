import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import '../home/home_page.dart';

import '../../widgets/futuristic_auth_widgets.dart';
import '../../widgets/futuristic_aurora_background.dart';

import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _obscurePassword =
      true;

  bool _isSubmitting =
      false;

  double _mouseX = 0;
  double _mouseY = 0;

  @override
  void dispose() {
    _emailController
        .dispose();

    _passwordController
        .dispose();

    super.dispose();
  }

  // ============================================================
  // PARALLAX
  // ============================================================

  void _updateParallax(
    PointerHoverEvent event,
    Size size,
  ) {
    final dx =
        ((event.localPosition.dx /
                    size.width) -
                0.5) *
            2;

    final dy =
        ((event.localPosition.dy /
                    size.height) -
                0.5) *
            2;

    setState(() {
      _mouseX =
          dx.clamp(
        -1.0,
        1.0,
      );

      _mouseY =
          dy.clamp(
        -1.0,
        1.0,
      );
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void>
      _handleSignIn() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting =
          true;
    });

    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting =
          false;
    });

    Navigator.of(context)
        .pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            const DashboardPage(),
      ),
    );
  }

  // ============================================================
  // SIGNUP
  // ============================================================

  void _goToSignUp() {
    Navigator.of(context)
        .pushReplacement(
      PageRouteBuilder(
        transitionDuration:
            const Duration(
          milliseconds: 480,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const SignUpPage();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final slide =
              Tween<Offset>(
            begin:
                const Offset(
              0.06,
              0,
            ),
            end:
                Offset.zero,
          ).animate(
            CurvedAnimation(
              parent:
                  animation,
              curve:
                  Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity:
                animation,
            child:
                SlideTransition(
              position:
                  slide,
              child:
                  child,
            ),
          );
        },
      ),
    );
  }

  void _social(
    String provider,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        duration:
            const Duration(
          milliseconds: 900,
        ),
        content:
            Text(
          '$provider login selected',
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
      ),
      (_) => false,
    );
  }

  Widget _buildHomeButton() {
    return Tooltip(
      message: 'Go to Home',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _goHome,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          FuturisticAuroraBackground(
        child:
            LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final Size size =
                Size(
              constraints
                  .maxWidth,
              constraints
                  .maxHeight,
            );

            return MouseRegion(
              onHover:
                  (event) {
                _updateParallax(
                  event,
                  size,
                );
              },
              onExit: (_) {
                setState(() {
                  _mouseX =
                      0;

                  _mouseY =
                      0;
                });
              },
              child: Stack(
                clipBehavior:
                    Clip.none,
                children: [
                  // ====================================================
                  // LOGIN CARD
                  // ====================================================

                  Center(
                    child:
                        SingleChildScrollView(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            24,
                        vertical:
                            34,
                      ),
                      child:
                          TweenAnimationBuilder<
                              double>(
                        tween:
                            Tween(
                          begin: 0,
                          end: 1,
                        ),
                        duration:
                            const Duration(
                          milliseconds:
                              850,
                        ),
                        curve:
                            Curves
                                .easeOutBack,
                        builder: (
                          context,
                          value,
                          child,
                        ) {
                          final opacity =
                              value.clamp(
                            0.0,
                            1.0,
                          );

                          return Opacity(
                            opacity:
                                opacity,
                            child:
                                Transform
                                    .translate(
                              offset:
                                  Offset(
                                0,
                                24 *
                                    (1 -
                                        opacity),
                              ),
                              child:
                                  Transform
                                      .scale(
                                scale:
                                    0.94 +
                                    opacity *
                                        0.06,
                                child:
                                    child,
                              ),
                            ),
                          );
                        },
                        child:
                            PremiumGlassAuthCard(
                          mouseX:
                              _mouseX,
                          mouseY:
                              _mouseY,
                          child:
                              _buildLoginForm(),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN FORM
  // ============================================================

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: AuthReveal(
            index: 0,
            child: _buildHomeButton(),
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        const AuthReveal(
          index: 1,
          child: Text(
            'Hello Again',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize: 30,
              fontWeight:
                  FontWeight.w800,
              letterSpacing:
                  -0.5,
            ),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        AuthReveal(
          index: 2,
          child: Text(
            'Welcome back to CODEXIA. Sign in to continue.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white
                      .withValues(
                        alpha: 0.54,
              ),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        // SOCIAL LOGIN

        AuthReveal(
          index: 3,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              SocialLoginButton(
                onTap: () =>
                    _social(
                  'Google',
                ),
                icon:
                    const Text(
                  'G',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize:
                        18,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              SocialLoginButton(
                onTap: () =>
                    _social(
                  'Apple',
                ),
                icon:
                    const Icon(
                  Icons
                      .phone_iphone_rounded,
                  color:
                      Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              SocialLoginButton(
                onTap: () =>
                    _social(
                  'Developer',
                ),
                icon:
                    const Icon(
                  Icons
                      .code_rounded,
                  color:
                      Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        Row(
          children: [
            Expanded(
              child:
                  Divider(
                color:
                    Colors.white
                        .withValues(
                      alpha: 0.09,
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
              ),
              child: Text(
                'or continue with email',
                style:
                    TextStyle(
                  color:
                      Colors.white
                          .withValues(
                          alpha: 0.38,
                  ),
                  fontSize:
                      11.5,
                ),
              ),
            ),

            Expanded(
              child:
                  Divider(
                color:
                    Colors.white
                        .withValues(
                      alpha: 0.09,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 22,
        ),

        AuthReveal(
          index: 4,
          child:
              PremiumAuthField(
            controller:
                _emailController,
            hintText:
                'Email Address',
            icon:
                Icons.mail_outline,
            keyboardType:
                TextInputType
                    .emailAddress,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        AuthReveal(
          index: 5,
          child:
              PremiumAuthField(
            controller:
                _passwordController,
            hintText:
                'Password',
            icon:
                Icons.lock_outline,
            obscureText:
                _obscurePassword,
            onToggleObscure:
                () {
              setState(() {
                _obscurePassword =
                    !_obscurePassword;
              });
            },
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        AuthReveal(
          index: 6,
          child: Align(
            alignment:
                Alignment
                    .centerRight,
            child:
                TextButton(
              onPressed: () {},
              child:
                  const Text(
                'Forgot Password?',
                style:
                    TextStyle(
                  color:
                      Color(
                    0xFFD8B64B,
                  ),
                  fontSize:
                      12.5,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        AuthReveal(
          index: 7,
          child: SizedBox(
            width:
                double.infinity,
            child:
                GradientLoginButton(
              label:
                  'Login',
              loading:
                  _isSubmitting,
              onPressed:
                  _isSubmitting
                      ? null
                      : _handleSignIn,
            ),
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        AuthReveal(
          index: 8,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Text(
                "Don't have an account? ",
                style:
                    TextStyle(
                  color:
                      Colors.white
                          .withValues(
                          alpha: 0.54,
                  ),
                  fontSize: 13,
                ),
              ),

              GestureDetector(
                onTap:
                    _goToSignUp,
                child:
                    const Text(
                  'Create one',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFD8B64B,
                    ),
                    fontSize:
                        13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}