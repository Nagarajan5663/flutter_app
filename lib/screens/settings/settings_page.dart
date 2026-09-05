import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ================================================================
  // SETTINGS VALUES
  // ================================================================

  String selectedTheme = 'Light Mode';
  String selectedLanguage = 'English';

  bool emailNotifications = true;

  // ================================================================
  // SAVE SETTINGS
  // ================================================================

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Preferences saved successfully.',
        ),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F6F9),
      child: Stack(
        children: [
          // ==========================================================
          // BACKGROUND DECORATION
          // ==========================================================

          Positioned(
            left: -180,
            top: 30,
            child: Container(
              width: 650,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),

          Positioned(
            right: -120,
            top: -80,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),

          // ==========================================================
          // MAIN CONTENT
          // ==========================================================

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              30,
              35,
              30,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====================================================
                // PAGE TITLE
                // ====================================================

                const Text(
                  'Preferences',
                  style: TextStyle(
                    color: Color(0xFF12395D),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 30),

                // ====================================================
                // SETTINGS CARD
                // ====================================================

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 820,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // ==========================================
                          // FORM CONTENT
                          // ==========================================

                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              32,
                              30,
                              32,
                              28,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // ====================================
                                // THEME + LANGUAGE
                                // ====================================

                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildDropdownField(
                                        label: 'Application Theme',
                                        value: selectedTheme,
                                        items: const [
                                          'Light Mode',
                                          'Dark Mode',
                                          'System Default',
                                        ],
                                        onChanged: (value) {
                                          if (value == null) return;

                                          setState(() {
                                            selectedTheme = value;
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 30),

                                    Expanded(
                                      child: _buildDropdownField(
                                        label: 'Language',
                                        value: selectedLanguage,
                                        items: const [
                                          'English',
                                          'Tamil',
                                          'Hindi',
                                        ],
                                        onChanged: (value) {
                                          if (value == null) return;

                                          setState(() {
                                            selectedLanguage = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 55),

                                // ====================================
                                // DIVIDER
                                // ====================================

                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE0E0E0),
                                ),

                                const SizedBox(height: 40),

                                // ====================================
                                // EMAIL NOTIFICATIONS
                                // ====================================

                                const Text(
                                  'Email Notifications',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value:
                                            emailNotifications,
                                        activeColor:
                                            const Color(
                                              0xFF1683F8,
                                            ),
                                        onChanged: (value) {
                                          setState(() {
                                            emailNotifications =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    const Text(
                                      'Receive email updates and alerts',
                                      style: TextStyle(
                                        color: Color(0xFF444444),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ==========================================
                          // BOTTOM BUTTON AREA
                          // ==========================================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              32,
                              20,
                              32,
                              20,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFE5E5E5),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _savePreferences,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF1683F8),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 14,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Preferences',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }

  // ================================================================
  // DROPDOWN FIELD
  // ================================================================

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,

          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),

          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFDADADA),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFDADADA),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF1683F8),
                width: 1.5,
              ),
            ),
          ),

          dropdownColor: Colors.white,

          items: items.map(
            (item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }
}