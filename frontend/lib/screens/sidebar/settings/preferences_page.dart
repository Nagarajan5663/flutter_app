import 'dart:ui';

import 'package:flutter/material.dart';

class PreferencesPage extends StatefulWidget {
  final VoidCallback onBack;

  const PreferencesPage({
    super.key,
    required this.onBack,
  });

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String _theme = 'Light Mode';
  String _language = 'English';
  bool _emailNotifications = false;

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10233A),
            Color(0xFF241B42),
            Color(0xFF152134),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -100,
            child: IgnorePointer(
              child: _blurOrb(size: 420, color: const Color(0xFF4F9FD6), alpha: 0.35),
            ),
          ),
          Positioned(
            bottom: -220,
            left: -150,
            child: IgnorePointer(
              child: _blurOrb(size: 430, color: const Color(0xFF9B6FD6), alpha: 0.30),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1035),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ==========================================================
                    // GLASS CARD
                    // ==========================================================

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.16),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(30, 30, 30, 38),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 650;
                                    final fields = [
                                      _dropdown(
                                        label: 'Application Theme',
                                        value: _theme,
                                        items: const ['Light Mode', 'Dark Mode'],
                                        onChanged: (value) => setState(() => _theme = value!),
                                      ),
                                      _dropdown(
                                        label: 'Language',
                                        value: _language,
                                        items: const ['English', 'Tamil', 'Hindi'],
                                        onChanged: (value) => setState(() => _language = value!),
                                      ),
                                    ];

                                    return Column(
                                      children: [
                                        compact
                                            ? Column(children: [fields[0], const SizedBox(height: 18), fields[1]])
                                            : Row(
                                                children: [
                                                  Expanded(child: fields[0]),
                                                  const SizedBox(width: 30),
                                                  Expanded(child: fields[1]),
                                                ],
                                              ),
                                        const SizedBox(height: 55),
                                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.16)),
                                        const SizedBox(height: 38),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Email Notifications',
                                                style: TextStyle(
                                                  color: Color(0xFFCBD5E1),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Checkbox(
                                                    value: _emailNotifications,
                                                    onChanged: (value) => setState(
                                                      () => _emailNotifications = value ?? false,
                                                    ),
                                                    activeColor: const Color(0xFF1687E8),
                                                    side: BorderSide(
                                                      color: Colors.white.withValues(alpha: 0.45),
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Receive email updates and alerts',
                                                    style: TextStyle(fontSize: 16, color: Color(0xFFF1F5F9)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  border: const Border(top: BorderSide(color: Colors.white24)),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _GlassButton(
                                    label: 'Save Preferences',
                                    onPressed: _savePreferences,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb({required double size, required Color color, required double alpha}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withValues(alpha: alpha), Colors.transparent]),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: const Color(0xFF1E2A3D),
          style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 15),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.6)),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFF6FB6F2)),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// GLASS BUTTON
// ================================================================

class _GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GlassButton({required this.label, required this.onPressed});

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering ? 1.03 : 1,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: hovering
                      ? [const Color(0xFF2E8FE0), const Color(0xFF8460D6)]
                      : [const Color(0xFF1687E8), const Color(0xFF6A4FC0)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                widget.label,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}