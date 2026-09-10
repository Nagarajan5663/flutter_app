import 'package:flutter/material.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'delivery_challan_filter.dart';
import 'delivery_challan_model.dart';
import 'delivery_challan_repository.dart';
import 'widgets/add_delivery_challan_dialog.dart';

class DeliveryChallansPage extends StatefulWidget {
  const DeliveryChallansPage({super.key});

  @override
  State<DeliveryChallansPage> createState() => _DeliveryChallansPageState();
}

class _DeliveryChallansPageState extends State<DeliveryChallansPage> {
  final DeliveryChallanRepository _repository = InMemoryDeliveryChallanRepository();

  List<DeliveryChallanModel> _challans = [];
  bool _isLoading = true;

  final customerController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  @override
  void dispose() {
    customerController.dispose();
    super.dispose();
  }

  DeliveryChallanFilter get _currentFilter => DeliveryChallanFilter(
        customerName: customerController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadChallans() async {
    setState(() => _isLoading = true);
    final result = await _repository.getChallans(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _challans = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddChallan() async {
    final challan = await showDialog<DeliveryChallanModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddDeliveryChallanDialog(),
    );
    if (!mounted || challan == null) return;
    await _repository.addChallan(challan);
    await _loadChallans();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery challan created successfully')));
  }

  Future<void> _deleteChallan(DeliveryChallanModel challan) async {
    if (challan.id == null) return;
    await _repository.deleteChallan(challan.id!);
    await _loadChallans();
  }

  void _clearFilters() {
    customerController.clear();
    dateFrom = null;
    dateTo = null;
    _loadChallans();
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
                  child: Text('Delivery Challans',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF123456))),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddChallan,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Challan'),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer Name',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(width: 180, child: salesFilterTextField(customerController, 'Customer name...')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date From',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 150,
                        child: salesFilterDateField(
                          context: context,
                          value: dateFrom,
                          onPicked: (d) => setState(() => dateFrom = d),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date To',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 150,
                        child: salesFilterDateField(
                          context: context,
                          value: dateTo,
                          onPicked: (d) => setState(() => dateTo = d),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _loadChallans,
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
                  width: 1050,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1050,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: SalesHeaderText('DATE')),
                            Expanded(flex: 2, child: SalesHeaderText('CHALLAN #')),
                            Expanded(flex: 3, child: SalesHeaderText('CUSTOMER NAME')),
                            Expanded(flex: 2, child: SalesHeaderText('INVOICE #')),
                            Expanded(flex: 2, child: SalesHeaderText('DELIVERY DATE')),
                            Expanded(flex: 2, child: SalesHeaderText('STATUS')),
                            Expanded(flex: 2, child: SalesHeaderText('AMOUNT')),
                            Expanded(flex: 1, child: SalesHeaderText('ACTIONS')),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFD9DEE5)),

                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_challans.isEmpty)
                        Container(
                          width: 1050,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No delivery challans found. Click "+ New Challan" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._challans.map((challan) {
                          return Column(
                            children: [
                              Container(
                                width: 1050,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          '${challan.challanDate.day.toString().padLeft(2, '0')}-${challan.challanDate.month.toString().padLeft(2, '0')}-${challan.challanDate.year}'),
                                    ),
                                    Expanded(flex: 2, child: Text(challan.challanNumber)),
                                    Expanded(flex: 3, child: Text(challan.customerName)),
                                    Expanded(flex: 2, child: Text(challan.invoiceNumber ?? '-')),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        challan.deliveryDate == null
                                            ? '-'
                                            : '${challan.deliveryDate!.day.toString().padLeft(2, '0')}-${challan.deliveryDate!.month.toString().padLeft(2, '0')}-${challan.deliveryDate!.year}',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: salesStatusPill(
                                          text: challan.status, bg: const Color(0xFFE7EEF6), fg: const Color(0xFF123456)),
                                    ),
                                    Expanded(flex: 2, child: Text('INR ${challan.total.toStringAsFixed(2)}')),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deleteChallan(challan),
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete challan',
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
}