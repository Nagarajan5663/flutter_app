import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/animated_auth_background.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/codexia_logo.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  bool _validate() {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? 'Enter your email address'
          : (!_emailController.text.contains('@')
                ? 'Enter a valid email address'
                : null);

      _passwordError = _passwordController.text.isEmpty
          ? 'Enter your password'
          : null;
    });

    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleSignIn() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    // TODO: Replace this with your real authentication call
    // (e.g. Firebase Auth, a REST API, etc). This delay is a placeholder
    // so the button shows a loading state.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showMessage('Signed in as ${_emailController.text.trim()}');
  }

  void _goToSignUp() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const SignUpPage()));
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 16,
                child: IconButton(
                  onPressed: _goBack,
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        color: CodexiaColors.card.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CodexiaColors.cardBorder.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CodexiaLogo(),

                          const SizedBox(height: 14),

                          const Text(
                            'Your Digital Librarian',
                            style: TextStyle(
                              color: CodexiaColors.muted,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 34),

                          AuthTextField(
                            controller: _emailController,
                            hintText: 'Email Address',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                          ),

                          const SizedBox(height: 16),

                          AuthTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            errorText: _passwordError,
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  _showMessage('Password reset coming soon.'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: CodexiaColors.gold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CodexiaColors.gold,
                                foregroundColor: CodexiaColors.navyDark,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: CodexiaColors.navyDark,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Divider(color: CodexiaColors.cardBorder),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: CodexiaColors.white,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToSignUp,
                                child: const Text(
                                  'Create one',
                                  style: TextStyle(
                                    color: CodexiaColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
