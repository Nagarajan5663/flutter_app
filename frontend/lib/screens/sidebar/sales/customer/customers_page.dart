import 'package:flutter/material.dart';

import '../widgets/sales_glass_widgets.dart';

import 'customer_filter.dart';
import 'customer_model.dart';
import 'customer_repository.dart';
import 'widgets/add_customer_dialog.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() =>
      _CustomersPageState();
}

class _CustomersPageState
    extends State<CustomersPage> {
  // ============================================================
  // REAL API REPOSITORY
  // ============================================================

  final CustomerRepository _repository =
      ApiCustomerRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<CustomerModel> _customers = [];

  bool _isLoading = true;

  String? _errorMessage;

  // ============================================================
  // FILTER CONTROLLERS
  // ============================================================

  final cityController =
      TextEditingController();

  final stateController =
      TextEditingController();

  final countryController =
      TextEditingController();

  String statusFilter = 'All';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadCustomers();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();

    super.dispose();
  }

  // ============================================================
  // CURRENT FILTER
  // ============================================================

  CustomerFilter get _currentFilter {
    return CustomerFilter(
      status: statusFilter,
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
    );
  }

  // ============================================================
  // LOAD CUSTOMERS FROM API
  // ============================================================

  Future<void> _loadCustomers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result =
          await _repository.getCustomers(
        filter: _currentFilter,
      );

      if (!mounted) return;

      setState(() {
        _customers = result;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _customers = [];
        _isLoading = false;
        _errorMessage =
            error.toString();
      });
    }
  }

  // ============================================================
  // ADD CUSTOMER
  // ============================================================

  Future<void> _openAddCustomer() async {
    final CustomerModel? customer =
        await showDialog<CustomerModel>(
      context: context,
      barrierColor:
          const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (_) =>
          const AddCustomerDialog(),
    );

    if (!mounted ||
        customer == null) {
      return;
    }

    try {
      await _repository.addCustomer(
        customer,
      );

      await _loadCustomers();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Customer added successfully',
          ),
          backgroundColor:
              Color(0xFF1E7B34),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add customer: $error',
          ),
          backgroundColor:
              const Color(0xFFAB2A2A),
        ),
      );
    }
  }

  // ============================================================
  // DELETE CUSTOMER
  // ============================================================

  Future<void> _deleteCustomer(
    CustomerModel customer,
  ) async {
    if (customer.id == null) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete "${customer.vendorName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFAB2A2A,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.deleteCustomer(
        customer.id!,
      );

      await _loadCustomers();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Customer deleted successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete customer: $error',
          ),
          backgroundColor:
              const Color(0xFFAB2A2A),
        ),
      );
    }
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void _clearFilters() {
    setState(() {
      statusFilter = 'All';

      cityController.clear();
      stateController.clear();
      countryController.clear();
    });

    _loadCustomers();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SalesGlassPageFrame(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // PAGE HEADER
            // ==================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'All Customers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF123456),
                    ),
                  ),
                ),

                // Refresh
                IconButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _loadCustomers,
                  tooltip:
                      'Refresh Customers',
                  icon: const Icon(
                    Icons.refresh,
                    color:
                        Color(0xFF123456),
                  ),
                ),

                const SizedBox(width: 8),

                // Add Customer
                ElevatedButton.icon(
                  onPressed:
                      _openAddCustomer,
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                  label: const Text(
                    'New Customer',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF123456,
                    ),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // FILTER SECTION
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    const Color(0x4FFFFFFF),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xC7FFFFFF,
                  ),
                ),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment:
                    WrapCrossAlignment.end,
                children: [
                  // Status
                  _filterField(
                    label: 'Status',
                    child: Container(
                      width: 160,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0x6EFFFFFF,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          11,
                        ),
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xC7FFFFFF,
                          ),
                        ),
                      ),
                      child:
                          DropdownButtonHideUnderline(
                        child:
                            DropdownButton<
                                String>(
                          value:
                              statusFilter,
                          style:
                              const TextStyle(
                            color:
                                Colors.black,
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child:
                                  Text('All'),
                            ),
                            DropdownMenuItem(
                              value:
                                  'Active',
                              child: Text(
                                'Active',
                              ),
                            ),
                            DropdownMenuItem(
                              value:
                                  'Inactive',
                              child: Text(
                                'Inactive',
                              ),
                            ),
                          ],
                          onChanged:
                              (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(() {
                              statusFilter =
                                  value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // City
                  _filterField(
                    label: 'City',
                    child: SizedBox(
                      width: 160,
                      child:
                          _filterTextField(
                        cityController,
                      ),
                    ),
                  ),

                  // State
                  _filterField(
                    label: 'State',
                    child: SizedBox(
                      width: 160,
                      child:
                          _filterTextField(
                        stateController,
                      ),
                    ),
                  ),

                  // Country
                  _filterField(
                    label: 'Country',
                    child: SizedBox(
                      width: 160,
                      child:
                          _filterTextField(
                        countryController,
                      ),
                    ),
                  ),

                  // Filter Button
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : _loadCustomers,
                    icon: const Icon(
                      Icons.filter_alt,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Filter',
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF2E7DD1,
                      ),
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 22,
                        vertical: 15,
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
                  ),

                  // Clear Button
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : _clearFilters,
                    icon: const Icon(
                      Icons.clear,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Clear',
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFE2E5E9,
                      ),
                      foregroundColor:
                          const Color(
                        0xFF3D4147,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 22,
                        vertical: 15,
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ERROR MESSAGE
            // ==================================================

            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFFECEC,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(10),
                  border: Border.all(
                    color:
                        const Color(
                      0xFFFFB8B8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color:
                          Color(
                        0xFFAB2A2A,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFFAB2A2A,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _loadCustomers,
                      child:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // CUSTOMER TABLE
            // ==================================================

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    const Color(
                  0x4FFFFFFF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xC7FFFFFF,
                  ),
                ),
              ),
              child:
                  SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: SizedBox(
                  width: 900,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // ================================
                      // TABLE HEADER
                      // ================================

                      Container(
                        width: 900,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration:
                            const BoxDecoration(
                          color:
                              Color(
                            0xFFF7F8FA,
                          ),
                          borderRadius:
                              BorderRadius
                                  .vertical(
                            top:
                                Radius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                        child:
                            const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child:
                                  _HeaderText(
                                'CUSTOMER NAME',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  _HeaderText(
                                'COMPANY NAME',
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  _HeaderText(
                                'EMAIL',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  _HeaderText(
                                'PHONE',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  _HeaderText(
                                'STATUS',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child:
                                  _HeaderText(
                                'ACTIONS',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 1,
                        color:
                            Color(
                          0xFFD9DEE5,
                        ),
                      ),

                      // ================================
                      // LOADING
                      // ================================

                      if (_isLoading)
                        const SizedBox(
                          width: 900,
                          height: 160,
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        )

                      // ================================
                      // EMPTY
                      // ================================

                      else if (_customers
                          .isEmpty)
                        Container(
                          width: 900,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 18,
                            vertical: 40,
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons
                                    .people_outline,
                                size: 42,
                                color:
                                    Color(
                                  0xFF8A949E,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const Text(
                                'No customers found',
                                style:
                                    TextStyle(
                                  fontSize:
                                      17,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color:
                                      Color(
                                    0xFF42474D,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                'Click "+ New Customer" to add your first customer.',
                                style:
                                    TextStyle(
                                  fontSize:
                                      14,
                                  color:
                                      Color(
                                    0xFF6F7881,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )

                      // ================================
                      // CUSTOMER ROWS
                      // ================================

                      else
                        ..._customers.map(
                          (customer) {
                            return Column(
                              children: [
                                Container(
                                  width:
                                      900,
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        18,
                                    vertical:
                                        16,
                                  ),
                                  child:
                                      Row(
                                    children: [
                                      // Customer Name
                                      Expanded(
                                        flex:
                                            2,
                                        child:
                                            Text(
                                          customer
                                              .vendorName,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(
                                              0xFF263238,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Company
                                      Expanded(
                                        flex:
                                            2,
                                        child:
                                            Text(
                                          customer
                                                  .companyName
                                                  .isEmpty
                                              ? '-'
                                              : customer
                                                  .companyName,
                                        ),
                                      ),

                                      // Email
                                      Expanded(
                                        flex:
                                            3,
                                        child:
                                            Text(
                                          customer
                                                  .email
                                                  .isEmpty
                                              ? '-'
                                              : customer
                                                  .email,
                                        ),
                                      ),

                                      // Phone
                                      Expanded(
                                        flex:
                                            2,
                                        child:
                                            Text(
                                          customer
                                                  .phone
                                                  .isEmpty
                                              ? '-'
                                              : customer
                                                  .phone,
                                        ),
                                      ),

                                      // Status
                                      Expanded(
                                        flex:
                                            2,
                                        child:
                                            Align(
                                          alignment:
                                              Alignment.centerLeft,
                                          child:
                                              Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal:
                                                  10,
                                              vertical:
                                                  4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: customer.status ==
                                                      'Active'
                                                  ? const Color(
                                                      0xFFE3F6E8,
                                                    )
                                                  : const Color(
                                                      0xFFF4E3E3,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                20,
                                              ),
                                            ),
                                            child:
                                                Text(
                                              customer
                                                  .status,
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    12,
                                                fontWeight:
                                                    FontWeight.w600,
                                                color: customer.status ==
                                                        'Active'
                                                    ? const Color(
                                                        0xFF1E7B34,
                                                      )
                                                    : const Color(
                                                        0xFFAB2A2A,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Delete
                                      Expanded(
                                        flex:
                                            1,
                                        child:
                                            IconButton(
                                          onPressed:
                                              () {
                                            _deleteCustomer(
                                              customer,
                                            );
                                          },
                                          icon:
                                              const Icon(
                                            Icons
                                                .delete_outline,
                                            color:
                                                Color(
                                              0xFFAB2A2A,
                                            ),
                                            size:
                                                20,
                                          ),
                                          tooltip:
                                              'Delete customer',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(
                                  height: 1,
                                  color:
                                      Color(
                                    0xFFEDEFF2,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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

  // ============================================================
  // FILTER FIELD
  // ============================================================

  Widget _filterField({
    required String label,
    required Widget child,
  }) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF5B5B5B),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // FILTER TEXT FIELD
  // ============================================================

  Widget _filterTextField(
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.black,
      ),
      onSubmitted: (_) {
        _loadCustomers();
      },
      decoration:
          InputDecoration(
        hintStyle:
            const TextStyle(
          color: Colors.black,
        ),
        filled: true,
        fillColor:
            const Color(
          0x6EFFFFFF,
        ),
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 12,
          vertical: 12,
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
            11,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(
              0xFFD9DEE5,
            ),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(
              0xFF123456,
            ),
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TABLE HEADER TEXT
// ============================================================

class _HeaderText
    extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,
      style:
          const TextStyle(
        fontSize: 13,
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