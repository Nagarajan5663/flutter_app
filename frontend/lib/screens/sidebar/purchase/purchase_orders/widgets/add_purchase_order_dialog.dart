import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../shared/glass_modal_shell.dart';
import '../../vendors/vendor_model.dart';
import '../../vendors/vendor_repository.dart';
import '../purchase_order_item_model.dart';
import '../purchase_order_model.dart';
import '../purchase_order_repository.dart';

// ============================================================
// CATALOG OPTION
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

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController qtyController = TextEditingController(
    text: '1',
  );

  final TextEditingController rateController = TextEditingController(
    text: '0.00',
  );

  double get amount {
    final double qty = double.tryParse(
          qtyController.text.trim(),
        ) ??
        0;

    final double rate = double.tryParse(
          rateController.text.trim(),
        ) ??
        0;

    return qty * rate;
  }

  void clear() {
    selectedProduct = null;

    descriptionController.clear();

    qtyController.text = '1';

    rateController.text = '0.00';
  }

  void dispose() {
    descriptionController.dispose();

    qtyController.dispose();

    rateController.dispose();
  }
}

// ============================================================
// DIALOG
// ============================================================

class AddPurchaseOrderDialog extends StatefulWidget {
  const AddPurchaseOrderDialog({
    super.key,
    this.initialVendor,
    this.initialOrder,
    this.isDuplicate = false,
    this.initialSalesOrderId,
    this.initialSalesOrderNumber,
    this.initialSalesOrderDate,
    this.initialItems,
  });

  final VendorModel? initialVendor;
  final PurchaseOrderModel? initialOrder;
  final bool isDuplicate;
  final int? initialSalesOrderId;
  final String? initialSalesOrderNumber;
  final DateTime? initialSalesOrderDate;
  final List<Map<String, dynamic>>? initialItems;

  @override
  State<AddPurchaseOrderDialog> createState() => _AddPurchaseOrderDialogState();
}

class _AddPurchaseOrderDialogState extends State<AddPurchaseOrderDialog> {
  static const String _baseUrl = 'http://localhost:3000/api';

  final VendorRepository _vendorRepository = InMemoryVendorRepository();

  final PurchaseOrderRepository _orderRepository =
      InMemoryPurchaseOrderRepository();

  final TextEditingController poNumberController = TextEditingController();

  final TextEditingController referenceNumberController =
      TextEditingController();

  List<VendorModel> _vendors = [];

  List<_CatalogOption> _catalog = [];

  VendorModel? selectedVendor;

  final GlobalKey _dateFieldKey = GlobalKey();
  final GlobalKey _deliveryDateFieldKey = GlobalKey();
  final GlobalKey _dueDateFieldKey = GlobalKey();

  DateTime date = DateTime.now();

  DateTime? deliveryExpectedDate;

  DateTime? dueDate;

  final List<String> paymentTermsOptions = const [
    '100% Advance',
    '50% Advance, 50% on Delivery',
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
  ];

  String paymentTerms = '100% Advance';

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
      final Future<List<VendorModel>> vendorsFuture =
          _vendorRepository.getVendors();

      final Future<List<_CatalogOption>> catalogFuture = _loadCatalog();

      final Future<String>? poNumberFuture =
          widget.initialOrder == null || widget.isDuplicate
              ? _orderRepository.nextPoNumber()
              : null;

      final List<VendorModel> vendors = await vendorsFuture;

      final List<_CatalogOption> catalog = await catalogFuture;

      final String? nextPoNumber = await poNumberFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _vendors = vendors;
        _catalog = catalog;

        final initialOrder = widget.initialOrder;
        final vendorId = initialOrder?.vendorId ?? widget.initialVendor?.id;
        selectedVendor = vendorId == null
            ? null
            : vendors.any((vendor) => vendor.id == vendorId)
                ? vendors.firstWhere((vendor) => vendor.id == vendorId)
                : null;

        if (widget.initialSalesOrderDate != null) {
          date = widget.initialSalesOrderDate!;
        }
        if (widget.initialSalesOrderNumber != null) {
          referenceNumberController.text = widget.initialSalesOrderNumber!;
        }

        poNumberController.text = initialOrder != null && !widget.isDuplicate
            ? initialOrder.poNumber
            : nextPoNumber ?? '';

        if (initialOrder != null) {
          referenceNumberController.text = initialOrder.referenceNumber;
          date = initialOrder.date;
          deliveryExpectedDate = initialOrder.deliveryExpectedDate;
          dueDate = initialOrder.dueDate;
          paymentTerms = initialOrder.paymentTerms;
          for (final row in rows) {
            row.dispose();
          }
          rows.clear();
          for (final item in initialOrder.items) {
            final row = _ItemRow();
            row.selectedProduct = _findCatalogOption(
              item.itemName,
              item.rate,
            );
            row.descriptionController.text = item.description;
            row.qtyController.text = item.qty.toString();
            row.rateController.text = item.rate.toStringAsFixed(2);
            rows.add(row);
          }
        } else if (widget.initialItems != null &&
            widget.initialItems!.isNotEmpty) {
          rows.clear();
          for (final item in widget.initialItems!) {
            final itemName = item['itemName']?.toString() ?? '';
            final sourceType = item['sourceType']?.toString();
            final itemId = item['itemId'] == null
                ? null
                : int.tryParse(item['itemId'].toString());
            final partId = item['partId'] == null
                ? null
                : int.tryParse(item['partId'].toString());
            final row = _ItemRow();
            final match = _matchCatalogOption(
              itemName: itemName,
              sourceType: sourceType,
              itemId: itemId,
              partId: partId,
            );
            if (match != null) {
              row.selectedProduct = match;
              row.descriptionController.text =
                  item['description']?.toString() ?? match.description;
              final parsedQty = double.tryParse(item['qty']?.toString() ?? '');
              row.qtyController.text = (parsedQty ?? 1).toString();
              final parsedRate =
                  double.tryParse(item['rate']?.toString() ?? '');
              final rateValue = parsedRate ?? match.purchasePrice;
              row.rateController.text = rateValue.toStringAsFixed(2);
            }
            rows.add(row);
          }
        }

        if (rows.isEmpty) {
          rows.add(_ItemRow());
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorText = 'Unable to load purchase order data: $error';
      });
    }
  }

  _CatalogOption? _matchCatalogOption({
    required String itemName,
    String? sourceType,
    int? itemId,
    int? partId,
  }) {
    for (final option in _catalog) {
      if (sourceType != null && option.sourceType != sourceType) {
        continue;
      }
      if (itemId != null &&
          option.id == itemId &&
          option.sourceType == 'Item') {
        return option;
      }
      if (partId != null &&
          option.id == partId &&
          option.sourceType == 'Part') {
        return option;
      }
      if (option.name.trim().toLowerCase() == itemName.trim().toLowerCase()) {
        return option;
      }
    }
    return null;
  }

  _CatalogOption? _findCatalogOption(String name, double rate) {
    for (final option in _catalog) {
      if (option.name == name && (option.purchasePrice - rate).abs() < 0.005) {
        return option;
      }
    }
    return null;
  }

  // ==========================================================
  // LOAD ITEMS + PARTS
  // ==========================================================

  Future<List<_CatalogOption>> _loadCatalog() async {
    final Future<http.Response> itemFuture = http.get(
      Uri.parse(
        '$_baseUrl/items',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final Future<http.Response> partFuture = http.get(
      Uri.parse(
        '$_baseUrl/parts',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final http.Response itemResponse = await itemFuture;

    final http.Response partResponse = await partFuture;

    final dynamic itemBody = jsonDecode(
      itemResponse.body,
    );

    final dynamic partBody = jsonDecode(
      partResponse.body,
    );

    if (itemBody is! Map<String, dynamic> ||
        itemResponse.statusCode != 200 ||
        itemBody['success'] != true) {
      throw Exception(
        itemBody is Map
            ? itemBody['message'] ?? 'Failed to load items'
            : 'Failed to load items',
      );
    }

    if (partBody is! Map<String, dynamic> ||
        partResponse.statusCode != 200 ||
        partBody['success'] != true) {
      throw Exception(
        partBody is Map
            ? partBody['message'] ?? 'Failed to load parts'
            : 'Failed to load parts',
      );
    }

    final List<_CatalogOption> result = [];

    // ----------------------------------------------------------
    // ITEMS
    // Purchase Order uses purchase_price.
    // ----------------------------------------------------------

    final List<dynamic> itemData =
        itemBody['data'] is List ? itemBody['data'] : <dynamic>[];

    for (final dynamic raw in itemData) {
      final Map<String, dynamic> item = Map<String, dynamic>.from(
        raw as Map,
      );

      final int id = int.tryParse(
            item['id']?.toString() ?? '',
          ) ??
          0;

      final String name = item['name']?.toString() ?? '';

      if (id <= 0 || name.trim().isEmpty) {
        continue;
      }

      result.add(
        _CatalogOption(
          sourceType: 'Item',
          id: id,
          name: name,
          sku: item['sku']?.toString() ?? '',
          description: item['description']?.toString() ?? '',
          purchasePrice: double.tryParse(
                item['purchase_price']?.toString() ?? '0',
              ) ??
              0,
        ),
      );
    }

    // ----------------------------------------------------------
    // PARTS
    // ----------------------------------------------------------

    final List<dynamic> partData =
        partBody['data'] is List ? partBody['data'] : <dynamic>[];

    for (final dynamic raw in partData) {
      final Map<String, dynamic> part = Map<String, dynamic>.from(
        raw as Map,
      );

      final int id = int.tryParse(
            part['id']?.toString() ?? '',
          ) ??
          0;

      final String name = part['name']?.toString() ?? '';

      if (id <= 0 || name.trim().isEmpty) {
        continue;
      }

      result.add(
        _CatalogOption(
          sourceType: 'Part',
          id: id,
          name: name,
          sku: part['sku']?.toString() ?? '',
          description: part['description']?.toString() ?? '',
          purchasePrice: double.tryParse(
                part['purchase_price']?.toString() ?? '0',
              ) ??
              0,
        ),
      );
    }

    return result;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    poNumberController.dispose();

    referenceNumberController.dispose();

    for (final _ItemRow row in rows) {
      row.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // ROWS
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
    if (rows.length == 1) {
      setState(() {
        rows[0].clear();
      });

      return;
    }

    setState(() {
      rows[index].dispose();

      rows.removeAt(
        index,
      );
    });
  }

  // ==========================================================
  // TOTAL
  // ==========================================================

  double get _subTotal {
    return rows.fold(
      0.0,
      (
        double sum,
        _ItemRow row,
      ) {
        return sum + row.amount;
      },
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime?> onPicked,
    required GlobalKey anchorKey,
    bool allowClear = true,
  }) async {
    final BuildContext? anchorContext = anchorKey.currentContext;
    if (anchorContext == null) {
      final fallback = initial ?? DateTime.now();
      onPicked(fallback);
      return;
    }

    final RenderBox renderBox = anchorContext.findRenderObject() as RenderBox;
    final RenderBox overlayBox = Navigator.of(anchorContext)
        .overlay!
        .context
        .findRenderObject() as RenderBox;
    final rect = Rect.fromPoints(
      renderBox.localToGlobal(Offset.zero, ancestor: overlayBox),
      renderBox.localToGlobal(
        renderBox.size.bottomRight(Offset.zero),
        ancestor: overlayBox,
      ),
    );

    final selected = await showMenu<DateTime?>(
      context: anchorContext,
      position: RelativeRect.fromRect(rect, Offset.zero & overlayBox.size),
      color: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 320),
      items: [
        _DatePickerPopupEntry(
          initialDate: initial ?? DateTime.now(),
          allowClear: allowClear,
          onPicked: onPicked,
        ),
      ],
    );

    if (selected != null) {
      onPicked(selected);
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  void _saveOrder() {
    if (_isSaving) {
      return;
    }

    if (selectedVendor == null) {
      setState(() {
        _errorText = 'Please select a vendor';
      });

      return;
    }

    if (selectedVendor!.id == null || selectedVendor!.id!.trim().isEmpty) {
      setState(() {
        _errorText = 'Selected vendor ID is missing';
      });

      return;
    }

    if (poNumberController.text.trim().isEmpty) {
      setState(() {
        _errorText = 'Please enter a purchase order number';
      });

      return;
    }

    final List<PurchaseOrderItemModel> items = [];

    for (final _ItemRow row in rows) {
      if (row.selectedProduct == null) {
        continue;
      }

      final double qty = double.tryParse(
            row.qtyController.text.trim(),
          ) ??
          0;

      final double rate = double.tryParse(
            row.rateController.text.trim(),
          ) ??
          0;

      if (qty <= 0) {
        setState(() {
          _errorText = 'Quantity must be greater than zero';
        });

        return;
      }

      if (rate < 0) {
        setState(() {
          _errorText = 'Rate cannot be negative';
        });

        return;
      }

      items.add(
        PurchaseOrderItemModel(
          itemName: row.selectedProduct!.name,
          description: row.descriptionController.text.trim(),
          qty: qty,
          rate: rate,
        ),
      );
    }

    if (items.isEmpty) {
      setState(() {
        _errorText = 'Please add at least one Item or Part';
      });

      return;
    }

    if (deliveryExpectedDate != null &&
        deliveryExpectedDate!.isBefore(
          DateTime(
            date.year,
            date.month,
            date.day,
          ),
        )) {
      setState(() {
        _errorText = 'Delivery expected date cannot be before PO date';
      });

      return;
    }

    setState(() {
      _isSaving = true;

      _errorText = null;
    });

    final PurchaseOrderModel order = PurchaseOrderModel(
      id: widget.isDuplicate ? null : widget.initialOrder?.id,
      poNumber: poNumberController.text.trim(),
      salesOrderId: widget.initialSalesOrderId?.toString(),
      salesOrderNumber: widget.initialSalesOrderNumber,
      vendorId: selectedVendor!.id!,
      vendorName: selectedVendor!.vendorName,
      date: date,
      deliveryExpectedDate: deliveryExpectedDate,
      paymentTerms: paymentTerms,
      dueDate: dueDate,
      referenceNumber: referenceNumberController.text.trim(),
      items: items,
      status:
          widget.isDuplicate ? 'Draft' : widget.initialOrder?.status ?? 'Draft',
    );

    Navigator.pop(
      context,
      order,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassModalShell(
      maxWidth: 900,
      maxHeight: 850,
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(
                60,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                34,
                30,
                34,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // HEADER
                  // ============================================

                  GlassDialogHeader(
                    title: widget.initialOrder == null || widget.isDuplicate
                        ? 'New Purchase Order'
                        : 'Edit Purchase Order',
                    icon: Icons.shopping_cart_outlined,
                    onClose: () {
                      Navigator.pop(
                        context,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ============================================
                  // ERROR
                  // ============================================

                  if (_errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF4E3E3,
                        ),
                        borderRadius: BorderRadius.circular(
                          7,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Color(
                                  0xFFAB2A2A,
                                ),
                              ),
                            ),
                          ),
                          if (_catalog.isEmpty || _vendors.isEmpty)
                            TextButton(
                              onPressed: _init,
                              child: const Text(
                                'Retry',
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],

                  // ============================================
                  // VENDOR + PO NUMBER
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          label: 'Vendor Name *',
                          child: DropdownSearch<VendorModel>(
                            items: (
                              filter,
                              infiniteScrollProps,
                            ) {
                              final String query = filter.trim().toLowerCase();

                              if (query.isEmpty) {
                                return _vendors;
                              }

                              return _vendors.where(
                                (
                                  VendorModel vendor,
                                ) {
                                  return vendor.vendorName
                                          .toLowerCase()
                                          .contains(
                                            query,
                                          ) ||
                                      vendor.companyName.toLowerCase().contains(
                                            query,
                                          ) ||
                                      vendor.email.toLowerCase().contains(
                                            query,
                                          );
                                },
                              ).toList();
                            },
                            itemAsString: (
                              VendorModel vendor,
                            ) {
                              if (vendor.companyName.trim().isEmpty) {
                                return vendor.vendorName;
                              }

                              return '${vendor.vendorName} - ${vendor.companyName}';
                            },
                            compareFn: (
                              VendorModel a,
                              VendorModel b,
                            ) {
                              return a.id == b.id;
                            },
                            selectedItem: selectedVendor,
                            onChanged: (
                              VendorModel? vendor,
                            ) {
                              setState(() {
                                selectedVendor = vendor;
                              });
                            },
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchDelay: Duration.zero,
                              disableFilter: true,
                              constraints: const BoxConstraints(
                                maxHeight: 320,
                              ),
                              menuProps: const MenuProps(
                                backgroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7)),
                                ),
                              ),
                              searchFieldProps: const TextFieldProps(
                                style: TextStyle(
                                  color: Color(0xFF102A43),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search vendors...',
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(7),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFFD9DEE5),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(7),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFFD9DEE5),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(7),
                                    ),
                                    borderSide: BorderSide(
                                      color: Color(0xFF6BAED6),
                                    ),
                                  ),
                                ),
                              ),
                              itemClickProps: const ClickProps(
                                hoverColor: Color(0xFFF1F3F5),
                                focusColor: Color(0xFFF1F3F5),
                                splashColor: Colors.transparent,
                              ),
                              itemBuilder:
                                  (context, vendor, isDisabled, isSelected) =>
                                      SizedBox(
                                height: 40,
                                width: double.infinity,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      vendor.companyName.trim().isEmpty
                                          ? vendor.vendorName
                                          : '${vendor.vendorName} - ${vendor.companyName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF102A43),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              emptyBuilder: (context, searchEntry) =>
                                  const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No vendors found',
                                  style: TextStyle(
                                    color: Color(0xFF102A43),
                                  ),
                                ),
                              ),
                            ),
                            decoratorProps: DropDownDecoratorProps(
                              decoration: _fieldDecoration(
                                hint: 'Select or type to search...',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _labeledField(
                          label: 'Purchase Order # *',
                          child: _textField(
                            controller: poNumberController,
                            readOnly: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ============================================
                  // DATE + DELIVERY
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          label: 'Date *',
                          child: _dateField(
                            key: _dateFieldKey,
                            value: date,
                            onTap: () {
                              _pickDate(
                                initial: date,
                                anchorKey: _dateFieldKey,
                                allowClear: false,
                                onPicked: (DateTime? value) {
                                  setState(() {
                                    date = value ?? DateTime.now();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _labeledField(
                          label: 'Delivery Expected Date',
                          child: _dateField(
                            key: _deliveryDateFieldKey,
                            value: deliveryExpectedDate,
                            onTap: () {
                              _pickDate(
                                initial: deliveryExpectedDate ?? date,
                                anchorKey: _deliveryDateFieldKey,
                                allowClear: true,
                                onPicked: (DateTime? value) {
                                  setState(() {
                                    deliveryExpectedDate = value;
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
                    height: 18,
                  ),

                  // ============================================
                  // PAYMENT + DUE DATE
                  // ============================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          label: 'Payment Terms',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF8F9FA,
                              ),
                              borderRadius: BorderRadius.circular(
                                7,
                              ),
                              border: Border.all(
                                color: const Color(
                                  0xFFD9DEE5,
                                ),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: paymentTerms,
                                isExpanded: true,
                                items: paymentTermsOptions.map(
                                  (
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged: (
                                  String? value,
                                ) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    paymentTerms = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: _labeledField(
                          label: 'Due Date',
                          child: _dateField(
                            key: _dueDateFieldKey,
                            value: dueDate,
                            onTap: () {
                              _pickDate(
                                initial: dueDate ?? date,
                                anchorKey: _dueDateFieldKey,
                                allowClear: true,
                                onPicked: (DateTime? value) {
                                  setState(() {
                                    dueDate = value;
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
                    height: 18,
                  ),

                  // ============================================
                  // REFERENCE
                  // ============================================

                  _labeledField(
                    label: 'Reference # (optional)',
                    child: _textField(
                      controller: referenceNumberController,
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ============================================
                  // ITEMS
                  // ============================================

                  const Text(
                    'Item Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(
                        0xFF3D4147,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: _SmallHeader(
                          'ITEM / DESCRIPTION',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _SmallHeader(
                          'QTY',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _SmallHeader(
                          'RATE',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _SmallHeader(
                          'AMOUNT',
                        ),
                      ),
                      SizedBox(
                        width: 36,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  ...rows.asMap().entries.map(
                    (
                      MapEntry<int, _ItemRow> entry,
                    ) {
                      final int index = entry.key;

                      final _ItemRow row = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  // ============================
                                  // ITEM / PART SEARCH
                                  // ============================

                                  DropdownSearch<_CatalogOption>(
                                    items: (
                                      filter,
                                      infiniteScrollProps,
                                    ) {
                                      final String query =
                                          filter.trim().toLowerCase();

                                      if (query.isEmpty) {
                                        return _catalog;
                                      }

                                      return _catalog.where(
                                        (
                                          _CatalogOption product,
                                        ) {
                                          return product.name
                                                  .toLowerCase()
                                                  .contains(
                                                    query,
                                                  ) ||
                                              product.sku
                                                  .toLowerCase()
                                                  .contains(
                                                    query,
                                                  ) ||
                                              product.sourceType
                                                  .toLowerCase()
                                                  .contains(
                                                    query,
                                                  );
                                        },
                                      ).toList();
                                    },
                                    itemAsString: (
                                      _CatalogOption product,
                                    ) {
                                      final String sku = product.sku.isEmpty
                                          ? ''
                                          : ' • ${product.sku}';

                                      return '${product.name} [${product.sourceType}]$sku';
                                    },
                                    compareFn: (
                                      _CatalogOption a,
                                      _CatalogOption b,
                                    ) {
                                      return a.sourceType == b.sourceType &&
                                          a.id == b.id;
                                    },
                                    selectedItem: row.selectedProduct,
                                    onChanged: (
                                      _CatalogOption? product,
                                    ) {
                                      setState(() {
                                        row.selectedProduct = product;

                                        if (product == null) {
                                          row.descriptionController.clear();

                                          row.rateController.text = '0.00';

                                          return;
                                        }

                                        row.descriptionController.text =
                                            product.description;

                                        row.rateController.text = product
                                            .purchasePrice
                                            .toStringAsFixed(
                                          2,
                                        );
                                      });
                                    },
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      searchDelay: Duration.zero,
                                      disableFilter: true,
                                      constraints: const BoxConstraints(
                                        maxHeight: 320,
                                      ),
                                      menuProps: const MenuProps(
                                        backgroundColor: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(7),
                                          ),
                                        ),
                                      ),
                                      searchFieldProps: const TextFieldProps(
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search items or parts...',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF6B7280),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            size: 20,
                                            color: Color(0xFF6B7280),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(7),
                                            ),
                                            borderSide: BorderSide(
                                              color: Color(0xFFD1D5DB),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(7),
                                            ),
                                            borderSide: BorderSide(
                                              color: Color(0xFFD1D5DB),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(7),
                                            ),
                                            borderSide: BorderSide(
                                              color: Color(0xFF60A5FA),
                                            ),
                                          ),
                                        ),
                                      ),
                                      itemClickProps: const ClickProps(
                                        hoverColor: Color(0xFFE5E7EB),
                                        focusColor: Color(0xFFE5E7EB),
                                        splashColor: Colors.transparent,
                                      ),
                                      itemBuilder: (
                                        context,
                                        product,
                                        isDisabled,
                                        isSelected,
                                      ) =>
                                          Container(
                                        height: 42,
                                        width: double.infinity,
                                        color: isSelected
                                            ? const Color(0xFFEAF3FF)
                                            : Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${product.name} [${product.sourceType}]${product.sku.isEmpty ? '' : ' • ${product.sku}'}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF1F2937)
                                                : const Color(0xFF1F2937),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      emptyBuilder: (context, searchEntry) =>
                                          const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          'No items found',
                                          style: TextStyle(
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ),
                                    ),
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        hintText: 'Select Item or Part...',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF6B7280),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 15,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD1D5DB),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD1D5DB),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF60A5FA),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  _textField(
                                    controller: row.descriptionController,
                                    hint: 'Description',
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.qtyController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: _textField(
                                controller: row.rateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: GlassSurface.fill(
                                    emphasized: true,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    7,
                                  ),
                                ),
                                child: Text(
                                  'INR ${row.amount.toStringAsFixed(2)}',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: IconButton(
                                onPressed: () {
                                  _removeRow(
                                    index,
                                  );
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(
                                    0xFFAB2A2A,
                                  ),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  TextButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                    label: const Text(
                      'Add Row',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(
                        0xFF2E7DD1,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ============================================
                  // TOTAL
                  // ============================================

                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'INR ${_subTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(
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
                    height: 28,
                  ),

                  // ============================================
                  // BUTTONS
                  // ============================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                );
                              },
                        icon: Icons.close,
                        label: 'Cancel',
                        primary: false,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      GlassButton(
                        onPressed: _isSaving ? null : _saveOrder,
                        icon: Icons.save,
                        label:
                            widget.initialOrder != null && !widget.isDuplicate
                                ? 'Update Purchase Order'
                                : 'Save Purchase Order',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // LABEL
  // ==========================================================

  Widget _labeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(
              0xFF3D4147,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        child,
      ],
    );
  }

  // ==========================================================
  // DECORATION
  // ==========================================================

  InputDecoration _fieldDecoration({
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: GlassSurface.fill(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: BorderSide(
          color: GlassSurface.border(),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: BorderSide(
          color: GlassSurface.border(
            focused: true,
          ),
          width: 2,
        ),
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: _fieldDecoration(
        hint: hint,
      ),
    );
  }

  // ==========================================================
  // DATE FIELD
  // ==========================================================

  Widget _dateField({
    Key? key,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: GlassSurface.fill(),
          borderRadius: BorderRadius.circular(
            7,
          ),
          border: Border.all(
            color: GlassSurface.border(),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: TextStyle(
                  color: value == null ? Colors.grey : const Color(0xFF1F2937),
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerPopupEntry extends PopupMenuEntry<DateTime?> {
  final DateTime initialDate;
  final bool allowClear;
  final ValueChanged<DateTime?> onPicked;

  const _DatePickerPopupEntry({
    required this.initialDate,
    required this.allowClear,
    required this.onPicked,
  });

  @override
  State<_DatePickerPopupEntry> createState() => _DatePickerPopupEntryState();

  @override
  double get height => 340;

  @override
  bool represents(DateTime? value) => false;
}

class _DatePickerPopupEntryState extends State<_DatePickerPopupEntry> {
  late DateTime _displayMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayMonth = DateTime(
      _selectedDate?.year ?? DateTime.now().year,
      _selectedDate?.month ?? DateTime.now().month,
      1,
    );
  }

  void _goToMonth(int delta) {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month + delta, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayMonth = DateTime(date.year, date.month, 1);
    });
    widget.onPicked(date);
    Navigator.of(context).pop(date);
  }

  void _selectToday() {
    final today = DateTime.now();
    widget.onPicked(today);
    Navigator.of(context).pop(today);
  }

  void _clearDate() {
    widget.onPicked(null);
    Navigator.of(context).pop(null);
  }

  List<DateTime> _buildMonthGrid() {
    final firstDayOfMonth =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final start = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    return List.generate(42, (index) => start.add(Duration(days: index)));
  }

  String _monthLabel(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildMonthGrid();
    final now = DateTime.now();
    final backgroundColor = Colors.white;
    final borderColor = const Color(0xFFE5E7EB);
    final textColor = const Color(0xFF1F2937);
    final mutedText = const Color(0xFF6B7280);
    final adjacentText = const Color(0xFFB0B7C3);
    final selectedColor = const Color(0xFF2F80ED);

    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _goToMonth(-1),
                icon: const Icon(Icons.chevron_left,
                    color: Color(0xFF1F2937), size: 20),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthLabel(_displayMonth.month)} ${_displayMonth.year}',
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _goToMonth(1),
                icon: const Icon(Icons.chevron_right,
                    color: Color(0xFF1F2937), size: 20),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (weekday) => Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: TextStyle(
                          color: mutedText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _displayMonth.month;
              final isSelected = _selectedDate != null &&
                  day.year == _selectedDate!.year &&
                  day.month == _selectedDate!.month &&
                  day.day == _selectedDate!.day;
              final isToday = now.year == day.year &&
                  now.month == day.month &&
                  now.day == day.day;

              return InkWell(
                onTap: () => _selectDate(day),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: const Color(0xFF93C5FD), width: 1)
                        : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                              ? textColor
                              : adjacentText,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.allowClear)
                TextButton(
                  onPressed: _clearDate,
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                        color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                  ),
                ),
              TextButton(
                onPressed: _selectToday,
                child: const Text(
                  'Today',
                  style: TextStyle(
                      color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL HEADER
// ============================================================

class _SmallHeader extends StatelessWidget {
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
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(
          0xFF5B5B5B,
        ),
      ),
    );
  }
}
