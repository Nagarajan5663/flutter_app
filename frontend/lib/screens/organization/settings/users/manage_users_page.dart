import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  final VoidCallback onBack;

  const ManageUsersPage({
    super.key,
    required this.onBack,
  });

  @override
  State<ManageUsersPage> createState() =>
      _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool _showSuccess = false;

  final List<_UserData> _users = [
    _UserData(
      email: 'nagarajanpandurangan2004@gmail.com',
      role: 'Super Admin',
      active: true,
      canDeactivate: false,
    ),
    _UserData(
      email: 'sureshkaniyappan27@gmail.com',
      role: 'Super Admin',
      active: true,
      canDeactivate: true,
    ),
  ];

  // ================================================================
  // SUCCESS MESSAGE
  // ================================================================

  void _showSuccessMessage() {
    setState(() {
      _showSuccess = true;
    });

    Future.delayed(
      const Duration(seconds: 4),
      () {
        if (!mounted) return;

        setState(() {
          _showSuccess = false;
        });
      },
    );
  }

  // ================================================================
  // EDIT USER
  // ================================================================

  Future<void> _editUser(_UserData user) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.48,
      ),
      builder: (context) {
        return _EditUserDialog(
          user: user,
        );
      },
    );

    if (saved == true) {
      _showSuccessMessage();
    }
  }

  // ================================================================
  // ADD USER
  // ================================================================

  Future<void> _addUser() async {
    final _UserData? newUser =
        await showDialog<_UserData>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.48,
      ),
      builder: (context) {
        return const _AddUserDialog();
      },
    );

    if (newUser == null) return;

    setState(() {
      _users.add(newUser);
    });
  }

  // ================================================================
  // DEACTIVATE
  // ================================================================

  void _deactivateUser(_UserData user) {
    if (!user.canDeactivate) return;

    setState(() {
      user.active = false;
    });
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF3F8FA),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          27,
          28,
          40,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================================================
            // TITLE + BUTTONS
            // =======================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manage Users',
                    style: TextStyle(
                      color: Color(0xFF252A2E),
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // BACK TO SETTINGS
                _TopButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'Back to Settings',
                  background:
                      const Color(0xFFECEEFF),
                  foreground:
                      const Color(0xFF5059B8),
                  hoverBackground:
                      const Color(0xFFE1E4FF),
                  onTap: widget.onBack,
                ),

                const SizedBox(width: 15),

                // ADD NEW USER
                _TopButton(
                  icon: Icons.add_rounded,
                  label: 'Add New User',
                  background:
                      const Color(0xFF1FAE4B),
                  foreground: Colors.white,
                  hoverBackground:
                      const Color(0xFF168F3B),
                  onTap: _addUser,
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =======================================================
            // SUCCESS BANNER
            // =======================================================

            if (_showSuccess) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF4E2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'User updated successfully!',
                  style: TextStyle(
                    color: Color(0xFF327B43),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // =======================================================
            // EXISTING USERS CARD
            // =======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                25,
                25,
                25,
                25,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE6EAEC),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Existing Users',
                    style: TextStyle(
                      color: Color(0xFF252A2E),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(
                    height: 1,
                    color: Color(0xFFE2E6E8),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // TABLE
                  // =================================================

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth < 900
                              ? 900
                              : constraints.maxWidth,
                          child: _buildUsersTable(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TABLE
  // ================================================================

  Widget _buildUsersTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3.3),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(0.85),
        3: FlexColumnWidth(1.9),
      },

      border: TableBorder.all(
        color: const Color(0xFFDDE2E5),
        width: 1,
      ),

      children: [
        // HEADER
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F8F9),
          ),
          children: [
            _headerCell('Email Address'),
            _headerCell('Role'),
            _headerCell('Status'),
            _headerCell('Actions'),
          ],
        ),

        // DATA
        for (final user in _users)
          TableRow(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            children: [
              _tableCell(
                user.email,
                bold: true,
              ),
              _tableCell(user.role),
              _statusCell(user),
              _actionsCell(user),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF22272A),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _tableCell(
    String text, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF373C40),
          fontSize: 13,
          fontWeight:
              bold ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  // ================================================================
  // STATUS
  // ================================================================

  Widget _statusCell(_UserData user) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: user.active
                ? const Color(0xFF20B34B)
                : const Color(0xFF90999E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.active ? 'ACTIVE' : 'INACTIVE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ACTIONS
  // ================================================================

  Widget _actionsCell(_UserData user) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          // EDIT
          _HoverAction(
            icon: Icons.edit_rounded,
            label: 'Edit',
            color: const Color(0xFF1688E8),
            hoverColor: const Color(0xFFE8F4FF),
            onTap: () {
              _editUser(user);
            },
          ),

          const SizedBox(width: 7),

          // DEACTIVATE
          _HoverAction(
            icon: Icons.delete_rounded,
            label: 'Deactivate',
            color: user.canDeactivate
                ? const Color(0xFFE23C3C)
                : const Color(0xFF8D9498),
            hoverColor: user.canDeactivate
                ? const Color(0xFFFFEAEA)
                : Colors.transparent,
            enabled: user.canDeactivate,
            onTap: () {
              _deactivateUser(user);
            },
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// TOP BUTTON WITH HOVER
// ==================================================================

class _TopButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color hoverBackground;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.hoverBackground,
    required this.onTap,
  });

  @override
  State<_TopButton> createState() =>
      _TopButtonState();
}

class _TopButtonState extends State<_TopButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: GestureDetector(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 140,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),

          decoration: BoxDecoration(
            color: _hovered
                ? widget.hoverBackground
                : widget.background,

            borderRadius: BorderRadius.circular(7),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: widget.foreground,
              ),

              const SizedBox(width: 7),

              Text(
                widget.label,
                style: TextStyle(
                  color: widget.foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// ACTION HOVER
// ==================================================================

class _HoverAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color hoverColor;
  final VoidCallback onTap;
  final bool enabled;

  const _HoverAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.hoverColor,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<_HoverAction> createState() =>
      _HoverActionState();
}

class _HoverActionState extends State<_HoverAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,

      onEnter: (_) {
        if (!widget.enabled) return;

        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        if (!widget.enabled) return;

        setState(() {
          _hovered = false;
        });
      },

      child: GestureDetector(
        onTap: widget.enabled
            ? widget.onTap
            : null,

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 120),

          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: _hovered
                ? widget.hoverColor
                : Colors.transparent,

            borderRadius: BorderRadius.circular(4),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: widget.color,
              ),

              const SizedBox(width: 3),

              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// EDIT USER DIALOG
// ==================================================================

class _EditUserDialog extends StatefulWidget {
  final _UserData user;

  const _EditUserDialog({
    required this.user,
  });

  @override
  State<_EditUserDialog> createState() =>
      _EditUserDialogState();
}

class _EditUserDialogState
    extends State<_EditUserDialog> {
  late final TextEditingController
      _emailController;

  final TextEditingController _passwordController =
      TextEditingController();

  late String _role;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(
      text: widget.user.email,
    );

    _role = widget.user.role;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 505,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            _dialogHeader(
              context: context,
              title: 'Edit User',
            ),

            // FORM
            Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                25,
                25,
                28,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Email Address'),

                  const SizedBox(height: 9),

                  _dialogTextField(
                    controller: _emailController,
                  ),

                  const SizedBox(height: 20),

                  _fieldLabel('Role'),

                  const SizedBox(height: 9),

                  _roleDropdown(
                    value: _role,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _role = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  _fieldLabel('Password'),

                  const SizedBox(height: 9),

                  _dialogTextField(
                    controller:
                        _passwordController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Leave blank to keep the current password when editing.',
                    style: TextStyle(
                      color: Color(0xFF777D81),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // FOOTER
            _dialogFooter(
              context: context,
              onSave: () {
                widget.user.email =
                    _emailController.text;

                widget.user.role = _role;

                Navigator.pop(
                  context,
                  true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ADD USER DIALOG
// ==================================================================

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() =>
      _AddUserDialogState();
}

class _AddUserDialogState
    extends State<_AddUserDialog> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  String? _role;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 505,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogHeader(
              context: context,
              title: 'Add New User',
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                25,
                25,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Email Address'),

                  const SizedBox(height: 9),

                  _dialogTextField(
                    controller: _emailController,
                  ),

                  const SizedBox(height: 20),

                  _fieldLabel('Role'),

                  const SizedBox(height: 9),

                  _roleDropdown(
                    value: _role,
                    hint: 'Select a role...',
                    onChanged: (value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  _fieldLabel('Password'),

                  const SizedBox(height: 9),

                  _dialogTextField(
                    controller:
                        _passwordController,
                    obscureText: true,
                  ),
                ],
              ),
            ),

            _dialogFooter(
              context: context,
              onSave: () {
                if (_emailController.text.trim().isEmpty ||
                    _role == null) {
                  return;
                }

                Navigator.pop(
                  context,
                  _UserData(
                    email:
                        _emailController.text.trim(),
                    role: _role!,
                    active: true,
                    canDeactivate: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// SHARED DIALOG PARTS
// ==================================================================

Widget _dialogHeader({
  required BuildContext context,
  required String title,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(
      25,
      20,
      18,
      20,
    ),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFE2E5E7),
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF303538),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFFA6AAAC),
            size: 24,
          ),
        ),
      ],
    ),
  );
}

Widget _dialogFooter({
  required BuildContext context,
  required VoidCallback onSave,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(
      25,
      16,
      25,
      16,
    ),
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Color(0xFFE2E5E7),
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFFE6E7E8),
            foregroundColor:
                const Color(0xFF4F5558),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(6),
            ),
          ),

          child: const Text('Cancel'),
        ),

        const SizedBox(width: 10),

        ElevatedButton(
          onPressed: onSave,

          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF20AE49),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 19,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(6),
            ),
          ),

          child: const Text('Save User'),
        ),
      ],
    ),
  );
}

Widget _fieldLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: Color(0xFF676D71),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget _dialogTextField({
  required TextEditingController controller,
  bool obscureText = false,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,

    style: const TextStyle(
      color: Color(0xFF333333),
      fontSize: 14,
    ),

    decoration: InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD9DFE2),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF8ABFE8),
        ),
      ),
    ),
  );
}

Widget _roleDropdown({
  required String? value,
  required ValueChanged<String?> onChanged,
  String? hint,
}) {
  /*
    IMPORTANT:
    The uploaded video does not open this dropdown.
    "Super Admin" is the only role value visible in the video.

    Add the remaining exact roles here only after confirming
    them from your reference.
  */
  const roles = [
    'Super Admin',
  ];

  return DropdownButtonFormField<String>(
    initialValue: value,

    hint: hint == null
        ? null
        : Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF363B3E),
              fontSize: 14,
            ),
          ),

    isExpanded: true,

    dropdownColor: Colors.white,

    borderRadius: BorderRadius.circular(6),

    icon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Color(0xFF222222),
      size: 21,
    ),

    style: const TextStyle(
      color: Color(0xFF303538),
      fontSize: 14,
    ),

    decoration: InputDecoration(
      isDense: true,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD9DFE2),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF8ABFE8),
        ),
      ),
    ),

    items: roles.map((role) {
      return DropdownMenuItem<String>(
        value: role,
        child: Text(role),
      );
    }).toList(),

    onChanged: onChanged,
  );
}

// ==================================================================
// DATA MODEL
// ==================================================================

class _UserData {
  String email;
  String role;
  bool active;
  final bool canDeactivate;

  _UserData({
    required this.email,
    required this.role,
    required this.active,
    required this.canDeactivate,
  });
}