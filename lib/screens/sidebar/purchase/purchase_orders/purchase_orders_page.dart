import 'package:flutter/material.dart';

import 'purchase_order_filter.dart';
import 'purchase_order_model.dart';
import 'purchase_order_repository.dart';
import 'widgets/add_purchase_order_dialog.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  final PurchaseOrderRepository _repository = InMemoryPurchaseOrderRepository();

  List<PurchaseOrderModel> _orders = [];
  bool _isLoading = true;

  final vendorController = TextEditingController();
  final referenceController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  String statusFilter = 'All';
  final statusOptions = const ['All', 'Draft', 'Ordered', 'Received', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    vendorController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  PurchaseOrderFilter get _currentFilter => PurchaseOrderFilter(
        status: statusFilter,
        vendorName: vendorController.text,
        referenceNumber: referenceController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final result = await _repository.getPurchaseOrders(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _orders = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddOrder() async {
    final order = await showDialog<PurchaseOrderModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddPurchaseOrderDialog(),
    );

    if (!mounted || order == null) return;

    await _repository.addPurchaseOrder(order);
    await _loadOrders();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase order created successfully')),
    );
  }

  Future<void> _deleteOrder(PurchaseOrderModel order) async {
    if (order.id == null) return;
    await _repository.deletePurchaseOrder(order.id!);
    await _loadOrders();
  }

  void _clearFilters() {
    statusFilter = 'All';
    vendorController.clear();
    referenceController.clear();
    dateFrom = null;
    dateTo = null;
    _loadOrders();
  }

  Future<void> _pickDate(DateTime? initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F6F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Purchase Orders',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddOrder,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Purchase Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123456),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FILTER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD9DEE5)),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterField(
                    label: 'Status',
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: const Color(0xFFD9DEE5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusFilter,
                          style: const TextStyle(color: Colors.black),
                          isExpanded: true,
                          items: statusOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => statusFilter = value);
                          },
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Vendor Name',
                    child: SizedBox(width: 170, child: _filterTextField(vendorController, 'Vendor name...')),
                  ),
                  _filterField(
                    label: 'Reference #',
                    child: SizedBox(width: 150, child: _filterTextField(referenceController, 'Reference...')),
                  ),
                  _filterField(
                    label: 'Date From',
                    child: SizedBox(
                      width: 150,
                      child: _filterDateField(dateFrom, (d) => setState(() => dateFrom = d)),
                    ),
                  ),
                  _filterField(
                    label: 'Date To',
                    child: SizedBox(
                      width: 150,
                      child: _filterDateField(dateTo, (d) => setState(() => dateTo = d)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7DD1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: const Text('Filter'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E5E9),
                      foregroundColor: const Color(0xFF3D4147),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TABLE CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD9DEE5)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1000,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: _HeaderText('DATE')),
                            Expanded(flex: 2, child: _HeaderText('PO #')),
                            Expanded(flex: 3, child: _HeaderText('VENDOR NAME')),
                            Expanded(flex: 2, child: _HeaderText('STATUS')),
                            Expanded(flex: 2, child: _HeaderText('REFERENCE #')),
                            Expanded(flex: 2, child: _HeaderText('AMOUNT')),
                            Expanded(flex: 1, child: _HeaderText('ACTIONS')),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFD9DEE5)),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_orders.isEmpty)
                        Container(
                          width: 1000,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No purchase orders found. Click "+ New Purchase Order" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._orders.map((order) {
                          return Column(
                            children: [
                              Container(
                                width: 1000,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${order.date.day.toString().padLeft(2, '0')}-${order.date.month.toString().padLeft(2, '0')}-${order.date.year}',
                                      ),
                                    ),
                                    Expanded(flex: 2, child: Text(order.poNumber)),
                                    Expanded(flex: 3, child: Text(order.vendorName)),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE7EEF6),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            order.status,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF123456),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(order.referenceNumber.isEmpty ? '-' : order.referenceNumber),
                                    ),
                                    Expanded(flex: 2, child: Text('INR ${order.total.toStringAsFixed(2)}')),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deleteOrder(order),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete purchase order',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFEDEFF2)),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _filterTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF123456), width: 2),
        ),
      ),
    );
  }

  Widget _filterDateField(DateTime? value, ValueChanged<DateTime> onPicked) {
    return GestureDetector(
      onTap: () => _pickDate(value, onPicked),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFD9DEE5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5B5B5B)),
    );
  }
}