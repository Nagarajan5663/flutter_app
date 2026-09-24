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

  late final List<_NumberSeriesItem> _items;

  @override
  void initState() {
    super.initState();

    _items = [
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

    for (final item in _items) {
      item.prefixController.addListener(_refreshPreview);
      item.startController.addListener(_refreshPreview);
    }
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.prefixController.dispose();
      item.startController.dispose();
    }

    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      _showSuccess = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  String _preview(_NumberSeriesItem item) {
    final String prefix = item.prefixController.text;

    final int number =
        int.tryParse(item.startController.text.trim()) ?? 1;

    final String paddedNumber =
        number.toString().padLeft(4, '0');

    return '$prefix$paddedNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF3F7F9),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          25,
          28,
          35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Transaction Number Series',
                    style: TextStyle(
                      color: Color(0xFF252A2E),
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                _BackButton(
                  onTap: widget.onBack,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ======================================================
            // SUCCESS MESSAGE
            // ======================================================

            if (_showSuccess) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4EDDA),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFFC3E6CB),
                  ),
                ),
                child: const Text(
                  'Transaction Number Series have been updated!',
                  style: TextStyle(
                    color: Color(0xFF26753A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // ======================================================
            // TABLE
            // ======================================================

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: constraints.maxWidth < 900
                        ? 900
                        : constraints.maxWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFE0E4E6),
                        ),
                      ),
                      child: Column(
                        children: [
                          // =========================================
                          // TABLE HEADER
                          // =========================================

                          Container(
                            height: 53,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F9F9),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFDDE2E4),
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 23,
                                  child: _TableHeader(
                                    'MODULE',
                                  ),
                                ),
                                Expanded(
                                  flex: 32,
                                  child: _TableHeader(
                                    'PREFIX',
                                  ),
                                ),
                                Expanded(
                                  flex: 32,
                                  child: _TableHeader(
                                    'STARTING NUMBER',
                                  ),
                                ),
                                Expanded(
                                  flex: 13,
                                  child: _TableHeader(
                                    'PREVIEW',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // =========================================
                          // ROWS
                          // =========================================

                          for (int i = 0;
                              i < _items.length;
                              i++)
                            _SeriesRow(
                              item: _items[i],
                              preview:
                                  _preview(_items[i]),
                              last:
                                  i == _items.length - 1,
                            ),

                          // =========================================
                          // SAVE AREA
                          // =========================================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              20,
                              20,
                              20,
                            ),
                            alignment: Alignment.centerRight,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFFE1E5E7),
                                ),
                              ),
                            ),
                            child: _SaveButton(
                              onTap: _saveChanges,
                            ),
                          ),
                        ],
                      ),
                    ),
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
// TABLE ROW
// ==================================================================

class _SeriesRow extends StatefulWidget {
  final _NumberSeriesItem item;
  final String preview;
  final bool last;

  const _SeriesRow({
    required this.item,
    required this.preview,
    required this.last,
  });

  @override
  State<_SeriesRow> createState() =>
      _SeriesRowState();
}

class _SeriesRowState extends State<_SeriesRow> {
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
        height: 67,
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFFFAFBFB)
              : Colors.white,
          border: widget.last
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: Color(0xFFE1E4E6),
                  ),
                ),
        ),

        child: Row(
          children: [
            // MODULE
            Expanded(
              flex: 23,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  widget.item.module,
                  style: const TextStyle(
                    color: Color(0xFF454C50),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // PREFIX
            Expanded(
              flex: 32,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: _SeriesField(
                  controller:
                      widget.item.prefixController,
                ),
              ),
            ),

            // START NUMBER
            Expanded(
              flex: 32,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: _SeriesField(
                  controller:
                      widget.item.startController,
                  numbersOnly: true,
                ),
              ),
            ),

            // PREVIEW
            Expanded(
              flex: 13,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  widget.preview,
                  style: const TextStyle(
                    color: Color(0xFF394146),
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
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
// TEXT FIELD
// ==================================================================

class _SeriesField extends StatelessWidget {
  final TextEditingController controller;
  final bool numbersOnly;

  const _SeriesField({
    required this.controller,
    this.numbersOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextFormField(
        controller: controller,

        keyboardType: numbersOnly
            ? TextInputType.number
            : TextInputType.text,

        inputFormatters: numbersOnly
            ? [
                FilteringTextInputFormatter
                    .digitsOnly,
              ]
            : null,

        style: const TextStyle(
          color: Color(0xFF33383B),
          fontSize: 14,
        ),

        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Color(0xFFD7DCDF),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Color(0xFF80BDFF),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// TABLE HEADER
// ==================================================================

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF333A3E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
            horizontal: 18,
            vertical: 13,
          ),

          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFE2E5FA)
                : const Color(0xFFECEEFF),

            borderRadius:
                BorderRadius.circular(7),
          ),

          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: 17,
                color: Color(0xFF5554B8),
              ),

              SizedBox(width: 6),

              Text(
                'Back to Settings',
                style: TextStyle(
                  color: Color(0xFF5554B8),
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

          height: 40,

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFF218838)
                : const Color(0xFF28A745),

            borderRadius:
                BorderRadius.circular(6),
          ),

          child: const Row(
            mainAxisSize: MainAxisSize.min,
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
                  fontSize: 13,
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
// MODEL
// ==================================================================

class _NumberSeriesItem {
  final String module;

  final TextEditingController prefixController =
      TextEditingController();

  final TextEditingController startController =
      TextEditingController(text: '1');

  _NumberSeriesItem(this.module);
}