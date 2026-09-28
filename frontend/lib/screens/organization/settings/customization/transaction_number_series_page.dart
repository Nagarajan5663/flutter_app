import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionNumberSeriesPage
    extends StatefulWidget {
  final VoidCallback? onBack;

  const TransactionNumberSeriesPage({
    super.key,
    this.onBack,
  });

  @override
  State<TransactionNumberSeriesPage>
      createState() =>
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

  // ==========================================================
  // DISPOSE
  // ==========================================================

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

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage =
            error.toString();
      });
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void>
      _saveChanges() async {
    if (_isSaving) {
      return;
    }

    for (
      final item
      in _items
    ) {
      final int? number =
          int.tryParse(
        item.startingNumberController
            .text
            .trim(),
      );

      if (
        number == null ||
        number <= 0
      ) {
        _showMessage(
          '${item.module}: Starting Number must be greater than 0.',
          error: true,
        );

        return;
      }
    }

    setState(() {
      _isSaving = true;

      _errorMessage = null;
    });

    try {
      final http.Response response =
          await http.put(
        Uri.parse(
          '$_baseUrl/transaction-number-series',
        ),
        headers: const {
          'Content-Type':
              'application/json',

          'Accept':
              'application/json',
        },
        body: jsonEncode({
          'series':
              _items
                  .map(
                    (
                      item,
                    ) =>
                        item.toJson(),
                  )
                  .toList(),
        }),
      );

      final dynamic body =
          jsonDecode(
        response.body,
      );

      if (
        body is! Map<String, dynamic>
      ) {
        throw Exception(
          'Invalid response from server',
        );
      }

      if (
        response.statusCode != 200 ||
        body['success'] != true
      ) {
        throw Exception(
          body['message'] ??
              'Failed to save transaction number series',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Transaction number series saved successfully.',
      );

      await _loadSeries();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;

        _errorMessage =
            error.toString();
      });

      _showMessage(
        'Failed to save: $error',
        error: true,
      );
    }
  }

  // ==========================================================
  // BACK
  // ==========================================================

  void _goBack() {
    if (
      widget.onBack != null
    ) {
      widget.onBack!();

      return;
    }

    if (
      Navigator.of(context)
          .canPop()
    ) {
      Navigator.of(context)
          .pop();
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          message,
        ),

        backgroundColor:
            error
                ? const Color(
                    0xFFB3261E,
                  )
                : const Color(
                    0xFF188038,
                  ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF5F8FA,
      ),

      body:
          SafeArea(
        child:
            Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 24,
                vertical: 18,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Colors.white,

                border:
                    Border(
                  bottom:
                      BorderSide(
                    color:
                        Color(
                      0xFFE2E7EC,
                    ),
                  ),
                ),
              ),

              child:
                  Row(
                children: [
                  IconButton(
                    onPressed:
                        _goBack,

                    icon:
                        const Icon(
                      Icons
                          .arrow_back,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  const Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          'Transaction Number Series',

                          style:
                              TextStyle(
                            fontSize:
                                25,

                            fontWeight:
                                FontWeight
                                    .w700,

                            color:
                                Color(
                              0xFF263B4E,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 3,
                        ),

                        Text(
                          'Configure prefixes and starting numbers for transactions.',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF73808C,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip:
                        'Refresh',

                    onPressed:
                        _isLoading ||
                                _isSaving
                            ? null
                            : _loadSeries,

                    icon:
                        const Icon(
                      Icons.refresh,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child:
                  _buildContent(),
            ),

            // ==================================================
            // FOOTER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                24,
                14,
                24,
                14,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Colors.white,

                border:
                    Border(
                  top:
                      BorderSide(
                    color:
                        Color(
                      0xFFE2E7EC,
                    ),
                  ),
                ),
              ),

              child:
                  Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .end,

                children: [
                  ElevatedButton.icon(
                    onPressed:
                        _isSaving ||
                                _isLoading
                            ? null
                            : _saveChanges,

                    icon:
                        _isSaving
                            ? const SizedBox(
                                width: 17,
                                height: 17,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,

                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),

                    label:
                        Text(
                      _isSaving
                          ? 'Saving...'
                          : 'Save Changes',
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF20A840,
                      ),

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            22,

                        vertical:
                            15,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (
      _errorMessage != null
    ) {
      return Center(
        child:
            Padding(
          padding:
              const EdgeInsets
                  .all(
            30,
          ),

          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              const Icon(
                Icons
                    .error_outline,

                size:
                    45,

                color:
                    Colors.red,
              ),

              const SizedBox(
                height:
                    12,
              ),

              Text(
                _errorMessage!,

                textAlign:
                    TextAlign
                        .center,
              ),

              const SizedBox(
                height:
                    16,
              ),

              ElevatedButton(
                onPressed:
                    _loadSeries,

                child:
                    const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding:
          const EdgeInsets
              .all(
        24,
      ),

      child:
          Container(
        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius
                  .circular(
            8,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xFFE1E6EA,
            ),
          ),
        ),

        child:
            Column(
          children: [
            // ==================================================
            // TABLE HEADER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal:
                    16,

                vertical:
                    17,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFF8FAFB,
                ),

                border:
                    Border(
                  bottom:
                      BorderSide(
                    color:
                        Color(
                      0xFFE1E6EA,
                    ),
                  ),
                ),
              ),

              child:
                  const Row(
                children: [
                  Expanded(
                    flex:
                        2,

                    child:
                        _HeaderText(
                      'MODULE',
                    ),
                  ),

                  Expanded(
                    flex:
                        3,

                    child:
                        _HeaderText(
                      'PREFIX',
                    ),
                  ),

                  SizedBox(
                    width:
                        28,
                  ),

                  Expanded(
                    flex:
                        3,

                    child:
                        _HeaderText(
                      'STARTING NUMBER',
                    ),
                  ),

                  SizedBox(
                    width:
                        28,
                  ),

                  Expanded(
                    flex:
                        1,

                    child:
                        _HeaderText(
                      'PREVIEW',
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // ROWS
            // ==================================================

            ..._items.map(
              (
                TransactionNumberSeriesItem
                    item,
              ) {
                return _buildRow(
                  item,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TABLE ROW
  // ==========================================================

  Widget _buildRow(
    TransactionNumberSeriesItem item,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal:
            16,

        vertical:
            14,
      ),

      decoration:
          const BoxDecoration(
        border:
            Border(
          bottom:
              BorderSide(
            color:
                Color(
              0xFFE5E9ED,
            ),
          ),
        ),
      ),

      child:
          Row(
        children: [
          Expanded(
            flex:
                2,

            child:
                Text(
              item.module,

              style:
                  const TextStyle(
                fontSize:
                    15,

                color:
                    Color(
                  0xFF4B545C,
                ),
              ),
            ),
          ),

          Expanded(
            flex:
                3,

            child:
                TextField(
              controller:
                  item.prefixController,

              onChanged:
                  (_) {
                setState(() {});
              },

              decoration:
                  _inputDecoration(),
            ),
          ),

          const SizedBox(
            width:
                28,
          ),

          Expanded(
            flex:
                3,

            child:
                TextField(
              controller:
                  item
                      .startingNumberController,

              keyboardType:
                  TextInputType.number,

              onChanged:
                  (_) {
                setState(() {});
              },

              decoration:
                  _inputDecoration(),
            ),
          ),

          const SizedBox(
            width:
                28,
          ),

          Expanded(
            flex:
                1,

            child:
                Text(
              item.preview,

              style:
                  const TextStyle(
                fontSize:
                    15,

                color:
                    Color(
                  0xFF5F6870,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration
      _inputDecoration() {
    return InputDecoration(
      isDense:
          true,

      filled:
          true,

      fillColor:
          Colors.white,

      contentPadding:
          const EdgeInsets
              .symmetric(
        horizontal:
            12,

        vertical:
            13,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          5,
        ),

        borderSide:
            const BorderSide(
          color:
              Color(
            0xFFD5DDE4,
          ),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          5,
        ),

        borderSide:
            const BorderSide(
          color:
              Color(
            0xFFD5DDE4,
          ),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          5,
        ),

        borderSide:
            const BorderSide(
          color:
              Color(
            0xFF2D7FF9,
          ),

          width:
              1.5,
        ),
      ),
    );
  }
}

// ============================================================
// HEADER TEXT
// ============================================================

class _HeaderText
    extends StatelessWidget {
  final String text;

  const _HeaderText(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,

      style:
          const TextStyle(
        fontSize:
            12,

        fontWeight:
            FontWeight.w700,

        color:
            Color(
          0xFF59636D,
        ),
      ),
    );
  }
}