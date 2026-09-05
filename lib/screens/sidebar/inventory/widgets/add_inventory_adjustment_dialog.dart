import 'package:flutter/material.dart';

class AddInventoryAdjustmentDialog extends StatefulWidget {
  const AddInventoryAdjustmentDialog({
    super.key,
  });

  @override
  State<AddInventoryAdjustmentDialog> createState() =>
      _AddInventoryAdjustmentDialogState();
}

class _AddInventoryAdjustmentDialogState
    extends State<AddInventoryAdjustmentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController reasonController =
      TextEditingController();

  String? selectedItem;
  String? selectedAdjustmentType;

  final List<String> itemOptions = [
    'Select an Item',
  ];

  final List<String> adjustmentTypeOptions = [
    'Increase Stock',
    'Decrease Stock',
  ];

  @override
  void dispose() {
    quantityController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final bool isMobile = screenSize.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 5 : 40,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: screenSize.height - 40,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 22 : 34,
              isMobile ? 28 : 34,
              isMobile ? 22 : 34,
              isMobile ? 24 : 34,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TITLE + CLOSE
                  // ==================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'New Inventory Adjustment',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF17395C),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // ITEM
                  // ==================================================

                  _buildLabel('Item'),

                  const SizedBox(height: 8),

                  _buildItemDropdown(),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ADJUSTMENT TYPE
                  // ==================================================

                  _buildLabel('Adjustment Type'),

                  const SizedBox(height: 8),

                  _buildAdjustmentTypeDropdown(),

                  const SizedBox(height: 20),

                  // ==================================================
                  // QUANTITY
                  // ==================================================

                  _buildLabel('Quantity'),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      hintText: 'Enter Quantity',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // REASON
                  // ==================================================

                  _buildLabel('Reason'),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: reasonController,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      hintText: 'Enter Reason',
                      verticalPadding: 14,
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ==================================================
                  // BUTTONS
                  // ==================================================

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // CLOSE
                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 17,
                          ),
                          label: const Text(
                            'Close',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF707981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // SUBMIT
                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _submitAdjustment,
                          icon: const Icon(
                            Icons.save,
                            size: 17,
                          ),
                          label: const Text(
                            'Submit Adjustment',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF12385F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ITEM DROPDOWN
  // ================================================================

  Widget _buildItemDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedItem,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.black,
      ),
      decoration: _inputDecoration(
        hintText: 'Select an Item',
      ),
      items: itemOptions.map(
        (String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF222222),
              ),
            ),
          );
        },
      ).toList(),
      onChanged: (String? value) {
        setState(() {
          selectedItem = value;
        });
      },
    );
  }

  // ================================================================
  // ADJUSTMENT TYPE DROPDOWN
  // ================================================================

  Widget _buildAdjustmentTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedAdjustmentType,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.black,
      ),
      decoration: _inputDecoration(
        hintText: 'Select Adjustment Type',
      ),
      items: adjustmentTypeOptions.map(
        (String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF222222),
              ),
            ),
          );
        },
      ).toList(),
      onChanged: (String? value) {
        setState(() {
          selectedAdjustmentType = value;
        });
      },
    );
  }

  // ================================================================
  // LABEL
  // ================================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF3D4147),
      ),
    );
  }

  // ================================================================
  // INPUT DECORATION
  // ================================================================

  InputDecoration _inputDecoration({
    required String hintText,
    double verticalPadding = 14,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFF222222),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: verticalPadding,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD8DEE5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFD8DEE5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFF17395C),
          width: 1.3,
        ),
      ),
    );
  }

  // ================================================================
  // SUBMIT
  // ================================================================

  void _submitAdjustment() {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Inventory adjustment submitted successfully.',
        ),
      ),
    );
  }
}