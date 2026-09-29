import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// MANAGE USERS PAGE
// ============================================================================

class ManageUsersPage extends StatefulWidget {
  final VoidCallback onBack;

  const ManageUsersPage({
    super.key,
    required this.onBack,
  });

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  static const String _usersApiUrl =
      'http://localhost:3000/api/users';

  final List<_UserData> _users = [];

  bool _loading = true;
  bool _busy = false;

  bool _showMessage = false;
  bool _messageIsError = false;

  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showPageMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    setState(() {
      _message = message;
      _messageIsError = isError;
      _showMessage = true;
    });

    Future.delayed(
      const Duration(seconds: 4),
      () {
        if (!mounted) return;

        setState(() {
          _showMessage = false;
        });
      },
    );
  }

  // ==========================================================================
  // RESPONSE MESSAGE
  // ==========================================================================

  String _extractMessage(
    http.Response response,
    String fallback,
  ) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final dynamic message = decoded['message'];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}

    return fallback;
  }

  // ==========================================================================
  // LOAD USERS
  // ==========================================================================

  Future<void> _loadUsers() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(_usersApiUrl),
        headers: const {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          _extractMessage(
            response,
            'Failed to load users',
          ),
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid users response');
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ??
              'Failed to load users',
        );
      }

      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw Exception('Invalid users data');
      }

      final loadedUsers = rawData
          .whereType<Map>()
          .map(
            (item) => _UserData.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _users
          ..clear()
          ..addAll(loadedUsers);
      });
    } catch (error) {
      _showPageMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ==========================================================================
  // CREATE PRIMARY SUPER ADMIN
  // ==========================================================================

  Future<void> _createPrimarySuperAdmin() async {
    if (_busy) return;

    final _PrimaryAdminFormData? form =
        await showDialog<_PrimaryAdminFormData>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.48,
      ),
      builder: (context) {
        return const _CreatePrimaryAdminDialog();
      },
    );

    if (form == null) return;

    setState(() {
      _busy = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          '$_usersApiUrl/setup',
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': form.email,
          'password': form.password,
          'role': form.role,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(
          _extractMessage(
            response,
            'Failed to create Primary Super Admin',
          ),
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
                  'Failed to create Primary Super Admin'
              : 'Failed to create Primary Super Admin',
        );
      }

      await _loadUsers();

      _showPageMessage(
        'Primary Super Admin created successfully!',
      );
    } catch (error) {
      _showPageMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // ==========================================================================
  // ADD USER
  // ==========================================================================

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

    if (form == null) return;

    setState(() {
      _busy = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_usersApiUrl),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': form.email,
          'password': form.password,
          'role': form.role,
          'canDeactivate': form.canDeactivate,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(
          _extractMessage(
            response,
            'Failed to create user',
          ),
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
                  'Failed to create user'
              : 'Failed to create user',
        );
      }

      await _loadUsers();

      _showPageMessage(
        'User created successfully!',
      );
    } catch (error) {
      _showPageMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // ==========================================================================
  // EDIT USER
  // ==========================================================================

  Future<void> _editUser(
    _UserData user,
  ) async {
    if (_busy) return;

    final _UserFormData? form =
        await showDialog<_UserFormData>(
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

    if (form == null) return;

    setState(() {
      _busy = true;
    });

    try {
      final Map<String, dynamic> body = {
        'email': form.email,
        'role': form.role,
      };

      if (form.password.trim().isNotEmpty) {
        body['password'] = form.password;
      }

      final response = await http.put(
        Uri.parse(
          '$_usersApiUrl/${user.id}',
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          _extractMessage(
            response,
            'Failed to update user',
          ),
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
                  'Failed to update user'
              : 'Failed to update user',
        );
      }

      await _loadUsers();

      _showPageMessage(
        'User updated successfully!',
      );
    } catch (error) {
      _showPageMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // ==========================================================================
  // DELETE USER
  // ==========================================================================

  Future<void> _deleteUser(
    _UserData user,
  ) async {
    if (_busy) return;

    if (user.isPrimarySuperAdmin) {
      _showPageMessage(
        'The Primary Super Admin cannot be deleted.',
        isError: true,
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Delete User',
          ),
          content: Text(
            'Are you sure you want to permanently delete ${user.email}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23C3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final response = await http.delete(
        Uri.parse(
          '$_usersApiUrl/${user.id}',
        ),
        headers: const {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          _extractMessage(
            response,
            'Failed to delete user',
          ),
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
                  'Failed to delete user'
              : 'Failed to delete user',
        );
      }

      await _loadUsers();

      _showPageMessage(
        'User deleted successfully!',
      );
    } catch (error) {
      _showPageMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // ==========================================================================
  // DEACTIVATE USER
  // ==========================================================================

  Future<void> _deactivateUser(
    _UserData user,
  ) async {
    if (_busy) return;

    if (user.isPrimarySuperAdmin) {
      _showPageMessage(
        'The Primary Super Admin cannot be deactivated.',
        isError: true,
      );
      return;
    }

    if (!user.canDeactivate) {
      _showPageMessage(
        'This user cannot be deactivated.',
        isError: true,
      );
      return;
    }

    if (!user.active) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Deactivate User',
          ),
          content: Text(
            'Are you sure you want to deactivate ${user.email}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23C3C),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _busy = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          '$_usersApiUrl/${user.id}/status',
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'active': false,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          _extractMessage(
            response,
            'Failed to deactivate user',
          ),
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw Exception(
          decoded is Map
              ? decoded['message']?.toString() ??
                  'Failed to deactivate user'
              : 'Failed to deactivate user',
        );
      }

      await _loadUsers();

      _showPageMessage(
        'User deactivated successfully!',
      );
    } catch (error) {
      _showPageMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

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

  // ==========================================================================
  // TABLE
  // ==========================================================================

  Widget _buildUsersTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3.0),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(1.1),
        3: FlexColumnWidth(1.4),
        4: FlexColumnWidth(3.0),
      },
      border: TableBorder.all(
        color: const Color(0xFFDDE2E5),
        width: 1,
      ),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F8F9),
          ),
          children: [
            _headerCell('Email Address'),
            _headerCell('Role'),
            _headerCell('Status'),
            _headerCell('Primary'),
            _headerCell('Actions'),
          ],
        ),

        for (final user in _users)
          TableRow(
            children: [
              _tableCell(
                user.email,
                bold: true,
              ),
              _tableCell(
                user.role,
              ),
              _statusCell(
                user,
              ),
              _primaryCell(
                user,
              ),
              _actionsCell(
                user,
              ),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(
    String text,
  ) {
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

  // ==========================================================================
  // PRIMARY CELL
  // ==========================================================================

  Widget _primaryCell(
    _UserData user,
  ) {
    if (!user.isPrimarySuperAdmin) {
      return _tableCell('-');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 11,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFECEEFF),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: const Text(
            'PRIMARY ADMIN',
            style: TextStyle(
              color: Color(0xFF5059B8),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // STATUS
  // ==========================================================================

  Widget _statusCell(
    _UserData user,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding:
              const EdgeInsets.symmetric(
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
            user.active
                ? 'ACTIVE'
                : 'INACTIVE',
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

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  Widget _actionsCell(
    _UserData user,
  ) {
    final bool isPrimary =
        user.isPrimarySuperAdmin;

    final bool canDeactivate =
        !isPrimary &&
        user.canDeactivate &&
        user.active &&
        !_busy;

    final bool canDelete =
        !isPrimary && !_busy;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          _HoverAction(
            icon: Icons.edit_rounded,
            label: 'Edit',
            color:
                const Color(0xFF1688E8),
            hoverColor:
                const Color(0xFFE8F4FF),
            enabled: !_busy,
            onTap: () {
              _editUser(user);
            },
          ),

          if (!isPrimary) ...[
            const SizedBox(width: 7),

            _HoverAction(
              icon: Icons
                  .pause_circle_outline_rounded,
              label: 'Deactivate',
              color: canDeactivate
                  ? const Color(0xFFE23C3C)
                  : const Color(0xFF8D9498),
              hoverColor: canDeactivate
                  ? const Color(0xFFFFEAEA)
                  : Colors.transparent,
              enabled: canDeactivate,
              onTap: () {
                _deactivateUser(user);
              },
            ),

            const SizedBox(width: 7),

            _HoverAction(
              icon: Icons.delete_rounded,
              label: 'Delete',
              color: canDelete
                  ? const Color(0xFFB42318)
                  : const Color(0xFF8D9498),
              hoverColor: canDelete
                  ? const Color(0xFFFFEAEA)
                  : Colors.transparent,
              enabled: canDelete,
              onTap: () {
                _deleteUser(user);
              },
            ),
          ],

          if (isPrimary)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              child: Text(
                'Protected',
                style: TextStyle(
                  color: Color(0xFF777D81),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP BUTTON
// ============================================================================

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
  State<_TopButton> createState() => _TopButtonState();
}

class _TopButtonState
    extends State<_TopButton> {
  bool _hovered = false;

  @override
  Widget build(
    BuildContext context,
  ) {
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

// ============================================================================
// ACTION BUTTON
// ============================================================================

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
  State<_HoverAction> createState() => _HoverActionState();
}

class _HoverActionState
    extends State<_HoverAction> {
  bool _hovered = false;

  @override
  Widget build(
    BuildContext context,
  ) {
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

// ============================================================================
// CREATE PRIMARY SUPER ADMIN DIALOG
// ============================================================================

class _CreatePrimaryAdminDialog
    extends StatefulWidget {
  const _CreatePrimaryAdminDialog();

  @override
  State<_CreatePrimaryAdminDialog>
      createState() =>
          _CreatePrimaryAdminDialogState();
}

class _CreatePrimaryAdminDialogState
    extends State<_CreatePrimaryAdminDialog> {
  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  String _role = 'Super Admin';

  String? _error;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _save() {
    final String email =
        _emailController.text.trim().toLowerCase();

    final String password =
        _passwordController.text;

    final String confirmPassword =
        _confirmPasswordController.text;

    if (!_isValidEmail(email)) {
      setState(() {
        _error =
            'Enter a valid email address.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _error = 'Password is required.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error =
            'Password must contain at least 6 characters.';
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _error =
            'Confirm your password.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error =
            'Passwords do not match.';
      });
      return;
    }

    Navigator.pop(
      context,
      _PrimaryAdminFormData(
        email: email,
        password: password,
        role: _role,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(11),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 505,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogHeader(
                context: context,
                title:
                    'Create Primary Super Admin',
              ),

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  25,
                  25,
                  25,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFECEEFF),
                        borderRadius:
                            BorderRadius.circular(
                          6,
                        ),
                      ),
                      child: const Text(
                        'This is the first administrator account. It will automatically become the Primary Super Admin and cannot be deactivated or deleted.',
                        style: TextStyle(
                          color:
                              Color(0xFF5059B8),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_error != null) ...[
                      _dialogError(_error!),
                      const SizedBox(height: 18),
                    ],

                    _fieldLabel(
                      'Email Address',
                    ),

                    const SizedBox(height: 9),

                    _dialogTextField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // ROLE
                    // ---------------------------------------------------------

                    _fieldLabel(
                      'Role',
                    ),

                    const SizedBox(height: 9),

                    _roleDropdown(
                      value: _role,
                      onChanged: null,
                    ),

                    const SizedBox(height: 20),

                    _fieldLabel(
                      'Password',
                    ),

                    const SizedBox(height: 9),

                    _dialogTextField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                          color: const Color(
                            0xFF777D81,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _fieldLabel(
                      'Confirm Password',
                    ),

                    const SizedBox(height: 9),

                    _dialogTextField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                          color: const Color(
                            0xFF777D81,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _dialogFooter(
                context: context,
                saveLabel:
                    'Create Administrator',
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EDIT USER DIALOG
// ============================================================================

class _EditUserDialog
    extends StatefulWidget {
  final _UserData user;

  const _EditUserDialog({
    required this.user,
  });

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController _emailController;

  final TextEditingController _passwordController =
      TextEditingController();

  late String _role;

  String? _error;

  @override
  void initState() {
    super.initState();

    _emailController =
        TextEditingController(
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

  void _save() {
    final String email =
        _emailController.text.trim().toLowerCase();

    final String password =
        _passwordController.text;

    if (!_isValidEmail(email)) {
      setState(() {
        _error =
            'Enter a valid email address.';
      });
      return;
    }

    if (password.isNotEmpty &&
        password.length < 6) {
      setState(() {
        _error =
            'Password must contain at least 6 characters.';
      });
      return;
    }

    Navigator.pop(
      context,
      _UserFormData(
        email: email,
        role: _role,
        password: password,
        canDeactivate:
            widget.user.canDeactivate,
      ),
    );
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

// ============================================================================
// ADD USER DIALOG
// ============================================================================

class _AddUserDialog
    extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState
    extends State<_AddUserDialog> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  String? _role;

  bool _canDeactivate = true;

  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _save() {
    final String email =
        _emailController.text.trim().toLowerCase();

    final String password =
        _passwordController.text;

    if (!_isValidEmail(email)) {
      setState(() {
        _error =
            'Enter a valid email address.';
      });
      return;
    }

    if (_role == null) {
      setState(() {
        _error = 'Select a role.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _error =
            'Password is required.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error =
            'Password must contain at least 6 characters.';
      });
      return;
    }

    Navigator.pop(
      context,
      _UserFormData(
        email: email,
        role: _role!,
        password: password,
        canDeactivate:
            _canDeactivate,
      ),
    );
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

// ============================================================================
// DIALOG HEADER
// ============================================================================

Widget _dialogHeader({
  required BuildContext context,
  required String title,
}) {
  return Container(
    padding:
        const EdgeInsets.fromLTRB(
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

// ============================================================================
// DIALOG FOOTER
// ============================================================================

Widget _dialogFooter({
  required BuildContext context,
  required VoidCallback onSave,
  String saveLabel = 'Save User',
}) {
  return Container(
    width: double.infinity,
    padding:
        const EdgeInsets.fromLTRB(
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
      mainAxisAlignment:
          MainAxisAlignment.end,
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
            padding:
                const EdgeInsets.symmetric(
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
            padding:
                const EdgeInsets.symmetric(
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

// ============================================================================
// FIELD LABEL
// ============================================================================

Widget _fieldLabel(
  String text,
) {
  return Text(
    text,
    style: const TextStyle(
      color: Color(0xFF676D71),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

// ============================================================================
// TEXT FIELD
// ============================================================================

Widget _dialogTextField({
  required TextEditingController controller,
  bool obscureText = false,
  TextInputType? keyboardType,
  Widget? suffixIcon,
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

// ============================================================================
// ROLE DROPDOWN
// ============================================================================

Widget _roleDropdown({
  required String? value,
  required ValueChanged<String?>? onChanged,
  String? hint,
}) {
  const List<String> roles = [
    'Super Admin',
    'Procurement',
  ];

  String? safeValue = value;

  if (safeValue != null &&
      !roles.contains(safeValue)) {
    safeValue = null;
  }

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

// ============================================================================
// ERROR BOX
// ============================================================================

Widget _dialogError(
  String message,
) {
  return Container(
    width: double.infinity,
    padding:
        const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE7E7),
      borderRadius:
          BorderRadius.circular(5),
      border: Border.all(
        color: const Color(0xFFF2B8B5),
      ),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: Color(0xFFB42318),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

// ============================================================================
// EMAIL VALIDATION
// ============================================================================

bool _isValidEmail(
  String email,
) {
  final RegExp emailPattern = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  return emailPattern.hasMatch(email);
}

// ============================================================================
// PRIMARY ADMIN FORM DATA
// ============================================================================

class _PrimaryAdminFormData {
  final String email;
  final String password;
  final String role;

  const _PrimaryAdminFormData({
    required this.email,
    required this.password,
    required this.role,
  });
}

// ============================================================================
// USER FORM DATA
// ============================================================================

class _UserFormData {
  final String email;
  final String role;
  final String password;
  final bool canDeactivate;

  const _UserFormData({
    required this.email,
    required this.role,
    required this.password,
    required this.canDeactivate,
  });
}

// ============================================================================
// USER MODEL
// ============================================================================

class _UserData {
  final int id;

  String email;

  final int roleId;

  String role;

  bool active;

  final bool canDeactivate;

  final bool isPrimarySuperAdmin;

  _UserData({
    required this.id,
    required this.email,
    required this.roleId,
    required this.role,
    required this.active,
    required this.canDeactivate,
    required this.isPrimarySuperAdmin,
  });

  factory _UserData.fromJson(
    Map<String, dynamic> json,
  ) {
    return _UserData(
      id: _toInt(json['id']),
      email:
          json['email']?.toString() ?? '',
      roleId:
          _toInt(json['roleId']),
      role:
          json['role']?.toString() ?? '',
      active:
          _toBool(json['active']),
      canDeactivate:
          _toBool(json['canDeactivate']),
      isPrimarySuperAdmin:
          _toBool(
        json['isPrimarySuperAdmin'],
      ),
    );
  }
}

// ============================================================================
// JSON HELPERS
// ============================================================================

int _toInt(
  dynamic value,
) {
  if (value is int) {
    return value;
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

bool _toBool(
  dynamic value,
) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final String text =
      value?.toString().toLowerCase().trim() ??
          '';

  return text == 'true' ||
      text == '1';
}
