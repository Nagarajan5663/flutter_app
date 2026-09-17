import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionNumberSeriesPage extends StatefulWidget {
  final VoidCallback onBack;

  const TransactionNumberSeriesPage({
    super.key,
    required this.onBack,
  });

  @override
  State<TransactionNumberSeriesPage> createState() =>
      _TransactionNumberSeriesPageState();
}

class _TransactionNumberSeriesPageState
    extends State<TransactionNumberSeriesPage> {
  bool _showSuccess = true;

  final List<_NumberSeriesItem> _items = [
    _NumberSeriesItem('Journal'),
    _NumberSeriesItem('Credit Note'),
    _NumberSeriesItem('Customer Payment'),
    _NumberSeriesItem('Purchase Order'),
    _NumberSeriesItem('Sales Order'),
    _NumberSeriesItem('Vendor Payment'),
    _NumberSeriesItem('Retainer Invoice'),
    _NumberSeriesItem('Vendor Credits'),
    _NumberSeriesItem('Bill Of Supply'),
    _NumberSeriesItem('Debit Note'),
    _NumberSeriesItem('Invoice'),
  ];

  @override
  void initState() {
    super.initState();

    for (final item in _items) {
      item.prefixController.addListener(_refreshPreview);
      item.startController.addListener(_refreshPreview);
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.prefixController.removeListener(_refreshPreview);
      item.startController.removeListener(_refreshPreview);

      item.prefixController.dispose();
      item.startController.dispose();
    }

    super.dispose();
  }

  void _refreshPreview() {
    if (!mounted) return;

    setState(() {});
  }

  String _preview(_NumberSeriesItem item) {
    final String prefix =
        item.prefixController.text;

    final int number =
        int.tryParse(
              item.startController.text.trim(),
            ) ??
            1;

    final String paddedNumber =
        number.toString().padLeft(4, '0');

    return '$prefix$paddedNumber';
  }

  void _saveChanges() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F8FA),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          35,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Transaction Number Series',
                    style: TextStyle(
                      color:
                          Color(0xFF252A2E),
                      fontSize: 28,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed:
                      widget.onBack,

                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                  ),

                  label: const Text(
                    'Back to Settings',
                  ),

                  style:
                      TextButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF5965CF,
                    ),

                    backgroundColor:
                        const Color(
                      0xFFEFF1FF,
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(5),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // SUCCESS MESSAGE
            // =====================================================

            if (_showSuccess) ...[
              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFDDF4E2,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(4),
                ),

                child:
                    const Text(
                  'Transaction Number Series have been updated!',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFF327B43,
                    ),
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),
            ],

            // =====================================================
            // TABLE
            // =====================================================

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
                        constraints
                                    .maxWidth <
                                900
                            ? 900
                            : constraints
                                .maxWidth,

                    child: Column(
                      children: [
                        // HEADER ROW
                        Container(
                          height: 46,

                          decoration:
                              const BoxDecoration(
                            color:
                                Color(
                              0xFFF7F9FA,
                            ),

                            border:
                                Border(
                              bottom:
                                  BorderSide(
                                color:
                                    Color(
                                  0xFFE3E7E9,
                                ),
                              ),
                            ),
                          ),

                          child:
                              const Row(
                            children: [
                              Expanded(
                                flex: 22,
                                child:
                                    _HeaderCell(
                                  'MODULE',
                                ),
                              ),

                              Expanded(
                                flex: 31,
                                child:
                                    _HeaderCell(
                                  'PREFIX',
                                ),
                              ),

                              Expanded(
                                flex: 33,
                                child:
                                    _HeaderCell(
                                  'STARTING NUMBER',
                                ),
                              ),

                              Expanded(
                                flex: 14,
                                child:
                                    _HeaderCell(
                                  'PREVIEW',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // DATA ROWS
                        for (
                          int i = 0;
                          i < _items.length;
                          i++
                        )
                          _NumberSeriesRow(
                            item:
                                _items[i],

                            preview:
                                _preview(
                              _items[i],
                            ),

                            showBottomBorder:
                                i !=
                                    _items.length -
                                        1,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 14,
            ),

            // =====================================================
            // SAVE
            // =====================================================

            Align(
              alignment:
                  Alignment.centerRight,

              child:
                  ElevatedButton.icon(
                onPressed:
                    _saveChanges,

                icon:
                    const Icon(
                  Icons.save_rounded,
                  size: 15,
                ),

                label:
                    const Text(
                  'Save Changes',
                ),

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF28A745,
                  ),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(5),
                  ),

                  textStyle:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
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
// HEADER CELL
// ==================================================================

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(
    this.text,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),

      child: Text(
        text,

        style:
            const TextStyle(
          color:
              Color(
            0xFF545D62,
          ),
          fontSize: 10,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// ==================================================================
// DATA ROW
// ==================================================================

class _NumberSeriesRow
    extends StatefulWidget {
  final _NumberSeriesItem item;
  final String preview;
  final bool showBottomBorder;

  const _NumberSeriesRow({
    required this.item,
    required this.preview,
    required this.showBottomBorder,
  });

  @override
  State<_NumberSeriesRow>
      createState() =>
          _NumberSeriesRowState();
}

class _NumberSeriesRowState
    extends State<_NumberSeriesRow> {
  bool _hovered = false;

  @override
  Widget build(
    BuildContext context,
  ) {
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

      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 100,
        ),

        constraints:
            const BoxConstraints(
          minHeight: 52,
        ),

        decoration:
            BoxDecoration(
          color: _hovered
              ? const Color(
                  0xFFFAFBFB,
                )
              : Colors.white,

          border: widget
                  .showBottomBorder
              ? const Border(
                  bottom:
                      BorderSide(
                    color:
                        Color(
                      0xFFE4E8EA,
                    ),
                  ),
                )
              : null,
        ),

        child: Row(
          children: [
            // MODULE
            Expanded(
              flex: 22,

              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                ),

                child: Text(
                  widget.item.module,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF454C50,
                    ),
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w400,
                  ),
                ),
              ),
            ),

            // PREFIX
            Expanded(
              flex: 31,

              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),

                child:
                    _SmallTextField(
                  controller:
                      widget.item
                          .prefixController,
                ),
              ),
            ),

            // START NUMBER
            Expanded(
              flex: 33,

              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),

                child:
                    _SmallTextField(
                  controller:
                      widget.item
                          .startController,

                  keyboardType:
                      TextInputType
                          .number,

                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                ),
              ),
            ),

            // PREVIEW
            Expanded(
              flex: 14,

              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                ),

                child: Text(
                  widget.preview,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF4D5559,
                    ),
                    fontSize: 11,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
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
// SMALL INPUT
// ==================================================================

class _SmallTextField
    extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>?
      inputFormatters;

  const _SmallTextField({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: 31,

      child: TextFormField(
        controller:
            controller,

        keyboardType:
            keyboardType,

        inputFormatters:
            inputFormatters,

        style:
            const TextStyle(
          color:
              Color(
            0xFF3D4549,
          ),
          fontSize: 11,
        ),

        decoration:
            InputDecoration(
          isDense: true,

          filled: true,
          fillColor:
              Colors.white,

          contentPadding:
              const EdgeInsets
                  .symmetric(
            horizontal: 8,
            vertical: 8,
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius
                    .circular(
              3,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(
                0xFFD9DFE2,
              ),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius
                    .circular(
              3,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(
                0xFF80BDFF,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// MODEL
// ==================================================================

class _NumberSeriesItem {
  final String module;

  final TextEditingController
      prefixController =
      TextEditingController();

  final TextEditingController
      startController =
      TextEditingController(
    text: '1',
  );

  _NumberSeriesItem(
    this.module,
  );
}