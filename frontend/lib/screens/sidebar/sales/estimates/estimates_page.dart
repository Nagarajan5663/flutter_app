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

// ============================================================
// API
// ============================================================

class EstimatesApi {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<EstimateData> approveEstimate(int id) async {
    final response =
        await http.post(Uri.parse('$baseUrl/estimates/$id/approve'), headers: {
      'Accept': 'application/json',
      ...SalesWorkflowSession.headers,
    });
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body is! Map || body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to approve Estimate'
          : 'Failed to approve Estimate');
    }
    return EstimateData.fromJson(
        Map<String, dynamic>.from(body['data'] as Map));
  }

  static Future<Map<String, dynamic>> createSalesOrderFromEstimate(
      int id) async {
    final response = await http
        .post(Uri.parse('$baseUrl/sales-orders/from-estimate/$id'), headers: {
      'Accept': 'application/json',
      ...SalesWorkflowSession.headers,
    });
    final body = jsonDecode(response.body);
    if ((response.statusCode != 200 && response.statusCode != 201) ||
        body is! Map ||
        body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to create Sales Order'
          : 'Failed to create Sales Order');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  // ==========================================================
  // GET ESTIMATES
  // ==========================================================

  static Future<List<EstimateData>> getEstimates() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/estimates',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Invalid server response',
      );
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to fetch estimates',
      );
    }

    final List<dynamic> data =
        body['data'] is List ? body['data'] : <dynamic>[];

    return data.map((item) {
      return EstimateData.fromJson(
        Map<String, dynamic>.from(
          item as Map,
        ),
      );
    }).toList();
  }

  static Future<EstimateData> getEstimate(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/estimates/$id'),
      headers: const {
        'Accept': 'application/json',
      },
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        body['data'] is! Map) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to fetch estimate details'
          : 'Invalid server response');
    }
    return EstimateData.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }

  // ==========================================================
  // NEXT NUMBER
  // ==========================================================

  static Future<String> getNextNumber() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/estimates/next-number',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Invalid server response',
      );
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to generate estimate number',
      );
    }

    return body['data']?['estimateNumber']?.toString() ?? 'EST-1';
  }

  // ==========================================================
  // CREATE ESTIMATE
  // ==========================================================

  static Future<EstimateData> createEstimate(
    EstimateData estimate,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/estimates',
      ),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(
        estimate.toCreateJson(),
      ),
    );

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Invalid server response',
      );
    }

    if (response.statusCode != 201 || body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to save estimate',
      );
    }

    return EstimateData.fromJson(
      Map<String, dynamic>.from(
        body['data'] as Map,
      ),
    );
  }

  // ==========================================================
  static Future<void> updateEstimate(int id, EstimateData estimate) async {
    final response = await http.put(
      Uri.parse('$baseUrl/estimates/$id'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode(estimate.toCreateJson()),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200 || body is! Map || body['success'] != true) {
      throw Exception(body is Map
          ? body['message'] ?? 'Failed to update Estimate'
          : 'Failed to update Estimate');
    }
  }

  // UPDATE STATUS
  // ==========================================================

  static Future<void> updateStatus(
    int id,
    EstimateStatus status,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/estimates/$id/status',
      ),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status.label,
      }),
    );

    final body = jsonDecode(response.body);

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

  // ==========================================================
  // DELETE
  // ==========================================================

  static Future<void> deleteEstimate(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/estimates/$id',
      ),
      headers: const {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to delete estimate'
            : 'Failed to delete estimate',
      );
    }
  }

  // ==========================================================
  // CUSTOMERS
  // ==========================================================

  static Future<List<CustomerOption>> getCustomers() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/customers',
      ),
    );

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic> ||
        response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'Failed to fetch customers'
            : 'Failed to fetch customers',
      );
    }

    final List<dynamic> data = body['data'] ?? [];

    return data
        .map((item) {
          final map = Map<String, dynamic>.from(
            item as Map,
          );

          return CustomerOption(
            id: int.tryParse(
                  map['id'].toString(),
                ) ??
                0,
            name: map['vendorName']?.toString() ?? '',
            companyName: map['companyName']?.toString() ?? '',
            email: map['email']?.toString() ?? '',
            phone: map['phone']?.toString() ?? '',
          );
        })
        .where(
          (customer) => customer.id > 0 && customer.name.isNotEmpty,
        )
        .toList();
  }

  // ==========================================================
  // ITEMS + PARTS
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

    final itemBody = jsonDecode(
      itemResponse.body,
    );

    final partBody = jsonDecode(
      partResponse.body,
    );

    if (itemBody is! Map<String, dynamic> ||
        itemResponse.statusCode != 200 ||
        itemBody['success'] != true) {
      throw Exception(
        itemBody is Map
            ? itemBody['message'] ?? 'Failed to fetch items'
            : 'Failed to fetch items',
      );
    }

    if (partBody is! Map<String, dynamic> ||
        partResponse.statusCode != 200 ||
        partBody['success'] != true) {
      throw Exception(
        partBody is Map
            ? partBody['message'] ?? 'Failed to fetch parts'
            : 'Failed to fetch parts',
      );
    }

    final List<CatalogOption> catalog = [];

    final List<dynamic> items = itemBody['data'] ?? [];

    for (final raw in items) {
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

          // Items use Sales Price
          rate: double.tryParse(
                item['sales_price'].toString(),
              ) ??
              0,
        ),
      );
    }

    final List<dynamic> parts = partBody['data'] ?? [];

    for (final raw in parts) {
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

          // Parts currently only have Purchase Price
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
// CUSTOMER SEARCH OPTION
// ============================================================

class CustomerOption {
  final int id;
  final String name;
  final String companyName;
  final String email;
  final String phone;

  const CustomerOption({
    required this.id,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
  });
}

// ============================================================
// ITEM / PART SEARCH OPTION
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
// ESTIMATE STATUS
// ============================================================

enum EstimateStatus {
  draft,
  sent,
  accepted,
  declined,
  expired;

  String get label {
    switch (this) {
      case EstimateStatus.draft:
        return 'Draft';

      case EstimateStatus.sent:
        return 'Sent';

      case EstimateStatus.accepted:
        return 'Accepted';

      case EstimateStatus.declined:
        return 'Declined';

      case EstimateStatus.expired:
        return 'Expired';
    }
  }

  String get tableLabel {
    switch (this) {
      case EstimateStatus.accepted:
        return 'Approved';
      case EstimateStatus.declined:
        return 'Rejected';
      default:
        return label;
    }
  }

  static EstimateStatus? fromTableLabel(String? value) {
    switch (value) {
      case 'Draft':
        return EstimateStatus.draft;
      case 'Sent':
        return EstimateStatus.sent;
      case 'Approved':
        return EstimateStatus.accepted;
      case 'Rejected':
        return EstimateStatus.declined;
      default:
        return null;
    }
  }

  static EstimateStatus fromString(
    String value,
  ) {
    switch (value) {
      case 'Sent':
        return EstimateStatus.sent;

      case 'Accepted':
        return EstimateStatus.accepted;

      case 'Declined':
        return EstimateStatus.declined;

      case 'Expired':
        return EstimateStatus.expired;

      default:
        return EstimateStatus.draft;
    }
  }
}

// ============================================================
// ESTIMATE ITEM MODEL
// ============================================================

class EstimateItem {
  final int? id;

  final String sourceType;

  final int? itemId;
  final int? partId;

  final String itemName;
  final String description;

  final double qty;
  final double rate;

  const EstimateItem({
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

  factory EstimateItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return EstimateItem(
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
            json['qty'].toString(),
          ) ??
          0,
      rate: double.tryParse(
            json['rate'].toString(),
          ) ??
          0,
    );
  }
}

// ============================================================
// ESTIMATE MODEL
// ============================================================

class EstimateData {
  final int? id;

  final DateTime date;

  final String estimateNumber;

  final int customerId;

  final String customerName;
  final String customerEmail;
  final String customerPhone;

  final String salesPerson;

  final DateTime? expiryDate;

  final List<EstimateItem> items;

  final double subTotal;

  final double total;

  EstimateStatus status;
  String approvalStatus;
  DateTime? approvedAt;
  int? approvedBy;
  int? salesOrderId;
  String? salesOrderNumber;

  EstimateData({
    this.id,
    required this.date,
    required this.estimateNumber,
    required this.customerId,
    required this.customerName,
    this.customerEmail = '',
    this.customerPhone = '',
    required this.salesPerson,
    this.expiryDate,
    required this.items,
    required this.subTotal,
    required this.total,
    this.status = EstimateStatus.draft,
    this.approvalStatus = 'Pending',
    this.approvedAt,
    this.approvedBy,
    this.salesOrderId,
    this.salesOrderNumber,
  });

  Map<String, dynamic> toCreateJson() {
    return {
      'estimateNumber': estimateNumber,
      'customerId': customerId,
      'salesPerson': salesPerson,
      'date': DateFormat(
        'yyyy-MM-dd',
      ).format(date),
      'expiryDate': expiryDate == null
          ? null
          : DateFormat(
              'yyyy-MM-dd',
            ).format(
              expiryDate!,
            ),
      'items': items
          .map(
            (item) => item.toJson(),
          )
          .toList(),
      'subTotal': subTotal,
      'total': total,
    };
  }

  factory EstimateData.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawItems =
        json['items'] is List ? json['items'] : <dynamic>[];

    return EstimateData(
      id: json['id'] == null
          ? null
          : int.tryParse(
              json['id'].toString(),
            ),
      date: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      estimateNumber: json['estimateNumber']?.toString() ?? '',
      customerId: int.tryParse(
            json['customerId']?.toString() ?? '0',
          ) ??
          0,
      customerName: json['customerName']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      salesPerson: json['salesPerson']?.toString() ?? '',
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.tryParse(
              json['expiryDate'].toString(),
            ),
      items: rawItems.map((item) {
        return EstimateItem.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        );
      }).toList(),
      subTotal: double.tryParse(
            json['subTotal']?.toString() ?? '0',
          ) ??
          0,
      total: double.tryParse(
            json['total']?.toString() ?? '0',
          ) ??
          0,
      status: EstimateStatus.fromString(
        json['status']?.toString() ?? 'Draft',
      ),
      approvalStatus: json['approvalStatus']?.toString() ?? 'Pending',
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.tryParse(json['approvedAt'].toString()),
      approvedBy: json['approvedBy'] == null
          ? null
          : int.tryParse(json['approvedBy'].toString()),
      salesOrderId: json['salesOrderId'] == null
          ? null
          : int.tryParse(json['salesOrderId'].toString()),
      salesOrderNumber: json['salesOrderNumber']?.toString(),
    );
  }
}

// ============================================================
// ESTIMATES PAGE
// ============================================================

class EstimatesPage extends StatefulWidget {
  final VoidCallback? onOpenSalesOrders;
  const EstimatesPage({
    super.key,
    this.onOpenSalesOrders,
  });

  @override
  State<EstimatesPage> createState() => _EstimatesPageState();
}

class _EstimatesPageState extends State<EstimatesPage> {
  final Set<int> _workflowBusyIds = {};
  List<EstimateData> _estimates = [];

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
    'Sent',
    'Accepted',
    'Declined',
    'Expired',
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadEstimates();
  }

  @override
  void dispose() {
    _customerFilterController.dispose();

    super.dispose();
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<EstimateData> get _filteredEstimates {
    return _estimates.where(
      (estimate) {
        if (_statusFilter != 'All' && estimate.status.label != _statusFilter) {
          return false;
        }

        final customerQuery =
            _customerFilterController.text.trim().toLowerCase();

        if (customerQuery.isNotEmpty &&
            !estimate.customerName.toLowerCase().contains(
                  customerQuery,
                )) {
          return false;
        }

        if (_dateFrom != null &&
            estimate.date.isBefore(
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

          if (estimate.date.isAfter(
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
  // LOAD
  // ==========================================================

  Future<void> _loadEstimates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final estimates = await EstimatesApi.getEstimates();

      if (!mounted) return;

      setState(() {
        _estimates = estimates;
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
  // NEW ESTIMATE
  // ==========================================================

  Future<void> _openNewEstimateForm() async {
    try {
      final nextNumber = await EstimatesApi.getNextNumber();

      if (!mounted) return;

      final bool? saved = await showDialog<bool>(
        context: context,
        barrierColor: const Color(
          0x9A12202C,
        ),
        barrierDismissible: false,
        builder: (_) {
          return NewEstimateDialog(
            nextNumber: nextNumber,
          );
        },
      );

      if (saved == true) {
        await _loadEstimates();
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to open estimate: $error',
        isError: true,
      );
    }
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  Future<void> _updateStatus(
    EstimateData estimate,
    EstimateStatus status,
  ) async {
    if (estimate.id == null) {
      return;
    }

    try {
      if (status == EstimateStatus.accepted) {
        await EstimatesApi.approveEstimate(estimate.id!);
      } else {
        await EstimatesApi.updateStatus(
          estimate.id!,
          status,
        );
      }

      await _loadEstimates();

      if (!mounted) return;

      _showMessage(
        status == EstimateStatus.accepted
            ? 'Estimate approved'
            : 'Estimate status updated',
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

  Future<void> _deleteEstimate(
    EstimateData estimate,
  ) async {
    if (estimate.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Estimate',
          ),
          content: Text(
            'Delete ${estimate.estimateNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await EstimatesApi.deleteEstimate(
        estimate.id!,
      );

      await _loadEstimates();

      if (!mounted) return;

      _showMessage(
        'Estimate deleted successfully',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete estimate: $error',
        isError: true,
      );
    }
  }

  Future<void> _openEstimateEditor(EstimateData estimate,
      {required bool clone}) async {
    if (!clone &&
        (estimate.approvalStatus == 'Approved' ||
            estimate.salesOrderId != null)) {
      _showMessage('Approved or converted Estimates cannot be edited.',
          isError: true);
      return;
    }
    try {
      final number =
          clone ? await EstimatesApi.getNextNumber() : estimate.estimateNumber;
      if (!mounted) return;
      final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => NewEstimateDialog(
          nextNumber: number,
          sourceEstimate: estimate,
          editMode: !clone,
        ),
      );
      if (saved == true) await _loadEstimates();
    } catch (error) {
      if (mounted)
        _showMessage('Unable to open Estimate: $error', isError: true);
    }
  }

  Future<bool> _createOrOpenSalesOrder(EstimateData estimate) async {
    if (estimate.approvalStatus != 'Approved') {
      _showMessage('Estimate must be approved before creating a Sales Order.',
          isError: true);
      return false;
    }
    if (estimate.id == null || !_workflowBusyIds.add(estimate.id!))
      return false;
    setState(() {});
    try {
      final order =
          await EstimatesApi.createSalesOrderFromEstimate(estimate.id!);
      await _loadEstimates();
      if (!mounted) return false;
      _showMessage('Sales Order ${order['orderNumber'] ?? ''} is ready.');
      widget.onOpenSalesOrders?.call();
      return true;
    } catch (error) {
      if (mounted)
        _showMessage(error.toString().replaceFirst('Exception: ', ''),
            isError: true);
      return false;
    } finally {
      _workflowBusyIds.remove(estimate.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _showEstimatePreview(EstimateData estimate) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _EstimatePreviewDialog(
        estimate: estimate,
        onConvert: _createOrOpenSalesOrder,
      ),
    );
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

  // ==========================================================
  // CLEAR FILTERS
  // ==========================================================

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
    final estimates = _filteredEstimates;

    return SalesGlassPageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Estimates',
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
                  onPressed: _isLoading ? null : _loadEstimates,
                  tooltip: 'Refresh Estimates',
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
                  onPressed: _openNewEstimateForm,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text(
                    'New Estimate',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF17395C,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // FILTER
            // ==================================================

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
                    child: _buildFilterDropdown(),
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
                        style: const TextStyle(
                          color: Color(
                            0xFFAB2A2A,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadEstimates,
                      child: const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // TABLE
            // ==================================================

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
                  width: 1100,
                  child: _isLoading
                      ? const SizedBox(
                          height: 350,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : estimates.isEmpty
                          ? _buildEmptyTable()
                          : _buildEstimateTable(
                              estimates,
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
  // FILTER WIDGETS
  // ==========================================================

  Widget _buildFilterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(
              0xFF444444,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        DropdownButtonFormField<String>(
          initialValue: _statusFilter,
          isExpanded: true,
          dropdownColor: Colors.white,
          decoration: _filterInputDecoration(),
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
            color: Color(
              0xFF444444,
            ),
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
          decoration: _filterInputDecoration().copyWith(
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
            color: Color(
              0xFF444444,
            ),
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
            decoration: _filterInputDecoration(),
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
          Icons.request_quote_outlined,
          size: 55,
          color: Color(
            0xFFB0B8C2,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        const Text(
          'No estimates found. Click "+ New Estimate" to add one!',
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
            width: 130,
            child: _HeaderText(
              'ESTIMATE #',
            ),
          ),
          SizedBox(
            width: 220,
            child: _HeaderText(
              'CUSTOMER NAME',
            ),
          ),
          SizedBox(
            width: 170,
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

  Widget _buildEstimateTable(
    List<EstimateData> estimates,
  ) {
    return Column(
      children: [
        _buildTableHeader(),
        const Divider(
          height: 1,
        ),
        ...estimates.map(
          (estimate) {
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
                            estimate.date,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: Text(
                          estimate.estimateNumber,
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: Text(
                          estimate.customerName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: Text(
                          estimate.salesPerson.isEmpty
                              ? '-'
                              : estimate.salesPerson,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: _StatusBadge(
                          status: estimate.approvalStatus == 'Approved'
                              ? EstimateStatus.accepted
                              : estimate.status == EstimateStatus.accepted
                                  ? EstimateStatus.sent
                                  : estimate.status,
                          onChanged: (status) {
                            if (status != null) {
                              final isApproved =
                                  estimate.approvalStatus == 'Approved';
                              if (status != estimate.status || isApproved) {
                                _updateStatus(estimate, status);
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          'INR ${estimate.total.toStringAsFixed(2)}',
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
                              tooltip: 'Preview Estimate',
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
                              onPressed: _workflowBusyIds.contains(estimate.id)
                                  ? null
                                  : () => _showEstimatePreview(estimate),
                            ),
                            IconButton(
                              tooltip: 'Edit Estimate',
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
                              onPressed: _workflowBusyIds.contains(estimate.id)
                                  ? null
                                  : () => _openEstimateEditor(
                                        estimate,
                                        clone: false,
                                      ),
                            ),
                            IconButton(
                              tooltip: 'Clone Estimate',
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
                              onPressed: _workflowBusyIds.contains(estimate.id)
                                  ? null
                                  : () => _openEstimateEditor(
                                        estimate,
                                        clone: true,
                                      ),
                            ),
                            IconButton(
                              tooltip: 'Delete Estimate',
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
                              onPressed: _workflowBusyIds.contains(estimate.id)
                                  ? null
                                  : () => _deleteEstimate(estimate),
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

  // ==========================================================
  // DECORATION
  // ==========================================================

  InputDecoration _filterInputDecoration() {
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
          6,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          6,
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
// NEW ESTIMATE DIALOG
// ============================================================

class _EstimatePreviewDialog extends StatefulWidget {
  const _EstimatePreviewDialog(
      {required this.estimate,
      required this.onConvert});

  final EstimateData estimate;
  final Future<bool> Function(EstimateData) onConvert;

  @override
  State<_EstimatePreviewDialog> createState() => _EstimatePreviewDialogState();
}

class _EstimatePreviewDialogState extends State<_EstimatePreviewDialog> {
  late EstimateData _estimate = widget.estimate;
  bool _busy = false;
  bool _loadingDetails = false;
  String? _detailsError;
  Future<void>? _detailsLoadFuture;

  @override
  void initState() {
    super.initState();
    if (_estimate.items.isEmpty && _estimate.id != null) {
      _detailsLoadFuture = _loadEstimateDetails();
    }
  }

  Future<void> _loadEstimateDetails() async {
    final estimateId = _estimate.id;
    if (estimateId == null) return;
    setState(() {
      _loadingDetails = true;
      _detailsError = null;
    });
    try {
      final detailedEstimate = await EstimatesApi.getEstimate(estimateId);
      if (!mounted) return;
      setState(() {
        _estimate = detailedEstimate;
        _loadingDetails = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingDetails = false;
        _detailsError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<bool> _waitForEstimateDetails() async {
    final loadFuture = _detailsLoadFuture;
    if (loadFuture != null) await loadFuture;
    if (_detailsError == null) return true;
    _showLaunchError('Unable to load estimate items: $_detailsError');
    return false;
  }

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Text('ESTIMATE',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Text('Estimate: ${_estimate.estimateNumber}'),
        pw.Text('Customer: ${_estimate.customerName}'),
        pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(_estimate.date)}'),
        pw.Text(
            'Status: ${_estimate.status.tableLabel}  •  Approval: ${_estimate.approvalStatus}'),
        pw.SizedBox(height: 18),
        pw.Table(border: pw.TableBorder.all(), children: [
          pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
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
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ]),
          for (final item in _estimate.items)
            pw.TableRow(
                children: [
              item.itemName,
              item.description,
              item.qty.toString(),
              item.rate.toStringAsFixed(2),
              (item.qty * item.rate).toStringAsFixed(2),
            ]
                    .map((value) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(value)))
                    .toList()),
        ]),
        pw.SizedBox(height: 18),
        pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Total: INR ${_estimate.total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold))),
      ],
    ));
    try {
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: '${_estimate.estimateNumber}.pdf');
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to create PDF: $error')));
    }
  }

  String _estimateShareMessage() {
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'INR ',
      decimalDigits: 2,
    );
    final buffer = StringBuffer()
      ..writeln('ESTIMATE')
      ..writeln('Estimate: ${_estimate.estimateNumber}')
      ..writeln('Customer: ${_estimate.customerName}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(_estimate.date)}');

    if (_estimate.expiryDate != null) {
      buffer.writeln(
        'Expiry Date: ${DateFormat('dd MMM yyyy').format(_estimate.expiryDate!)}',
      );
    }
    if (_estimate.salesPerson.isNotEmpty) {
      buffer.writeln('Sales Person: ${_estimate.salesPerson}');
    }
    if (_estimate.salesOrderNumber?.isNotEmpty ?? false) {
      buffer.writeln('Sales Order: ${_estimate.salesOrderNumber}');
    }
    buffer
      ..writeln('Status: ${_estimate.status.tableLabel}')
      ..writeln('Approval: ${_estimate.approvalStatus}')
      ..writeln()
      ..writeln('ITEMS');

    if (_estimate.items.isEmpty) {
      buffer.writeln('No line items.');
    } else {
      for (var index = 0; index < _estimate.items.length; index++) {
        final item = _estimate.items[index];
        buffer
          ..writeln('${index + 1}. ${item.itemName}')
          ..writeln(
              '   Description: ${item.description.isEmpty ? '-' : item.description}')
          ..writeln('   Quantity: ${item.qty.toStringAsFixed(2)}')
          ..writeln('   Rate: ${money.format(item.rate)}')
          ..writeln('   Amount: ${money.format(item.amount)}');
      }
    }

    buffer
      ..writeln()
      ..writeln('Subtotal: ${money.format(_estimate.subTotal)}')
      ..writeln('Total: ${money.format(_estimate.total)}');
    return buffer.toString().trimRight();
  }

  Future<void> _sendEmail() async {
    if (!await _waitForEstimateDetails()) return;
    if (_estimate.customerEmail.trim().isEmpty) {
      _showLaunchError('This customer does not have an email address.');
      return;
    }
    final uri = Uri(
        scheme: 'mailto',
        path: _estimate.customerEmail.trim(),
        queryParameters: {
          'subject': 'Estimate ${_estimate.estimateNumber}',
          'body': _estimateShareMessage(),
        });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication))
      _showLaunchError('Email app could not be opened.');
  }

  Future<void> _sendWhatsApp() async {
    if (!await _waitForEstimateDetails()) return;
    final phone = _estimate.customerPhone.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      _showLaunchError('This customer does not have a phone number.');
      return;
    }
    final message = _estimateShareMessage();
    final encoded = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/$phone?text=$encoded');
    final alternateUrl =
        Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encoded');

    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(alternateUrl,
          mode: LaunchMode.externalApplication)) {
        _showLaunchError('WhatsApp could not be opened.');
      }
    }
  }

  void _showLaunchError(String message) {
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final previewWidth = (screenSize.width * .9).clamp(0.0, 900.0).toDouble();
    final previewHeight =
        (screenSize.height - 32).clamp(260.0, 760.0).toDouble();
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: 'INR', decimalDigits: 2);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: previewWidth,
        height: previewHeight,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 10, 18),
            child: LayoutBuilder(builder: (context, constraints) {
              final customer = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_estimate.customerName,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(
                    '${_estimate.estimateNumber} | ${DateFormat('M/d/yyyy').format(_estimate.date)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              );
              final actions = Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _downloadPdf,
                  icon: const Icon(Icons.download_outlined,
                      size: 18, color: Colors.black),
                  label: const Text('Download PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.black,
                    backgroundColor: const Color(0xFFE3E3E3),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
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
                      ),
                    ),
                    PopupMenuItem(
                      value: 'whatsapp',
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 18),
                          SizedBox(width: 8),
                          Text('WhatsApp'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_outlined,
                            size: 18, color: Colors.black),
                        SizedBox(width: 6),
                        Text('Send', style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_estimate.approvalStatus == 'Approved')
                  PopupMenuButton<String>(
                    enabled: !_busy,
                    onSelected: (_) async {
                      final navigator = Navigator.of(context);
                      setState(() => _busy = true);
                      final converted = await widget.onConvert(_estimate);
                      if (!mounted) return;
                      if (converted) navigator.pop();
                      if (!converted) setState(() => _busy = false);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'convert',
                        child: Text(
                          _estimate.salesOrderId == null
                              ? 'Sales Order'
                              : 'Open Sales Order ${_estimate.salesOrderNumber ?? ''}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                          color: const Color(0xFF3498DB),
                          borderRadius: BorderRadius.circular(6)),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Convert As',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.black, size: 20),
                      ]),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.black,
                    backgroundColor: const Color(0xFF899597),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  child: const Text('Void'),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ]);
              if (constraints.maxWidth < 760) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customer,
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: actions,
                      ),
                    ]);
              }
              if (constraints.maxWidth < 930) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customer,
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: actions,
                          )),
                    ]);
              }
              return Row(children: [
                Expanded(child: customer),
                actions,
              ]);
            }),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: LayoutBuilder(builder: (context, constraints) {
                final lineItems = Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    color: const Color(0xFFF5F6F7),
                    child: const Row(children: [
                      Expanded(
                          flex: 3,
                          child: Text('Item & Description',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black))),
                      Expanded(
                          flex: 1,
                          child: Text('Qty',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black))),
                      Expanded(
                          flex: 2,
                          child: Text('Rate',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black))),
                      Expanded(
                          flex: 2,
                          child: Text('Amount',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black))),
                    ]),
                  ),
                  Expanded(
                    child: _loadingDetails
                        ? const Center(child: CircularProgressIndicator())
                        : _detailsError != null
                            ? Center(
                                child: Text(
                                  'Unable to load estimate items: $_detailsError',
                                  style: const TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : _estimate.items.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No estimate items found.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                : ListView(
                                    children: _estimate.items
                                        .map((item) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12),
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: Color(
                                                              0xFFE0E0E0)))),
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
                                                              Text(
                                                                  item.itemName,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .black)),
                                                              if (item
                                                                  .description
                                                                  .isNotEmpty) ...[
                                                                const SizedBox(
                                                                    height: 3),
                                                                Text(
                                                                    item
                                                                        .description,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                              ],
                                                            ])),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            item.qty
                                                                .toStringAsFixed(
                                                                    2),
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black))),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            currency.format(
                                                                item.rate),
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black))),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            currency.format(
                                                                item.qty *
                                                                    item.rate),
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black))),
                                                  ]),
                                            ))
                                        .toList(),
                                  ),
                  ),
                ]);
                final summary = Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Summary',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Sub Total',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              Text(currency.format(_estimate.total),
                                  style: const TextStyle(color: Colors.black)),
                            ]),
                        const SizedBox(height: 12),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                              Text(currency.format(_estimate.total),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black)),
                            ]),
                      ]),
                );
                if (constraints.maxWidth < 700) {
                  return Column(children: [
                    Expanded(child: lineItems),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight * .35,
                      ),
                      child: SingleChildScrollView(child: summary),
                    ),
                  ]);
                }
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 65, child: lineItems),
                      const VerticalDivider(width: 1, color: Color(0xFFE0E0E0)),
                      Expanded(
                        flex: 35,
                        child: SingleChildScrollView(child: summary),
                      ),
                    ]);
              }),
            ),
          ),
        ]),
      ),
    );
  }
}

class NewEstimateDialog extends StatefulWidget {
  final String nextNumber;
  final EstimateData? sourceEstimate;
  final bool editMode;
  final int? initialCustomerId;
  final String? initialCustomerName;

  const NewEstimateDialog({
    super.key,
    required this.nextNumber,
    this.sourceEstimate,
    this.editMode = false,
    this.initialCustomerId,
    this.initialCustomerName,
  });

  @override
  State<NewEstimateDialog> createState() => _NewEstimateDialogState();
}

class _NewEstimateDialogState extends State<NewEstimateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController estimateNumberController =
      TextEditingController(
    text: widget.editMode
        ? widget.sourceEstimate?.estimateNumber
        : widget.nextNumber,
  );

  final TextEditingController customerController = TextEditingController();

  final FocusNode customerFocusNode = FocusNode();

  final TextEditingController salesPersonController = TextEditingController();

  CustomerOption? _selectedCustomer;

  List<CustomerOption> _customers = [];

  List<CatalogOption> _catalog = [];

  final List<_ItemRow> _itemRows = [
    _ItemRow(),
  ];

  DateTime selectedDate = DateTime.now();

  DateTime? expiryDate;

  bool _isLoadingData = true;

  bool _isSaving = false;

  String? _loadingError;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadReferenceData();
  }

  @override
  void dispose() {
    estimateNumberController.dispose();

    customerController.dispose();

    customerFocusNode.dispose();

    salesPersonController.dispose();

    for (final row in _itemRows) {
      row.dispose();
    }

    super.dispose();
  }

  // ==========================================================
  // LOAD CUSTOMERS + PRODUCTS
  // ==========================================================

  Future<void> _loadReferenceData() async {
    setState(() {
      _isLoadingData = true;
      _loadingError = null;
    });

    try {
      final customerFuture = EstimatesApi.getCustomers();

      final catalogFuture = EstimatesApi.getCatalog();

      final customers = await customerFuture;

      final catalog = await catalogFuture;

      if (!mounted) return;

      setState(() {
        _customers = customers;

        _catalog = catalog;

        _isLoadingData = false;
      });
      _populateSourceEstimate();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingData = false;

        _loadingError = error.toString();
      });
    }
  }

  void _populateSourceEstimate() {
    final source = widget.sourceEstimate;
    if (source == null) {
      setState(() {
        final matchingCustomers = _customers
            .where((customer) => customer.id == widget.initialCustomerId)
            .toList();
        _selectedCustomer =
            matchingCustomers.isEmpty ? null : matchingCustomers.first;
        customerController.text =
            _selectedCustomer?.name ?? widget.initialCustomerName ?? '';
      });
      return;
    }
    final matchingCustomers =
        _customers.where((c) => c.id == source.customerId).toList();
    _selectedCustomer =
        matchingCustomers.isEmpty ? null : matchingCustomers.first;
    customerController.text = _selectedCustomer?.name ?? source.customerName;
    salesPersonController.text = source.salesPerson;
    selectedDate = source.date;
    expiryDate = source.expiryDate;
    for (final row in _itemRows) {
      row.dispose();
    }
    _itemRows.clear();
    for (final item in source.items) {
      final productId = item.sourceType == 'Part' ? item.partId : item.itemId;
      final row = _ItemRow();
      final matchingProducts = _catalog
          .where((p) => p.sourceType == item.sourceType && p.id == productId)
          .toList();
      row.selectedProduct = matchingProducts.isNotEmpty
          ? matchingProducts.first
          : (productId == null
              ? null
              : CatalogOption(
                  sourceType: item.sourceType,
                  id: productId,
                  name: item.itemName,
                  sku: '',
                  description: item.description,
                  rate: item.rate,
                ));
      row.itemController.text = item.itemName;
      row.descriptionController.text = item.description;
      row.qtyController.text = item.qty.toString();
      row.rateController.text = item.rate.toStringAsFixed(2);
      _itemRows.add(row);
    }
    if (_itemRows.isEmpty) _itemRows.add(_ItemRow());
    if (mounted) setState(() {});
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double get subTotal {
    double value = 0;

    for (final row in _itemRows) {
      value += row.amount;
    }

    return value;
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
      _itemRows.remove(row);

      row.dispose();
    });
  }

  // ==========================================================
  // DATE
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

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _saveEstimate() async {
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

    final List<EstimateItem> items = [];

    for (final row in _itemRows) {
      if (row.itemController.text.trim().isEmpty) {
        continue;
      }

      if (row.selectedProduct == null) {
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

      final product = row.selectedProduct!;

      items.add(
        EstimateItem(
          sourceType: product.sourceType,
          itemId: product.sourceType == 'Item' ? product.id : null,
          partId: product.sourceType == 'Part' ? product.id : null,
          itemName: product.name,
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
      final estimate = EstimateData(
        date: selectedDate,
        estimateNumber: estimateNumberController.text.trim(),
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        salesPerson: salesPersonController.text.trim(),
        expiryDate: expiryDate,
        items: items,
        subTotal: subTotal,
        total: total,
      );

      if (widget.editMode && widget.sourceEstimate?.id != null) {
        await EstimatesApi.updateEstimate(widget.sourceEstimate!.id!, estimate);
      } else {
        await EstimatesApi.createEstimate(estimate);
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
        'Failed to save estimate: $error',
      );
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
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
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 960,
          maxHeight: 720,
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
              // ================================================
              // HEADER
              // ================================================

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
                        widget.editMode
                            ? 'Edit Estimate'
                            : widget.sourceEstimate == null
                                ? 'New Estimate'
                                : 'Clone Estimate',
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
                        size: 28,
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
                Container(
                  width: double.infinity,
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

              // ================================================
              // FORM
              // ================================================

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
                        // ======================================
                        // TOP FIELDS
                        // ======================================

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
                                label: 'Estimate # *',
                                controller: estimateNumberController,
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
                            label: 'Expiry Date',
                            value: expiryDate,
                            onTap: _selectExpiryDate,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ======================================
                        // ITEM TABLE
                        // ======================================

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
                                          fontSize: 16,
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
                          height: 15,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // ======================================
                        // TOTAL
                        // ======================================

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
                                  height: 15,
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
                      ],
                    ),
                  ),
                ),
              ),

              // ================================================
              // FOOTER
              // ================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFF8F8FA,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Color(
                        0xFFE0E0E0,
                      ),
                    ),
                  ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
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
                          _isSaving || _isLoadingData ? null : _saveEstimate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1E78B7,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
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
                          : const Text(
                              'Save Estimate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
            color: Color(
              0xFF444444,
            ),
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
              style: const TextStyle(
                color: Colors.black,
              ),
              decoration: _inputDecoration().copyWith(
                hintText: 'Select or type to search...',
              ),
              onChanged: (value) {
                if (_selectedCustomer != null &&
                    value.trim() != _selectedCustomer!.name) {
                  _selectedCustomer = null;
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
                borderRadius: BorderRadius.circular(
                  10,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 250,
                    maxWidth: 330,
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
                  displayStringForOption: (option) => option.name,
                  optionsBuilder: (textValue) {
                    final query = textValue.text.trim().toLowerCase();

                    if (query.isEmpty) {
                      return _catalog.take(
                        10,
                      );
                    }

                    return _catalog
                        .where(
                          (item) =>
                              item.name.toLowerCase().contains(
                                    query,
                                  ) ||
                              item.sku.toLowerCase().contains(
                                    query,
                                  ) ||
                              item.sourceType.toLowerCase().contains(
                                    query,
                                  ),
                        )
                        .take(
                          10,
                        );
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
                      decoration: _cellInputDecoration().copyWith(
                        hintText: 'Select or type to search...',
                      ),
                      onChanged: (value) {
                        if (row.selectedProduct != null &&
                            value.trim() != row.selectedProduct!.name) {
                          row.selectedProduct = null;

                          setState(() {});
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
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 450,
                            maxHeight: 280,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (_, index) {
                              final item = list[index];

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.sourceType == 'Item'
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
                                    item.sourceType,
                                    style: const TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                ),
                                subtitle: Text(
                                  item.sku.isEmpty
                                      ? 'Rate: INR ${item.rate.toStringAsFixed(2)}'
                                      : '${item.sku} • INR ${item.rate.toStringAsFixed(2)}',
                                ),
                                onTap: () {
                                  onSelected(
                                    item,
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
                  decoration: _cellInputDecoration().copyWith(
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
              decoration: _cellInputDecoration(),
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
              decoration: _cellInputDecoration(),
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

  // ==========================================================
  // COMMON FIELDS
  // ==========================================================

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
            color: Color(
              0xFF444444,
            ),
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
            color: Color(
              0xFF444444,
            ),
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
                  size: 19,
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
            color: Color(
              0xFF444444,
            ),
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
                  size: 19,
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
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFF1E78B7,
          ),
          width: 1.5,
        ),
      ),
    );
  }

  InputDecoration _cellInputDecoration() {
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
          8,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFFD7DCE2,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8,
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
// ITEM ROW CONTROLLER
// ============================================================

class _ItemRow {
  CatalogOption? selectedProduct;

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
// SMALL UI WIDGETS
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

class _StatusBadge extends StatelessWidget {
  final EstimateStatus status;
  final ValueChanged<EstimateStatus?> onChanged;

  const _StatusBadge({
    required this.status,
    required this.onChanged,
  });

  Color get backgroundColor {
    switch (status) {
      case EstimateStatus.draft:
        return const Color(
          0xFFF1F1F1,
        );

      case EstimateStatus.sent:
        return const Color(
          0xFFE3F2FD,
        );

      case EstimateStatus.accepted:
        return const Color(
          0xFFE6F7EC,
        );

      case EstimateStatus.declined:
        return const Color(
          0xFFFDEAEA,
        );

      case EstimateStatus.expired:
        return const Color(
          0xFFFFF3E0,
        );
    }
  }

  Color get textColor {
    switch (status) {
      case EstimateStatus.draft:
        return const Color(
          0xFF6B7280,
        );

      case EstimateStatus.sent:
        return const Color(
          0xFF1E78B7,
        );

      case EstimateStatus.accepted:
        return const Color(
          0xFF1F9254,
        );

      case EstimateStatus.declined:
        return const Color(
          0xFFC0392B,
        );

      case EstimateStatus.expired:
        return const Color(
          0xFFB07A15,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (status == EstimateStatus.expired) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: backgroundColor, borderRadius: BorderRadius.circular(20)),
          child: Text(status.label,
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      );
    }

    return Tooltip(
      message: 'Document status only. Workflow approval is separate.',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          child: DropdownButton<String>(
            value: status.tableLabel,
            isDense: true,
            dropdownColor: Colors.white,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.keyboard_arrow_down, size: 18, color: textColor),
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
            borderRadius: BorderRadius.circular(10),
            items: const ['Draft', 'Sent', 'Approved', 'Rejected']
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) =>
                onChanged(EstimateStatus.fromTableLabel(value)),
          ),
        ),
      ),
    );
  }
}
