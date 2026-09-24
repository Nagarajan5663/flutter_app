import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class AddPartDialog extends StatefulWidget {
  const AddPartDialog({
    super.key,
  });

  @override
  State<AddPartDialog> createState() =>
      _AddPartDialogState();
}

class _AddPartDialogState
    extends State<AddPartDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController skuController =
      TextEditingController();

  final TextEditingController
      purchasePriceController =
      TextEditingController();

  final TextEditingController
      descriptionController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE PART
  // ============================================================

  void _savePart() {
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
          borderRadius: BorderRadius.circular(12),
        ),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Part added successfully.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
    return GlassModalShell(
      maxWidth: 680,
      maxHeight: 760,
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

              GlassDialogHeader(
                title: 'Add New Part',
                subtitle:
                    'Create a new component for your inventory.',
                icon:
                    Icons.precision_manufacturing_outlined,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // PART NAME
              // ==================================================

              const GlassLabel(
                'Part Name',
                required: true,
              ),

              GlassTextField(
                controller: nameController,
                hintText: 'Enter part name',
                prefixIcon:
                    Icons.settings_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter part name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // RESPONSIVE SKU + PRICE
              // ==================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool twoColumns =
                      constraints.maxWidth >= 520;

                  final skuField = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'SKU',
                        required: true,
                      ),

                      GlassTextField(
                        controller: skuController,
                        hintText: 'Enter SKU',
                        prefixIcon:
                            Icons.qr_code_2_rounded,
                        validator: (value) {
                          if (value == null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Please enter SKU';
                          }

                          return null;
                        },
                      ),
                    ],
                  );

                  final priceField = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'Purchase Price',
                        required: true,
                      ),

                      GlassTextField(
                        controller:
                            purchasePriceController,
                        hintText: '0.00',
                        prefixIcon: Icons
                            .currency_rupee_rounded,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Please enter purchase price';
                          }

                          return null;
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
                          child: skuField,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: priceField,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      skuField,
                      const SizedBox(height: 19),
                      priceField,
                    ],
                  );
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              const GlassLabel(
                'Description',
              ),

              GlassTextField(
                controller:
                    descriptionController,
                hintText:
                    'Enter part description',
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
                    GlassButton(
                      label: 'Close',
                      icon:
                          Icons.close_rounded,
                      primary: false,
                      onPressed: () {
                        Navigator.of(context)
                            .pop();
                      },
                    ),

                    GlassButton(
                      label: 'Save Part',
                      icon:
                          Icons.save_outlined,
                      onPressed: _savePart,
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