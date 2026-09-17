import 'package:flutter/material.dart';

class ManageRolesPage extends StatefulWidget {
  final VoidCallback onBack;

  const ManageRolesPage({
    super.key,
    required this.onBack,
  });

  @override
  State<ManageRolesPage> createState() =>
      _ManageRolesPageState();
}

class _ManageRolesPageState extends State<ManageRolesPage> {
  final List<_RoleData> _roles = [
    _RoleData(
      name: 'Procurement',
      description: 'For vendor and purchase management',
      permissions: {
        'Dashboard',
        'Items',
        'Inventory',
        'Purchase',
      },
    ),
    _RoleData(
      name: 'Super Admin',
      description: 'Full administrative access.',
      permissions: {},
    ),
  ];

  Future<void> _openEditRole(_RoleData role) async {
    final _RoleData? updatedRole =
        await showDialog<_RoleData>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.48,
      ),
      builder: (context) {
        return _RoleDialog(
          title: 'Edit Role',
          role: role,
        );
      },
    );

    if (updatedRole == null) return;

    setState(() {
      role.name = updatedRole.name;
      role.description = updatedRole.description;

      role.permissions
        ..clear()
        ..addAll(updatedRole.permissions);
    });
  }

  Future<void> _openAddRole() async {
    final _RoleData? newRole =
        await showDialog<_RoleData>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.48,
      ),
      builder: (context) {
        return const _RoleDialog(
          title: 'Add New Role',
        );
      },
    );

    if (newRole == null) return;

    setState(() {
      _roles.add(newRole);
    });
  }

  void _deleteRole(_RoleData role) {
    setState(() {
      _roles.remove(role);
    });
  }

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
            // =====================================================
            // HEADER
            // =====================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manage Roles',
                    style: TextStyle(
                      color: Color(0xFF252A2E),
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                _HeaderButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'Back to Settings',
                  backgroundColor:
                      const Color(0xFFEDEFFF),
                  hoverColor:
                      const Color(0xFFE2E5FF),
                  foregroundColor:
                      const Color(0xFF5554B8),
                  onTap: widget.onBack,
                ),

                const SizedBox(width: 15),

                _HeaderButton(
                  icon: Icons.add_rounded,
                  label: 'Add New Role',
                  backgroundColor:
                      const Color(0xFF1CAD4B),
                  hoverColor:
                      const Color(0xFF158F3C),
                  foregroundColor: Colors.white,
                  onTap: _openAddRole,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================================
            // EXISTING ROLES CARD
            // =====================================================

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
                  color: const Color(0xFFE7EBED),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Existing Roles',
                    style: TextStyle(
                      color: Color(0xFF252A2E),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(
                    height: 1,
                    color: Color(0xFFE1E5E7),
                  ),

                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                        child: SizedBox(
                          width: constraints.maxWidth < 950
                              ? 950
                              : constraints.maxWidth,

                          child: _buildRolesTable(),
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

  // ===============================================================
  // TABLE
  // ===============================================================

  Widget _buildRolesTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.35),
        1: FlexColumnWidth(3.45),
        2: FlexColumnWidth(2.9),
        3: FlexColumnWidth(1.8),
      },

      border: TableBorder.all(
        color: const Color(0xFFD9DFE2),
        width: 1,
      ),

      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7F7),
          ),
          children: [
            _headerCell('Role Name'),
            _headerCell('Description'),
            _headerCell('Permissions'),
            _headerCell('Actions'),
          ],
        ),

        for (final role in _roles)
          TableRow(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            children: [
              _normalCell(
                role.name,
                bold: true,
              ),

              _normalCell(
                role.description,
              ),

              _permissionsCell(role),

              _actionsCell(role),
            ],
          ),
      ],
    );
  }

  Widget _headerCell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF272B2E),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _normalCell(
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 18,
      ),
      child: Text(
        value,
        style: TextStyle(
          color: const Color(0xFF535A5E),
          fontSize: 13,
          fontWeight:
              bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _permissionsCell(_RoleData role) {
    final String permissions =
        role.permissions.isEmpty
            ? 'None'
            : _permissionOrder
                .where(
                  role.permissions.contains,
                )
                .join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 18,
      ),
      child: Text(
        permissions,
        style: TextStyle(
          color: const Color(0xFF60676A),
          fontSize: 12,
          fontStyle: role.permissions.isEmpty
              ? FontStyle.italic
              : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _actionsCell(_RoleData role) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),

      child: Row(
        children: [
          _ActionButton(
            icon: Icons.edit_rounded,
            label: 'Edit',
            foreground:
                const Color(0xFF1688E8),
            hoverColor:
                const Color(0xFFE9F4FE),
            onTap: () {
              _openEditRole(role);
            },
          ),

          const SizedBox(width: 9),

          _ActionButton(
            icon: Icons.delete_rounded,
            label: 'Delete',
            foreground:
                const Color(0xFFD83345),
            hoverColor:
                const Color(0xFFFFEAEC),
            onTap: () {
              _deleteRole(role);
            },
          ),
        ],
      ),
    );
  }
}

// =================================================================
// HEADER BUTTON
// =================================================================

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color hoverColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.hoverColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  State<_HeaderButton> createState() =>
      _HeaderButtonState();
}

class _HeaderButtonState
    extends State<_HeaderButton> {
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
          duration:
              const Duration(milliseconds: 140),

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),

          decoration: BoxDecoration(
            color: _hovered
                ? widget.hoverColor
                : widget.backgroundColor,

            borderRadius: BorderRadius.circular(7),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.foregroundColor,
                size: 17,
              ),

              const SizedBox(width: 7),

              Text(
                widget.label,
                style: TextStyle(
                  color: widget.foregroundColor,
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

// =================================================================
// EDIT / DELETE HOVER
// =================================================================

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color hoverColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() =>
      _ActionButtonState();
}

class _ActionButtonState
    extends State<_ActionButton> {
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
                color: widget.foreground,
              ),

              const SizedBox(width: 3),

              Text(
                widget.label,
                style: TextStyle(
                  color: widget.foreground,
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

// =================================================================
// ROLE DIALOG
// =================================================================

class _RoleDialog extends StatefulWidget {
  final String title;
  final _RoleData? role;

  const _RoleDialog({
    required this.title,
    this.role,
  });

  @override
  State<_RoleDialog> createState() =>
      _RoleDialogState();
}

class _RoleDialogState extends State<_RoleDialog> {
  late final TextEditingController
      _nameController;

  late final TextEditingController
      _descriptionController;

  late Set<String> _selectedPermissions;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.role?.name ?? '',
    );

    _descriptionController =
        TextEditingController(
      text: widget.role?.description ?? '',
    );

    _selectedPermissions = {
      ...?widget.role?.permissions,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _togglePermission(
    String permission,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedPermissions.add(
          permission,
        );
      } else {
        _selectedPermissions.remove(
          permission,
        );
      }
    });
  }

  void _saveRole() {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    Navigator.pop(
      context,
      _RoleData(
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim(),
        permissions: {
          ..._selectedPermissions,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,

      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 605,
          maxHeight: 650,
        ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ===================================================
              // DIALOG HEADER
              // ===================================================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  20,
                  18,
                  20,
                ),

                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE0E4E6),
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF303438),
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
                        color: Color(0xFFA4A8AA),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================================
              // FORM
              // ===================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  25,
                  25,
                  25,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _formLabel('Role Name'),

                    const SizedBox(height: 9),

                    _textField(
                      controller: _nameController,
                    ),

                    const SizedBox(height: 20),

                    _formLabel('Description'),

                    const SizedBox(height: 9),

                    _textField(
                      controller:
                          _descriptionController,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 26),

                    _formLabel(
                      'Module Permissions',
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(
                        10,
                        10,
                        10,
                        10,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        border: Border.all(
                          color:
                              const Color(0xFFD9DFE2),
                        ),

                        borderRadius:
                            BorderRadius.circular(7),
                      ),

                      child: LayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          if (constraints.maxWidth >=
                              450) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _permissionTile(
                                        'Dashboard',
                                        'View the main dashboard',
                                      ),

                                      _permissionTile(
                                        'Inventory',
                                        'Access Current Stock and Adjustments',
                                      ),

                                      _permissionTile(
                                        'Purchase',
                                        'Access Vendors, Bills, Purchase Orders, etc.',
                                      ),

                                      _permissionTile(
                                        'Reports',
                                        'Access all Reports',
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    children: [
                                      _permissionTile(
                                        'Items',
                                        'Access Items and Parts',
                                      ),

                                      _permissionTile(
                                        'Sales',
                                        'Access Customers, Invoices, Sales Orders, etc.',
                                      ),

                                      _permissionTile(
                                        'Accountant',
                                        'Access Expenses, Reimbursements, etc.',
                                      ),

                                      _permissionTile(
                                        'Settings',
                                        'Access organization-level Settings',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              for (final permission
                                  in _allPermissions)
                                _permissionTile(
                                  permission.title,
                                  permission.description,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================================
              // FOOTER
              // ===================================================

              Container(
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
                      color: Color(0xFFE0E4E6),
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

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE7E7E7),

                        foregroundColor:
                            const Color(0xFF52575A),

                        elevation: 0,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 19,
                          vertical: 13,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            7,
                          ),
                        ),
                      ),

                      child: const Text(
                        'Cancel',
                      ),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: _saveRole,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF22AE4B),

                        foregroundColor:
                            Colors.white,

                        elevation: 0,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 13,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            7,
                          ),
                        ),
                      ),

                      child: const Text(
                        'Save Role',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionTile(
    String title,
    String description,
  ) {
    final bool selected =
        _selectedPermissions.contains(title);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 27,
            height: 27,

            child: Checkbox(
              value: selected,

              activeColor:
                  const Color(0xFF168AE5),

              checkColor: Colors.white,

              side: const BorderSide(
                color: Color(0xFF838A8E),
                width: 1,
              ),

              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,

              onChanged: (value) {
                _togglePermission(
                  title,
                  value ?? false,
                );
              },
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    color: Color(0xFF44494C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,

                  style: const TextStyle(
                    color: Color(0xFF72787B),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// FORM HELPERS
// =================================================================

Widget _formLabel(String text) {
  return Text(
    text,

    style: const TextStyle(
      color: Color(0xFF62686C),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget _textField({
  required TextEditingController controller,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,

    style: const TextStyle(
      color: Color(0xFF363A3D),
      fontSize: 14,
    ),

    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,

      isDense: true,

      contentPadding: EdgeInsets.symmetric(
        horizontal: 13,
        vertical: maxLines == 1 ? 15 : 14,
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
          width: 1.2,
        ),
      ),
    ),
  );
}

// =================================================================
// ROLE DATA
// =================================================================

class _RoleData {
  String name;
  String description;
  final Set<String> permissions;

  _RoleData({
    required this.name,
    required this.description,
    required this.permissions,
  });
}

// =================================================================
// PERMISSIONS
// =================================================================

class _PermissionInfo {
  final String title;
  final String description;

  const _PermissionInfo(
    this.title,
    this.description,
  );
}

const List<String> _permissionOrder = [
  'Dashboard',
  'Items',
  'Inventory',
  'Sales',
  'Purchase',
  'Accountant',
  'Reports',
  'Settings',
];

const List<_PermissionInfo> _allPermissions = [
  _PermissionInfo(
    'Dashboard',
    'View the main dashboard',
  ),

  _PermissionInfo(
    'Items',
    'Access Items and Parts',
  ),

  _PermissionInfo(
    'Inventory',
    'Access Current Stock and Adjustments',
  ),

  _PermissionInfo(
    'Sales',
    'Access Customers, Invoices, Sales Orders, etc.',
  ),

  _PermissionInfo(
    'Purchase',
    'Access Vendors, Bills, Purchase Orders, etc.',
  ),

  _PermissionInfo(
    'Accountant',
    'Access Expenses, Reimbursements, etc.',
  ),

  _PermissionInfo(
    'Reports',
    'Access all Reports',
  ),

  _PermissionInfo(
    'Settings',
    'Access organization-level Settings',
  ),
];