import 'package:flutter/material.dart';

import '../item_model.dart';
import 'glass_widgets.dart';

class AddItemDialog extends StatefulWidget {
  final ItemModel? initialItem;

  const AddItemDialog({
    super.key,
    this.initialItem,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _taxBoxKey = GlobalKey();

  late final TextEditingController nameController;
  late final TextEditingController skuController;
  late final TextEditingController purchasePriceController;
  late final TextEditingController salesPriceController;
  late final TextEditingController descriptionController;

  final List<String> taxOptions = [
    'GST0 (Tax Group)',
    'GST5 (Tax Group)',
    'GST12 (Tax Group)',
    'GST18 (Tax Group)',
    'IGST0',
    'IGST5',
    'IGST12',
    'IGST18',
  ];

  String? selectedTax;

  bool get isEditing => widget.initialItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.initialItem;

    nameController = TextEditingController(
      text: item?.name ?? '',
    );

    skuController = TextEditingController(
      text: item?.sku ?? '',
    );

    purchasePriceController = TextEditingController(
      text: item?.purchasePrice ?? '',
    );

    salesPriceController = TextEditingController(
      text: item?.salesPrice ?? '',
    );

    descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    if (item != null && item.tax.trim().isNotEmpty) {
      selectedTax = item.tax;

      if (!taxOptions.contains(item.tax)) {
        taxOptions.add(item.tax);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    purchasePriceController.dispose();
    salesPriceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter price';
    }

    final number = double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  Future<void> _openTaxDropdown() async {
    final RenderBox? renderBox =
        _taxBoxKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset position = renderBox.localToGlobal(
      Offset.zero,
    );

    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double itemHeight = 46;

    final double estimatedHeight =
        ((taxOptions.length + 1) * itemHeight) + 10;

    final double menuHeight = estimatedHeight > 350
        ? 350
        : estimatedHeight;

    double menuTop = position.dy + size.height + 6;

    if (menuTop + menuHeight > screenSize.height - 15) {
      menuTop = position.dy - menuHeight - 6;
    }

    if (menuTop < 10) {
      menuTop = 10;
    }

    final String? result = await showMenu<String>(
      context: context,
      color: const Color(0xFF223A52).withValues(
        alpha: 0.98,
      ),
      elevation: 20,
      shadowColor: Colors.black.withValues(
        alpha: 0.35,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      position: RelativeRect.fromLTRB(
        position.dx,
        menuTop,
        screenSize.width - (position.dx + size.width),
        screenSize.height - menuTop - menuHeight,
      ),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: 350,
      ),
      items: [
        const PopupMenuItem<String>(
          value: '__none__',
          child: Row(
            children: [
              Icon(
                Icons.remove_circle_outline_rounded,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'No Tax',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        ...taxOptions.map(
          (tax) => PopupMenuItem<String>(
            value: tax,
            child: Row(
              children: [
                Icon(
                  selectedTax == tax
                      ? Icons.check_circle_rounded
                      : Icons.receipt_long_outlined,
                  size: 18,
                  color: selectedTax == tax
                      ? const Color(0xFF9AD5FF)
                      : Colors.white70,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tax,
                    style: TextStyle(
                      color: selectedTax == tax
                          ? const Color(0xFF9AD5FF)
                          : Colors.white,
                      fontWeight: selectedTax == tax
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      selectedTax =
          result == '__none__' ? null : result;
    });
  }

  Future<void> _addNewTax() async {
    final String? newTax = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AddTaxRateDialog();
      },
    );

    if (!mounted ||
        newTax == null ||
        newTax.trim().isEmpty) {
      return;
    }

    final value = newTax.trim();

    setState(() {
      if (!taxOptions.contains(value)) {
        taxOptions.add(value);
      }

      selectedTax = value;
    });
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ItemModel item = ItemModel(
      name: nameController.text.trim(),
      sku: skuController.text.trim(),
      purchasePrice:
          purchasePriceController.text.trim(),
      salesPrice: salesPriceController.text.trim(),
      tax: selectedTax ?? '',
      description:
          descriptionController.text.trim(),
    );

    Navigator.of(context).pop(item);
  }

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
              GlassDialogHeader(
                title: isEditing
                    ? 'Edit Item'
                    : 'Add New Item',
                subtitle: isEditing
                    ? 'Update your inventory item details.'
                    : 'Create a new product for your inventory.',
                icon: Icons.inventory_2_outlined,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 28),

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

              LayoutBuilder(
                builder: (context, constraints) {
                  final bool twoColumns =
                      constraints.maxWidth >= 520;

                  final purchase = Column(
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
                        validator: _validatePrice,
                      ),
                    ],
                  );

                  final sales = Column(
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
                        prefixIcon:
                            Icons.sell_outlined,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePrice,
                      ),
                    ],
                  );

                  if (twoColumns) {
                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(child: purchase),
                        const SizedBox(width: 16),
                        Expanded(child: sales),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      purchase,
                      const SizedBox(height: 19),
                      sales,
                    ],
                  );
                },
              ),

              const SizedBox(height: 19),

              Row(
                children: [
                  const Expanded(
                    child: GlassLabel('Tax'),
                  ),
                  GlassAddNewLink(
                    onTap: _addNewTax,
                  ),
                ],
              ),

              GlassSelectBox(
                boxKey: _taxBoxKey,
                selectedLabel: selectedTax,
                placeholder: 'Select Tax',
                icon:
                    Icons.receipt_long_outlined,
                onTap: _openTaxDropdown,
              ),

              const SizedBox(height: 19),

              const GlassLabel('Description'),

              GlassTextField(
                controller: descriptionController,
                hintText:
                    'Enter item description',
                prefixIcon:
                    Icons.notes_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    GlassButton(
                      label: 'Close',
                      icon: Icons.close_rounded,
                      primary: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    GlassButton(
                      label: isEditing
                          ? 'Update Item'
                          : 'Save Item',
                      icon: Icons.save_outlined,
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

class AddTaxRateDialog extends StatefulWidget {
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

  final TextEditingController taxNameController =
      TextEditingController();

  final TextEditingController rateController =
      TextEditingController();

  final TextEditingController cgstController =
      TextEditingController();

  final TextEditingController sgstController =
      TextEditingController();

  @override
  void dispose() {
    taxNameController.dispose();
    rateController.dispose();
    cgstController.dispose();
    sgstController.dispose();

    super.dispose();
  }

  String? _validateNumber(
    String? value, {
    bool required = false,
  }) {
    final input = value?.trim() ?? '';

    if (required && input.isEmpty) {
      return 'Please enter rate';
    }

    if (input.isEmpty) {
      return null;
    }

    final number = double.tryParse(input);

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0 || number > 100) {
      return 'Rate must be between 0 and 100';
    }

    return null;
  }

  void _saveTax() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      taxNameController.text.trim(),
    );
  }

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
              GlassDialogHeader(
                title: 'Add New Tax Rate',
                subtitle:
                    'Create a custom tax rate for this item.',
                icon: Icons.percent_rounded,
                onClose: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 27),

              const GlassLabel(
                'Tax Name',
                required: true,
              ),

              GlassTextField(
                controller: taxNameController,
                hintText: 'Enter tax name',
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

              const GlassLabel(
                'Rate (%)',
                required: true,
              ),

              GlassTextField(
                controller: rateController,
                hintText: '0.00',
                prefixIcon:
                    Icons.percent_rounded,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    _validateNumber(
                  value,
                  required: true,
                ),
              ),

              const SizedBox(height: 19),

              LayoutBuilder(
                builder: (context, constraints) {
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
                        controller: cgstController,
                        hintText: '0.00',
                        prefixIcon:
                            Icons.percent_rounded,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        validator:
                            _validateNumber,
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
                        controller: sgstController,
                        hintText: '0.00',
                        prefixIcon:
                            Icons.percent_rounded,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        validator:
                            _validateNumber,
                      ),
                    ],
                  );

                  if (twoColumns) {
                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cgst),
                        const SizedBox(width: 16),
                        Expanded(child: sgst),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      cgst,
                      const SizedBox(height: 19),
                      sgst,
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  children: [
                    GlassButton(
                      label: 'Close',
                      icon: Icons.close_rounded,
                      primary: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    GlassButton(
                      label: 'Save Tax',
                      icon: Icons.save_outlined,
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