import 'package:flutter/material.dart';

class ManageSubscriptionPage extends StatefulWidget {
  final VoidCallback onBack;

  const ManageSubscriptionPage({
    super.key,
    required this.onBack,
  });

  @override
  State<ManageSubscriptionPage> createState() =>
      _ManageSubscriptionPageState();
}

class _ManageSubscriptionPageState
    extends State<ManageSubscriptionPage> {
  String? _selectedPlan;
  String? _paymentMode;

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _referenceController =
      TextEditingController();

  final TextEditingController _dateController =
      TextEditingController(
    text: '11-09-2026',
  );

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _selectPlan(
    String planName,
    String amount,
  ) {
    setState(() {
      _selectedPlan = planName;
      _amountController.text = amount;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 9, 11),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selected == null) {
      return;
    }

    final String day =
        selected.day.toString().padLeft(2, '0');

    final String month =
        selected.month.toString().padLeft(2, '0');

    setState(() {
      _dateController.text =
          '$day-$month-${selected.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF3F8FA),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          40,
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 820,
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
                        'Subscription Billing Details',
                        style: TextStyle(
                          color: Color(0xFF252A2E),
                          fontSize: 29,
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
                            const Color(0xFF5361D5),

                        backgroundColor:
                            const Color(0xFFEDEEFF),

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 13,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(7),
                        ),

                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ===================================================
                // MAIN WHITE CARD
                // ===================================================

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(11),

                    border: Border.all(
                      color: const Color(0xFFE2E6E8),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // CURRENT PLAN STATUS
                      // =============================================

                      const Text(
                        'Current Plan Status',
                        style: TextStyle(
                          color: Color(0xFF272C30),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 17),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE4E7E9),
                      ),

                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFC9EEF1),
                          borderRadius:
                              BorderRadius.circular(7),
                        ),

                        child: const Row(
                          children: [
                            Icon(
                              Icons
                                  .calendar_month_rounded,
                              size: 18,
                              color: Color(0xFF08707A),
                            ),

                            SizedBox(width: 7),

                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color:
                                        Color(0xFF096C75),
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Your current subscription is valid until: ',
                                    ),
                                    TextSpan(
                                      text:
                                          'December 2, 2026.',
                                      style: TextStyle(
                                        color:
                                            Color(0xFF263238),
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =============================================
                      // CHOOSE PLAN
                      // =============================================

                      const Text(
                        'Choose Subscription Plan',
                        style: TextStyle(
                          color: Color(0xFF272C30),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 17),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE4E7E9),
                      ),

                      const SizedBox(height: 25),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >=
                              650) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PlanCard(
                                        title:
                                            '1 Month Subscription',
                                        price:
                                            '₹1,999.00',
                                        selected:
                                            _selectedPlan ==
                                                '1 Month',
                                        onTap: () {
                                          _selectPlan(
                                            '1 Month',
                                            '1999.00',
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 20,
                                    ),

                                    Expanded(
                                      child: _PlanCard(
                                        title:
                                            '3 Months Subscription',
                                        price:
                                            '₹4,999.00',
                                        saving:
                                            'Save ₹998.00',
                                        selected:
                                            _selectedPlan ==
                                                '3 Months',
                                        onTap: () {
                                          _selectPlan(
                                            '3 Months',
                                            '4999.00',
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 20,
                                    ),

                                    Expanded(
                                      child: _PlanCard(
                                        title:
                                            '6 Months Subscription',
                                        price:
                                            '₹8,999.00',
                                        saving:
                                            'Save ₹2,995.00',
                                        selected:
                                            _selectedPlan ==
                                                '6 Months',
                                        onTap: () {
                                          _selectPlan(
                                            '6 Months',
                                            '8999.00',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                Align(
                                  alignment:
                                      Alignment.centerLeft,
                                  child: SizedBox(
                                    width:
                                        (constraints.maxWidth -
                                                40) /
                                            3,
                                    child: _PlanCard(
                                      title:
                                          '1 Year Subscription',
                                      price:
                                          '₹15,999.00',
                                      saving:
                                          'Save ₹7,989.00',
                                      selected:
                                          _selectedPlan ==
                                              '1 Year',
                                      onTap: () {
                                        _selectPlan(
                                          '1 Year',
                                          '15999.00',
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _PlanCard(
                                title:
                                    '1 Month Subscription',
                                price: '₹1,999.00',
                                selected:
                                    _selectedPlan ==
                                        '1 Month',
                                onTap: () {
                                  _selectPlan(
                                    '1 Month',
                                    '1999.00',
                                  );
                                },
                              ),

                              const SizedBox(height: 15),

                              _PlanCard(
                                title:
                                    '3 Months Subscription',
                                price: '₹4,999.00',
                                saving:
                                    'Save ₹998.00',
                                selected:
                                    _selectedPlan ==
                                        '3 Months',
                                onTap: () {
                                  _selectPlan(
                                    '3 Months',
                                    '4999.00',
                                  );
                                },
                              ),

                              const SizedBox(height: 15),

                              _PlanCard(
                                title:
                                    '6 Months Subscription',
                                price: '₹8,999.00',
                                saving:
                                    'Save ₹2,995.00',
                                selected:
                                    _selectedPlan ==
                                        '6 Months',
                                onTap: () {
                                  _selectPlan(
                                    '6 Months',
                                    '8999.00',
                                  );
                                },
                              ),

                              const SizedBox(height: 15),

                              _PlanCard(
                                title:
                                    '1 Year Subscription',
                                price: '₹15,999.00',
                                saving:
                                    'Save ₹7,989.00',
                                selected:
                                    _selectedPlan ==
                                        '1 Year',
                                onTap: () {
                                  _selectPlan(
                                    '1 Year',
                                    '15999.00',
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // =============================================
                      // MANUAL PAYMENT INSTRUCTIONS
                      // =============================================

                      const Text(
                        'Manual Payment Instructions',
                        style: TextStyle(
                          color: Color(0xFF272C30),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 17),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE4E7E9),
                      ),

                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFC9EEF1),
                          borderRadius:
                              BorderRadius.circular(7),
                        ),

                        child: const Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_rounded,
                              size: 18,
                              color: Color(0xFF08707A),
                            ),

                            SizedBox(width: 7),

                            Expanded(
                              child: Text(
                                'Please make a bank transfer for the **selected plan\'s amount** to the account details or UPI ID below, then enter the transaction reference number.',
                                style: TextStyle(
                                  color:
                                      Color(0xFF176A73),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'ARK CODUX DIGITAL Payment Details',
                        style: TextStyle(
                          color: Color(0xFF31373B),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =============================================
                      // PAYMENT DETAILS
                      // =============================================

                      _paymentDetailsGrid(),

                      const SizedBox(height: 32),

                      // =============================================
                      // PAYMENT CONFIRMATION
                      // =============================================

                      const Text(
                        'Submit Payment Confirmation',
                        style: TextStyle(
                          color: Color(0xFF272C30),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 17),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE4E7E9),
                      ),

                      const SizedBox(height: 25),

                      // PAYMENT MODE
                      _requiredLabel(
                        'Payment Mode',
                      ),

                      const SizedBox(height: 8),

                      _paymentModeDropdown(),

                      const SizedBox(height: 20),

                      // AMOUNT PAID
                      _requiredLabel(
                        'Amount Paid (₹)',
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _amountController,
                        readOnly: true,

                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                        ),

                        decoration: _fieldDecoration(
                          hint:
                              'Select a plan to auto-fill',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // REFERENCE
                      _requiredLabel(
                        'Transaction Reference Number (UTR/IMPS Ref)',
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller:
                            _referenceController,

                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                        ),

                        decoration: _fieldDecoration(
                          hint:
                              'Enter the UTR or Bank Reference Number',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DATE
                      _requiredLabel(
                        'Date of Payment',
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _dateController,
                        readOnly: true,

                        onTap: _selectDate,

                        decoration: _fieldDecoration(
                          hint: '',
                          suffixIcon:
                              Icons.calendar_month_outlined,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Divider(
                        height: 1,
                        color: Color(0xFFE4E7E9),
                      ),

                      const SizedBox(height: 20),

                      // =============================================
                      // SUBMIT
                      // =============================================

                      Align(
                        alignment:
                            Alignment.centerRight,

                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(
                                    context)
                                .hideCurrentSnackBar();

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Payment reference submitted',
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.send_rounded,
                            size: 17,
                          ),

                          label: const Text(
                            'Submit Payment Reference',
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xFF2196F3,
                            ),

                            foregroundColor:
                                Colors.white,

                            elevation: 0,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 19,
                              vertical: 14,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                7,
                              ),
                            ),

                            textStyle:
                                const TextStyle(
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
  // PAYMENT DETAILS GRID
  // ================================================================

  Widget _paymentDetailsGrid() {
    final List<_PaymentInfo> items = [
      const _PaymentInfo(
        label: 'UPI ID',
        value: 'arkcodux@icici',
      ),
      const _PaymentInfo(
        label: 'Account Number',
        value: '253905002272',
      ),
      const _PaymentInfo(
        label: 'Account Holder Name',
        value: 'ARK CODUX DIGITAL',
      ),
      const _PaymentInfo(
        label: 'Bank Name',
        value: 'ICICI Bank',
      ),
      const _PaymentInfo(
        label: 'IFSC Code',
        value: 'ICIC0002539',
      ),
      const _PaymentInfo(
        label: 'MICR Code',
        value: '600229083',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool desktop =
            constraints.maxWidth >= 600;

        return Wrap(
          spacing: 20,
          runSpacing: 20,

          children: items.map((item) {
            final double width = desktop
                ? (constraints.maxWidth - 20) / 2
                : constraints.maxWidth;

            return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCF9),

                  border: Border.all(
                    color: const Color(0xFFE2E2DD),
                  ),

                  borderRadius:
                      BorderRadius.circular(7),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Color(0xFF62676A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      item.value,
                      style: const TextStyle(
                        color: Color(0xFF24282B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ================================================================
  // PAYMENT MODE DROPDOWN
  // ================================================================

  Widget _paymentModeDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: const Color(0xFFEAF6FF),
        highlightColor: const Color(0xFFDCEFFF),
      ),

      child: InputDecorator(
        decoration: _fieldDecoration(
          hint: '',
        ),

        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _paymentMode,
            isExpanded: true,
            isDense: true,

            hint: const Text(
              'Select how you paid',
              style: TextStyle(
                color: Color(0xFF444444),
                fontSize: 13,
              ),
            ),

            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF353535),
              size: 20,
            ),

            dropdownColor: Colors.white,

            borderRadius:
                BorderRadius.circular(7),

            style: const TextStyle(
              color: Color(0xFF252A2E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),

            // The video never opens this dropdown.
            // These two options are based on the
            // payment instructions shown in the page.
            items: const [
              DropdownMenuItem<String>(
                value: 'Bank Transfer',
                child: Text(
                  'Bank Transfer',
                ),
              ),
              DropdownMenuItem<String>(
                value: 'UPI',
                child: Text(
                  'UPI',
                ),
              ),
            ],

            onChanged: (value) {
              setState(() {
                _paymentMode = value;
              });
            },
          ),
        ),
      ),
    );
  }

  // ================================================================
  // REQUIRED LABEL
  // ================================================================

  Widget _requiredLabel(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              color: Color(0xFF555E63),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FIELD STYLE
  // ================================================================

  InputDecoration _fieldDecoration({
    required String hint,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFF9B9B9B),
        fontSize: 12,
      ),

      isDense: true,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),

      suffixIcon: suffixIcon == null
          ? null
          : Icon(
              suffixIcon,
              size: 18,
              color: const Color(0xFF555555),
            ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD9D9D9),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF555555),
          width: 1.2,
        ),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ==================================================================
// SUBSCRIPTION PLAN CARD
// ==================================================================

class _PlanCard extends StatefulWidget {
  final String title;
  final String price;
  final String? saving;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.saving,
  });

  @override
  State<_PlanCard> createState() =>
      _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active =
        _hovered || widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: GestureDetector(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 150),

          height: 126,

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(10),

            border: Border.all(
              color: active
                  ? const Color(0xFF2196F3)
                  : const Color(0xFFD7D7D7),

              width: active ? 1.7 : 1,
            ),

            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF2196F3)
                          .withValues(
                        alpha: 0.18,
                      ),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [],
          ),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                widget.title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.price,

                style: const TextStyle(
                  color: Color(0xFF242424),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (widget.saving != null) ...[
                const SizedBox(height: 6),

                Text(
                  '(${widget.saving})',

                  style: const TextStyle(
                    color: Color(0xFF2DBA43),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// PAYMENT INFO MODEL
// ==================================================================

class _PaymentInfo {
  final String label;
  final String value;

  const _PaymentInfo({
    required this.label,
    required this.value,
  });
}