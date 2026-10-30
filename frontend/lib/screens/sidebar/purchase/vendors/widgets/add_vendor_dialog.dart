import 'package:flutter/material.dart';

import '../../shared/glass_modal_shell.dart';
import '../vendor_model.dart';

class AddVendorDialog extends StatefulWidget {
  const AddVendorDialog({super.key, this.initialVendor});

  final VendorModel? initialVendor;

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
  void initState() {
    super.initState();
    final vendor = widget.initialVendor;
    if (vendor == null) return;

    companyNameController.text = vendor.companyName;
    firstNameController.text = vendor.firstName;
    lastNameController.text = vendor.lastName;
    displayNameController.text = vendor.vendorName;
    emailController.text = vendor.email;
    phoneController.text = vendor.phone;
    websiteController.text = vendor.website;
    billingStreetController.text = vendor.billingStreet;
    billingCityController.text = vendor.city;
    billingStateController.text = vendor.state;
    billingZipController.text = vendor.billingZip;
    billingCountryController.text = vendor.country;
    shippingStreetController.text = vendor.shippingStreet;
    shippingCityController.text = vendor.shippingCity;
    shippingStateController.text = vendor.shippingState;
    shippingZipController.text = vendor.shippingZip;
    shippingCountryController.text = vendor.shippingCountry;
    vendorType = vendor.vendorType;
    salutation = vendor.salutation;
    gstApplicable = vendor.gstApplicable;
    shippingSameAsBilling = vendor.shippingSameAsBilling;
    status = vendor.status;
  }

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
      id: widget.initialVendor?.id,
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
    const labelTextColor = Color(0xFF1F2937);
    const bodyTextColor = Color(0xFF111827);
    const secondaryTextColor = Color(0xFF3D4147);
    const placeholderTextColor = Color(0xFF6B7280);
    const fieldFillColor = Colors.white;
    const fieldBorderColor = Color(0xFFD1D5DB);
    const focusedBorderColor = Color(0xFF93C5FD);
    const fieldErrorColor = Color(0xFFB91C1C);
    const menuBackgroundColor = Colors.white;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                title: widget.initialVendor == null
                    ? 'Add New Vendor'
                    : 'Edit Vendor',
                icon: Icons.storefront_outlined,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 25),

              // Vendor Type + Company Name
              _twoColumnRow(
                left: _fieldBlock(
                  label: 'Vendor Type',
                  labelColor: labelTextColor,
                  child: _buildDropdown(
                    value: vendorType,
                    items: const ['Business', 'Individual'],
                    onChanged: (v) => setState(() => vendorType = v),
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    backgroundColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    menuBackgroundColor: menuBackgroundColor,
                  ),
                ),
                right: _fieldBlock(
                  label: 'Company Name',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: companyNameController,
                    hint: 'e.g., ACME Corp',
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Salutation + First Name
              _twoColumnRow(
                left: _fieldBlock(
                  label: 'Salutation',
                  labelColor: labelTextColor,
                  child: _buildDropdown(
                    value: salutation,
                    items: const ['Mr.', 'Mrs.', 'Ms.', 'Dr.'],
                    onChanged: (v) => setState(() => salutation = v),
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    backgroundColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    menuBackgroundColor: menuBackgroundColor,
                  ),
                ),
                right: _fieldBlock(
                  label: 'First Name',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: firstNameController,
                    hint: 'e.g., John',
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Last Name + Display Name
              _twoColumnRow(
                left: _fieldBlock(
                  label: 'Last Name',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: lastNameController,
                    hint: 'e.g., Doe',
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
                right: _fieldBlock(
                  label: 'Display Name *',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: displayNameController,
                    hint: 'e.g., John Doe',
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
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
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: emailController,
                    hint: 'e.g., john.d@acmecorp.com',
                    keyboardType: TextInputType.emailAddress,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                ),
                right: _fieldBlock(
                  label: 'Phone',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: phoneController,
                    hint: 'e.g., +1-555-123-4567',
                    keyboardType: TextInputType.phone,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Website
              _fieldBlock(
                label: 'Website',
                labelColor: labelTextColor,
                child: _buildTextField(
                  controller: websiteController,
                  hint: 'e.g., https://www.acmecorp.com',
                  textColor: bodyTextColor,
                  placeholderColor: placeholderTextColor,
                  fillColor: fieldFillColor,
                  borderColor: fieldBorderColor,
                  focusedBorderColor: focusedBorderColor,
                  errorColor: fieldErrorColor,
                ),
              ),
              const SizedBox(height: 18),

              // GST Applicable
              _fieldBlock(
                label: 'GST Applicable',
                labelColor: labelTextColor,
                child: _buildDropdown(
                  value: gstApplicable,
                  items: const ['Yes', 'No'],
                  onChanged: (v) => setState(() => gstApplicable = v),
                  textColor: bodyTextColor,
                  placeholderColor: placeholderTextColor,
                  backgroundColor: fieldFillColor,
                  borderColor: fieldBorderColor,
                  focusedBorderColor: focusedBorderColor,
                  menuBackgroundColor: menuBackgroundColor,
                ),
              ),
              const SizedBox(height: 26),

              Text(
                'Billing Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: labelTextColor,
                ),
              ),
              const SizedBox(height: 14),

              _fieldBlock(
                label: 'Street',
                labelColor: labelTextColor,
                child: _buildTextField(
                  controller: billingStreetController,
                  textColor: bodyTextColor,
                  placeholderColor: placeholderTextColor,
                  fillColor: fieldFillColor,
                  borderColor: fieldBorderColor,
                  focusedBorderColor: focusedBorderColor,
                  errorColor: fieldErrorColor,
                ),
              ),
              const SizedBox(height: 18),

              _twoColumnRow(
                left: _fieldBlock(
                  label: 'City',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: billingCityController,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
                right: _fieldBlock(
                  label: 'State',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: billingStateController,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              _twoColumnRow(
                left: _fieldBlock(
                  label: 'Zip Code',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: billingZipController,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
                right: _fieldBlock(
                  label: 'Country',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: billingCountryController,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: labelTextColor,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Checkbox(
                    value: shippingSameAsBilling,
                    activeColor:
                        isDarkMode ? Colors.white : const Color(0xFF123456),
                    checkColor: isDarkMode ? const Color(0xFF111827) : null,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return isDarkMode
                            ? Colors.white
                            : const Color(0xFF123456);
                      }
                      return isDarkMode
                          ? const Color(0xFF1F2937)
                          : Colors.white;
                    }),
                    onChanged: (v) =>
                        setState(() => shippingSameAsBilling = v ?? false),
                  ),
                  Text(
                    'Shipping address is same as billing address',
                    style: TextStyle(fontSize: 15, color: secondaryTextColor),
                  ),
                ],
              ),

              if (!shippingSameAsBilling) ...[
                const SizedBox(height: 8),
                _fieldBlock(
                  label: 'Street',
                  labelColor: labelTextColor,
                  child: _buildTextField(
                    controller: shippingStreetController,
                    textColor: bodyTextColor,
                    placeholderColor: placeholderTextColor,
                    fillColor: fieldFillColor,
                    borderColor: fieldBorderColor,
                    focusedBorderColor: focusedBorderColor,
                    errorColor: fieldErrorColor,
                  ),
                ),
                const SizedBox(height: 18),
                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'City',
                    labelColor: labelTextColor,
                    child: _buildTextField(
                      controller: shippingCityController,
                      textColor: bodyTextColor,
                      placeholderColor: placeholderTextColor,
                      fillColor: fieldFillColor,
                      borderColor: fieldBorderColor,
                      focusedBorderColor: focusedBorderColor,
                      errorColor: fieldErrorColor,
                    ),
                  ),
                  right: _fieldBlock(
                    label: 'State',
                    labelColor: labelTextColor,
                    child: _buildTextField(
                      controller: shippingStateController,
                      textColor: bodyTextColor,
                      placeholderColor: placeholderTextColor,
                      fillColor: fieldFillColor,
                      borderColor: fieldBorderColor,
                      focusedBorderColor: focusedBorderColor,
                      errorColor: fieldErrorColor,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _twoColumnRow(
                  left: _fieldBlock(
                    label: 'Zip Code',
                    labelColor: labelTextColor,
                    child: _buildTextField(
                      controller: shippingZipController,
                      textColor: bodyTextColor,
                      placeholderColor: placeholderTextColor,
                      fillColor: fieldFillColor,
                      borderColor: fieldBorderColor,
                      focusedBorderColor: focusedBorderColor,
                      errorColor: fieldErrorColor,
                    ),
                  ),
                  right: _fieldBlock(
                    label: 'Country',
                    labelColor: labelTextColor,
                    child: _buildTextField(
                      controller: shippingCountryController,
                      textColor: bodyTextColor,
                      placeholderColor: placeholderTextColor,
                      fillColor: fieldFillColor,
                      borderColor: fieldBorderColor,
                      focusedBorderColor: focusedBorderColor,
                      errorColor: fieldErrorColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              _fieldBlock(
                label: 'Status',
                labelColor: labelTextColor,
                child: _buildDropdown(
                  value: status,
                  items: const ['Active', 'Inactive'],
                  onChanged: (v) => setState(() => status = v),
                  textColor: bodyTextColor,
                  placeholderColor: placeholderTextColor,
                  backgroundColor: fieldFillColor,
                  borderColor: fieldBorderColor,
                  focusedBorderColor: focusedBorderColor,
                  menuBackgroundColor: menuBackgroundColor,
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
                    label: widget.initialVendor == null
                        ? 'Save Vendor'
                        : 'Update Vendor',
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

  Widget _fieldBlock({
    required String label,
    required Color labelColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, labelColor),
        child,
      ],
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required Color textColor,
    required Color placeholderColor,
    required Color fillColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color errorColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: textColor),
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: placeholderColor),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        errorStyle: TextStyle(color: errorColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required Color textColor,
    required Color placeholderColor,
    required Color backgroundColor,
    required Color borderColor,
    required Color focusedBorderColor,
    required Color menuBackgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: menuBackgroundColor,
          iconEnabledColor: textColor,
          iconDisabledColor: placeholderColor,
          style: TextStyle(color: textColor, fontSize: 15),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(color: textColor),
                    ),
                  ))
              .toList(),
          selectedItemBuilder: (context) => items
              .map((item) => Text(
                    item,
                    style: TextStyle(color: textColor),
                  ))
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
