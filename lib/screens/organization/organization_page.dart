import 'package:flutter/material.dart';

class OrganizationPage extends StatefulWidget {
  final VoidCallback onBack;

  const OrganizationPage({
    super.key,
    required this.onBack,
  });

  @override
  State<OrganizationPage> createState() =>
      _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  bool gstApplicable = true;

  String baseCurrency = 'INR - Indian Rupee';
  String fiscalYear = 'April - March';
  String organizationLanguage = 'English';

  String timeZone =
      '(GMT 5:30) India Standard Time (Asia/Kolkata)';

  String dateFormat = 'dd/MM/yyyy';

  final TextEditingController organizationNameController =
      TextEditingController(
    text: 'test',
  );

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

  final TextEditingController countryController =
      TextEditingController();

  final TextEditingController websiteController =
      TextEditingController();

  final TextEditingController gstController =
      TextEditingController();

  final TextEditingController cinController =
      TextEditingController();

  @override
  void dispose() {
    organizationNameController.dispose();
    primaryEmailController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    websiteController.dispose();
    gstController.dispose();
    cinController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F7FA),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          25,
          28,
          35,
        ),

        child: Container(
          width: double.infinity,

          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE2E6E9),
            ),
            borderRadius: BorderRadius.circular(5),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // MAIN CONTENT
              // =====================================================

              Padding(
                padding: const EdgeInsets.all(28),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // TITLE + ID
                    // =================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Organization Profile',
                            style: TextStyle(
                              color: Color(0xFF23292D),
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F3),
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ID: 0aec398a',
                            style: TextStyle(
                              color: Color(0xFF59666D),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // ORGANIZATION LOGO
                    // =================================================

                    const Text(
                      'Organization Logo',
                      style: _labelStyle,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color:
                                  const Color(0xFFE0E4E6),
                            ),
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: const Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 20,
                                color: Color(0xFF69835F),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Logo\nPreview',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      Color(0xFF666666),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Container(
                            height: 42,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    const Color(0xFFDDE1E3),
                              ),
                              borderRadius:
                                  BorderRadius.circular(3),
                            ),
                            child: Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    // File picker functionality
                                    // can be connected later.
                                  },
                                  style:
                                      OutlinedButton.styleFrom(
                                    foregroundColor:
                                        const Color(
                                      0xFF333333,
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                  ),
                                  child: const Text(
                                    'Choose File',
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                const Text(
                                  'No file chosen',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF666666),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // =================================================
                    // ORGANIZATION DETAILS
                    // =================================================

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 800) {
                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  label:
                                      'Organization Name',
                                  controller:
                                      organizationNameController,
                                ),
                              ),

                              const SizedBox(width: 25),

                              Expanded(
                                child: _buildField(
                                  label:
                                      'Primary Contact Email',
                                  controller:
                                      primaryEmailController,
                                ),
                              ),

                              const SizedBox(width: 25),

                              Expanded(
                                child: _buildField(
                                  label: 'Contact Person',
                                  controller:
                                      contactPersonController,
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _buildField(
                              label: 'Organization Name',
                              controller:
                                  organizationNameController,
                            ),

                            const SizedBox(height: 18),

                            _buildField(
                              label:
                                  'Primary Contact Email',
                              controller:
                                  primaryEmailController,
                            ),

                            const SizedBox(height: 18),

                            _buildField(
                              label: 'Contact Person',
                              controller:
                                  contactPersonController,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: 340,
                      child: _buildField(
                        label: 'Phone Number',
                        controller: phoneController,
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Divider(
                      color: Color(0xFFE5E8EA),
                    ),

                    const SizedBox(height: 27),

                    // =================================================
                    // ADDRESS
                    // =================================================

                    _buildField(
                      label: 'Organization Address',
                      controller: addressController,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 25),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 700) {
                          return Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  label: 'City',
                                  controller:
                                      cityController,
                                ),
                              ),

                              const SizedBox(width: 25),

                              Expanded(
                                child: _buildField(
                                  label: 'Country',
                                  controller:
                                      countryController,
                                ),
                              ),

                              const Spacer(flex: 2),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _buildField(
                              label: 'City',
                              controller: cityController,
                            ),

                            const SizedBox(height: 18),

                            _buildField(
                              label: 'Country',
                              controller:
                                  countryController,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildField(
                      label: 'Website URL',
                      controller: websiteController,
                      hintText:
                          'e.g., https://www.example.com',
                    ),

                    const SizedBox(height: 32),

                    const Divider(
                      color: Color(0xFFE5E8EA),
                    ),

                    const SizedBox(height: 27),

                    // =================================================
                    // GST
                    // =================================================

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 700) {
                          return Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: _buildGstApplicable(),
    ),

    if (gstApplicable) ...[
      const SizedBox(width: 25),

      Expanded(
        child: _buildField(
          label: 'GST Number',
          controller: gstController,
        ),
      ),
    ],

    const Spacer(),
  ]
                          );
    

                        }

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildGstApplicable(),

                            const SizedBox(height: 20),

                            _buildField(
                              label: 'GST Number',
                              controller: gstController,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildField(
                      label: 'CIN Number',
                      controller: cinController,
                    ),

                    const SizedBox(height: 32),

                    const Divider(
                      color: Color(0xFFE5E8EA),
                    ),

                    const SizedBox(height: 27),

                    // =================================================
                    // CURRENCY / YEAR / LANGUAGE
                    // =================================================

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 800) {
                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Base Currency',
                                  value: baseCurrency,
                                  items: const [
                                    'INR - Indian Rupee',
                                    'USD - US Dollar',
                                    'EUR - Euro',
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      baseCurrency = value;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 25),

                              Expanded(
                                child: _buildDropdown(
                                  label: 'Fiscal Year',
                                  value: fiscalYear,
                                  items: const [
                                    'April - March',
                                    'January - December',
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      fiscalYear = value;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 25),

                              Expanded(
                                child: _buildDropdown(
                                  label:
                                      'Organization Language',
                                  value:
                                      organizationLanguage,
                                  items: const [
                                    'English',
                                  ],
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      organizationLanguage =
                                          value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _buildDropdown(
                              label: 'Base Currency',
                              value: baseCurrency,
                              items: const [
                                'INR - Indian Rupee',
                                'USD - US Dollar',
                                'EUR - Euro',
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    baseCurrency = value;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 18),

                            _buildDropdown(
                              label: 'Fiscal Year',
                              value: fiscalYear,
                              items: const [
                                'April - March',
                                'January - December',
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    fiscalYear = value;
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 18),

                            _buildDropdown(
                              label:
                                  'Organization Language',
                              value:
                                  organizationLanguage,
                              items: const [
                                'English',
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    organizationLanguage =
                                        value;
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: 390,
                      child: _buildDropdown(
                        label: 'Time Zone',
                        value: timeZone,
                        items: const [
                          '(GMT 5:30) India Standard Time (Asia/Kolkata)',
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              timeZone = value;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildDropdown(
                      label: 'Date Format',
                      value: dateFormat,
                      items: const [
                        'dd/MM/yyyy',
                        'MM/dd/yyyy',
                        'yyyy-MM-dd',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            dateFormat = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // =====================================================
              // BOTTOM BUTTON BAR
              // =====================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),

                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE4E8EA),
                    ),
                  ),
                ),

                child: Row(
                  children: [
                    // BACK
                    ElevatedButton(
                      onPressed: widget.onBack,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF6F7D83),
                        foregroundColor: Colors.white,
                        elevation: 0,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),

                      child: const Text(
                        'Back to All Settings',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // SAVE
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Organization profile saved',
                            ),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF168FE5),
                        foregroundColor: Colors.white,
                        elevation: 0,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),

                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 11,
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

  // ================================================================
  // GST YES / NO
  // ================================================================

  Widget _buildGstApplicable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Is GST Applicable?',
          style: _labelStyle,
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: gstApplicable,
              activeColor: const Color(0xFF2196E4),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  gstApplicable = value;
                });
              },
            ),

            const Text(
              'Yes',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),

        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: gstApplicable,
              activeColor: const Color(0xFF2196E4),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  gstApplicable = value;
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
      ],
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _labelStyle,
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          maxLines: maxLines,

          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
          ),

          decoration: InputDecoration(
            hintText: hintText,

            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 11,
            ),

            isDense: true,
            filled: true,
            fillColor: Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(
                color: Color(0xFFDDE2E5),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(
                color: Color(0xFF2196E4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DROPDOWN
  // ================================================================

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _labelStyle,
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,

          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
          ),

          decoration: InputDecoration(
            isDense: true,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(
                color: Color(0xFFDDE2E5),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(
                color: Color(0xFF2196E4),
              ),
            ),
          ),

          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: Color(0xFF4D555A),
  fontSize: 11,
  fontWeight: FontWeight.w500,
);