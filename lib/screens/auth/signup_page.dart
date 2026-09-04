import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/animated_auth_background.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/codexia_logo.dart';
import '../dashboard/dashboard_page.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
const SignUpPage({super.key});

@override
State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
final _orgNameController = TextEditingController();
final _orgEmailController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();

bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
bool _isSubmitting = false;

@override
void dispose() {
_orgNameController.dispose();
_orgEmailController.dispose();
_passwordController.dispose();
_confirmPasswordController.dispose();
super.dispose();
}

Future<void> _handleCreateAccount() async {
setState(() {
  _isSubmitting = true;
});

// Temporary delay.
// Later, replace this with your real registration API/Firebase.
await Future.delayed(const Duration(milliseconds: 500));

if (!mounted) return;

setState(() {
  _isSubmitting = false;
});

// Temporary navigation:
// Sign Up -> Dashboard
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => const DashboardPage(),
  ),
);

}

void _goToSignIn() {
Navigator.of(context).pushReplacement(
MaterialPageRoute(
builder: (_) => const LoginPage(),
),
);
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
icon: const Icon(
Icons.arrow_back,
color: Colors.white,
),
),
),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: CodexiaColors.card.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CodexiaColors.cardBorder.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.35,
                        ),
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
                        'Create Your Digital Librarian Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CodexiaColors.muted,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 34),

                      AuthTextField(
                        controller: _orgNameController,
                        hintText: 'Organization Name',
                        icon: Icons.apartment_outlined,
                      ),

                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _orgEmailController,
                        hintText: 'Organization Email',
                        icon: Icons.mail_outline,
                        keyboardType:
                            TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      AuthTextField(
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

                      const SizedBox(height: 16),

                      AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        icon: Icons.check_circle_outline,
                        obscureText:
                            _obscureConfirmPassword,
                        onToggleObscure: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : _handleCreateAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                CodexiaColors.gold,
                            foregroundColor:
                                CodexiaColors.navyDark,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color:
                                        CodexiaColors.navyDark,
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        color: CodexiaColors.cardBorder,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: CodexiaColors.white,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToSignIn,
                            child: const Text(
                              'Sign In',
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
