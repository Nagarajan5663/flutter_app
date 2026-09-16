import 'dart:ui';

import 'package:flutter/material.dart';

class ExpenseSettingsPage extends StatefulWidget {
  final VoidCallback? onBack;

  const ExpenseSettingsPage({
    super.key,
    this.onBack,
  });

  @override
  State<ExpenseSettingsPage> createState() =>
      _ExpenseSettingsPageState();
}

class _ExpenseSettingsPageState extends State<ExpenseSettingsPage> {
  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _ExpenseGlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            28,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: 1,
            ),
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeOutCubic,
            builder: (
              context,
              value,
              child,
            ) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    20 * (1 - value),
                  ),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ===================================================
                // HEADER
                // ===================================================

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final isSmall =
                        constraints.maxWidth < 650;

                    if (isSmall) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 16),
                          _BackButton(
                            onTap: _goBack,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildTitle(),
                        ),
                        _BackButton(
                          onTap: _goBack,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ===================================================
                // EXPENSE CATEGORIES
                // ===================================================

                _ExpenseGlassCard(
                  child: Column(
                    children: [
                      _SectionHeader(
                        title: 'Expense Categories',
                        buttonText:
                            'Add New Category',
                        onPressed:
                            _showAddCategoryDialog,
                      ),
                      _ExpenseTable(
                        columns: const [
                          'Category Name',
                          'Description',
                          'Status',
                          'Actions',
                        ],
                        emptyText:
                            'No expense categories found.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===================================================
                // PAYMENT ACCOUNTS
                // ===================================================

                _ExpenseGlassCard(
                  child: Column(
                    children: [
                      _SectionHeader(
                        title:
                            'Payment Accounts (Paid Through)',
                        buttonText:
                            'Add New Account',
                        onPressed:
                            _showAddAccountDialog,
                      ),
                      _ExpenseTable(
                        columns: const [
                          'Account Name',
                          'Description',
                          'Status',
                          'Actions',
                        ],
                        emptyText:
                            'No payment accounts found.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===================================================
                // TAXES
                // ===================================================

                _ExpenseGlassCard(
                  child: Column(
                    children: [
                      _SectionHeader(
                        title: 'Taxes',
                        buttonText:
                            'Add New Tax',
                        onPressed:
                            _showAddTaxDialog,
                      ),
                      _ExpenseTable(
                        columns: const [
                          'Tax Name',
                          'Tax Rate (%)',
                          'Status',
                          'Actions',
                        ],
                        emptyText:
                            'No taxes found.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '© 2026 Codexia. All Rights Reserved.',
                    style: TextStyle(
                      color: Color(0xFF657A89),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Expense Settings',
      style: TextStyle(
        color: Color(0xFF123456),
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ================================================================
  // ADD CATEGORY
  // ================================================================

  void _showAddCategoryDialog() {
    final categoryController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      barrierColor:
          Colors.black.withValues(alpha: 0.48),
      builder: (dialogContext) {
        return _ExpenseDialog(
          title: 'Add New Category',
          saveLabel: 'Save Category',
          fields: [
            _DialogField(
              label: 'Category Name',
              requiredField: true,
              controller:
                  categoryController,
            ),
            _DialogField(
              label: 'Description',
              controller:
                  descriptionController,
              maxLines: 3,
            ),
          ],
          onSave: () {
            if (categoryController
                .text
                .trim()
                .isEmpty) {
              return;
            }

            Navigator.of(
              dialogContext,
            ).pop();
          },
        );
      },
    ).whenComplete(() {
      categoryController.dispose();
      descriptionController.dispose();
    });
  }

  // ================================================================
  // ADD ACCOUNT
  // ================================================================

  void _showAddAccountDialog() {
    final accountController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      barrierColor:
          Colors.black.withValues(alpha: 0.48),
      builder: (dialogContext) {
        return _ExpenseDialog(
          title: 'Add New Account',
          saveLabel: 'Save Account',
          fields: [
            _DialogField(
              label: 'Account Name',
              requiredField: true,
              controller:
                  accountController,
            ),
            _DialogField(
              label: 'Description',
              controller:
                  descriptionController,
              maxLines: 3,
            ),
          ],
          onSave: () {
            if (accountController
                .text
                .trim()
                .isEmpty) {
              return;
            }

            Navigator.of(
              dialogContext,
            ).pop();
          },
        );
      },
    ).whenComplete(() {
      accountController.dispose();
      descriptionController.dispose();
    });
  }

  // ================================================================
  // ADD TAX
  // ================================================================

  void _showAddTaxDialog() {
    final taxNameController =
        TextEditingController();

    final taxRateController =
        TextEditingController();

    showDialog(
      context: context,
      barrierColor:
          Colors.black.withValues(alpha: 0.48),
      builder: (dialogContext) {
        return _ExpenseDialog(
          title: 'Add New Tax',
          saveLabel: 'Save Tax',
          fields: [
            _DialogField(
              label: 'Tax Name',
              requiredField: true,
              controller:
                  taxNameController,
            ),
            _DialogField(
              label: 'Tax Rate (%)',
              requiredField: true,
              controller:
                  taxRateController,
              hintText: 'e.g., 18.00',
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
          onSave: () {
            if (taxNameController
                    .text
                    .trim()
                    .isEmpty ||
                taxRateController
                    .text
                    .trim()
                    .isEmpty) {
              return;
            }

            Navigator.of(
              dialogContext,
            ).pop();
          },
        );
      },
    ).whenComplete(() {
      taxNameController.dispose();
      taxRateController.dispose();
    });
  }
}

// ============================================================================
// BACKGROUND - SAME AS ITEM PREFERENCES
// ============================================================================

class _ExpenseGlassBackground
    extends StatelessWidget {
  final Widget child;

  const _ExpenseGlassBackground({
    required this.child,
  });

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
            Color(0xFFCADAE7),
            Color(0xFFD2D6E3),
            Color(0xFFC7DCD9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: _GlowCircle(
              size: 380,
              color:
                  const Color(0xFF3984BA),
              opacity: 0.30,
            ),
          ),

          Positioned(
            left: -120,
            top: 320,
            child: _GlowCircle(
              size: 340,
              color:
                  const Color(0xFF46B6A0),
              opacity: 0.17,
            ),
          ),

          Positioned(
            left: 100,
            bottom: -220,
            child: _GlowCircle(
              size: 500,
              color:
                  const Color(0xFF7564AE),
              opacity: 0.20,
            ),
          ),

          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(
                alpha: opacity,
              ),
              color.withValues(
                alpha: opacity * 0.25,
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARD
// ============================================================================

class _ExpenseGlassCard
    extends StatefulWidget {
  final Widget child;

  const _ExpenseGlassCard({
    required this.child,
  });

  @override
  State<_ExpenseGlassCard> createState() =>
      _ExpenseGlassCardState();
}

class _ExpenseGlassCardState
    extends State<_ExpenseGlassCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        scale: hovering ? 1.002 : 1,
        duration:
            const Duration(milliseconds: 180),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 200,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha:
                      hovering ? 0.54 : 0.42,
                ),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color:
                      Colors.white.withValues(
                    alpha:
                        hovering ? 0.95 : 0.76,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF173D59,
                    ).withValues(
                      alpha:
                          hovering ? 0.13 : 0.06,
                    ),
                    blurRadius:
                        hovering ? 30 : 18,
                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  const _SectionHeader({
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        14,
      ),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final small =
              constraints.maxWidth < 520;

          if (small) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF243B4C),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                _GreenActionButton(
                  text: buttonText,
                  onTap: onPressed,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF243B4C),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              _GreenActionButton(
                text: buttonText,
                onTap: onPressed,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// TABLE
// ============================================================================

class _ExpenseTable extends StatelessWidget {
  final List<String> columns;
  final String emptyText;

  const _ExpenseTable({
    required this.columns,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.28,
        ),
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.75,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: SizedBox(
          width: 900,
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.35,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children:
                      List.generate(
                    columns.length,
                    (index) {
                      return Expanded(
                        child: Container(
                          height:
                              double.infinity,
                          alignment: Alignment
                              .centerLeft,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                          ),
                          decoration:
                              BoxDecoration(
                            border: index <
                                    columns.length -
                                        1
                                ? Border(
                                    right:
                                        BorderSide(
                                      color: Colors
                                          .white
                                          .withValues(
                                        alpha:
                                            0.55,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          child: Text(
                            columns[index],
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF243B4C,
                              ),
                              fontSize: 12.5,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(
                height: 52,
                alignment:
                    Alignment.center,
                child: Text(
                  emptyText,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF70818B),
                    fontSize: 12.5,
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

// ============================================================================
// GREEN BUTTON
// ============================================================================

class _GreenActionButton
    extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _GreenActionButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_GreenActionButton>
      createState() =>
          _GreenActionButtonState();
}

class _GreenActionButtonState
    extends State<_GreenActionButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        scale:
            hovering ? 1.035 : 1,
        duration:
            const Duration(milliseconds: 150),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius:
                BorderRadius.circular(8),
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 170,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF20A440),
                borderRadius:
                    BorderRadius.circular(8),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF20A440,
                          ).withValues(
                            alpha: 0.30,
                          ),
                          blurRadius: 18,
                          offset:
                              const Offset(
                            0,
                            6,
                          ),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.text,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BACK BUTTON
// ============================================================================

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  State<_BackButton> createState() =>
      _BackButtonState();
}

class _BackButtonState
    extends State<_BackButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        scale:
            hovering ? 1.025 : 1,
        duration:
            const Duration(milliseconds: 160),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius:
                BorderRadius.circular(10),
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE4E5F4)
                        .withValues(
                  alpha:
                      hovering ? 1 : 0.88,
                ),
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white
                      .withValues(
                    alpha: 0.76,
                  ),
                ),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF5965B0,
                          ).withValues(
                            alpha: 0.18,
                          ),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child:
                  const Text(
                '← Back to Settings',
                style:
                    TextStyle(
                  color:
                      Color(0xFF4052A5),
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DIALOG
// ============================================================================

class _ExpenseDialog
    extends StatelessWidget {
  final String title;
  final String saveLabel;
  final List<Widget> fields;
  final VoidCallback onSave;

  const _ExpenseDialog({
    required this.title,
    required this.saveLabel,
    required this.fields,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 430,
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.88,
                ),
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white
                      .withValues(
                    alpha: 0.95,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(
                      alpha: 0.20,
                    ),
                    blurRadius: 30,
                    offset:
                        const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      20,
                      18,
                      14,
                      14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF243B4C,
                              ),
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop();
                          },
                          icon:
                              const Icon(
                            Icons.close,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: const Color(
                      0xFF80909A,
                    ).withValues(
                      alpha: 0.18,
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0;
                            i <
                                fields
                                    .length;
                            i++) ...[
                          fields[i],
                          if (i <
                              fields.length -
                                  1)
                            const SizedBox(
                              height: 16,
                            ),
                        ],
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      18,
                      12,
                      18,
                      16,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.26,
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white
                              .withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop();
                          },
                          child:
                              const Text(
                            'Cancel',
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF52646F,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        ElevatedButton(
                          onPressed:
                              onSave,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            elevation: 0,
                            backgroundColor:
                                const Color(
                              0xFF20A440,
                            ),
                            foregroundColor:
                                Colors.white,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),
                          ),
                          child: Text(
                            saveLabel,
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
      ),
    );
  }
}

// ============================================================================
// DIALOG FIELD
// ============================================================================

class _DialogField extends StatelessWidget {
  final String label;
  final bool requiredField;
  final TextEditingController controller;
  final int maxLines;
  final String? hintText;
  final TextInputType? keyboardType;

  const _DialogField({
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.maxLines = 1,
    this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style:
                const TextStyle(
              color:
                  Color(0xFF52646F),
              fontSize: 12.5,
              fontWeight:
                  FontWeight.w500,
            ),
            children: [
              if (requiredField)
                const TextSpan(
                  text: ' *',
                  style:
                      TextStyle(
                    color:
                        Color(0xFFE74C3C),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType:
              keyboardType,
          style:
              const TextStyle(
            color:
                Color(0xFF243B4C),
            fontSize: 13.5,
          ),
          decoration:
              InputDecoration(
            hintText: hintText,
            hintStyle:
                const TextStyle(
              color:
                  Color(0xFF9AA8B0),
              fontSize: 13,
            ),
            filled: true,
            fillColor:
                Colors.white.withValues(
              alpha: 0.50,
            ),
            contentPadding:
                const EdgeInsets.all(
              13,
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFFD1DCE2),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
              borderSide:
                  const BorderSide(
                color:
                    Color(0xFF438CC0),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}