import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import '../home/home_page.dart';

import '../../widgets/futuristic_auth_widgets.dart';
import '../../widgets/futuristic_aurora_background.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
  });

  @override
  State<SignUpPage> createState() =>
      _SignUpPageState();
}

class _SignUpPageState
    extends State<SignUpPage> {
  final _organizationNameController =
      TextEditingController();

  final _organizationEmailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword =
      true;

  bool _obscureConfirmPassword =
      true;

  bool _isSubmitting =
      false;

  double _mouseX = 0;
  double _mouseY = 0;

  @override
  void dispose() {
    _organizationNameController
        .dispose();

    _organizationEmailController
        .dispose();

    _passwordController
        .dispose();

    _confirmPasswordController
        .dispose();

    super.dispose();
  }

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

  Future<void>
      _handleCreateAccount() async {
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

  void _goToLogin() {
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
          return const LoginPage();
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
              -0.06,
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

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
      ),
      (_) => false,
    );
  }

  Widget _buildHomeButton() {
    return Transform.translate(
      offset: const Offset(14, -8),
      child: Tooltip(
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
              size: 22,
            ),
          ),
        ),
      ),
      ),
    );
  }

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
            final size =
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
              child: Stack(
                children: [
                  Center(
                    child:
                        SingleChildScrollView(
                      padding:
                          const EdgeInsets
                              .all(
                        24,
                      ),
                      child:
                          PremiumGlassAuthCard(
                        maxWidth:
                            470,
                        mouseX:
                            _mouseX,
                        mouseY:
                            _mouseY,
                        child:
                            _buildForm(),
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

  Widget _buildForm() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: _buildHomeButton(),
        ),

        const SizedBox(
          height: 16,
        ),

        const Text(
          'Create Account',
          style: TextStyle(
            color:
                Colors.white,
            fontSize: 29,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          'Start your CODEXIA workspace.',
          style: TextStyle(
            color:
                Colors.white
                    .withValues(
                    alpha: 0.54,
            ),
            fontSize: 13.5,
          ),
        ),

        const SizedBox(
          height: 26,
        ),

        PremiumAuthField(
          controller:
              _organizationNameController,
          hintText:
              'Organization Name',
          icon:
              Icons.apartment_outlined,
        ),

        const SizedBox(
          height: 14,
        ),

        PremiumAuthField(
          controller:
              _organizationEmailController,
          hintText:
              'Organization Email',
          icon:
              Icons.mail_outline,
          keyboardType:
              TextInputType
                  .emailAddress,
        ),

        const SizedBox(
          height: 14,
        ),

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

        const SizedBox(
          height: 14,
        ),

        PremiumAuthField(
          controller:
              _confirmPasswordController,
          hintText:
              'Confirm Password',
          icon:
              Icons.check_circle_outline,
          obscureText:
              _obscureConfirmPassword,
          onToggleObscure:
              () {
            setState(() {
              _obscureConfirmPassword =
                  !_obscureConfirmPassword;
            });
          },
        ),

        const SizedBox(
          height: 24,
        ),

        SizedBox(
          width:
              double.infinity,
          child:
              GradientLoginButton(
            label:
                'Create Account',
            loading:
                _isSubmitting,
            onPressed:
                _isSubmitting
                    ? null
                    : _handleCreateAccount,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
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
                  _goToLogin,
              child:
                  const Text(
                'Sign In',
                style:
                    TextStyle(
                  color:
                      Color(
                    0xFFD8B64B,
                  ),
                  fontWeight:
                      FontWeight.w700,
                  fontSize:
                      13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}