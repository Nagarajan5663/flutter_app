import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../dashboard/dashboard_page.dart';
import '../home/home_page.dart';
import '../sidebar/sales/workflow_session.dart';

import '../../widgets/futuristic_auth_widgets.dart';
import '../../widgets/futuristic_aurora_background.dart';

import 'signup_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _loginApiUrl =
      'http://localhost:3000/api/users/login';

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _isSubmitting = false;

  double _mouseX = 0;
  double _mouseY = 0;

  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();

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
        ((event.localPosition.dx / size.width) - 0.5) * 2;

    final dy =
        ((event.localPosition.dy / size.height) - 0.5) * 2;

    setState(() {
      _mouseX = dx.clamp(
        -1.0,
        1.0,
      );

      _mouseY = dy.clamp(
        -1.0,
        1.0,
      );
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleSignIn() async {
    if (_isSubmitting) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your email and password.',
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
            Uri.parse(_loginApiUrl),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      final dynamic decoded = jsonDecode(
        response.body,
      );

      if (response.statusCode != 200 ||
          decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        final message = decoded is Map
            ? decoded['message']?.toString()
            : null;

        throw Exception(
          message ?? 'Unable to sign in.',
        );
      }

      final dynamic user = decoded['data'];

      if (user is! Map<String, dynamic>) {
        throw Exception(
          'Invalid sign-in response.',
        );
      }

      final permissions = user['permissions'] is List
          ? (user['permissions'] as List)
              .whereType<String>()
              .toList()
          : <String>[];
      SalesWorkflowSession.token = user['workflowToken']?.toString();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            userEmail:
                user['email']?.toString() ?? email,
            permissions: permissions,
          ),
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
  // SIGNUP
  // ============================================================

  void _goToSignUp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(
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
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void _goToForgotPassword() {
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
          return const ForgotPasswordPage();
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
  }

  // ============================================================
  // HOME
  // ============================================================

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
      ),
      (_) => false,
    );
  }

  // ============================================================
  // HOME BUTTON
  // ============================================================

  Widget _buildHomeButton() {
    return Transform.translate(
      offset: const Offset(
        18,
        -8,
      ),
      child: Tooltip(
        message: 'Go to Home',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _goHome,
            borderRadius: BorderRadius.circular(
              18,
            ),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.22,
                  ),
                ),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 19,
              ),
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
      body: FuturisticAuroraBackground(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final Size size = Size(
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
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ==================================================
                  // LOGIN CARD
                  // ==================================================

                  Center(
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
                          milliseconds: 850,
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
                                scale:
                                    0.94 +
                                    opacity * 0.06,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: PremiumGlassAuthCard(
                          mouseX: _mouseX,
                          mouseY: _mouseY,
                          child: _buildLoginForm(),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
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

              Align(
                alignment: Alignment.topRight,
                child: AuthReveal(
                  index: 0,
                  child: _buildHomeButton(),
                ),
              ),
            ],
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
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(
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

        AuthReveal(
          index: 4,
          child: PremiumAuthField(
            controller: _emailController,
            hintText: 'Email Address',
            icon: Icons.mail_outline,
            keyboardType:
                TextInputType.emailAddress,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        AuthReveal(
          index: 5,
          child: PremiumAuthField(
            controller: _passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            onToggleObscure: () {
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

        // ========================================================
        // FORGOT PASSWORD
        // ========================================================

        AuthReveal(
          index: 6,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goToForgotPassword,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(
                    0xFFD8B64B,
                  ),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
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
            width: double.infinity,
            child: GradientLoginButton(
              label: 'Login',
              loading: _isSubmitting,
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
                MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.54,
                  ),
                  fontSize: 13,
                ),
              ),

              GestureDetector(
                onTap: _goToSignUp,
                child: const Text(
                  'Create one',
                  style: TextStyle(
                    color: Color(
                      0xFFD8B64B,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
