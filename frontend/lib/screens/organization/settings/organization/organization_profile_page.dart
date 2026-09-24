import 'package:flutter/material.dart';

class OrganizationProfilePage extends StatefulWidget {
  final VoidCallback onBack;

  const OrganizationProfilePage({
    super.key,
    required this.onBack,
  });

  @override
  State<OrganizationProfilePage> createState() =>
      _OrganizationProfilePageState();
}

class _OrganizationProfilePageState
    extends State<OrganizationProfilePage> {
  final TextEditingController organizationNameController =
      TextEditingController(text: 'test');

  final TextEditingController primaryEmailController =
      TextEditingController(
    text: 'sureshkaniyappan27@gmail.com',
  );

  final TextEditingController contactPersonController =
      TextEditingController(
    text: 'Suresh K',
  );

  final TextEditingController phoneController =
      TextEditingController(
    text: '08098482620',
  );

  final TextEditingController addressController =
      TextEditingController(
    text: '2/78, main street, putur -626111',
  );

  final TextEditingController cityController =
      TextEditingController();

  final TextEditingController stateController =
      TextEditingController();

  final TextEditingController countryController =
      TextEditingController();

  final TextEditingController postalCodeController =
      TextEditingController();

  final TextEditingController websiteController =
      TextEditingController();

  final TextEditingController gstNumberController =
      TextEditingController();

  final TextEditingController cinNumberController =
      TextEditingController();

  bool gstApplicable = true;

  String baseCurrency = 'INR - Indian Rupee';
  String fiscalYear = 'April - March';
  String organizationLanguage = 'English';
  String timeZone =
      '(GMT +05:30) India Standard Time (Asia/Kolkata)';
  String dateFormat = 'dd/MM/yyyy';

  String selectedLogoName = 'No file chosen';

  @override
  void dispose() {
    organizationNameController.dispose();
    primaryEmailController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    websiteController.dispose();
    gstNumberController.dispose();
    cinNumberController.dispose();

    super.dispose();
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Organization profile saved successfully',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          25,
          28,
          35,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1050,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ===================================================
                // HEADER
                // ===================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Organization Profile',
                        style: TextStyle(
                          color: Color(0xFF222A2E),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'Back to All Settings',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF4A60D8),
                        backgroundColor:
                            const Color(0xFFE9ECFF),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ===================================================
                // MAIN CARD
                // ===================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(
                        0xFFE3E7E9,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // ORGANIZATION DETAILS
                      // =============================================

                      const Text(
                        'Organization Details',
                        style: TextStyle(
                          color: Color(0xFF2A3034),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 22),

                      // =============================================
                      // LOGO
                      // =============================================

                      const Text(
                        'Organization Logo',
                        style: TextStyle(
                          color: Color(0xFF505A60),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Container(
                            width: 78,
                            height: 65,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFF8FAFB),
                              borderRadius:
                                  BorderRadius.circular(
                                5,
                              ),
                              border: Border.all(
                                color:
                                    const Color(
                                  0xFFDDE2E5,
                                ),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons
                                    .image_outlined,
                                size: 28,
                                color:
                                    Color(
                                  0xFF8E989E,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedLogoName =
                                      'organization_logo.png';
                                });
                              },
                              style: OutlinedButton
                                  .styleFrom(
                                alignment:
                                    Alignment.centerLeft,
                                foregroundColor:
                                    const Color(
                                  0xFF4D5960,
                                ),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                  vertical: 15,
                                ),
                                side:
                                    const BorderSide(
                                  color:
                                      Color(
                                    0xFFDDE2E5,
                                  ),
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    4,
                                  ),
                                ),
                              ),
                              child: Text(
                                selectedLogoName,
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // =============================================
                      // NAME + EMAIL
                      // =============================================

                      _responsiveTwoFields(
                        left: _buildField(
                          label:
                              'Organization Name',
                          controller:
                              organizationNameController,
                        ),
                        right: _buildField(
                          label:
                              'Primary Contact Email',
                          controller:
                              primaryEmailController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _responsiveTwoFields(
                        left: _buildField(
                          label:
                              'Contact Person',
                          controller:
                              contactPersonController,
                        ),
                        right: _buildField(
                          label:
                              'Phone Number',
                          controller:
                              phoneController,
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 22),

                      // =============================================
                      // ADDRESS DETAILS
                      // =============================================

                      const Text(
                        'Organization Address',
                        style: TextStyle(
                          color: Color(0xFF41494E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildField(
                        label: 'Address',
                        controller:
                            addressController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      _responsiveTwoFields(
                        left: _buildField(
                          label: 'City',
                          controller:
                              cityController,
                        ),
                        right: _buildField(
                          label: 'State',
                          controller:
                              stateController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _responsiveTwoFields(
                        left: _buildField(
                          label: 'Country',
                          controller:
                              countryController,
                        ),
                        right: _buildField(
                          label:
                              'Postal Code',
                          controller:
                              postalCodeController,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildField(
                        label: 'Website URL',
                        hintText:
                            'https://www.example.com',
                        controller:
                            websiteController,
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 22),

                      // =============================================
                      // TAX DETAILS
                      // =============================================

                      const Text(
                        'Tax & Registration Details',
                        style: TextStyle(
                          color: Color(0xFF41494E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'GST Applicable',
                        style: TextStyle(
                          color: Color(0xFF505A60),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue:
                                gstApplicable,
                            onChanged: (value) {
                              setState(() {
                                gstApplicable =
                                    value ?? true;
                              });
                            },
                          ),
                          const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Radio<bool>(
                            value: false,
                            groupValue:
                                gstApplicable,
                            onChanged: (value) {
                              setState(() {
                                gstApplicable =
                                    value ?? false;

                                if (!gstApplicable) {
                                  gstNumberController
                                      .clear();
                                }
                              });
                            },
                          ),

                          const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      if (gstApplicable) ...[
                        const SizedBox(height: 12),

                        _buildField(
                          label: 'GST Number',
                          controller:
                              gstNumberController,
                        ),
                      ],

                      const SizedBox(height: 20),

                      _buildField(
                        label: 'CIN Number',
                        controller:
                            cinNumberController,
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 22),

                      // =============================================
                      // PREFERENCES
                      // =============================================

                      const Text(
                        'Organization Preferences',
                        style: TextStyle(
                          color: Color(0xFF41494E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _responsiveTwoFields(
                        left: _buildDropdown(
                          label:
                              'Base Currency',
                          value:
                              baseCurrency,
                          items: const [
                            'INR - Indian Rupee',
                            'USD - US Dollar',
                            'EUR - Euro',
                          ],
                          onChanged:
                              (value) {
                            setState(() {
                              baseCurrency =
                                  value!;
                            });
                          },
                        ),
                        right: _buildDropdown(
                          label:
                              'Fiscal Year',
                          value:
                              fiscalYear,
                          items: const [
                            'April - March',
                            'January - December',
                          ],
                          onChanged:
                              (value) {
                            setState(() {
                              fiscalYear =
                                  value!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      _responsiveTwoFields(
                        left: _buildDropdown(
                          label:
                              'Organization Language',
                          value:
                              organizationLanguage,
                          items: const [
                            'English',
                          ],
                          onChanged:
                              (value) {
                            setState(() {
                              organizationLanguage =
                                  value!;
                            });
                          },
                        ),
                        right: _buildDropdown(
                          label:
                              'Date Format',
                          value:
                              dateFormat,
                          items: const [
                            'dd/MM/yyyy',
                            'MM/dd/yyyy',
                            'yyyy-MM-dd',
                          ],
                          onChanged:
                              (value) {
                            setState(() {
                              dateFormat =
                                  value!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildDropdown(
                        label: 'Time Zone',
                        value: timeZone,
                        items: const [
                          '(GMT +05:30) India Standard Time (Asia/Kolkata)',
                          '(GMT +00:00) UTC',
                        ],
                        onChanged: (value) {
                          setState(() {
                            timeZone =
                                value!;
                          });
                        },
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 18),

                      // =============================================
                      // ACTION BUTTONS
                      // =============================================

                      Row(
                        children: [
                          TextButton.icon(
                            onPressed:
                                widget.onBack,
                            icon: const Icon(
                              Icons
                                  .arrow_back_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Back to All Settings',
                            ),
                          ),

                          const Spacer(),

                          ElevatedButton.icon(
                            onPressed:
                                _saveChanges,
                            icon: const Icon(
                              Icons.save_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Save Changes',
                            ),
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFF27A844,
                              ),
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _responsiveTwoFields({
    required Widget left,
    required Widget right,
  }) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        if (constraints.maxWidth >=
            650) {
          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: left,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: right,
              ),
            ],
          );
        }

        return Column(
          children: [
            left,
            const SizedBox(height: 18),
            right,
          ],
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF505A60),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
          ),
          decoration:
              _inputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF505A60),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration:
              _inputDecoration(),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<
                        String>(
                  value: item,
                  child: Text(
                    item,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA5AA),
        fontSize: 11,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          4,
        ),
        borderSide:
            const BorderSide(
          color: Color(
            0xFFDDE2E5,
          ),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          4,
        ),
        borderSide:
            const BorderSide(
          color: Color(
            0xFF4C79E8,
          ),
        ),
      ),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          4,
        ),
      ),
    );
  }
}