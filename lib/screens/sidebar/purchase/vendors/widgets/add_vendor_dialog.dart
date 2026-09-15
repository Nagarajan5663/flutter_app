import 'package:flutter/material.dart';

import '../../shared/glass_modal_shell.dart';
import '../vendor_model.dart';

class AddVendorDialog extends StatefulWidget {
  const AddVendorDialog({super.key});

  @override
  State<AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<AddVendorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final companyNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();

  final billingStreetController = TextEditingController();
  final billingCityController = TextEditingController();
  final billingStateController = TextEditingController();
  final billingZipController = TextEditingController();
  final billingCountryController = TextEditingController();

  final shippingStreetController = TextEditingController();
  final shippingCityController = TextEditingController();
  final shippingStateController = TextEditingController();
  final shippingZipController = TextEditingController();
  final shippingCountryController = TextEditingController();

  String vendorType = 'Business';
  String salutation = 'Mr.';
  String gstApplicable = 'No';
  bool shippingSameAsBilling = false;
  String status = 'Active';
  bool _isSaving = false;

  @override
  void dispose() {
    companyNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    billingStreetController.dispose();
    billingCityController.dispose();
    billingStateController.dispose();
    billingZipController.dispose();
    billingCountryController.dispose();
    shippingStreetController.dispose();
    shippingCityController.dispose();
    shippingStateController.dispose();
    shippingZipController.dispose();
    shippingCountryController.dispose();
    super.dispose();
  }

  void _saveVendor() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final vendor = VendorModel(
      vendorType: vendorType,
      salutation: salutation,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      website: websiteController.text.trim(),
      gstApplicable: gstApplicable,
      billingStreet: billingStreetController.text.trim(),
      billingZip: billingZipController.text.trim(),
      shippingSameAsBilling: shippingSameAsBilling,
      shippingStreet: shippingSameAsBilling
          ? billingStreetController.text.trim()
          : shippingStreetController.text.trim(),
      shippingCity: shippingSameAsBilling
          ? billingCityController.text.trim()
          : shippingCityController.text.trim(),
      shippingState: shippingSameAsBilling
          ? billingStateController.text.trim()
          : shippingStateController.text.trim(),
      shippingZip: shippingSameAsBilling
          ? billingZipController.text.trim()
          : shippingZipController.text.trim(),
      shippingCountry: shippingSameAsBilling
          ? billingCountryController.text.trim()
          : shippingCountryController.text.trim(),
      vendorName: displayNameController.text.trim(),
      companyName: companyNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      city: billingCityController.text.trim(),
      state: billingStateController.text.trim(),
      country: billingCountryController.text.trim(),
      status: status,
    );

    Navigator.pop(context, vendor);
  }

  @override
  Widget build(BuildContext context) {
    return GlassModalShell(
      maxWidth: 700,
      maxHeight: 780,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassDialogHeader(
                title: 'Add New Vendor',
                icon: Icons.storefront_outlined,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 25),

                // Vendor Type + Company Name
                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'Vendor Type',
                    child: _buildDropdown(
                      value: vendorType,
                      items: const ['Business', 'Individual'],
                      onChanged: (v) => setState(() => vendorType = v),
                    ),
                  ),
                  right: _fieldBlock(
                    label: 'Company Name',
                    child: _buildTextField(
                      controller: companyNameController,
                      hint: 'e.g., ACME Corp',
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Salutation + First Name
                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'Salutation',
                    child: _buildDropdown(
                      value: salutation,
                      items: const ['Mr.', 'Mrs.', 'Ms.', 'Dr.'],
                      onChanged: (v) => setState(() => salutation = v),
                    ),
                  ),
                  right: _fieldBlock(
                    label: 'First Name',
                    child: _buildTextField(
                      controller: firstNameController,
                      hint: 'e.g., John',
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Last Name + Display Name
                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'Last Name',
                    child: _buildTextField(
                      controller: lastNameController,
                      hint: 'e.g., Doe',
                    ),
                  ),
                  right: _fieldBlock(
                    label: 'Display Name *',
                    child: _buildTextField(
                      controller: displayNameController,
                      hint: 'e.g., John Doe',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter display name'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Email + Phone
                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'Email',
                    child: _buildTextField(
                      controller: emailController,
                      hint: 'e.g., john.d@acmecorp.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),
                  right: _fieldBlock(
                    label: 'Phone',
                    child: _buildTextField(
                      controller: phoneController,
                      hint: 'e.g., +1-555-123-4567',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Website
                _fieldBlock(
                  label: 'Website',
                  child: _buildTextField(
                    controller: websiteController,
                    hint: 'e.g., https://www.acmecorp.com',
                  ),
                ),
                const SizedBox(height: 18),

                // GST Applicable
                _fieldBlock(
                  label: 'GST Applicable',
                  child: _buildDropdown(
                    value: gstApplicable,
                    items: const ['Yes', 'No'],
                    onChanged: (v) => setState(() => gstApplicable = v),
                  ),
                ),
                const SizedBox(height: 26),

                const Text(
                  'Billing Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123456),
                  ),
                ),
                const SizedBox(height: 14),

                _fieldBlock(
                  label: 'Street',
                  child: _buildTextField(controller: billingStreetController),
                ),
                const SizedBox(height: 18),

                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'City',
                    child: _buildTextField(controller: billingCityController),
                  ),
                  right: _fieldBlock(
                    label: 'State',
                    child: _buildTextField(controller: billingStateController),
                  ),
                ),
                const SizedBox(height: 18),

                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'Zip Code',
                    child: _buildTextField(controller: billingZipController),
                  ),
                  right: _fieldBlock(
                    label: 'Country',
                    child: _buildTextField(controller: billingCountryController),
                  ),
                ),
                const SizedBox(height: 26),

                const Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123456),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Checkbox(
                      value: shippingSameAsBilling,
                      activeColor: const Color(0xFF123456),
                      onChanged: (v) =>
                          setState(() => shippingSameAsBilling = v ?? false),
                    ),
                    const Text(
                      'Shipping address is same as billing address',
                      style: TextStyle(fontSize: 15, color: Color(0xFF3D4147)),
                    ),
                  ],
                ),

                if (!shippingSameAsBilling) ...[
                  const SizedBox(height: 8),
                  _fieldBlock(
                    label: 'Street',
                    child: _buildTextField(controller: shippingStreetController),
                  ),
                  const SizedBox(height: 18),
                  _twoColumnRow(
                    left: _fieldBlock(
                      label: 'City',
                      child: _buildTextField(controller: shippingCityController),
                    ),
                    right: _fieldBlock(
                      label: 'State',
                      child: _buildTextField(controller: shippingStateController),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _twoColumnRow(
                    left: _fieldBlock(
                      label: 'Zip Code',
                      child: _buildTextField(controller: shippingZipController),
                    ),
                    right: _fieldBlock(
                      label: 'Country',
                      child: _buildTextField(controller: shippingCountryController),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                _fieldBlock(
                  label: 'Status',
                  child: _buildDropdown(
                    value: status,
                    items: const ['Active', 'Inactive'],
                    onChanged: (v) => setState(() => status = v),
                  ),
                ),
                const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icons.close,
                    label: 'Cancel',
                    primary: false,
                  ),
                  const SizedBox(width: 16),
                  GlassButton(
                    onPressed: _isSaving ? null : _saveVendor,
                    icon: Icons.save,
                    label: 'Save Vendor',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _twoColumnRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 20),
        Expanded(child: right),
      ],
    );
  }

  Widget _fieldBlock({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        child,
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF3D4147),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: GlassSurface.fill(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: GlassSurface.border()),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: GlassSurface.border(focused: true), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: GlassSurface.fill(),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: GlassSurface.border()),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}