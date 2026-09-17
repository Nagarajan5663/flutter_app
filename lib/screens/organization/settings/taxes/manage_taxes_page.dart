import 'package:flutter/material.dart';

class ManageTaxesPage extends StatefulWidget {
  final VoidCallback onBack;

  const ManageTaxesPage({
    super.key,
    required this.onBack,
  });

  @override
  State<ManageTaxesPage> createState() =>
      _ManageTaxesPageState();
}

class _ManageTaxesPageState
    extends State<ManageTaxesPage> {
  final List<_TaxData> _taxes = [
    _TaxData(
      name: 'GST0 (Tax Group)',
      type: 'Tax Group',
      rate: 0,
      isDefault: true,
    ),
    _TaxData(
      name: 'GST12 (Tax Group)',
      type: 'Tax Group',
      rate: 12,
      isDefault: true,
    ),
    _TaxData(
      name: 'GST18 (Tax Group)',
      type: 'Tax Group',
      rate: 18,
      isDefault: true,
    ),
    _TaxData(
      name: 'GST5 (Tax Group)',
      type: 'Tax Group',
      rate: 5,
      isDefault: true,
    ),
    _TaxData(
      name: 'IGST0',
      type: 'IGST',
      rate: 0,
      isDefault: true,
    ),
    _TaxData(
      name: 'IGST12',
      type: 'IGST',
      rate: 12,
      isDefault: true,
    ),
    _TaxData(
      name: 'IGST18',
      type: 'IGST',
      rate: 18,
      isDefault: true,
    ),
    _TaxData(
      name: 'IGST5',
      type: 'IGST',
      rate: 5,
      isDefault: true,
    ),
  ];

  // ================================================================
  // NEW TAX
  // ================================================================

  Future<void> _openNewTax() async {
    final _TaxData? result =
        await showDialog<_TaxData>(
      context: context,

      barrierDismissible: false,

      // Dark overlay exactly like screenshot
      barrierColor: Colors.black.withValues(
        alpha: 0.50,
      ),

      builder: (context) {
        return const _TaxDialog();
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      _taxes.add(result);
    });
  }

  // ================================================================
  // EDIT TAX
  // ================================================================

  Future<void> _editTax(_TaxData tax) async {
    final _TaxData? result =
        await showDialog<_TaxData>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.50,
      ),
      builder: (context) {
        return _TaxDialog(
          existingTax: tax,
          title: 'Edit Tax',
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      tax.name = result.name;
      tax.type = result.type;
      tax.rate = result.rate;
    });
  }

  // ================================================================
  // PAGE
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,

      color: const Color(0xFFF2F6F8),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          20,
          28,
          35,
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1160,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ===================================================
                // TITLE + BUTTONS
                // ===================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Taxes',
                        style: TextStyle(
                          color: Color(0xFF252A2E),
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // ================================================
                    // BACK TO SETTINGS
                    // ================================================

                    _BackButton(
                      onTap: widget.onBack,
                    ),

                    const SizedBox(width: 25),

                    // ================================================
                    // NEW TAX BUTTON
                    // ================================================

                    _NewTaxButton(
                      onTap: _openNewTax,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ===================================================
                // TAX TABLE
                // ===================================================

                LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    return SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,

                      child: SizedBox(
                        width:
                            constraints.maxWidth < 900
                                ? 900
                                : constraints.maxWidth,

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),

                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),

                            child: Column(
                              children: [
                                // =====================================
                                // TABLE HEADER
                                // =====================================

                                Container(
                                  height: 56,
                                  color: const Color(
                                    0xFFF7F9F9,
                                  ),

                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 46,
                                        child:
                                            _HeaderCell(
                                          'TAX NAME',
                                        ),
                                      ),

                                      Expanded(
                                        flex: 23,
                                        child:
                                            _HeaderCell(
                                          'TAX TYPE',
                                        ),
                                      ),

                                      Expanded(
                                        flex: 21,
                                        child:
                                            _HeaderCell(
                                          'RATE (%)',
                                        ),
                                      ),

                                      Expanded(
                                        flex: 10,
                                        child:
                                            SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),

                                // =====================================
                                // TAX ROWS
                                // =====================================

                                for (
                                  int i = 0;
                                  i < _taxes.length;
                                  i++
                                )
                                  _TaxRow(
                                    tax: _taxes[i],
                                    showBottomBorder:
                                        i !=
                                            _taxes.length -
                                                1,
                                    onEdit: () {
                                      _editTax(
                                        _taxes[i],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// TABLE HEADER CELL
// ==================================================================

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF596166),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ==================================================================
// TAX ROW WITH HOVER
// ==================================================================

class _TaxRow extends StatefulWidget {
  final _TaxData tax;
  final bool showBottomBorder;
  final VoidCallback onEdit;

  const _TaxRow({
    required this.tax,
    required this.showBottomBorder,
    required this.onEdit,
  });

  @override
  State<_TaxRow> createState() =>
      _TaxRowState();
}

class _TaxRowState extends State<_TaxRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 100,
        ),

        height: 59,

        decoration: BoxDecoration(
          // Exact light row hover from video
          color: _hovered
              ? const Color(0xFFF2F6F8)
              : Colors.white,

          border: widget.showBottomBorder
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0E4E6),
                    width: 1,
                  ),
                )
              : null,
        ),

        child: Row(
          children: [
            // =======================================================
            // TAX NAME
            // =======================================================

            Expanded(
              flex: 46,

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.tax.name,

                        style: const TextStyle(
                          color:
                              Color(0xFF384044),
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      if (widget.tax.isDefault)
                        const TextSpan(
                          text: ' (Default)',

                          style: TextStyle(
                            color:
                                Color(0xFF7D858A),
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // =======================================================
            // TYPE
            // =======================================================

            Expanded(
              flex: 23,

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  widget.tax.type,

                  style: const TextStyle(
                    color: Color(0xFF454C50),
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            // =======================================================
            // RATE
            // =======================================================

            Expanded(
              flex: 21,

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Text(
                  widget.tax.rate
                      .toStringAsFixed(2),

                  style: const TextStyle(
                    color: Color(0xFF454C50),
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            // =======================================================
            // EDIT
            // =======================================================

            Expanded(
              flex: 10,

              child: Align(
                alignment: Alignment.center,

                child: _EditButton(
                  onTap: widget.onEdit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// BACK TO SETTINGS BUTTON
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
            milliseconds: 120,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),

          child: Text(
            'Back to Settings',

            style: TextStyle(
              color: const Color(0xFF7B1E83),
              fontSize: 13,
              fontWeight: FontWeight.w600,

              decoration: _hovered
                  ? TextDecoration.underline
                  : TextDecoration.none,

              decorationColor:
                  const Color(0xFF7B1E83),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// NEW TAX BUTTON
// ==================================================================

class _NewTaxButton extends StatefulWidget {
  final VoidCallback onTap;

  const _NewTaxButton({
    required this.onTap,
  });

  @override
  State<_NewTaxButton> createState() =>
      _NewTaxButtonState();
}

class _NewTaxButtonState
    extends State<_NewTaxButton> {
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
            milliseconds: 120,
          ),

          height: 39,

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),

          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFF218838)
                : const Color(0xFF28A745),

            borderRadius: BorderRadius.circular(
              7,
            ),
          ),

          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),

              SizedBox(width: 5),

              Text(
                'New Tax',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
// EDIT BUTTON
// ==================================================================

class _EditButton extends StatefulWidget {
  final VoidCallback onTap;

  const _EditButton({
    required this.onTap,
  });

  @override
  State<_EditButton> createState() =>
      _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
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
            milliseconds: 100,
          ),

          width: 32,
          height: 32,

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFE9EDF0)
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(5),
          ),

          child: Icon(
            Icons.edit_rounded,

            size: 18,

            color: _hovered
                ? const Color(0xFFA0A7AB)
                : const Color(0xFFDDE2E4),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// NEW / EDIT TAX DIALOG
// ==================================================================

class _TaxDialog extends StatefulWidget {
  final _TaxData? existingTax;
  final String title;

  const _TaxDialog({
    this.existingTax,
    this.title = 'New Tax',
  });

  @override
  State<_TaxDialog> createState() =>
      _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
  late final TextEditingController
      _taxNameController;

  late final TextEditingController
      _rateController;

  final TextEditingController
      _cgstController =
      TextEditingController();

  final TextEditingController
      _sgstController =
      TextEditingController();

  String? _nameError;
  String? _rateError;

  @override
  void initState() {
    super.initState();

    _taxNameController =
        TextEditingController(
      text: widget.existingTax?.name ?? '',
    );

    _rateController =
        TextEditingController(
      text: widget.existingTax == null
          ? ''
          : widget.existingTax!.rate
              .toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _taxNameController.dispose();
    _rateController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();

    super.dispose();
  }

  // ================================================================
  // SAVE
  // ================================================================

  void _save() {
    final String name =
        _taxNameController.text.trim();

    final double? rate =
        double.tryParse(
      _rateController.text.trim(),
    );

    setState(() {
      _nameError =
          name.isEmpty ? 'Required' : null;

      _rateError =
          rate == null ? 'Required' : null;
    });

    if (name.isEmpty || rate == null) {
      return;
    }

    final bool hasCgst =
        _cgstController.text.trim().isNotEmpty;

    final bool hasSgst =
        _sgstController.text.trim().isNotEmpty;

    final String taxType =
        hasCgst || hasSgst
            ? 'Tax Group'
            : 'IGST';

    Navigator.pop(
      context,

      _TaxData(
        name: name,
        type: taxType,
        rate: rate,
        isDefault:
            widget.existingTax?.isDefault ??
                false,
      ),
    );
  }

  // ================================================================
  // DIALOG
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          const Color(0xFFFEFEFE),

      elevation: 12,

      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          11,
        ),
      ),

      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // =======================================================
            // HEADER
            // =======================================================

            Container(
              height: 73,

              padding:
                  const EdgeInsets.fromLTRB(
                26,
                0,
                15,
                0,
              ),

              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,

                      style: const TextStyle(
                        color:
                            Color(0xFF333333),
                        fontSize: 23,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  _CloseButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // =======================================================
            // BODY
            // =======================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                26,
                28,
                26,
                42,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // TAX NAME
                  // =================================================

                  const _FieldLabel(
                    'Tax Name',
                  ),

                  const SizedBox(height: 10),

                  _TaxTextField(
                    controller:
                        _taxNameController,

                    hintText:
                        'e.g., GST @ 28%',

                    errorText:
                        _nameError,
                  ),

                  const SizedBox(height: 23),

                  // =================================================
                  // RATE
                  // =================================================

                  const _FieldLabel(
                    'Rate (%)',
                  ),

                  const SizedBox(height: 10),

                  _TaxTextField(
                    controller:
                        _rateController,

                    hintText: 'e.g., 28',

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),

                    errorText:
                        _rateError,
                  ),

                  const SizedBox(height: 22),

                  // =================================================
                  // OPTIONAL TEXT
                  // =================================================

                  const Text(
                    'This is a cess tax (Optional)',

                    style: TextStyle(
                      color: Color(0xFF404040),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // =================================================
                  // CGST + SGST
                  // =================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const _FieldLabel(
                              'CGST Rate (%)',
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            _TaxTextField(
                              controller:
                                  _cgstController,

                              hintText:
                                  'e.g., 14',

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const _FieldLabel(
                              'SGST Rate (%)',
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            _TaxTextField(
                              controller:
                                  _sgstController,

                              hintText:
                                  'e.g., 14',

                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =======================================================
            // FOOTER
            // =======================================================

            Container(
              height: 71,
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 26,
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),

                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,

                children: [
                  _DialogButton(
                    text: 'Cancel',

                    backgroundColor:
                        const Color(0xFFE0E0E0),

                    hoverColor:
                        const Color(0xFFD4D4D4),

                    textColor:
                        const Color(0xFF333333),

                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(width: 10),

                  _DialogButton(
                    text: 'Save',

                    backgroundColor:
                        const Color(0xFF28A745),

                    hoverColor:
                        const Color(0xFF218838),

                    textColor: Colors.white,

                    onTap: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// LABEL
// ==================================================================

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,

      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ==================================================================
// TEXT FIELD
// ==================================================================

class _TaxTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? errorText;

  const _TaxTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: errorText == null ? 45 : 65,

      child: TextFormField(
        controller: controller,

        keyboardType: keyboardType,

        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 16,
        ),

        decoration: InputDecoration(
          hintText: hintText,

          errorText: errorText,

          hintStyle: const TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),

          isDense: true,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 13,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide:
                const BorderSide(
              color: Color(0xFFD9D9D9),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide:
                const BorderSide(
              color: Color(0xFF80BDFF),
              width: 1,
            ),
          ),

          errorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide:
                const BorderSide(
              color: Color(0xFFDC3545),
            ),
          ),

          focusedErrorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(7),

            borderSide:
                const BorderSide(
              color: Color(0xFFDC3545),
            ),
          ),

          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ==================================================================
// CLOSE BUTTON
// ==================================================================

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CloseButton({
    required this.onTap,
  });

  @override
  State<_CloseButton> createState() =>
      _CloseButtonState();
}

class _CloseButtonState
    extends State<_CloseButton> {
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

        child: SizedBox(
          width: 36,
          height: 50,

          child: Icon(
            Icons.close_rounded,

            size: 24,

            color: _hovered
                ? const Color(0xFF777777)
                : const Color(0xFFA7A7A7),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CANCEL / SAVE BUTTON
// ==================================================================

class _DialogButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color hoverColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.text,
    required this.backgroundColor,
    required this.hoverColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_DialogButton> createState() =>
      _DialogButtonState();
}

class _DialogButtonState
    extends State<_DialogButton> {
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

          height: 38,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: _hovered
                ? widget.hoverColor
                : widget.backgroundColor,

            borderRadius:
                BorderRadius.circular(7),
          ),

          child: Text(
            widget.text,

            style: TextStyle(
              color: widget.textColor,
              fontSize: 15,
              fontWeight:
                  widget.text == 'Save'
                      ? FontWeight.w600
                      : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// DATA
// ==================================================================

class _TaxData {
  String name;
  String type;
  double rate;
  bool isDefault;

  _TaxData({
    required this.name,
    required this.type,
    required this.rate,
    this.isDefault = false,
  });
}