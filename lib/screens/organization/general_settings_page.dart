import 'package:flutter/material.dart';

class GeneralSettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const GeneralSettingsPage({
    super.key,
    required this.onBack,
  });

  @override
  State<GeneralSettingsPage> createState() =>
      _GeneralSettingsPageState();
}

class _GeneralSettingsPageState
    extends State<GeneralSettingsPage> {
  final TextEditingController bankNameController =
      TextEditingController();

  final TextEditingController accountNumberController =
      TextEditingController();

  final TextEditingController ifscController =
      TextEditingController();

  final TextEditingController branchNameController =
      TextEditingController();

  final TextEditingController upiController =
      TextEditingController();

  final TextEditingController whatsappController =
      TextEditingController();

  @override
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    branchNameController.dispose();
    upiController.dispose();
    whatsappController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF1F7F8),

      child: SingleChildScrollView(
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
                // PAGE HEADER
                // ===================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'General Settings',
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
                // PAYMENT DETAILS CARD
                // ===================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(8),

                    border: Border.all(
                      color: const Color(0xFFE3E7E9),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // PAYMENT DETAILS
                      // =============================================

                      const Text(
                        'Payment Details',
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

                      const SizedBox(height: 20),

                      const Text(
                        'These details will be displayed on your invoices to help you get paid.',
                        style: TextStyle(
                          color: Color(0xFF7B858B),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =============================================
                      // BANK ACCOUNT DETAILS
                      // =============================================

                      const Text(
                        'Bank Account Details',
                        style: TextStyle(
                          color: Color(0xFF41494E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // BANK NAME + ACCOUNT NUMBER
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >=
                              650) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'Bank Name',
                                    hintText:
                                        'e.g., HDFC Bank',
                                    controller:
                                        bankNameController,
                                  ),
                                ),

                                const SizedBox(width: 22),

                                Expanded(
                                  child: _buildField(
                                    label:
                                        'Account Number',
                                    hintText:
                                        'Your account number',
                                    controller:
                                        accountNumberController,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildField(
                                label: 'Bank Name',
                                hintText:
                                    'e.g., HDFC Bank',
                                controller:
                                    bankNameController,
                              ),

                              const SizedBox(height: 18),

                              _buildField(
                                label: 'Account Number',
                                hintText:
                                    'Your account number',
                                controller:
                                    accountNumberController,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      // IFSC + BRANCH
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >=
                              650) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'IFSC Code',
                                    hintText:
                                        "Your bank's IFSC code",
                                    controller:
                                        ifscController,
                                  ),
                                ),

                                const SizedBox(width: 22),

                                Expanded(
                                  child: _buildField(
                                    label: 'Branch Name',
                                    hintText:
                                        "Your bank's branch name",
                                    controller:
                                        branchNameController,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildField(
                                label: 'IFSC Code',
                                hintText:
                                    "Your bank's IFSC code",
                                controller:
                                    ifscController,
                              ),

                              const SizedBox(height: 18),

                              _buildField(
                                label: 'Branch Name',
                                hintText:
                                    "Your bank's branch name",
                                controller:
                                    branchNameController,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 22),

                      // =============================================
                      // UPI / MESSAGING DETAILS
                      // =============================================

                      const Text(
                        'UPI / Messaging Details',
                        style: TextStyle(
                          color: Color(0xFF41494E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >=
                              650) {
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildField(
                                    label: 'UPI ID (VPA)',
                                    hintText:
                                        'e.g., your-business@upi',
                                    controller:
                                        upiController,
                                  ),
                                ),

                                const SizedBox(width: 22),

                                Expanded(
                                  child: _buildField(
                                    label:
                                        'WhatsApp Number (For API)',
                                    hintText:
                                        'e.g., +919876543210',
                                    controller:
                                        whatsappController,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildField(
                                label: 'UPI ID (VPA)',
                                hintText:
                                    'e.g., your-business@upi',
                                controller:
                                    upiController,
                              ),

                              const SizedBox(height: 18),

                              _buildField(
                                label:
                                    'WhatsApp Number (For API)',
                                hintText:
                                    'e.g., +919876543210',
                                controller:
                                    whatsappController,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE6E9EB),
                      ),

                      const SizedBox(height: 18),

                      // =============================================
                      // SAVE BUTTON
                      // =============================================

                      Align(
                        alignment: Alignment.centerRight,

                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'General settings saved',
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.save_rounded,
                            size: 16,
                          ),

                          label: const Text(
                            'Save Changes',
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF27A844),

                            foregroundColor:
                                Colors.white,

                            elevation: 0,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 13,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                5,
                              ),
                            ),

                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
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
      ),
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

  Widget _buildField({
    required String label,
    required String hintText,
    required TextEditingController controller,
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

          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 12,
          ),

          decoration: InputDecoration(
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

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFDDE2E5),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFF4C79E8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}