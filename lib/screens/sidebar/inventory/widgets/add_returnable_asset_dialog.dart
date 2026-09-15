import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class AddReturnableAssetDialog
    extends StatefulWidget {
  const AddReturnableAssetDialog({
    super.key,
  });

  @override
  State<AddReturnableAssetDialog>
      createState() =>
          _AddReturnableAssetDialogState();
}

class _AddReturnableAssetDialogState
    extends State<
        AddReturnableAssetDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController
      assetTagController =
      TextEditingController();

  final TextEditingController
      serialNumberController =
      TextEditingController();

  final TextEditingController
      initialLocationController =
      TextEditingController();

  // ============================================================
  // PRODUCT ITEM
  // ============================================================

  String? selectedProductItem;

  // EXACT EXISTING OPTION
  final List<String>
      productItemOptions = [
    'Select a Product Item',
  ];

  @override
  void dispose() {
    assetTagController.dispose();
    serialNumberController.dispose();
    initialLocationController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _saveAsset() {
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
                'Returnable asset saved successfully.',
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
      maxWidth: 700,
      maxHeight: 790,
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
                    'Add Returnable Asset',
                subtitle:
                    'Register a reusable asset and track its availability.',
                icon: Icons
                    .assignment_return_outlined,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // ITEM
              // ==================================================

              const InventoryGlassLabel(
                'Item (Type of Asset)',
              ),

              InventoryGlassDropdown(
                value:
                    selectedProductItem,
                options:
                    productItemOptions,
                hintText:
                    'Select a Product Item',
                prefixIcon:
                    Icons.inventory_outlined,
                onChanged: (value) {
                  setState(() {
                    selectedProductItem =
                        value;
                  });
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // TAG + SERIAL
              // ==================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool twoColumns =
                      constraints.maxWidth >=
                          520;

                  final Widget tagField =
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const InventoryGlassLabel(
                        'Asset Tag (Unique ID)',
                      ),

                      InventoryGlassTextField(
                        controller:
                            assetTagController,
                        hintText:
                            'Enter asset tag',
                        prefixIcon:
                            Icons.qr_code_rounded,
                      ),
                    ],
                  );

                  final Widget serialField =
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const InventoryGlassLabel(
                        'Serial Number (Optional)',
                      ),

                      InventoryGlassTextField(
                        controller:
                            serialNumberController,
                        hintText:
                            'Enter serial number',
                        prefixIcon:
                            Icons.tag_rounded,
                      ),
                    ],
                  );

                  if (twoColumns) {
                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: tagField,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: serialField,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      tagField,
                      const SizedBox(
                        height: 19,
                      ),
                      serialField,
                    ],
                  );
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // LOCATION
              // ==================================================

              const InventoryGlassLabel(
                'Initial Location',
              ),

              InventoryGlassTextField(
                controller:
                    initialLocationController,
                hintText:
                    'Enter initial location',
                prefixIcon:
                    Icons.location_on_outlined,
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
                      label: 'Save Asset',
                      icon:
                          Icons.save_outlined,
                      onPressed: _saveAsset,
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