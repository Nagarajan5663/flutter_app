import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/sales_glass_widgets.dart';
import '../workflow_session.dart';
import '../../purchase/purchase_orders/purchase_order_model.dart';
import '../../purchase/purchase_orders/purchase_order_repository.dart';
import '../../purchase/purchase_orders/widgets/add_purchase_order_dialog.dart';
import '../delivery_challans/delivery_challan_repository.dart';

// ============================================================
// API
// ============================================================

class SalesOrdersApi {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<SalesOrderData> approveSalesOrder(int id) async {
    final response = await http
        .post(Uri.parse('$baseUrl/sales-orders/$id/approve'), headers: {
      'Accept': 'application/json',
      ...SalesWorkflowSession.headers,
    });
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body is! Map || body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to approve Sales Order'
          : 'Failed to approve Sales Order');
    }
    return SalesOrderData.fromJson(
        Map<String, dynamic>.from(body['data'] as Map));
  }

  static Future<Map<String, dynamic>> createInvoiceFromSalesOrder(
      int id) async {
    final response = await http
        .post(Uri.parse('$baseUrl/invoices/from-sales-order/$id'), headers: {
      'Accept': 'application/json',
      ...SalesWorkflowSession.headers,
    });
    final body = jsonDecode(response.body);
    if ((response.statusCode != 200 && response.statusCode != 201) ||
        body is! Map ||
        body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to create Invoice'
          : 'Failed to create Invoice');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  static Future<SalesOrderData> getSalesOrder(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/sales-orders/$id'), headers: {
      'Accept': 'application/json',
      ...SalesWorkflowSession.headers,
    });
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body is! Map || body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to load Sales Order'
          : 'Failed to load Sales Order');
    }
    return SalesOrderData.fromJson(
        Map<String, dynamic>.from(body['data'] as Map));
  }

  // ==========================================================
  // GET SALES ORDERS
  // ==========================================================

  static Future<List<SalesOrderData>> getSalesOrders() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/sales-orders',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Invalid server response',
      );
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to fetch sales orders',
      );
    }

    final List<dynamic> data =
        body['data'] is List ? body['data'] : <dynamic>[];

    return data.map(
      (dynamic raw) {
        return SalesOrderData.fromJson(
          Map<String, dynamic>.from(
            raw as Map,
          ),
        );
      },
    ).toList();
  }

  // ==========================================================
  // NEXT NUMBER
  // ==========================================================

  static Future<String> getNextNumber() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/sales-orders/next-number',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to get next sales order number'
            : 'Failed to get next sales order number',
      );
    }

    return body['data']?['orderNumber']?.toString() ?? 'SO-1';
  }

  // ==========================================================
  // CREATE SALES ORDER
  // ==========================================================

  static Future<SalesOrderData> createSalesOrder(
    SalesOrderData order,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/sales-orders',
      ),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(
        order.toCreateJson(),
      ),
    );

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 201 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to save sales order'
            : 'Failed to save sales order',
      );
    }

    return SalesOrderData.fromJson(
      Map<String, dynamic>.from(
        body['data'] as Map,
      ),
    );
  }

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================

  static Future<void> updateStatus(
    int id,
    SalesOrderStatus status,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/sales-orders/$id/status',
      ),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status.label,
      }),
    );

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to update status'
            : 'Failed to update status',
      );
    }
  }

  static Future<void> updateSalesOrder(
    int id,
    SalesOrderData order,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sales-orders/$id'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(order.toCreateJson()),
    );
    final dynamic body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to update sales order'
            : 'Failed to update sales order',
      );
    }
  }

  // ==========================================================
  // DELETE SALES ORDER
  // ==========================================================

  static Future<void> deleteSalesOrder(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/sales-orders/$id',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to delete sales order'
            : 'Failed to delete sales order',
      );
    }
  }

  // ==========================================================
  // GET EXISTING CUSTOMERS
  // ==========================================================

  static Future<List<CustomerOption>> getCustomers() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/customers',
      ),
    );

    final dynamic body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to load customers'
            : 'Failed to load customers',
      );
    }

    final List<dynamic> data = body['data'] ?? [];

    return data
        .map(
          (dynamic raw) {
            final map = Map<String, dynamic>.from(
              raw as Map,
            );

            return CustomerOption(
              id: int.tryParse(
                    map['id'].toString(),
                  ) ??
                  0,
              name: map['vendorName']?.toString() ?? '',
              companyName: map['companyName']?.toString() ?? '',
              email: map['email']?.toString() ?? '',
            );
          },
        )
        .where(
          (customer) => customer.id > 0 && customer.name.isNotEmpty,
        )
        .toList();
  }

  // ==========================================================
  // GET EXISTING ITEMS + PARTS
  // ==========================================================

  static Future<List<CatalogOption>> getCatalog() async {
    final itemFuture = http.get(
      Uri.parse(
        '$baseUrl/items',
      ),
    );

    final partFuture = http.get(
      Uri.parse(
        '$baseUrl/parts',
      ),
    );

    final itemResponse = await itemFuture;

    final partResponse = await partFuture;

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

    final List<CatalogOption> catalog = [];

    final List<dynamic> items = itemBody['data'] ?? [];

    for (final dynamic raw in items) {
      final item = Map<String, dynamic>.from(
        raw as Map,
      );

      catalog.add(
        CatalogOption(
          sourceType: 'Item',

          id: int.tryParse(
                item['id'].toString(),
              ) ??
              0,

          name: item['name']?.toString() ?? '',

          sku: item['sku']?.toString() ?? '',

          description: item['description']?.toString() ?? '',

          // Existing Items use sales price
          rate: double.tryParse(
                item['sales_price'].toString(),
              ) ??
              0,
        ),
      );
    }

    final List<dynamic> parts = partBody['data'] ?? [];

    for (final dynamic raw in parts) {
      final part = Map<String, dynamic>.from(
        raw as Map,
      );

      catalog.add(
        CatalogOption(
          sourceType: 'Part',

          id: int.tryParse(
                part['id'].toString(),
              ) ??
              0,

          name: part['name']?.toString() ?? '',

          sku: part['sku']?.toString() ?? '',

          description: part['description']?.toString() ?? '',

          // Current Parts table only has purchase price
          rate: double.tryParse(
                part['purchase_price'].toString(),
              ) ??
              0,
        ),
      );
    }

    catalog.removeWhere(
      (product) => product.id <= 0 || product.name.isEmpty,
    );

    return catalog;
  }
}

// ============================================================
// CUSTOMER OPTION
// ============================================================

class CustomerOption {
  final int id;
  final String name;
  final String companyName;
  final String email;

  const CustomerOption({
    required this.id,
    required this.name,
    required this.companyName,
    required this.email,
  });
}

// ============================================================
// ITEM/PART OPTION
// ============================================================

class CatalogOption {
  final String sourceType;

  final int id;

  final String name;
  final String sku;

  final String description;

  final double rate;

  const CatalogOption({
    required this.sourceType,
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.rate,
  });
}

// ============================================================
// ENUMS
// ============================================================

enum SalesOrderStatus {
  draft,
  approved,
  sent,
  rejected;

  String get label {
    switch (this) {
      case SalesOrderStatus.draft:
        return 'Draft';

      case SalesOrderStatus.approved:
        return 'Approved';

      case SalesOrderStatus.sent:
        return 'Sent';

      case SalesOrderStatus.rejected:
        return 'Rejected';
    }
  }

  static SalesOrderStatus fromString(
    String value,
  ) {
    switch (value) {
      case 'Approved':
        return SalesOrderStatus.approved;

      case 'Sent':
        return SalesOrderStatus.sent;

      case 'Rejected':
        return SalesOrderStatus.rejected;

      default:
        return SalesOrderStatus.draft;
    }
  }
}

enum PurchaseStatus {
  notStarted,
  partial,
  completed;

  String get label {
    switch (this) {
      case PurchaseStatus.notStarted:
        return 'Not Started';

      case PurchaseStatus.partial:
        return 'Partial';

      case PurchaseStatus.completed:
        return 'Completed';
    }
  }

  static PurchaseStatus fromString(
    String value,
  ) {
    switch (value) {
      case 'Partial':
        return PurchaseStatus.partial;

      case 'Completed':
        return PurchaseStatus.completed;

      default:
        return PurchaseStatus.notStarted;
    }
  }
}

// ============================================================
// SALES ORDER ITEM
// ============================================================

class SalesOrderItem {
  final int? id;

  final String sourceType;

  final int? itemId;
  final int? partId;

  final String itemName;
  final String description;

  final double qty;
  final double rate;

  const SalesOrderItem({
    this.id,
    required this.sourceType,
    this.itemId,
    this.partId,
    required this.itemName,
    required this.description,
    required this.qty,
    required this.rate,
  });

  double get amount => qty * rate;

  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType,
      'itemId': itemId,
      'partId': partId,
      'itemName': itemName,
      'description': description,
      'qty': qty,
      'rate': rate,
      'amount': amount,
    };
  }

  factory SalesOrderItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalesOrderItem(
      id: json['id'] == null
          ? null
          : int.tryParse(
              json['id'].toString(),
            ),
      sourceType: json['sourceType']?.toString() ?? 'Item',
      itemId: json['itemId'] == null
          ? null
          : int.tryParse(
              json['itemId'].toString(),
            ),
      partId: json['partId'] == null
          ? null
          : int.tryParse(
              json['partId'].toString(),
            ),
      itemName: json['itemName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      qty: double.tryParse(
            json['qty']?.toString() ?? '0',
          ) ??
          0,
      rate: double.tryParse(
            json['rate']?.toString() ?? '0',
          ) ??
          0,
    );
  }
}

// ============================================================
// SALES ORDER MODEL
// ============================================================

class SalesOrderData {
  final int? id;

  final DateTime date;

  final String orderNumber;

  final int customerId;

  final String customerName;

  final String customerEmail;

  final String customerPhone;

  final int? estimateId;

  final String estimateNumber;

  final String salesPerson;

  final DateTime? expectedShipmentDate;

  final List<SalesOrderItem> items;

  final double subTotal;

  final double total;

  final String notes;

  final String termsAndConditions;

  SalesOrderStatus status;

  PurchaseStatus purchaseStatus;
  String approvalStatus;
  DateTime? approvedAt;
  int? approvedBy;
  int? invoiceId;
  String? invoiceNumber;

  SalesOrderData({
    this.id,
    required this.date,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    this.customerEmail = '',
    this.customerPhone = '',
    this.estimateId,
    this.estimateNumber = '',
    required this.salesPerson,
    this.expectedShipmentDate,
    required this.items,
    required this.subTotal,
    required this.total,
    this.notes = '',
    this.termsAndConditions = '',
    this.status = SalesOrderStatus.draft,
    this.purchaseStatus = PurchaseStatus.notStarted,
    this.approvalStatus = 'Pending',
    this.approvedAt,
    this.approvedBy,
    this.invoiceId,
    this.invoiceNumber,
  });

  Map<String, dynamic> toCreateJson() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'estimateId': estimateId,
      'estimateNumber': estimateNumber.isEmpty ? null : estimateNumber,
      'salesPerson': salesPerson,
      'date': DateFormat(
        'yyyy-MM-dd',
      ).format(date),
      'expectedShipmentDate': expectedShipmentDate == null
          ? null
          : DateFormat(
              'yyyy-MM-dd',
            ).format(
              expectedShipmentDate!,
            ),
      'items': items
          .map(
            (item) => item.toJson(),
          )
          .toList(),
      'subTotal': subTotal,
      'total': total,
      'notes': notes,
      'termsAndConditions': termsAndConditions,
    };
  }

  factory SalesOrderData.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawItems =
        json['items'] is List ? json['items'] : <dynamic>[];

    return SalesOrderData(
      id: json['id'] == null
          ? null
          : int.tryParse(
              json['id'].toString(),
            ),
      date: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      orderNumber: json['orderNumber']?.toString() ?? '',
      customerId: int.tryParse(
            json['customerId']?.toString() ?? '0',
          ) ??
          0,
      customerName: json['customerName']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      estimateId: json['estimateId'] == null
          ? null
          : int.tryParse(
              json['estimateId'].toString(),
            ),
      estimateNumber: json['estimateNumber']?.toString() ?? '',
      salesPerson: json['salesPerson']?.toString() ?? '',
      expectedShipmentDate: json['expectedShipmentDate'] == null
          ? null
          : DateTime.tryParse(
              json['expectedShipmentDate'].toString(),
            ),
      items: rawItems.map(
        (dynamic raw) {
          return SalesOrderItem.fromJson(
            Map<String, dynamic>.from(
              raw as Map,
            ),
          );
        },
      ).toList(),
      subTotal: double.tryParse(
            json['subTotal']?.toString() ?? '0',
          ) ??
          0,
      total: double.tryParse(
            json['total']?.toString() ?? '0',
          ) ??
          0,
      notes: json['notes']?.toString() ?? '',
      termsAndConditions: json['termsAndConditions']?.toString() ?? '',
      status: SalesOrderStatus.fromString(
        json['status']?.toString() ?? 'Draft',
      ),
      purchaseStatus: PurchaseStatus.fromString(
        json['purchaseStatus']?.toString() ?? 'Not Started',
      ),
      approvalStatus: json['approvalStatus']?.toString() ?? 'Pending',
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.tryParse(json['approvedAt'].toString()),
      approvedBy: json['approvedBy'] == null
          ? null
          : int.tryParse(json['approvedBy'].toString()),
      invoiceId: json['invoiceId'] == null
          ? null
          : int.tryParse(json['invoiceId'].toString()),
      invoiceNumber: json['invoiceNumber']?.toString(),
    );
  }
}

// ============================================================
// SALES ORDERS PAGE
// ============================================================

class SalesOrderPage extends StatefulWidget {
  final VoidCallback? onOpenInvoices;
  final VoidCallback? onOpenPurchaseOrders;
  const SalesOrderPage({
    super.key,
    this.onOpenInvoices,
    this.onOpenPurchaseOrders,
  });

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  final Set<int> _workflowBusyIds = {};
  List<SalesOrderData> _orders = [];

  bool _isLoading = true;

  String? _errorMessage;

  String _statusFilter = 'All';

  final TextEditingController _customerFilterController =
      TextEditingController();

  DateTime? _dateFrom;

  DateTime? _dateTo;

  final List<String> _statusOptions = const [
    'All',
    'Draft',
    'Approved',
    'Sent',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();

    _loadOrders();
  }

  @override
  void dispose() {
    _customerFilterController.dispose();

    super.dispose();
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<SalesOrderData> get _filteredOrders {
    return _orders.where(
      (order) {
        if (_statusFilter != 'All' && order.status.label != _statusFilter) {
          return false;
        }

        final query = _customerFilterController.text.trim().toLowerCase();

        if (query.isNotEmpty &&
            !order.customerName.toLowerCase().contains(query)) {
          return false;
        }

        if (_dateFrom != null &&
            order.date.isBefore(
              DateTime(
                _dateFrom!.year,
                _dateFrom!.month,
                _dateFrom!.day,
              ),
            )) {
          return false;
        }

        if (_dateTo != null) {
          final endDate = DateTime(
            _dateTo!.year,
            _dateTo!.month,
            _dateTo!.day,
            23,
            59,
            59,
          );

          if (order.date.isAfter(
            endDate,
          )) {
            return false;
          }
        }

        return true;
      },
    ).toList();
  }

  // ==========================================================
  // LOAD ORDERS
  // ==========================================================

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await SalesOrdersApi.getSalesOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _errorMessage = error.toString();
      });
    }
  }

  // ==========================================================
  // NEW ORDER
  // ==========================================================

  Future<void> _openNewOrderForm() async {
    try {
      final nextNumber = await SalesOrdersApi.getNextNumber();

      if (!mounted) return;

      await _showOrderForm(nextNumber: nextNumber);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to open sales order: $error',
        isError: true,
      );
    }
  }

  Future<void> _showOrderForm({
    required String nextNumber,
    SalesOrderData? order,
    bool isClone = false,
  }) async {
    final bool? saved = await showDialog<bool>(
      context: context,
      barrierColor: const Color(
        0x9A12202C,
      ),
      barrierDismissible: false,
      builder: (_) {
        return NewSalesOrderDialog(
          nextNumber: nextNumber,
          initialOrder: order,
          isClone: isClone,
        );
      },
    );

    if (saved == true) {
      await _loadOrders();
    }
  }

  Future<void> _cloneOrder(SalesOrderData order) async {
    try {
      final detailedOrder = order.items.isEmpty && order.id != null
          ? await SalesOrdersApi.getSalesOrder(order.id!)
          : order;
      final nextNumber = await SalesOrdersApi.getNextNumber();
      if (!mounted) return;
      await _showOrderForm(
        nextNumber: nextNumber,
        order: detailedOrder,
        isClone: true,
      );
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Unable to clone sales order: $error',
          isError: true,
        );
      }
    }
  }

  Future<void> _editOrder(SalesOrderData order) async {
    try {
      final detailedOrder = order.items.isEmpty && order.id != null
          ? await SalesOrdersApi.getSalesOrder(order.id!)
          : order;
      if (!mounted) return;
      await _showOrderForm(
        nextNumber: detailedOrder.orderNumber,
        order: detailedOrder,
      );
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Unable to edit sales order: $error',
          isError: true,
        );
      }
    }
  }

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================

  Future<void> _updateStatus(
    SalesOrderData order,
    SalesOrderStatus status,
  ) async {
    if (order.id == null) {
      return;
    }

    try {
      if (status == SalesOrderStatus.approved) {
        await SalesOrdersApi.approveSalesOrder(order.id!);
      } else {
        await SalesOrdersApi.updateStatus(order.id!, status);
      }

      await _loadOrders();

      if (!mounted) return;

      _showMessage(
        'Sales order status updated',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Failed to update status: $error',
        isError: true,
      );
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> _deleteOrder(
    SalesOrderData order,
  ) async {
    if (order.id == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Sales Order',
          ),
          content: Text(
            'Delete ${order.orderNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await SalesOrdersApi.deleteSalesOrder(
        order.id!,
      );

      await _loadOrders();

      if (!mounted) return;

      _showMessage(
        'Sales order deleted successfully',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete sales order: $error',
        isError: true,
      );
    }
  }

  Future<void> _showSalesOrderPreview(SalesOrderData order) async {
    try {
      final detailedOrder = order.items.isEmpty && order.id != null
          ? await SalesOrdersApi.getSalesOrder(order.id!)
          : order;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _SalesOrderPreviewDialog(
          order: detailedOrder,
          onConvert: (currentOrder, target) =>
              _convertSalesOrder(currentOrder, target),
        ),
      );
    } catch (error) {
      if (mounted)
        _showMessage(error.toString().replaceFirst('Exception: ', ''),
            isError: true);
    }
  }

  Future<bool> _convertSalesOrder(SalesOrderData order, String target) async {
    if (order.approvalStatus != 'Approved') {
      _showMessage('Sales Order must be approved before conversion.',
          isError: true);
      return false;
    }
    if (order.id == null || !_workflowBusyIds.add(order.id!)) return false;
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() {});
    try {
      if (target == 'Invoice') {
        final invoice =
            await SalesOrdersApi.createInvoiceFromSalesOrder(order.id!);
        await _loadOrders();
        if (!mounted) return true;
        _showMessage('Invoice ${invoice['invoiceNumber'] ?? ''} is ready.');
        widget.onOpenInvoices?.call();
      } else if (target == 'Purchase Order') {
        final createdOrder = await showDialog<PurchaseOrderModel>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AddPurchaseOrderDialog(
            initialSalesOrderId: order.id,
            initialSalesOrderNumber: order.orderNumber,
            initialSalesOrderDate: order.date,
            initialItems: order.items
                .map((item) => {
                      'sourceType': item.sourceType,
                      'itemId': item.itemId,
                      'partId': item.partId,
                      'itemName': item.itemName,
                      'description': item.description,
                      'qty': item.qty,
                      'rate': item.rate,
                    })
                .toList(),
          ),
        );
        if (createdOrder == null || !mounted) return false;
        final purchaseOrder =
            await ApiPurchaseOrderRepository().addPurchaseOrder(createdOrder);
        await _loadOrders();
        if (mounted) {
          messenger?.showSnackBar(
            SnackBar(
                content:
                    Text('Purchase Order ${purchaseOrder.poNumber} is ready.')),
          );
          widget.onOpenPurchaseOrders?.call();
        }
      } else {
        final challan = await InMemoryDeliveryChallanRepository()
            .createFromSalesOrder(order.id.toString());
        await _loadOrders();
        if (mounted)
          _showMessage('Delivery Challan ${challan.challanNumber} is ready.');
      }
      return true;
    } catch (error) {
      if (mounted)
        _showMessage(error.toString().replaceFirst('Exception: ', ''),
            isError: true);
      return false;
    } finally {
      _workflowBusyIds.remove(order.id);
      if (mounted) setState(() {});
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(
                0xFFAB2A2A,
              )
            : const Color(
                0xFF1E7B34,
              ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = 'All';

      _customerFilterController.clear();

      _dateFrom = null;

      _dateTo = null;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final orders = _filteredOrders;

    return SalesGlassPageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sales Orders',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(
                        0xFF17395C,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadOrders,
                  tooltip: 'Refresh Sales Orders',
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(
                      0xFF17395C,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton.icon(
                  onPressed: _openNewOrderForm,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text('New Sales Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF17395C,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 17,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // FILTER BAR

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0x4FFFFFFF,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color: const Color(
                    0xD0FFFFFF,
                  ),
                ),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  SizedBox(
                    width: 150,
                    child: _buildStatusFilter(),
                  ),
                  SizedBox(
                    width: 200,
                    child: _buildCustomerFilter(),
                  ),
                  SizedBox(
                    width: 170,
                    child: _buildFilterDate(
                      label: 'Date From:',
                      value: _dateFrom,
                      onChanged: (value) {
                        setState(() {
                          _dateFrom = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: _buildFilterDate(
                      label: 'Date To:',
                      value: _dateTo,
                      onChanged: (value) {
                        setState(() {
                          _dateTo = value;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF1E78B7,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Filter',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'Clear',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 16,
                ),
                padding: const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFECEC,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(
                        0xFFAB2A2A,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                      ),
                    ),
                    TextButton(
                      onPressed: _loadOrders,
                      child: const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),

            // TABLE

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 350,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0x4FFFFFFF,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color: const Color(
                    0xD0FFFFFF,
                  ),
                ),
              ),
              child: FittedBox(
                alignment: Alignment.topLeft,
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 1330,
                  child: _isLoading
                      ? const SizedBox(
                          height: 350,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : orders.isEmpty
                          ? _buildEmptyTable()
                          : _buildOrderTable(
                              orders,
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        DropdownButtonFormField<String>(
          initialValue: _statusFilter,
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: _inputDecoration(),
          items: _statusOptions.map(
            (status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            },
          ).toList(),
          onChanged: (value) {
            setState(() {
              _statusFilter = value ?? 'All';
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomerFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Name:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        TextField(
          controller: _customerFilterController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: _inputDecoration().copyWith(
            hintText: 'Customer name...',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDate({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              onChanged(picked);
            }
          },
          child: InputDecorator(
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? 'dd-mm-yyyy'
                        : DateFormat(
                            'dd-MM-yyyy',
                          ).format(
                            value,
                          ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TABLE
  // ==========================================================

  Widget _buildEmptyTable() {
    return Column(
      children: [
        _buildTableHeader(),
        const Divider(
          height: 1,
        ),
        const SizedBox(
          height: 60,
        ),
        const Icon(
          Icons.shopping_cart_outlined,
          size: 55,
          color: Color(
            0xFFB0B8C2,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        const Text(
          'No sales orders found. Click "+ New Sales Order" to add one!',
          style: TextStyle(
            color: Color(
              0xFF777777,
            ),
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 60,
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: _HeaderText(
              'DATE',
            ),
          ),
          SizedBox(
            width: 110,
            child: _HeaderText(
              'SO #',
            ),
          ),
          SizedBox(
            width: 120,
            child: _HeaderText(
              'ESTIMATE #',
            ),
          ),
          SizedBox(
            width: 210,
            child: _HeaderText(
              'CUSTOMER NAME',
            ),
          ),
          SizedBox(
            width: 160,
            child: _HeaderText(
              'SALES PERSON',
            ),
          ),
          SizedBox(
            width: 130,
            child: _HeaderText(
              'STATUS',
            ),
          ),
          SizedBox(
            width: 150,
            child: _HeaderText(
              'PURCHASE STATUS',
            ),
          ),
          SizedBox(
            width: 150,
            child: _HeaderText(
              'AMOUNT',
            ),
          ),
          SizedBox(
            width: 140,
            child: _HeaderText(
              'ACTIONS',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTable(
    List<SalesOrderData> orders,
  ) {
    return Column(
      children: [
        _buildTableHeader(),
        const Divider(
          height: 1,
        ),
        ...orders.map(
          (order) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          DateFormat(
                            'dd-MM-yyyy',
                          ).format(
                            order.date,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          order.orderNumber,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          order.estimateNumber.isEmpty
                              ? '-'
                              : order.estimateNumber,
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        child: Text(
                          order.customerName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: Text(
                          order.salesPerson.isEmpty ? '-' : order.salesPerson,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: _StatusBadge(
                          status: order.status,
                          onChanged: (status) {
                            if (status != null && status != order.status) {
                              _updateStatus(order, status);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: _PurchaseStatusBadge(
                          status: order.purchaseStatus,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          'INR ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(
                              0xFF17395C,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Preview Sales Order',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 18,
                                color: Color(0xFF777777),
                              ),
                              onPressed: _workflowBusyIds.contains(order.id)
                                  ? null
                                  : () => _showSalesOrderPreview(order),
                            ),
                            IconButton(
                              tooltip: 'Edit Sales Order',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF777777),
                              ),
                              onPressed: _workflowBusyIds.contains(order.id)
                                  ? null
                                  : () => _editOrder(order),
                            ),
                            IconButton(
                              tooltip: 'Clone Sales Order',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(
                                Icons.content_copy_outlined,
                                size: 18,
                                color: Color(0xFF777777),
                              ),
                              onPressed: _workflowBusyIds.contains(order.id)
                                  ? null
                                  : () => _cloneOrder(order),
                            ),
                            IconButton(
                              tooltip: 'Delete Sales Order',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFF777777),
                              ),
                              onPressed: _workflowBusyIds.contains(order.id)
                                  ? null
                                  : () => _deleteOrder(order),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(
        0x7AFFFFFF,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          7,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFF1E78B7,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NEW SALES ORDER DIALOG
// ============================================================

class _SalesOrderPreviewDialog extends StatefulWidget {
  const _SalesOrderPreviewDialog(
      {required this.order, required this.onConvert});

  final SalesOrderData order;
  final Future<bool> Function(SalesOrderData order, String target) onConvert;

  @override
  State<_SalesOrderPreviewDialog> createState() =>
      _SalesOrderPreviewDialogState();
}

class _SalesOrderPreviewDialogState extends State<_SalesOrderPreviewDialog> {
  late SalesOrderData _order = widget.order;
  bool _busy = false;
  final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: 'INR', decimalDigits: 2);

  Future<void> _convert(String target) async {
    if (_order.approvalStatus != 'Approved') {
      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Conversion unavailable'),
                content: const Text(
                    'Sales Order must be approved before conversion.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              ));
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    final converted = await widget.onConvert(_order, target);
    if (!mounted) return;
    if (converted) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
    }
  }

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
              pw.Text('SALES ORDER',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('Sales Order: ${_order.orderNumber}'),
              pw.Text('Customer: ${_order.customerName}'),
              pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(_order.date)}'),
              pw.Text(
                  'Document Status: ${_order.status.label}  •  Approval: ${_order.approvalStatus}'),
              pw.SizedBox(height: 18),
              pw.Table(border: pw.TableBorder.all(), children: [
                pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.blueGrey100),
                    children: [
                      for (final title in [
                        'Item',
                        'Description',
                        'Qty',
                        'Rate',
                        'Amount'
                      ])
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(title,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold))),
                    ]),
                for (final item in _order.items)
                  pw.TableRow(
                      children: [
                    item.itemName,
                    item.description,
                    item.qty.toStringAsFixed(2),
                    item.rate.toStringAsFixed(2),
                    item.amount.toStringAsFixed(2)
                  ]
                          .map((value) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(value)))
                          .toList()),
              ]),
              pw.SizedBox(height: 18),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      'Total: INR ${_order.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold))),
            ]));
    try {
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: '${_order.orderNumber}.pdf');
    } catch (error) {
      if (mounted) _showMessage('Unable to create PDF: $error');
    }
  }

  String _salesOrderShareMessage() {
    final money = NumberFormat.currency(
        locale: 'en_IN', symbol: 'INR ', decimalDigits: 2);
    final buffer = StringBuffer()
      ..writeln('SALES ORDER')
      ..writeln('Sales Order: ${_order.orderNumber}')
      ..writeln('Customer: ${_order.customerName}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(_order.date)}');

    if (_order.estimateNumber.isNotEmpty) {
      buffer.writeln('Estimate: ${_order.estimateNumber}');
    }
    if (_order.salesPerson.isNotEmpty) {
      buffer.writeln('Sales Person: ${_order.salesPerson}');
    }
    if (_order.expectedShipmentDate != null) {
      buffer.writeln(
        'Expected Shipment: ${DateFormat('dd MMM yyyy').format(_order.expectedShipmentDate!)}',
      );
    }
    buffer
      ..writeln('Status: ${_order.status.label}')
      ..writeln('Approval: ${_order.approvalStatus}')
      ..writeln()
      ..writeln('ITEMS');

    for (var index = 0; index < _order.items.length; index++) {
      final item = _order.items[index];
      buffer
        ..writeln('${index + 1}. ${item.itemName}')
        ..writeln(
            '   Description: ${item.description.isEmpty ? '-' : item.description}')
        ..writeln('   Quantity: ${item.qty.toStringAsFixed(2)}')
        ..writeln('   Rate: ${money.format(item.rate)}')
        ..writeln('   Amount: ${money.format(item.amount)}');
    }

    buffer
      ..writeln()
      ..writeln('Subtotal: ${money.format(_order.subTotal)}')
      ..writeln('Total: ${money.format(_order.total)}');
    if (_order.notes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Notes: ${_order.notes}');
    }
    if (_order.termsAndConditions.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Terms and Conditions: ${_order.termsAndConditions}');
    }
    return buffer.toString().trimRight();
  }

  Future<void> _sendEmail() async {
    if (_order.customerEmail.trim().isEmpty) {
      _showMessage('This customer does not have an email address.');
      return;
    }
    final uri = Uri(
        scheme: 'mailto',
        path: _order.customerEmail.trim(),
        queryParameters: {
          'subject': 'Sales Order ${_order.orderNumber}',
          'body': _salesOrderShareMessage(),
        });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Email app could not be opened.');
    }
  }

  Future<void> _sendWhatsApp() async {
    final phone = _order.customerPhone.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      _showMessage('This customer does not have a phone number.');
      return;
    }
    final message = _salesOrderShareMessage();
    final encoded = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/$phone?text=$encoded');
    final alternateUrl =
        Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encoded');

    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(alternateUrl,
          mode: LaunchMode.externalApplication)) {
        _showMessage('WhatsApp could not be opened.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * .9).clamp(0.0, 900.0).toDouble();
    final height = (size.height - 32).clamp(260.0, 760.0).toDouble();
    final actions = Row(mainAxisSize: MainAxisSize.min, children: [
      OutlinedButton.icon(
          onPressed: _busy ? null : _downloadPdf,
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Download PDF'),
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFE3E3E3),
              side: BorderSide.none)),
      const SizedBox(width: 8),
      PopupMenuButton<String>(
          enabled: !_busy,
          tooltip: 'Send document',
          onSelected: (value) async {
            if (value == 'email') {
              await _sendEmail();
            } else if (value == 'whatsapp') {
              await _sendWhatsApp();
            }
          },
          itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'email',
                    child: Row(
                      children: [
                        Icon(Icons.mail_outline, size: 18),
                        SizedBox(width: 8),
                        Text('Mail'),
                      ],
                    )),
                PopupMenuItem(
                    value: 'whatsapp',
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18),
                        SizedBox(width: 8),
                        Text('WhatsApp'),
                      ],
                    )),
              ],
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                  color: const Color(0xFFE3E3E3),
                  borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.send_outlined, size: 18, color: Colors.black),
                SizedBox(width: 6),
                Text('Send', style: TextStyle(color: Colors.black)),
              ]))),
      const SizedBox(width: 8),
      if (_order.approvalStatus == 'Approved')
        PopupMenuButton<String>(
            enabled: !_busy,
            onSelected: _convert,
            itemBuilder: (_) => const [
                  PopupMenuItem(value: 'Invoice', child: Text('Invoice')),
                  PopupMenuItem(
                      value: 'Purchase Order', child: Text('Purchase Order')),
                  PopupMenuItem(
                      value: 'Delivery Challan',
                      child: Text('Delivery Challan')),
                ],
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                    color: const Color(0xFF3498DB),
                    borderRadius: BorderRadius.circular(6)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Convert As',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.black, size: 20)
                ]))),
      const SizedBox(width: 8),
      OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
              disabledForegroundColor: Colors.black,
              backgroundColor: const Color(0xFF899597),
              side: BorderSide.none),
          child: const Text('Void')),
      IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black)),
    ]);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
          width: width,
          height: height,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 10, 18),
                child: LayoutBuilder(builder: (context, constraints) {
                  final customer = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_order.customerName,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        const SizedBox(height: 4),
                        Text(
                            '${_order.orderNumber} | ${DateFormat('M/d/yyyy').format(_order.date)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black)),
                      ]);
                  if (constraints.maxWidth < 760)
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customer,
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal, child: actions)
                        ]);
                  if (constraints.maxWidth < 930)
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customer,
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerRight,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: actions))
                        ]);
                  return Row(children: [Expanded(child: customer), actions]);
                })),
            const Divider(height: 1),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final rows = Column(children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            color: const Color(0xFFF5F6F7),
                            child: const Row(children: [
                              Expanded(
                                  flex: 3,
                                  child: Text('Item & Description',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                              Expanded(
                                  flex: 1,
                                  child: Text('Qty',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Rate',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Amount',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                            ])),
                        Expanded(
                            child: ListView(
                                children: _order.items
                                    .map((item) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Color(0xFFE0E0E0))),
                                        ),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(item.itemName,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        if (item.description
                                                            .isNotEmpty)
                                                          Text(item.description)
                                                      ])),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                      item.qty
                                                          .toStringAsFixed(2),
                                                      textAlign:
                                                          TextAlign.right)),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                      _currency
                                                          .format(item.rate),
                                                      textAlign:
                                                          TextAlign.right)),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                      _currency
                                                          .format(item.amount),
                                                      textAlign:
                                                          TextAlign.right)),
                                            ])))
                                    .toList())),
                      ]);
                      final summary = Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Summary',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Sub Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(_currency.format(_order.subTotal))
                                    ]),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      Text(_currency.format(_order.total),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700))
                                    ]),
                              ]));
                      if (constraints.maxWidth < 700)
                        return Column(children: [
                          Expanded(child: rows),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight * .35,
                            ),
                            child: SingleChildScrollView(child: summary),
                          )
                        ]);
                      return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 65, child: rows),
                            const VerticalDivider(
                                width: 1, color: Color(0xFFE0E0E0)),
                            Expanded(
                                flex: 35,
                                child: SingleChildScrollView(child: summary))
                          ]);
                    }))),
          ])),
    );
  }
}

class NewSalesOrderDialog extends StatefulWidget {
  final String nextNumber;
  final int? initialCustomerId;
  final String? initialCustomerName;
  final SalesOrderData? initialOrder;
  final bool isClone;

  const NewSalesOrderDialog({
    super.key,
    required this.nextNumber,
    this.initialCustomerId,
    this.initialCustomerName,
    this.initialOrder,
    this.isClone = false,
  });

  @override
  State<NewSalesOrderDialog> createState() => _NewSalesOrderDialogState();
}

class _NewSalesOrderDialogState extends State<NewSalesOrderDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController orderNumberController =
      TextEditingController(
    text: widget.initialOrder != null && !widget.isClone
        ? widget.initialOrder!.orderNumber
        : widget.nextNumber,
  );

  final TextEditingController customerController = TextEditingController();

  final FocusNode customerFocusNode = FocusNode();

  final TextEditingController salesPersonController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  final TextEditingController termsController = TextEditingController();

  CustomerOption? _selectedCustomer;

  List<CustomerOption> _customers = [];

  List<CatalogOption> _catalog = [];

  final List<_ItemRow> _itemRows = [
    _ItemRow(),
  ];

  DateTime selectedDate = DateTime.now();

  DateTime? expectedShipmentDate;

  bool _isLoadingData = true;

  bool _isSaving = false;

  String? _loadingError;

  @override
  void initState() {
    super.initState();

    _loadReferenceData();
  }

  @override
  void dispose() {
    orderNumberController.dispose();

    customerController.dispose();

    customerFocusNode.dispose();

    salesPersonController.dispose();

    notesController.dispose();

    termsController.dispose();

    for (final row in _itemRows) {
      row.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // LOAD CUSTOMER + ITEM/PART DATA
  // ==========================================================

  Future<void> _loadReferenceData() async {
    setState(() {
      _isLoadingData = true;

      _loadingError = null;
    });

    try {
      final customerFuture = SalesOrdersApi.getCustomers();

      final catalogFuture = SalesOrdersApi.getCatalog();

      final customers = await customerFuture;

      final catalog = await catalogFuture;

      if (!mounted) return;

      setState(() {
        _customers = customers;

        _catalog = catalog;

        final order = widget.initialOrder;
        final matchingCustomers = customers
            .where((customer) =>
                customer.id == (order?.customerId ?? widget.initialCustomerId))
            .toList();
        _selectedCustomer =
            matchingCustomers.isEmpty ? null : matchingCustomers.first;
        customerController.text = _selectedCustomer?.name ??
            order?.customerName ??
            widget.initialCustomerName ??
            '';
        if (order != null) {
          salesPersonController.text = order.salesPerson;
          notesController.text = order.notes;
          termsController.text = order.termsAndConditions;
          selectedDate = order.date;
          expectedShipmentDate = order.expectedShipmentDate;
          for (final row in _itemRows) {
            row.dispose();
          }
          _itemRows
            ..clear()
            ..addAll(order.items.map((item) {
              final row = _ItemRow()..initialItem = item;
              final matchingProducts = _catalog.where((product) =>
                  product.sourceType == item.sourceType &&
                  product.id ==
                      (item.sourceType == 'Item' ? item.itemId : item.partId));
              row.selectedProduct =
                  matchingProducts.isEmpty ? null : matchingProducts.first;
              row.itemController.text = item.itemName;
              row.descriptionController.text = item.description;
              row.qtyController.text = item.qty.toString();
              row.rateController.text = item.rate.toStringAsFixed(2);
              return row;
            }));
          if (_itemRows.isEmpty) {
            _itemRows.add(_ItemRow());
          }
        }

        _isLoadingData = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingData = false;

        _loadingError = error.toString();
      });
    }
  }

  // ==========================================================
  // TOTALS
  // ==========================================================

  double get subTotal {
    double sum = 0;

    for (final row in _itemRows) {
      sum += row.amount;
    }

    return sum;
  }

  double get total => subTotal;

  // ==========================================================
  // ROWS
  // ==========================================================

  void _addRow() {
    setState(() {
      _itemRows.add(
        _ItemRow(),
      );
    });
  }

  void _removeRow(
    _ItemRow row,
  ) {
    if (_itemRows.length == 1) {
      setState(() {
        row.clear();
      });

      return;
    }

    setState(() {
      _itemRows.remove(
        row,
      );

      row.dispose();
    });
  }

  // ==========================================================
  // DATES
  // ==========================================================

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectShipmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expectedShipmentDate ?? selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expectedShipmentDate = picked;
      });
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _saveOrder() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      _showMessage(
        'Please select a customer from the saved customer list.',
      );

      return;
    }

    final List<SalesOrderItem> items = [];

    for (final row in _itemRows) {
      if (row.itemController.text.trim().isEmpty) {
        continue;
      }

      if (row.selectedProduct == null &&
          (row.initialItem == null ||
              row.itemController.text.trim() != row.initialItem!.itemName)) {
        _showMessage(
          'Please select an Item or Part from the saved list.',
        );

        return;
      }

      final qty = double.tryParse(
            row.qtyController.text.trim(),
          ) ??
          0;

      final rate = double.tryParse(
            row.rateController.text.trim(),
          ) ??
          0;

      if (qty <= 0) {
        _showMessage(
          'Quantity must be greater than zero.',
        );

        return;
      }

      if (rate < 0) {
        _showMessage(
          'Rate cannot be negative.',
        );

        return;
      }

      final product = row.selectedProduct;
      final existingItem = row.initialItem;

      items.add(
        SalesOrderItem(
          sourceType: product?.sourceType ?? existingItem!.sourceType,
          itemId: product?.sourceType == 'Item'
              ? product!.id
              : product == null
                  ? existingItem!.itemId
                  : null,
          partId: product?.sourceType == 'Part'
              ? product!.id
              : product == null
                  ? existingItem!.partId
                  : null,
          itemName: product?.name ?? row.itemController.text.trim(),
          description: row.descriptionController.text.trim(),
          qty: qty,
          rate: rate,
        ),
      );
    }

    if (items.isEmpty) {
      _showMessage(
        'Please add at least one item.',
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final order = SalesOrderData(
        id: widget.isClone ? null : widget.initialOrder?.id,
        date: selectedDate,
        orderNumber: orderNumberController.text.trim(),
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        estimateId: widget.isClone ? null : widget.initialOrder?.estimateId,
        estimateNumber:
            widget.isClone ? '' : widget.initialOrder?.estimateNumber ?? '',
        salesPerson: salesPersonController.text.trim(),
        expectedShipmentDate: expectedShipmentDate,
        items: items,
        subTotal: subTotal,
        total: total,
        notes: notesController.text.trim(),
        termsAndConditions: termsController.text.trim(),
      );

      if (widget.initialOrder != null && !widget.isClone) {
        await SalesOrdersApi.updateSalesOrder(
          widget.initialOrder!.id!,
          order,
        );
      } else {
        await SalesOrdersApi.createSalesOrder(order);
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Failed to save sales order: $error',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(
          0xFFAB2A2A,
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
    return SalesGlassDialog(
      insetPadding: const EdgeInsets.all(
        12,
      ),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1180,
          maxHeight: 790,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(
              0xFFE6EAED,
            ),
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
          child: Column(
            children: [
              // HEADER

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  16,
                  12,
                  16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initialOrder == null
                            ? 'New Sales Order'
                            : widget.isClone
                                ? 'Clone Sales Order'
                                : 'Edit Sales Order',
                        style: TextStyle(
                          color: Color(
                            0xFF17395C,
                          ),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                              );
                            },
                      icon: const Icon(
                        Icons.close,
                        color: Color(
                          0xFF777777,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
              ),

              if (_isLoadingData) const LinearProgressIndicator(),

              if (_loadingError != null)
                Padding(
                  padding: const EdgeInsets.all(
                    12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _loadingError!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadReferenceData,
                        child: const Text(
                          'Retry',
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCustomerSearch(),
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: _buildTextField(
                                label: 'Sales Order # *',
                                controller: orderNumberController,
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: _buildTextField(
                                label: 'Sales Person Name',
                                controller: salesPersonController,
                              ),
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: _buildDateField(
                                label: 'Date *',
                                value: selectedDate,
                                onTap: _selectDate,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        SizedBox(
                          width: 330,
                          child: _buildOptionalDateField(
                            label: 'Expected Shipment Date',
                            value: expectedShipmentDate,
                            onTap: _selectShipmentDate,
                          ),
                        ),

                        const SizedBox(
                          height: 26,
                        ),

                        // ITEMS TABLE

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(
                                0xFFFFFFFF,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(
                                    0xFFF7F8FA,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        'Item Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        'Qty',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 140,
                                      child: Text(
                                        'Rate',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 55,
                                    ),
                                  ],
                                ),
                              ),
                              ..._itemRows.map(
                                (row) {
                                  return _buildItemRow(
                                    row,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        ElevatedButton.icon(
                          onPressed: _isLoadingData ? null : _addRow,
                          icon: const Icon(
                            Icons.add,
                          ),
                          label: const Text(
                            'Add Row',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF1E78B7,
                            ),
                            foregroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 390,
                            child: Column(
                              children: [
                                _buildTotalRow(
                                  'Sub Total',
                                  subTotal,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                _buildTotalRow(
                                  'Total',
                                  total,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: _inputDecoration(),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        TextFormField(
                          controller: termsController,
                          maxLines: 3,
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // FOOTER

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                color: const Color(
                  0xFFF8F8FA,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF747B82,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    ElevatedButton(
                      onPressed:
                          _isSaving || _isLoadingData ? null : _saveOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1E78B7,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.initialOrder != null && !widget.isClone
                                  ? 'Update Sales Order'
                                  : 'Save Sales Order',
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

  // ==========================================================
  // CUSTOMER SEARCH
  // ==========================================================

  Widget _buildCustomerSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Name *',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        RawAutocomplete<CustomerOption>(
          textEditingController: customerController,
          focusNode: customerFocusNode,
          displayStringForOption: (customer) => customer.name,
          optionsBuilder: (textValue) {
            final query = textValue.text.trim().toLowerCase();

            if (query.isEmpty) {
              return _customers.take(8);
            }

            return _customers
                .where(
                  (customer) =>
                      customer.name.toLowerCase().contains(
                            query,
                          ) ||
                      customer.companyName.toLowerCase().contains(
                            query,
                          ) ||
                      customer.email.toLowerCase().contains(
                            query,
                          ),
                )
                .take(8);
          },
          onSelected: (customer) {
            setState(() {
              _selectedCustomer = customer;

              customerController.text = customer.name;
            });
          },
          fieldViewBuilder: (
            context,
            controller,
            focusNode,
            onSubmitted,
          ) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: _inputDecoration().copyWith(
                hintText: 'Select or type to search...',
              ),
              onChanged: (value) {
                if (_selectedCustomer != null &&
                    value.trim() != _selectedCustomer!.name) {
                  setState(() {
                    _selectedCustomer = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }

                return null;
              },
            );
          },
          optionsViewBuilder: (
            context,
            onSelected,
            options,
          ) {
            final list = options.toList();

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 10,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 340,
                    maxHeight: 260,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (_, index) {
                      final customer = list[index];

                      return ListTile(
                        title: Text(
                          customer.name,
                        ),
                        subtitle: customer.companyName.isEmpty
                            ? null
                            : Text(
                                customer.companyName,
                              ),
                        onTap: () {
                          onSelected(
                            customer,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // ITEM ROW
  // ==========================================================

  Widget _buildItemRow(
    _ItemRow row,
  ) {
    return Padding(
      padding: const EdgeInsets.all(
        14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              children: [
                RawAutocomplete<CatalogOption>(
                  textEditingController: row.itemController,
                  focusNode: row.focusNode,
                  displayStringForOption: (product) => product.name,
                  optionsBuilder: (textValue) {
                    final query = textValue.text.trim().toLowerCase();

                    if (query.isEmpty) {
                      return _catalog.take(10);
                    }

                    return _catalog
                        .where(
                          (product) =>
                              product.name.toLowerCase().contains(
                                    query,
                                  ) ||
                              product.sku.toLowerCase().contains(
                                    query,
                                  ) ||
                              product.sourceType.toLowerCase().contains(
                                    query,
                                  ),
                        )
                        .take(10);
                  },
                  onSelected: (product) {
                    setState(() {
                      row.selectedProduct = product;

                      row.itemController.text = product.name;

                      row.descriptionController.text = product.description;

                      row.rateController.text = product.rate.toStringAsFixed(
                        2,
                      );
                    });
                  },
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onSubmitted,
                  ) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: _cellDecoration().copyWith(
                        hintText: 'Select or type to search...',
                      ),
                      onChanged: (value) {
                        if (row.selectedProduct != null &&
                            value.trim() != row.selectedProduct!.name) {
                          setState(() {
                            row.selectedProduct = null;
                          });
                        }
                      },
                    );
                  },
                  optionsViewBuilder: (
                    context,
                    onSelected,
                    options,
                  ) {
                    final list = options.toList();

                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 10,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 460,
                            maxHeight: 280,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (_, index) {
                              final product = list[index];

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.sourceType == 'Item'
                                        ? const Color(
                                            0xFFE3F2FD,
                                          )
                                        : const Color(
                                            0xFFFFF3E0,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  child: Text(
                                    product.sourceType,
                                    style: const TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                ),
                                subtitle: Text(
                                  product.sku.isEmpty
                                      ? 'INR ${product.rate.toStringAsFixed(2)}'
                                      : '${product.sku} • INR ${product.rate.toStringAsFixed(2)}',
                                ),
                                onTap: () {
                                  onSelected(
                                    product,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: row.descriptionController,
                  minLines: 1,
                  maxLines: 2,
                  decoration: _cellDecoration().copyWith(
                    hintText: 'Description',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: row.qtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              decoration: _cellDecoration(),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 140,
            child: TextFormField(
              controller: row.rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              decoration: _cellDecoration(),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          SizedBox(
            width: 150,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF5F6F7,
                ),
                borderRadius: BorderRadius.circular(
                  8,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFD7DCE2,
                  ),
                ),
              ),
              child: Text(
                'INR ${row.amount.toStringAsFixed(2)}',
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: IconButton(
              onPressed: () {
                _removeRow(
                  row,
                );
              },
              icon: const Icon(
                Icons.close,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: _inputDecoration(),
          validator: label.contains('*')
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }

                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat(
                      'dd-MM-yyyy',
                    ).format(
                      value,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? 'dd-mm-yyyy'
                        : DateFormat(
                            'dd-MM-yyyy',
                          ).format(
                            value,
                          ),
                    style: TextStyle(
                      color: value == null
                          ? const Color(
                              0xFF9AA3AD,
                            )
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    String label,
    double value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 20 : 17,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          'INR ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 22 : 17,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: const Color(
              0xFF17395C,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(
        0xFFF8FAFB,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          9,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          9,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          9,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFF1E78B7,
          ),
        ),
      ),
    );
  }

  InputDecoration _cellDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(
        0xFFF8FAFB,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
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
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ITEM ROW STATE
// ============================================================

class _ItemRow {
  CatalogOption? selectedProduct;
  SalesOrderItem? initialItem;

  final TextEditingController itemController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController qtyController = TextEditingController(
    text: '1',
  );

  final TextEditingController rateController = TextEditingController(
    text: '0.00',
  );

  double get amount {
    final qty = double.tryParse(
          qtyController.text.trim(),
        ) ??
        0;

    final rate = double.tryParse(
          rateController.text.trim(),
        ) ??
        0;

    return qty * rate;
  }

  void clear() {
    selectedProduct = null;
    initialItem = null;

    itemController.clear();

    descriptionController.clear();

    qtyController.text = '1';

    rateController.text = '0.00';
  }

  void dispose() {
    itemController.dispose();

    focusNode.dispose();

    descriptionController.dispose();

    qtyController.dispose();

    rateController.dispose();
  }
}

// ============================================================
// TABLE HEADER
// ============================================================

class _HeaderText extends StatelessWidget {
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
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(
          0xFF555555,
        ),
      ),
    );
  }
}

// ============================================================
// ORDER STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final SalesOrderStatus status;
  final ValueChanged<SalesOrderStatus?> onChanged;

  const _StatusBadge({
    required this.status,
    required this.onChanged,
  });

  Color get background {
    switch (status) {
      case SalesOrderStatus.draft:
        return const Color(
          0xFFF1F1F1,
        );

      case SalesOrderStatus.approved:
        return const Color(
          0xFFE6F7EC,
        );

      case SalesOrderStatus.sent:
        return const Color(
          0xFFE3F2FD,
        );

      case SalesOrderStatus.rejected:
        return const Color(
          0xFFFDEAEA,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            20,
          ),
        ),
        child: DropdownButton<SalesOrderStatus>(
          value: status,
          isDense: true,
          dropdownColor: Colors.white,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
          borderRadius: BorderRadius.circular(10),
          items: SalesOrderStatus.values
              .map((value) =>
                  DropdownMenuItem(value: value, child: Text(value.label)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============================================================
// PURCHASE STATUS BADGE
// ============================================================

class _PurchaseStatusBadge extends StatelessWidget {
  final PurchaseStatus status;

  const _PurchaseStatusBadge({
    required this.status,
  });

  Color get background {
    switch (status) {
      case PurchaseStatus.notStarted:
        return const Color(
          0xFFF1F1F1,
        );

      case PurchaseStatus.partial:
        return const Color(
          0xFFFFF3E0,
        );

      case PurchaseStatus.completed:
        return const Color(
          0xFFE6F7EC,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            20,
          ),
        ),
        child: Text(
          status.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
