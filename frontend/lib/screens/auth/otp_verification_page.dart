import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/futuristic_auth_widgets.dart';
import '../../widgets/futuristic_aurora_background.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const String _verifyOtpApiUrl =
      'http://localhost:3000/api/users/verify-reset-otp';

  final _otpController = TextEditingController();

  double _mouseX = 0;
  double _mouseY = 0;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
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
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    if (_isSubmitting) {
      return;
    }

    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter the OTP sent to your email.',
          ),
        ),
      );

      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter the 6-digit OTP.',
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
            Uri.parse(_verifyOtpApiUrl),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': widget.email,
              'otp': otp,
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
          message ?? 'Unable to verify the OTP.',
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP verified successfully.',
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
            return ResetPasswordPage(
              email: widget.email,
              otp: otp,
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
  // BACK
  // ============================================================

  void _goBack() {
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
                _updateParallax(event, size);
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
                      child: _buildOtpForm(),
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
  // OTP FORM
  // ============================================================

  Widget _buildOtpForm() {
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
            Icons.mark_email_read_outlined,
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
            'Verify OTP',
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
            'Enter the 6-digit verification code sent to ${widget.email}.',
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
            controller: _otpController,
            hintText: '6-Digit OTP',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
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
              label: 'VERIFY OTP',
              loading: _isSubmitting,
              onPressed: _isSubmitting
                  ? null
                  : _verifyOtp,
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
                : _goBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 17,
              color: Color(0xFFD8B64B),
            ),
            label: const Text(
              'Back',
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