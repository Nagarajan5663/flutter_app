import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class AddInventoryAdjustmentDialog
    extends StatefulWidget {
  const AddInventoryAdjustmentDialog({
    super.key,
  });

  @override
  State<AddInventoryAdjustmentDialog>
      createState() =>
          _AddInventoryAdjustmentDialogState();
}

class _AddInventoryAdjustmentDialogState
    extends State<
        AddInventoryAdjustmentDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      quantityController =
      TextEditingController();

  final TextEditingController
      reasonController =
      TextEditingController();

  String? selectedItem;
  String? selectedAdjustmentType;

  // EXACT EXISTING OPTIONS
  final List<String> itemOptions = [
    'Select an Item',
  ];

  // EXACT EXISTING OPTIONS
  final List<String>
      adjustmentTypeOptions = [
    'Increase Stock',
    'Decrease Stock',
  ];

  @override
  void dispose() {
    quantityController.dispose();
    reasonController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _submitAdjustment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger =
        ScaffoldMessenger.of(context);

    Navigator.of(context).pop();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            const Color(0xFF163F5E),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        content: const Row(
          children: [
            Icon(
              Icons
                  .check_circle_outline_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Inventory adjustment submitted successfully.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return InventoryGlassModalShell(
      maxWidth: 680,
      maxHeight: 780,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          30,
          28,
          30,
          28,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              InventoryDialogHeader(
                title:
                    'New Inventory Adjustment',
                subtitle:
                    'Increase or decrease the stock quantity of an inventory item.',
                icon: Icons.tune_rounded,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // ITEM + TYPE
              // ==================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool twoColumns =
                      constraints.maxWidth >=
                          520;

                  final Widget itemField =
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const InventoryGlassLabel(
                        'Item',
                      ),

                      InventoryGlassDropdown(
                        value: selectedItem,
                        options: itemOptions,
                        hintText:
                            'Select an Item',
                        prefixIcon: Icons
                            .inventory_2_outlined,
                        onChanged: (value) {
                          setState(() {
                            selectedItem =
                                value;
                          });
                        },
                      ),
                    ],
                  );

                  final Widget typeField =
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const InventoryGlassLabel(
                        'Adjustment Type',
                      ),

                      InventoryGlassDropdown(
                        value:
                            selectedAdjustmentType,
                        options:
                            adjustmentTypeOptions,
                        hintText:
                            'Select Adjustment Type',
                        prefixIcon:
                            Icons.swap_vert_rounded,
                        onChanged: (value) {
                          setState(() {
                            selectedAdjustmentType =
                                value;
                          });
                        },
                      ),
                    ],
                  );

                  if (twoColumns) {
                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: itemField,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: typeField,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      itemField,
                      const SizedBox(
                        height: 19,
                      ),
                      typeField,
                    ],
                  );
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // QUANTITY
              // ==================================================

              const InventoryGlassLabel(
                'Quantity',
              ),

              InventoryGlassTextField(
                controller:
                    quantityController,
                hintText:
                    'Enter Quantity',
                prefixIcon:
                    Icons.numbers_rounded,
                keyboardType:
                    TextInputType.number,
              ),

              const SizedBox(height: 19),

              // ==================================================
              // REASON
              // ==================================================

              const InventoryGlassLabel(
                'Reason',
              ),

              InventoryGlassTextField(
                controller:
                    reasonController,
                hintText:
                    'Enter Reason',
                prefixIcon:
                    Icons.notes_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // ==================================================
              // BUTTONS
              // ==================================================

              Align(
                alignment:
                    Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment:
                      WrapAlignment.end,
                  children: [
                    InventoryGlassButton(
                      label: 'Close',
                      icon:
                          Icons.close_rounded,
                      primary: false,
                      onPressed: () {
                        Navigator.of(context)
                            .pop();
                      },
                    ),

                    InventoryGlassButton(
                      label:
                          'Submit Adjustment',
                      icon:
                          Icons.save_outlined,
                      onPressed:
                          _submitAdjustment,
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
}