import 'package:flutter/material.dart';

import '../widgets/sales_glass_widgets.dart';

import 'customer_filter.dart';
import 'customer_model.dart';
import 'customer_repository.dart';
import 'widgets/add_customer_dialog.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  // Only line that changes when a real backend exists:
  // final VendorRepository _repository = ApiVendorRepository('https://your-api.com');
  final CustomerRepository _repository = InMemoryCustomerRepository();

  List<CustomerModel> _customers = [];
  bool _isLoading = true;

  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  String statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  @override
  void dispose() {
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    super.dispose();
  }

  CustomerFilter get _currentFilter => CustomerFilter(
        status: statusFilter,
        city: cityController.text,
        state: stateController.text,
        country: countryController.text,
      );

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);

    final result = await _repository.getCustomers(filter: _currentFilter);

    if (!mounted) return;
    setState(() {
      _customers = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddCustomer() async {
    final CustomerModel? customer = await showDialog<CustomerModel>(
      context: context,
      barrierColor: const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (_) => const AddCustomerDialog(),
    );

    if (!mounted || customer == null) return;

    await _repository.addCustomer(customer);
    await _loadVendors();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer added successfully')),
    );
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    if (customer.id == null) return;
    await _repository.deleteCustomer(customer.id!);
    await _loadVendors();
  }

  void _clearFilters() {
    statusFilter = 'All';
    cityController.clear();
    stateController.clear();
    countryController.clear();
    _loadVendors();
  }

  @override
  Widget build(BuildContext context) {
    return SalesGlassPageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'All Customers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddCustomer,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Customer'),
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
                color: const Color(0x4FFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xC7FFFFFF)),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterField(
                    label: 'Status',
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x6EFFFFFF),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: const Color(0xC7FFFFFF)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusFilter,
                          style: const TextStyle(color: Colors.black),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All')),
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => statusFilter = value);
                          },
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'City',
                    child: SizedBox(width: 160, child: _filterTextField(cityController)),
                  ),
                  _filterField(
                    label: 'State',
                    child: SizedBox(width: 160, child: _filterTextField(stateController)),
                  ),
                  _filterField(
                    label: 'Country',
                    child: SizedBox(width: 160, child: _filterTextField(countryController)),
                  ),
                  ElevatedButton(
                    onPressed: _loadVendors,
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
                color: const Color(0x4FFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xC7FFFFFF)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 950,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 950,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: _HeaderText('CUSTOMER NAME')),
                            Expanded(flex: 2, child: _HeaderText('COMPANY NAME')),
                            Expanded(flex: 3, child: _HeaderText('EMAIL')),
                            Expanded(flex: 2, child: _HeaderText('PHONE')),
                            Expanded(flex: 2, child: _HeaderText('STATUS')),
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
                      else if (_customers.isEmpty)
                        Container(
                          width: 950,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No customers found. Click "+ New Customer" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._customers.map((customer) {
                          return Column(
                            children: [
                              Container(
                                width: 950,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(customer.vendorName)),
                                    Expanded(flex: 2, child: Text(customer.companyName)),
                                    Expanded(flex: 3, child: Text(customer.email)),
                                    Expanded(flex: 2, child: Text(customer.phone)),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: customer.status == 'Active'
                                                ? const Color(0xFFE3F6E8)
                                                : const Color(0xFFF4E3E3),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            customer.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: customer.status == 'Active'
                                                  ? const Color(0xFF1E7B34)
                                                  : const Color(0xFFAB2A2A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deleteCustomer(customer),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete customer',
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
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _filterTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0x6EFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF123456), width: 2),
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