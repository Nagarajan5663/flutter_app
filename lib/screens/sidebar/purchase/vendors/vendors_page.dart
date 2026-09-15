import 'package:flutter/material.dart';

import '../shared/glass_modal_shell.dart';
import 'vendor_filter.dart';
import 'vendor_model.dart';
import 'vendor_repository.dart';
import 'widgets/add_vendor_dialog.dart';

class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  // Only line that changes when a real backend exists:
  // final VendorRepository _repository = ApiVendorRepository('https://your-api.com');
  final VendorRepository _repository = InMemoryVendorRepository();

  List<VendorModel> _vendors = [];
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

  VendorFilter get _currentFilter => VendorFilter(
        status: statusFilter,
        city: cityController.text,
        state: stateController.text,
        country: countryController.text,
      );

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);

    final result = await _repository.getVendors(filter: _currentFilter);

    if (!mounted) return;
    setState(() {
      _vendors = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddVendor() async {
    final VendorModel? vendor = await showDialog<VendorModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddVendorDialog(),
    );

    if (!mounted || vendor == null) return;

    await _repository.addVendor(vendor);
    await _loadVendors();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vendor added successfully')),
    );
  }

  Future<void> _deleteVendor(VendorModel vendor) async {
    if (vendor.id == null) return;
    await _repository.deleteVendor(vendor.id!);
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
    return GlassPageBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'All Vendors',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                GlassButton(
                  onPressed: _openAddVendor,
                  icon: Icons.add,
                  label: 'New Vendor',
                ),
              ],
            ),
            const SizedBox(height: 20),

            GlassPanel(
              padding: const EdgeInsets.all(20),
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
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: const Color(0xFFD9DEE5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusFilter,
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
                  GlassButton(
                    onPressed: _loadVendors,
                    icon: Icons.filter_alt_outlined,
                    label: 'Filter',
                  ),
                  GlassButton(
                    onPressed: _clearFilters,
                    icon: Icons.refresh,
                    label: 'Clear',
                    primary: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GlassPanel(
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
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: _HeaderText('VENDOR NAME')),
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
                      else if (_vendors.isEmpty)
                        Container(
                          width: 950,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No vendors found. Click "+ New Vendor" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._vendors.map((vendor) {
                          return Column(
                            children: [
                              Container(
                                width: 950,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(vendor.vendorName)),
                                    Expanded(flex: 2, child: Text(vendor.companyName)),
                                    Expanded(flex: 3, child: Text(vendor.email)),
                                    Expanded(flex: 2, child: Text(vendor.phone)),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: vendor.status == 'Active'
                                                ? const Color(0xFFE3F6E8)
                                                : const Color(0xFFF4E3E3),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            vendor.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: vendor.status == 'Active'
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
                                        onPressed: () => _deleteVendor(vendor),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete vendor',
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
      decoration: InputDecoration(
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