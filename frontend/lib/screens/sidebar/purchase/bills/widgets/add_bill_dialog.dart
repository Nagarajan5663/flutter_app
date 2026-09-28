import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../shared/glass_modal_shell.dart';
import '../../purchase_orders/purchase_order_item_model.dart';
import '../../vendors/vendor_model.dart';
import '../../vendors/vendor_repository.dart';
import '../bill_repository.dart';

// ============================================================
// CATALOG ITEM / PART
// ============================================================

class _CatalogOption {
  final String sourceType;

  final int id;

  final String name;

  final String sku;

  final String description;

  final double purchasePrice;

  const _CatalogOption({
    required this.sourceType,
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.purchasePrice,
  });
}

// ============================================================
// ITEM ROW
// ============================================================

class _ItemRow {
  _CatalogOption? selectedProduct;

  final TextEditingController
      descriptionController =
      TextEditingController();

  final TextEditingController
      qtyController =
      TextEditingController(
    text: '1',
  );

  final TextEditingController
      rateController =
      TextEditingController(
    text: '0.00',
  );

  double get amount {
    final double qty =
        double.tryParse(
          qtyController.text.trim(),
        ) ??
        0;

    final double rate =
        double.tryParse(
          rateController.text.trim(),
        ) ??
        0;

    return qty * rate;
  }

  void clear() {
    selectedProduct = null;

    descriptionController
        .clear();

    qtyController.text =
        '1';

    rateController.text =
        '0.00';
  }

  void dispose() {
    descriptionController
        .dispose();

    qtyController.dispose();

    rateController.dispose();
  }
}

// ============================================================
// ADD BILL DIALOG
// ============================================================

class AddBillDialog
    extends StatefulWidget {
  const AddBillDialog({
    super.key,
  });

  @override
  State<AddBillDialog>
      createState() =>
          _AddBillDialogState();
}

class _AddBillDialogState
    extends State<AddBillDialog> {
  static const String _baseUrl =
      'http://localhost:3000/api';

  final VendorRepository
      _vendorRepository =
      InMemoryVendorRepository();

  final BillRepository
      _billRepository =
      InMemoryBillRepository();

  final TextEditingController
      billNumberController =
      TextEditingController();

  final TextEditingController
      vendorInvoiceController =
      TextEditingController();

  final TextEditingController
      taxController =
      TextEditingController(
    text: '0.00',
  );

  List<VendorModel> _vendors =
      [];

  List<_CatalogOption> _catalog =
      [];

  VendorModel? selectedVendor;

  DateTime billDate =
      DateTime.now();

  DateTime? dueDate;

  String? _attachedFileName;

  final List<_ItemRow> rows = [
    _ItemRow(),
  ];

  bool _isLoading = true;

  bool _isSaving = false;

  String? _errorText;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;

      _errorText = null;
    });

    try {
      final Future<List<VendorModel>>
          vendorFuture =
          _vendorRepository
              .getVendors();

      final Future<String>
          billNumberFuture =
          _billRepository
              .nextBillNumber();

      final Future<List<_CatalogOption>>
          catalogFuture =
          _loadCatalog();

      final List<VendorModel>
          vendors =
          await vendorFuture;

      final String billNumber =
          await billNumberFuture;

      final List<_CatalogOption>
          catalog =
          await catalogFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _vendors =
            vendors;

        _catalog =
            catalog;

        billNumberController.text =
            billNumber;

        _isLoading =
            false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading =
            false;

        _errorText =
            'Unable to load Bill data: $error';
      });
    }
  }

  // ==========================================================
  // LOAD ITEMS + PARTS
  //
  // Bills use PURCHASE PRICE because it is vendor-side.
  // ==========================================================

  Future<List<_CatalogOption>>
      _loadCatalog() async {
    final Future<http.Response>
        itemFuture =
        http.get(
      Uri.parse(
        '$_baseUrl/items',
      ),
      headers: const {
        'Accept':
            'application/json',
      },
    );

    final Future<http.Response>
        partFuture =
        http.get(
      Uri.parse(
        '$_baseUrl/parts',
      ),
      headers: const {
        'Accept':
            'application/json',
      },
    );

    final http.Response itemResponse =
        await itemFuture;

    final http.Response partResponse =
        await partFuture;

    final dynamic itemBody =
        jsonDecode(
      itemResponse.body,
    );

    final dynamic partBody =
        jsonDecode(
      partResponse.body,
    );

    if (
      itemBody is! Map<String, dynamic> ||
      itemResponse.statusCode != 200 ||
      itemBody['success'] != true
    ) {
      throw Exception(
        itemBody is Map
            ? itemBody['message'] ??
                'Failed to load items'
            : 'Failed to load items',
      );
    }

    if (
      partBody is! Map<String, dynamic> ||
      partResponse.statusCode != 200 ||
      partBody['success'] != true
    ) {
      throw Exception(
        partBody is Map
            ? partBody['message'] ??
                'Failed to load parts'
            : 'Failed to load parts',
      );
    }

    final List<_CatalogOption>
        catalog = [];

    // ==========================================================
    // ITEMS
    // ==========================================================

    final List<dynamic> items =
        itemBody['data'] is List
            ? itemBody['data']
            : <dynamic>[];

    for (
      final dynamic raw
      in items
    ) {
      final Map<String, dynamic>
          item =
          Map<String, dynamic>.from(
        raw as Map,
      );

      final int id =
          int.tryParse(
            item['id']
                    ?.toString() ??
                '',
          ) ??
          0;

      final String name =
          item['name']
                  ?.toString() ??
              '';

      if (
        id <= 0 ||
        name.trim().isEmpty
      ) {
        continue;
      }

      catalog.add(
        _CatalogOption(
          sourceType:
              'Item',

          id:
              id,

          name:
              name,

          sku:
              item['sku']
                      ?.toString() ??
                  '',

          description:
              item['description']
                      ?.toString() ??
                  '',

          purchasePrice:
              double.tryParse(
                item[
                        'purchase_price']
                    ?.toString() ??
                    '0',
              ) ??
              0,
        ),
      );
    }

    // ==========================================================
    // PARTS
    // ==========================================================

    final List<dynamic> parts =
        partBody['data'] is List
            ? partBody['data']
            : <dynamic>[];

    for (
      final dynamic raw
      in parts
    ) {
      final Map<String, dynamic>
          part =
          Map<String, dynamic>.from(
        raw as Map,
      );

      final int id =
          int.tryParse(
            part['id']
                    ?.toString() ??
                '',
          ) ??
          0;

      final String name =
          part['name']
                  ?.toString() ??
              '';

      if (
        id <= 0 ||
        name.trim().isEmpty
      ) {
        continue;
      }

      catalog.add(
        _CatalogOption(
          sourceType:
              'Part',

          id:
              id,

          name:
              name,

          sku:
              part['sku']
                      ?.toString() ??
                  '',

          description:
              part['description']
                      ?.toString() ??
                  '',

          purchasePrice:
              double.tryParse(
                part[
                        'purchase_price']
                    ?.toString() ??
                    '0',
              ) ??
              0,
        ),
      );
    }

    return catalog;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    billNumberController
        .dispose();

    vendorInvoiceController
        .dispose();

    taxController
        .dispose();

    for (
      final _ItemRow row
      in rows
    ) {
      row.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // ADD / REMOVE ROW
  // ==========================================================

  void _addRow() {
    setState(() {
      rows.add(
        _ItemRow(),
      );
    });
  }

  void _removeRow(
    int index,
  ) {
    if (
      rows.length == 1
    ) {
      setState(() {
        rows.first.clear();
      });

      return;
    }

    setState(() {
      rows[index]
          .dispose();

      rows.removeAt(
        index,
      );
    });
  }

  // ==========================================================
  // TOTALS
  // ==========================================================

  double get _subTotal {
    return rows.fold(
      0.0,
      (
        double total,
        _ItemRow row,
      ) {
        return total +
            row.amount;
      },
    );
  }

  double get _tax {
    return double.tryParse(
          taxController.text
              .trim(),
        ) ??
        0;
  }

  double get _total {
    return _subTotal +
        _tax;
  }

  // ==========================================================
  // DATE
  // ==========================================================

  Future<void> _pickDate({
    required DateTime? initial,

    required ValueChanged<DateTime>
        onPicked,
  }) async {
    final DateTime? picked =
        await showDatePicker(
      context:
          context,

      initialDate:
          initial ??
              DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),
    );

    if (
      picked != null
    ) {
      onPicked(
        picked,
      );
    }
  }

  // ==========================================================
  // FILE PICKER
  //
  // Currently only stores file name.
  // Actual file upload can be added separately.
  // ==========================================================

  Future<void>
      _pickInvoiceFile() async {
    final FilePickerResult? result =
        await FilePicker.platform
            .pickFiles(
      type:
          FileType.custom,

      allowedExtensions:
          const [
        'pdf',
        'png',
        'jpg',
        'jpeg',
      ],
    );

    if (
      result == null ||
      result.files.isEmpty
    ) {
      return;
    }

    setState(() {
      _attachedFileName =
          result.files.single.name;
    });
  }

  // ==========================================================
  // SAVE BILL
  // ==========================================================

  void _saveBill() {
    if (_isSaving) {
      return;
    }

    // ----------------------------------------------------------
    // Vendor validation
    // ----------------------------------------------------------

    if (
      selectedVendor == null
    ) {
      setState(() {
        _errorText =
            'Please select a vendor';
      });

      return;
    }

    if (
      selectedVendor!.id ==
              null ||
          selectedVendor!.id!
              .trim()
              .isEmpty
    ) {
      setState(() {
        _errorText =
            'Selected vendor ID is missing';
      });

      return;
    }

    // ----------------------------------------------------------
    // Bill Number
    // ----------------------------------------------------------

    if (
      billNumberController
          .text
          .trim()
          .isEmpty
    ) {
      setState(() {
        _errorText =
            'Bill number is required';
      });

      return;
    }

    // ----------------------------------------------------------
    // Due Date
    // ----------------------------------------------------------

    if (
      dueDate != null &&
      dueDate!.isBefore(
        DateTime(
          billDate.year,
          billDate.month,
          billDate.day,
        ),
      )
    ) {
      setState(() {
        _errorText =
            'Due date cannot be before bill date';
      });

      return;
    }

    // ----------------------------------------------------------
    // Tax
    // ----------------------------------------------------------

    if (_tax < 0) {
      setState(() {
        _errorText =
            'Tax cannot be negative';
      });

      return;
    }

    // ----------------------------------------------------------
    // Items
    // ----------------------------------------------------------

    final List<
            PurchaseOrderItemModel>
        items = [];

    for (
      final _ItemRow row
      in rows
    ) {
      if (
        row.selectedProduct ==
        null
      ) {
        continue;
      }

      final double qty =
          double.tryParse(
            row.qtyController
                .text
                .trim(),
          ) ??
          0;

      final double rate =
          double.tryParse(
            row.rateController
                .text
                .trim(),
          ) ??
          0;

      if (
        qty <= 0
      ) {
        setState(() {
          _errorText =
              'Quantity must be greater than zero';
        });

        return;
      }

      if (
        rate < 0
      ) {
        setState(() {
          _errorText =
              'Rate cannot be negative';
        });

        return;
      }

      items.add(
        PurchaseOrderItemModel(
          itemName:
              row.selectedProduct!
                  .name,

          description:
              row.descriptionController
                  .text
                  .trim(),

          qty:
              qty,

          rate:
              rate,
        ),
      );
    }

    if (
      items.isEmpty
    ) {
      setState(() {
        _errorText =
            'Please select at least one Item or Part';
      });

      return;
    }

    setState(() {
      _isSaving =
          true;

      _errorText =
          null;
    });

    final BillModelDraft draft =
        BillModelDraft(
      billNumber:
          billNumberController
              .text
              .trim(),

      vendorInvoiceNumber:
          vendorInvoiceController
              .text
              .trim(),

      invoiceAttachmentPath:
          _attachedFileName,

      vendorId:
          selectedVendor!.id!,

      vendorName:
          selectedVendor!
              .vendorName,

      billDate:
          billDate,

      dueDate:
          dueDate,

      items:
          items,

      taxAmount:
          _tax,
    );

    Navigator.pop(
      context,
      draft,
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassModalShell(
      maxWidth:
          1000,

      maxHeight:
          850,

      child: _isLoading
          ? const Padding(
              padding:
                  EdgeInsets.all(
                60,
              ),

              child:
                  Center(
                child:
                    CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                34,
                30,
                34,
                28,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  // ============================================
                  // HEADER
                  // ============================================

                  GlassDialogHeader(
                    title:
                        'New Bill',

                    icon:
                        Icons
                            .receipt_long_outlined,

                    onClose:
                        () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),

                  const SizedBox(
                    height:
                        20,
                  ),

                  // ============================================
                  // ERROR
                  // ============================================

                  if (
                    _errorText !=
                    null
                  ) ...[
                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        12,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF4E3E3,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          7,
                        ),
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child:
                                Text(
                              _errorText!,

                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFFAB2A2A,
                                ),
                              ),
                            ),
                          ),

                          if (
                            _vendors
                                    .isEmpty ||
                                _catalog
                                    .isEmpty
                          )
                            TextButton(
                              onPressed:
                                  _init,

                              child:
                                  const Text(
                                'Retry',
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                          16,
                    ),
                  ],

                  // ============================================
                  // TOP ROW
                  // Vendor / Bill / Vendor Invoice / Date
                  // ============================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Expanded(
                        child:
                            _labeledField(
                          label:
                              'Vendor Name *',

                          child:
                              DropdownSearch<
                                  VendorModel>(
                            items: (
                              filter,
                              infiniteScrollProps,
                            ) {
                              final String
                                  query =
                                  filter
                                      .trim()
                                      .toLowerCase();

                              if (
                                query
                                    .isEmpty
                              ) {
                                return _vendors;
                              }

                              return _vendors
                                  .where(
                                    (
                                      VendorModel
                                          vendor,
                                    ) {
                                      return vendor
                                              .vendorName
                                              .toLowerCase()
                                              .contains(
                                                query,
                                              ) ||
                                          vendor
                                              .companyName
                                              .toLowerCase()
                                              .contains(
                                                query,
                                              ) ||
                                          vendor
                                              .email
                                              .toLowerCase()
                                              .contains(
                                                query,
                                              );
                                    },
                                  )
                                  .toList();
                            },

                            itemAsString:
                                (
                              VendorModel
                                  vendor,
                            ) {
                              if (
                                vendor
                                    .companyName
                                    .trim()
                                    .isEmpty
                              ) {
                                return vendor
                                    .vendorName;
                              }

                              return '${vendor.vendorName} - ${vendor.companyName}';
                            },

                            compareFn:
                                (
                              VendorModel a,
                              VendorModel b,
                            ) {
                              return a.id ==
                                  b.id;
                            },

                            selectedItem:
                                selectedVendor,

                            onChanged:
                                (
                              VendorModel?
                                  vendor,
                            ) {
                              setState(() {
                                selectedVendor =
                                    vendor;
                              });
                            },

                            popupProps:
                                const PopupProps
                                    .menu(
                              showSearchBox:
                                  true,
                            ),

                            decoratorProps:
                                DropDownDecoratorProps(
                              decoration:
                                  _fieldDecoration(
                                hint:
                                    'Select or type to search...',
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width:
                            12,
                      ),

                      Expanded(
                        child:
                            _labeledField(
                          label:
                              'Bill # *',

                          child:
                              _textField(
                            controller:
                                billNumberController,

                            enabled:
                                false,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width:
                            12,
                      ),

                      Expanded(
                        child:
                            _labeledField(
                          label:
                              'Vendor Invoice #',

                          child:
                              _textField(
                            controller:
                                vendorInvoiceController,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width:
                            12,
                      ),

                      Expanded(
                        child:
                            _labeledField(
                          label:
                              'Date *',

                          child:
                              _dateField(
                            value:
                                billDate,

                            onTap:
                                () {
                              _pickDate(
                                initial:
                                    billDate,

                                onPicked:
                                    (
                                  DateTime
                                      value,
                                ) {
                                  setState(() {
                                    billDate =
                                        value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        18,
                  ),

                  // ============================================
                  // DUE DATE + FILE
                  // ============================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Expanded(
                        child:
                            _labeledField(
                          label:
                              'Due Date',

                          child:
                              _dateField(
                            value:
                                dueDate,

                            onTap:
                                () {
                              _pickDate(
                                initial:
                                    dueDate ??
                                        billDate,

                                onPicked:
                                    (
                                  DateTime
                                      value,
                                ) {
                                  setState(() {
                                    dueDate =
                                        value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(
                        width:
                            12,
                      ),

                      Expanded(
                        child:
                            _labeledField(
                          label:
                              'Attach Invoice',

                          child:
                              Row(
                            children: [
                              OutlinedButton(
                                onPressed:
                                    _pickInvoiceFile,

                                style:
                                    OutlinedButton
                                        .styleFrom(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        14,

                                    vertical:
                                        14,
                                  ),

                                  side:
                                      const BorderSide(
                                    color:
                                        Color(
                                      0xFFD9DEE5,
                                    ),
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      7,
                                    ),
                                  ),
                                ),

                                child:
                                    const Text(
                                  'Choose File',
                                ),
                              ),

                              const SizedBox(
                                width:
                                    10,
                              ),

                              Expanded(
                                child:
                                    Text(
                                  _attachedFileName ??
                                      'No file chosen',

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF5B5B5B,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        26,
                  ),

                  // ============================================
                  // ITEM DETAILS
                  // ============================================

                  const Text(
                    'Item Details',

                    style:
                        TextStyle(
                      fontSize:
                          17,

                      fontWeight:
                          FontWeight
                              .w700,

                      color:
                          Color(
                        0xFF3D4147,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        12,
                  ),

                  const Row(
                    children: [
                      Expanded(
                        flex:
                            4,

                        child:
                            _SmallHeader(
                          'ITEM / DESCRIPTION',
                        ),
                      ),

                      Expanded(
                        flex:
                            2,

                        child:
                            _SmallHeader(
                          'QTY',
                        ),
                      ),

                      Expanded(
                        flex:
                            2,

                        child:
                            _SmallHeader(
                          'RATE',
                        ),
                      ),

                      Expanded(
                        flex:
                            2,

                        child:
                            _SmallHeader(
                          'AMOUNT',
                        ),
                      ),

                      SizedBox(
                        width:
                            36,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        8,
                  ),

                  ...rows
                      .asMap()
                      .entries
                      .map(
                    (
                      MapEntry<
                              int,
                              _ItemRow>
                          entry,
                    ) {
                      final int index =
                          entry.key;

                      final _ItemRow row =
                          entry.value;

                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom:
                              14,
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            // ==================================
                            // ITEM / PART
                            // ==================================

                            Expanded(
                              flex:
                                  4,

                              child:
                                  Column(
                                children: [
                                  DropdownSearch<
                                      _CatalogOption>(
                                    items: (
                                      filter,
                                      infiniteScrollProps,
                                    ) {
                                      final String
                                          query =
                                          filter
                                              .trim()
                                              .toLowerCase();

                                      if (
                                        query
                                            .isEmpty
                                      ) {
                                        return _catalog;
                                      }

                                      return _catalog
                                          .where(
                                            (
                                              _CatalogOption
                                                  product,
                                            ) {
                                              return product
                                                      .name
                                                      .toLowerCase()
                                                      .contains(
                                                        query,
                                                      ) ||
                                                  product
                                                      .sku
                                                      .toLowerCase()
                                                      .contains(
                                                        query,
                                                      ) ||
                                                  product
                                                      .sourceType
                                                      .toLowerCase()
                                                      .contains(
                                                        query,
                                                      );
                                            },
                                          )
                                          .toList();
                                    },

                                    itemAsString:
                                        (
                                      _CatalogOption
                                          product,
                                    ) {
                                      final String
                                          skuText =
                                          product
                                                  .sku
                                                  .isEmpty
                                              ? ''
                                              : ' • ${product.sku}';

                                      return '${product.name} [${product.sourceType}]$skuText';
                                    },

                                    compareFn:
                                        (
                                      _CatalogOption
                                          a,
                                      _CatalogOption
                                          b,
                                    ) {
                                      return a.id ==
                                              b.id &&
                                          a.sourceType ==
                                              b.sourceType;
                                    },

                                    selectedItem:
                                        row.selectedProduct,

                                    onChanged:
                                        (
                                      _CatalogOption?
                                          product,
                                    ) {
                                      setState(() {
                                        row.selectedProduct =
                                            product;

                                        if (
                                          product ==
                                          null
                                        ) {
                                          row
                                              .descriptionController
                                              .clear();

                                          row.rateController.text =
                                              '0.00';

                                          return;
                                        }

                                        row
                                                .descriptionController
                                                .text =
                                            product
                                                .description;

                                        row.rateController.text =
                                            product
                                                .purchasePrice
                                                .toStringAsFixed(
                                              2,
                                            );
                                      });
                                    },

                                    popupProps:
                                        const PopupProps
                                            .menu(
                                      showSearchBox:
                                          true,
                                    ),

                                    decoratorProps:
                                        DropDownDecoratorProps(
                                      decoration:
                                          _fieldDecoration(
                                        hint:
                                            'Select or type to search...',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        6,
                                  ),

                                  _textField(
                                    controller:
                                        row.descriptionController,

                                    hint:
                                        'Description',

                                    maxLines:
                                        2,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width:
                                  8,
                            ),

                            // ==================================
                            // QTY
                            // ==================================

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _textField(
                                controller:
                                    row.qtyController,

                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal:
                                      true,
                                ),

                                onChanged:
                                    (_) {
                                  setState(() {});
                                },
                              ),
                            ),

                            const SizedBox(
                              width:
                                  8,
                            ),

                            // ==================================
                            // RATE
                            // ==================================

                            Expanded(
                              flex:
                                  2,

                              child:
                                  _textField(
                                controller:
                                    row.rateController,

                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal:
                                      true,
                                ),

                                onChanged:
                                    (_) {
                                  setState(() {});
                                },
                              ),
                            ),

                            const SizedBox(
                              width:
                                  8,
                            ),

                            // ==================================
                            // AMOUNT
                            // ==================================

                            Expanded(
                              flex:
                                  2,

                              child:
                                  Container(
                                height:
                                    50,

                                alignment:
                                    Alignment
                                        .centerLeft,

                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      12,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      GlassSurface
                                          .fill(
                                    emphasized:
                                        true,
                                  ),

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    7,
                                  ),
                                ),

                                child:
                                    Text(
                                  'INR ${row.amount.toStringAsFixed(2)}',
                                ),
                              ),
                            ),

                            // ==================================
                            // REMOVE
                            // ==================================

                            SizedBox(
                              width:
                                  36,

                              child:
                                  IconButton(
                                onPressed:
                                    () {
                                  _removeRow(
                                    index,
                                  );
                                },

                                icon:
                                    const Icon(
                                  Icons.close,

                                  color:
                                      Color(
                                    0xFFAB2A2A,
                                  ),

                                  size:
                                      18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  TextButton.icon(
                    onPressed:
                        _addRow,

                    icon:
                        const Icon(
                      Icons.add,

                      size:
                          18,
                    ),

                    label:
                        const Text(
                      'Add Row',
                    ),

                    style:
                        TextButton
                            .styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF2E7DD1,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        15,
                  ),

                  // ============================================
                  // TOTAL
                  // ============================================

                  Align(
                    alignment:
                        Alignment
                            .centerRight,

                    child: SizedBox(
                      width:
                          300,

                      child:
                          Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                'Sub Total',
                              ),

                              Text(
                                'INR ${_subTotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),

                          const SizedBox(
                            height:
                                12,
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                'Tax',
                              ),

                              SizedBox(
                                width:
                                    130,

                                child:
                                    TextField(
                                  controller:
                                      taxController,

                                  textAlign:
                                      TextAlign
                                          .right,

                                  keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                    decimal:
                                        true,
                                  ),

                                  onChanged:
                                      (_) {
                                    setState(() {});
                                  },

                                  decoration:
                                      InputDecoration(
                                    prefixText:
                                        'INR ',

                                    isDense:
                                        true,

                                    filled:
                                        true,

                                    fillColor:
                                        GlassSurface
                                            .fill(),

                                    contentPadding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          10,

                                      vertical:
                                          10,
                                    ),

                                    border:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        7,
                                      ),
                                    ),

                                    enabledBorder:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        7,
                                      ),

                                      borderSide:
                                          BorderSide(
                                        color:
                                            GlassSurface
                                                .border(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(
                            height:
                                24,

                            color:
                                Color(
                              0xFFD9DEE5,
                            ),
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [
                              const Text(
                                'Total',

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  fontSize:
                                      17,
                                ),
                              ),

                              Text(
                                'INR ${_total.toStringAsFixed(2)}',

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  fontSize:
                                      17,

                                  color:
                                      Color(
                                    0xFF123456,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        28,
                  ),

                  // ============================================
                  // BUTTONS
                  // ============================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .end,

                    children: [
                      GlassButton(
                        onPressed:
                            _isSaving
                                ? null
                                : () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },

                        icon:
                            Icons.close,

                        label:
                            'Cancel',

                        primary:
                            false,
                      ),

                      const SizedBox(
                        width:
                            16,
                      ),

                      GlassButton(
                        onPressed:
                            _isSaving
                                ? null
                                : _saveBill,

                        icon:
                            Icons.save,

                        label:
                            'Save Bill',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // LABELED FIELD
  // ==========================================================

  Widget _labeledField({
    required String label,

    required Widget child,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style:
              const TextStyle(
            fontSize:
                14,

            fontWeight:
                FontWeight.w500,

            color:
                Color(
              0xFF3D4147,
            ),
          ),
        ),

        const SizedBox(
          height:
              6,
        ),

        child,
      ],
    );
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration
      _fieldDecoration({
    String? hint,
  }) {
    return InputDecoration(
      hintText:
          hint,

      filled:
          true,

      fillColor:
          GlassSurface.fill(),

      contentPadding:
          const EdgeInsets
              .symmetric(
        horizontal:
            16,

        vertical:
            15,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          7,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          7,
        ),

        borderSide:
            BorderSide(
          color:
              GlassSurface
                  .border(),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          7,
        ),

        borderSide:
            BorderSide(
          color:
              GlassSurface
                  .border(
            focused:
                true,
          ),

          width:
              2,
        ),
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _textField({
    required TextEditingController
        controller,

    String? hint,

    TextInputType? keyboardType,

    int maxLines = 1,

    bool enabled = true,

    ValueChanged<String>?
        onChanged,
  }) {
    return TextField(
      controller:
          controller,

      keyboardType:
          keyboardType,

      maxLines:
          maxLines,

      enabled:
          enabled,

      onChanged:
          onChanged,

      decoration:
          _fieldDecoration(
        hint:
            hint,
      ),
    );
  }

  // ==========================================================
  // DATE FIELD
  // ==========================================================

  Widget _dateField({
    required DateTime? value,

    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap,

      child: Container(
        height:
            50,

        padding:
            const EdgeInsets
                .symmetric(
          horizontal:
              16,
        ),

        decoration:
            BoxDecoration(
          color:
              GlassSurface.fill(),

          borderRadius:
              BorderRadius.circular(
            7,
          ),

          border:
              Border.all(
            color:
                GlassSurface
                    .border(),
          ),
        ),

        child:
            Row(
          children: [
            Expanded(
              child:
                  Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',

                style:
                    TextStyle(
                  color:
                      value == null
                          ? Colors
                              .grey
                          : Colors
                              .black,
                ),
              ),
            ),

            const Icon(
              Icons
                  .calendar_today_outlined,

              size:
                  18,

              color:
                  Color(
                0xFF888888,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SMALL HEADER
// ============================================================

class _SmallHeader
    extends StatelessWidget {
  final String text;

  const _SmallHeader(
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
            FontWeight.bold,

        color:
            Color(
          0xFF5B5B5B,
        ),
      ),
    );
  }
}

// ============================================================
// BILL DRAFT RETURNED TO BillsPage
// ============================================================

class BillModelDraft {
  final String billNumber;

  final String vendorInvoiceNumber;

  final String?
      invoiceAttachmentPath;

  final String vendorId;

  final String vendorName;

  final String?
      purchaseOrderId;

  final String?
      purchaseOrderNumber;

  final DateTime billDate;

  final DateTime? dueDate;

  final List<
          PurchaseOrderItemModel>
      items;

  final double taxAmount;

  BillModelDraft({
    required this.billNumber,

    this.vendorInvoiceNumber = '',

    this.invoiceAttachmentPath,

    required this.vendorId,

    required this.vendorName,

    this.purchaseOrderId,

    this.purchaseOrderNumber,

    required this.billDate,

    this.dueDate,

    required this.items,

    this.taxAmount = 0,
  });
}