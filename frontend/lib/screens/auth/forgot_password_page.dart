import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/futuristic_auth_widgets.dart';
import '../../widgets/futuristic_aurora_background.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const String _forgotPasswordApiUrl =
      'http://localhost:3000/api/users/forgot-password';

  final _emailController = TextEditingController();

  double _mouseX = 0;
  double _mouseY = 0;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // PARALLAX
  // ============================================================

  void _updateParallax(
    PointerHoverEvent event,
    Size size,
  ) {
    final dx = ((event.localPosition.dx / size.width) - 0.5) * 2;
    final dy = ((event.localPosition.dy / size.height) - 0.5) * 2;

    setState(() {
      _mouseX = dx.clamp(-1.0, 1.0);
      _mouseY = dy.clamp(-1.0, 1.0);
    });
  }

  // ============================================================
  // SEND RESET CODE
  // ============================================================

  Future<void> _sendResetCode() async {
    if (_isSubmitting) {
      return;
    }

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your email address.',
          ),
        ),
      );

      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid email address.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(_forgotPasswordApiUrl),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode != 200 ||
          decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        final message = decoded is Map
            ? decoded['message']?.toString()
            : null;

        throw Exception(
          message ?? 'Unable to send the reset code.',
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A password reset code has been sent to your email.',
          ),
        ),
      );

      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(
            milliseconds: 480,
          ),
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return OtpVerificationPage(
              email: email,
            );
          },
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            final slide = Tween<Offset>(
              begin: const Offset(
                0.06,
                0,
              ),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // BACK TO LOGIN
  // ============================================================

  void _goBackToLogin() {
    Navigator.of(context).pop();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FuturisticAuroraBackground(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final size = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return MouseRegion(
              onHover: (event) {
                _updateParallax(
                  event,
                  size,
                );
              },
              onExit: (_) {
                setState(() {
                  _mouseX = 0;
                  _mouseY = 0;
                });
              },
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 34,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: 1,
                    ),
                    duration: const Duration(
                      milliseconds: 700,
                    ),
                    curve: Curves.easeOutBack,
                    builder: (
                      context,
                      value,
                      child,
                    ) {
                      final opacity = value.clamp(
                        0.0,
                        1.0,
                      );

                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            24 * (1 - opacity),
                          ),
                          child: Transform.scale(
                            scale: 0.94 + opacity * 0.06,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: PremiumGlassAuthCard(
                      mouseX: _mouseX,
                      mouseY: _mouseY,
                      child: _buildForgotPasswordForm(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // FORGOT PASSWORD FORM
  // ============================================================

  Widget _buildForgotPasswordForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthReveal(
          index: 0,
          child: Image.asset(
            'lib/widgets/Codexia.png',
            width: 150,
            height: 56,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        const AuthReveal(
          index: 1,
          child: Icon(
            Icons.lock_reset_rounded,
            color: Color(0xFFD8B64B),
            size: 52,
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        const AuthReveal(
          index: 2,
          child: Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        AuthReveal(
          index: 3,
          child: Text(
            'Enter your registered email address and we will help you reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.54,
              ),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(
          height: 26,
        ),

        AuthReveal(
          index: 4,
          child: PremiumAuthField(
            controller: _emailController,
            hintText: 'Email Address',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        AuthReveal(
          index: 5,
          child: SizedBox(
            width: double.infinity,
            child: GradientLoginButton(
              label: 'SEND RESET CODE',
              loading: _isSubmitting,
              onPressed: _isSubmitting
                  ? null
                  : _sendResetCode,
            ),
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        AuthReveal(
          index: 6,
          child: TextButton.icon(
            onPressed: _isSubmitting
                ? null
                : _goBackToLogin,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 17,
              color: Color(0xFFD8B64B),
            ),
            label: const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFFD8B64B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}