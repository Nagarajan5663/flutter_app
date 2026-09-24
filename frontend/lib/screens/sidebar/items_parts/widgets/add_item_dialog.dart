import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({
    super.key,
  });

  @override
  State<AddItemDialog> createState() =>
      _AddItemDialogState();
}

class _AddItemDialogState
    extends State<AddItemDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final GlobalKey _taxBoxKey =
      GlobalKey();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController skuController =
      TextEditingController();

  final TextEditingController
      purchasePriceController =
      TextEditingController();

  final TextEditingController
      salesPriceController =
      TextEditingController();

  final TextEditingController
      descriptionController =
      TextEditingController();

  // ============================================================
  // TAX OPTIONS
  // ============================================================

  final List<String> taxOptions = [
    'GST0 (Tax Group)',
    'GST12 (Tax Group)',
    'GST18 (Tax Group)',
    'GST5 (Tax Group)',
    'IGST0',
    'IGST12',
    'IGST18',
    'IGST5',
  ];

  String? selectedTax;

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    salesPriceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // OPEN TAX DROPDOWN
  // ============================================================

  Future<void> _openTaxDropdown() async {
    final RenderBox? renderBox =
        _taxBoxKey.currentContext
            ?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset position =
        renderBox.localToGlobal(
      Offset.zero,
    );

    final Size size = renderBox.size;

    final Size screenSize =
        MediaQuery.of(context).size;

    const double itemHeight = 46;

    final double menuHeight =
        ((taxOptions.length + 1) *
                itemHeight) +
            10;

    double menuTop =
        position.dy + size.height + 6;

    // If not enough space below,
    // open menu above.
    if (menuTop + menuHeight >
        screenSize.height - 15) {
      menuTop =
          position.dy - menuHeight - 6;
    }

    if (menuTop < 10) {
      menuTop = 10;
    }

    final double menuLeft =
        position.dx;

    final double menuRight =
        screenSize.width -
            (position.dx + size.width);

    final String? result =
        await showMenu<String>(
      context: context,

      color: const Color(0xFF223A52)
          .withValues(
        alpha: 0.97,
      ),

      elevation: 20,

      shadowColor: Colors.black
          .withValues(
        alpha: 0.35,
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white
              .withValues(
            alpha: 0.25,
          ),
        ),
      ),

      position: RelativeRect.fromLTRB(
        menuLeft,
        menuTop,
        menuRight,
        screenSize.height -
            menuTop -
            menuHeight,
      ),

      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: 350,
      ),

      items: [
        // ======================================================
        // NONE
        // ======================================================

        PopupMenuItem<String>(
          value: '__none__',
          height: itemHeight,
          child: Row(
            children: [
              Icon(
                Icons
                    .remove_circle_outline_rounded,
                size: 18,
                color: Colors.white
                    .withValues(
                  alpha: 0.60,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'Select Tax',
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.65,
                  ),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // TAX OPTIONS
        // ======================================================

        ...taxOptions.map(
          (String tax) {
            final bool selected =
                selectedTax == tax;

            return PopupMenuItem<String>(
              value: tax,
              height: itemHeight,
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .receipt_long_outlined,
                    size: 18,
                    color: selected
                        ? const Color(
                            0xFF75C7FF,
                          )
                        : Colors.white
                            .withValues(
                            alpha: 0.72,
                          ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      tax,
                      style: TextStyle(
                        color: selected
                            ? const Color(
                                0xFF9AD5FF,
                              )
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );

    if (!mounted ||
        result == null) {
      return;
    }

    setState(() {
      if (result == '__none__') {
        selectedTax = null;
      } else {
        selectedTax = result;
      }
    });
  }

  // ============================================================
  // ADD NEW TAX
  // ============================================================

  Future<void> _addNewTax() async {
    final String? newTax =
        await showDialog<String>(
      context: context,

      barrierDismissible: false,

      barrierColor:
          const Color(0xA30F1A24),

      builder: (
        BuildContext context,
      ) {
        return const AddTaxRateDialog();
      },
    );

    if (!mounted ||
        newTax == null ||
        newTax.trim().isEmpty) {
      return;
    }

    setState(() {
      if (!taxOptions.contains(newTax)) {
        taxOptions.add(newTax);
      }

      selectedTax = newTax;
    });
  }

  // ============================================================
  // SAVE ITEM
  // ============================================================

  void _saveItem() {
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
            Text(
              'Item added successfully.',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w600,
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
      maxWidth: 720,
      maxHeight: 860,
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
                title: 'Add New Item',
                subtitle:
                    'Create a new product for your inventory.',
                icon:
                    Icons.inventory_2_outlined,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // ITEM NAME
              // ==================================================

              const GlassLabel(
                'Item Name',
                required: true,
              ),

              GlassTextField(
                controller: nameController,
                hintText: 'Enter item name',
                prefixIcon:
                    Icons.inventory_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter item name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // SKU
              // ==================================================

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
                      value.trim().isEmpty) {
                    return 'Please enter SKU';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // PRICES
              // ==================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool twoColumns =
                      constraints.maxWidth >= 520;

                  final purchasePrice =
                      Column(
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

                  final salesPrice = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'Sales Price',
                        required: true,
                      ),

                      GlassTextField(
                        controller:
                            salesPriceController,
                        hintText: '0.00',
                        prefixIcon: Icons
                            .sell_outlined,
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
                            return 'Please enter sales price';
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
                          child:
                              purchasePrice,
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: salesPrice,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      purchasePrice,

                      const SizedBox(
                        height: 19,
                      ),

                      salesPrice,
                    ],
                  );
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // TAX LABEL
              // ==================================================

              Row(
                children: [
                  const Expanded(
                    child: GlassLabel(
                      'Tax',
                    ),
                  ),

                  GlassAddNewLink(
                    onTap: _addNewTax,
                  ),
                ],
              ),

              // ==================================================
              // TAX SELECT BOX
              // ==================================================

              GlassSelectBox(
                boxKey: _taxBoxKey,
                selectedLabel: selectedTax,
                placeholder: 'Select Tax',
                icon:
                    Icons.receipt_long_outlined,
                onTap: _openTaxDropdown,
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
                    'Enter item description',
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
                      label: 'Save Item',
                      icon:
                          Icons.save_outlined,
                      onPressed: _saveItem,
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

// ============================================================================
// ADD NEW TAX RATE DIALOG
// ============================================================================

class AddTaxRateDialog
    extends StatefulWidget {
  const AddTaxRateDialog({
    super.key,
  });

  @override
  State<AddTaxRateDialog> createState() =>
      _AddTaxRateDialogState();
}

class _AddTaxRateDialogState
    extends State<AddTaxRateDialog> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      taxNameController =
      TextEditingController();

  final TextEditingController
      rateController =
      TextEditingController();

  final TextEditingController
      cgstController =
      TextEditingController();

  final TextEditingController
      sgstController =
      TextEditingController();

  @override
  void dispose() {
    taxNameController.dispose();
    rateController.dispose();
    cgstController.dispose();
    sgstController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE TAX
  // ============================================================

  void _saveTax() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String taxName =
        taxNameController.text.trim();

    Navigator.of(context).pop(
      taxName,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return GlassModalShell(
      maxWidth: 590,
      maxHeight: 720,
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
                title: 'Add New Tax Rate',
                subtitle:
                    'Create a custom tax rate for this item.',
                icon:
                    Icons.percent_rounded,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 27),

              // ==================================================
              // TAX NAME
              // ==================================================

              const GlassLabel(
                'Tax Name',
                required: true,
              ),

              GlassTextField(
                controller:
                    taxNameController,
                hintText:
                    'Enter tax name',
                prefixIcon:
                    Icons.label_outline_rounded,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter tax name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // RATE
              // ==================================================

              const GlassLabel(
                'Rate (%)',
                required: true,
              ),

              GlassTextField(
                controller:
                    rateController,
                hintText: '0.00',
                prefixIcon:
                    Icons.percent_rounded,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter rate';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 19),

              // ==================================================
              // CGST + SGST
              // ==================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool twoColumns =
                      constraints.maxWidth >= 450;

                  final cgst = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'CGST Rate (%)',
                      ),

                      GlassTextField(
                        controller:
                            cgstController,
                        hintText: '0.00',
                        prefixIcon:
                            Icons.percent_rounded,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  );

                  final sgst = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const GlassLabel(
                        'SGST Rate (%)',
                      ),

                      GlassTextField(
                        controller:
                            sgstController,
                        hintText: '0.00',
                        prefixIcon:
                            Icons.percent_rounded,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  );

                  if (twoColumns) {
                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: cgst,
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: sgst,
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      cgst,

                      const SizedBox(
                        height: 19,
                      ),

                      sgst,
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // ==================================================
              // ACTIONS
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
                      label: 'Save Tax',
                      icon:
                          Icons.save_outlined,
                      onPressed: _saveTax,
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