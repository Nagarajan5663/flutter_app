import 'package:flutter/material.dart';

import 'shared/glass_widgets.dart';

class SalesOrderPreferencesPage extends StatefulWidget {
  final VoidCallback? onBack;

  const SalesOrderPreferencesPage({
    super.key,
    this.onBack,
  });

  @override
  State<SalesOrderPreferencesPage> createState() =>
      _SalesOrderPreferencesPageState();
}

class _SalesOrderPreferencesPageState
    extends State<SalesOrderPreferencesPage> {
  bool _address = true;
  bool _customerNotes = false;
  bool _termsAndConditionsInvoice = false;

  String _closeSalesOrder =
      'When shipment is fulfilled and invoice is created';

  bool _restrictClosedSalesOrders = false;

  final TextEditingController _termsController =
      TextEditingController();

  @override
  void dispose() {
    _termsController.dispose();
    super.dispose();
  }

  // ================================================================
  // BACK
  // ================================================================

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }

    Navigator.of(context).maybePop();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GlassPageBackground(
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
                  18 * (1 - value),
                ),
                child: child,
              ),
            );
          },
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ====================================================
              // HEADER
              // ====================================================

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

                        const SizedBox(
                          height: 16,
                        ),

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

              // ====================================================
              // CONTENT CARD
              // ====================================================

              _HoverGlassCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        30,
                        30,
                        30,
                        38,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // =========================================
                          // INVOICE FIELDS
                          // =========================================

                          const Text(
                            'Which of the following fields of Sales Orders do you want to update in the respective Invoices?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          _PreferenceCheckbox(
                            value: _address,
                            title: 'Address',
                            onChanged: (value) {
                              setState(() {
                                _address = value;
                              });
                            },
                          ),

                          _PreferenceCheckbox(
                            value:
                                _customerNotes,
                            title:
                                'Customer Notes',
                            onChanged: (value) {
                              setState(() {
                                _customerNotes =
                                    value;
                              });
                            },
                          ),

                          _PreferenceCheckbox(
                            value:
                                _termsAndConditionsInvoice,
                            title:
                                'Terms & Conditions',
                            onChanged: (value) {
                              setState(() {
                                _termsAndConditionsInvoice =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          // =========================================
                          // CLOSE SALES ORDER
                          // =========================================

                          const Text(
                            'When do you want your Sales Orders to be closed?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          _PreferenceRadio(
                            value:
                                'When invoice is created',
                            groupValue:
                                _closeSalesOrder,
                            title:
                                'When invoice is created',
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _closeSalesOrder =
                                    value;
                              });
                            },
                          ),

                          _PreferenceRadio(
                            value:
                                'When shipment is fulfilled',
                            groupValue:
                                _closeSalesOrder,
                            title:
                                'When shipment is fulfilled',
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _closeSalesOrder =
                                    value;
                              });
                            },
                          ),

                          _PreferenceRadio(
                            value:
                                'When shipment is fulfilled and invoice is created',
                            groupValue:
                                _closeSalesOrder,
                            title:
                                'When shipment is fulfilled and invoice is created',
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _closeSalesOrder =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          _PreferenceCheckbox(
                            value:
                                _restrictClosedSalesOrders,
                            title:
                                'Restrict closed sales orders from being edited',
                            onChanged: (value) {
                              setState(() {
                                _restrictClosedSalesOrders =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // =========================================
                          // TERMS
                          // =========================================

                          const Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 720,
                            ),
                            child: _GlassTermsField(
                              controller:
                                  _termsController,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===============================================
                    // BOTTOM SAVE AREA
                    // ===============================================

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        22,
                        18,
                        22,
                        18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.04,
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white
                                .withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                      ),
                      child: Align(
                        alignment:
                            Alignment.centerRight,
                        child: _SaveButton(
                          onTap: () {},
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
    );
  }

  // ================================================================
  // TITLE
  // ================================================================

  Widget _buildTitle() {
    return const Text(
      'Sales Order Preferences',
      style: TextStyle(
        color: Colors.white,
        fontSize: 27,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ==================================================================
// GLASS CARD WITH HOVER
// ==================================================================

class _HoverGlassCard extends StatefulWidget {
  final Widget child;

  const _HoverGlassCard({
    required this.child,
  });

  @override
  State<_HoverGlassCard> createState() =>
      _HoverGlassCardState();
}

class _HoverGlassCardState
    extends State<_HoverGlassCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedScale(
        duration:
            const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        scale: _hovering ? 1.002 : 1,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF2563EB,
                ).withValues(
                  alpha:
                      _hovering ? 0.14 : 0.06,
                ),
                blurRadius:
                    _hovering ? 30 : 18,
                offset:
                    const Offset(0, 10),
              ),
            ],
          ),
          child: GlassPanel(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CHECKBOX
// ==================================================================

class _PreferenceCheckbox
    extends StatefulWidget {
  final bool value;
  final String title;
  final ValueChanged<bool> onChanged;

  const _PreferenceCheckbox({
    required this.value,
    required this.title,
    required this.onChanged,
  });

  @override
  State<_PreferenceCheckbox>
      createState() =>
          _PreferenceCheckboxState();
}

class _PreferenceCheckboxState
    extends State<_PreferenceCheckbox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onChanged(
            !widget.value,
          );
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(
            bottom: 2,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(8),
            color: _hovering
                ? Colors.white.withValues(
                    alpha: 0.05,
                  )
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Checkbox(
                value: widget.value,
                onChanged: (value) {
                  widget.onChanged(
                    value ?? false,
                  );
                },
                activeColor:
                    const Color(0xFF3478F6),
                checkColor: Colors.white,
                side: BorderSide(
                  color: Colors.white
                      .withValues(
                    alpha: 0.60,
                  ),
                  width: 1.3,
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight:
                        FontWeight.w600,
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

// ==================================================================
// RADIO
// ==================================================================

class _PreferenceRadio
    extends StatefulWidget {
  final String value;
  final String groupValue;
  final String title;
  final ValueChanged<String?>
      onChanged;

  const _PreferenceRadio({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
  });

  @override
  State<_PreferenceRadio> createState() =>
      _PreferenceRadioState();
}

class _PreferenceRadioState
    extends State<_PreferenceRadio> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onChanged(
            widget.value,
          );
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(8),
            color: _hovering
                ? Colors.white.withValues(
                    alpha: 0.05,
                  )
                : Colors.transparent,
          ),
          child: Row(
            children: [
                RadioGroup<String>(
                groupValue: widget.groupValue,
                onChanged: widget.onChanged,
                child: Radio<String>(
                  value: widget.value,
                activeColor:
                    const Color(0xFF3478F6),
                fillColor:
                    WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(
                      WidgetState.selected,
                    )) {
                      return const Color(
                        0xFF3478F6,
                      );
                    }

                    return Colors.white
                        .withValues(
                      alpha: 0.60,
                    );
                  },
                ),
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight:
                        FontWeight.w600,
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

// ==================================================================
// TERMS FIELD
// ==================================================================

class _GlassTermsField
    extends StatefulWidget {
  final TextEditingController controller;

  const _GlassTermsField({
    required this.controller,
  });

  @override
  State<_GlassTermsField> createState() =>
      _GlassTermsFieldState();
}

class _GlassTermsFieldState
    extends State<_GlassTermsField> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(10),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color:
                        const Color(
                      0xFF3478F6,
                    ).withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: 6,
          minLines: 6,
          style: const TextStyle(
            color: GlassSurface.inputText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText:
                'Enter the default terms and conditions for your sales orders...',
            hintStyle: TextStyle(
              color:
                  GlassSurface.hintText,
              fontSize: 13.5,
            ),
            filled: true,
            fillColor:
                GlassSurface.fill(),
            contentPadding:
                const EdgeInsets.all(16),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: BorderSide(
                color:
                    GlassSurface.border(),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: BorderSide(
                color: GlassSurface.border(
                  focused: true,
                ),
                width: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// BACK BUTTON
// ==================================================================

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
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedScale(
        scale: _hovering ? 1.025 : 1,
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
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10),
                color:
                    const Color(0xFF4F46E5)
                        .withValues(
                  alpha:
                      _hovering ? 0.28 : 0.17,
                ),
                border: Border.all(
                  color:
                      Colors.white.withValues(
                    alpha:
                        _hovering ? 0.40 : 0.20,
                  ),
                ),
                boxShadow: _hovering
                    ? [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF6366F1,
                          ).withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: const Text(
                '← Back to Settings',
                style: TextStyle(
                  color:
                      Color(0xFFBFC8FF),
                  fontSize: 13.5,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SAVE BUTTON
// ==================================================================

class _SaveButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SaveButton({
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() =>
      _SaveButtonState();
}

class _SaveButtonState
    extends State<_SaveButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedScale(
        scale: _hovering ? 1.035 : 1,
        duration:
            const Duration(milliseconds: 160),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius:
                BorderRadius.circular(9),
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF20A844),
                borderRadius:
                    BorderRadius.circular(9),
                boxShadow: _hovering
                    ? [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF20A844,
                          ).withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 20,
                          offset:
                              const Offset(
                            0,
                            7,
                          ),
                        ),
                      ]
                    : null,
              ),
              child: const Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.save_rounded,
                    size: 17,
                    color: Colors.white,
                  ),

                  SizedBox(width: 7),

                  Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
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